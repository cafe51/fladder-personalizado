import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:fladder/models/seerr/seerr_dashboard_model.dart';
import 'package:fladder/models/seerr/seerr_item_models.dart';
import 'package:fladder/providers/seerr_api_provider.dart';
import 'package:fladder/providers/seerr_service_provider.dart';
import 'package:fladder/providers/seerr_user_provider.dart';
import 'package:fladder/providers/user_provider.dart';
import 'package:fladder/providers/settings/client_settings_provider.dart';
import 'package:fladder/seerr/seerr_models.dart';

import 'package:fladder/seerr/seerr_models.dart';

part 'seerr_dashboard_provider.g.dart';

@riverpod
Future<Map<int, String>> seerrProviderLogos(SeerrProviderLogosRef ref) async {
  final api = ref.watch(seerrApiProvider);
  final userSettings = ref.watch(seerrUserProvider)?.settings;
  final watchRegion = userSettings?.streamingRegion ?? userSettings?.discoverRegion ?? 'US';
  final res = await api.getMovieWatchProviders(watchRegion: watchRegion);
  final map = <int, String>{};
  final providers = res.body ?? const <SeerrWatchProvider>[];
  for (final p in providers) {
    if (p.providerId != null && p.logoUrl != null) {
      map[p.providerId!] = p.logoUrl!;
    }
  }
  return map;
}

@riverpod
class SeerrDashboard extends _$SeerrDashboard {
  @override
  SeerrDashboardModel build() {
    return const SeerrDashboardModel();
  }

  SeerrService get api => ref.read(seerrApiProvider);

  Future<void> fetchDashboard() async {
    await ref.read(seerrUserProvider.notifier).refreshUser();
    final clientSettings = ref.read(clientSettingsProvider);
    final userSettings = ref.read(seerrUserProvider)?.settings;
    final watchRegion = userSettings?.streamingRegion ?? userSettings?.discoverRegion ?? 'US';

    await Future.wait([
      fetchRecentlyAdded(),
      fetchRecentRequests(),
      fetchTrending(),
      fetchPopularMovies(),
      fetchPopularSeries(),
      if (!clientSettings.seerrHideUnreleased) fetchExpectedMovies(),
      if (!clientSettings.seerrHideUnreleased) fetchExpectedSeries(),
      fetchProviderCarousels(watchRegion),
    ]);
  }

  Future<void> fetchRecentlyAdded() async {
    try {
      final user = ref.read(seerrUserProvider);
      if (user != null && !user.canViewRecent) {
        state = state.copyWith(recentlyAdded: const []);
        return;
      }

      final response = await api.media(
        filter: MediaFilter.allavailable,
        take: 10,
        sort: MediaSort.mediaadded,
        skip: 0,
      );

      if (!response.isSuccessful || response.body == null) {
        return;
      }

      final media = response.body?.results ?? const <SeerrMedia>[];
      final posters = await _postersFrom(media, _posterForMedia);

      state = state.copyWith(recentlyAdded: posters);
    } catch (_) {
      return;
    }
  }

  Future<void> fetchRecentRequests() async {
    try {
      final response = await api.listRequests(
        filter: RequestFilter.all,
        take: 10,
        skip: 0,
        sort: RequestSort.modified,
        sortDirection: SortDirection.desc,
      );

      if (!response.isSuccessful || response.body == null) {
        return;
      }

      final requests = response.body?.results ?? const [];
      final items = await _postersFrom(requests, _posterForRequest);

      state = state.copyWith(recentRequests: items);
    } catch (_) {
      return;
    }
  }

  Future<void> fetchTrending() async =>
      _safeSet(() => api.discoverTrending(), (items) => state.copyWith(trending: items));

  Future<void> fetchPopularMovies() async =>
      _safeSet(() => api.discoverPopularMovies(), (items) => state.copyWith(popularMovies: items));

  Future<void> fetchPopularSeries() async =>
      _safeSet(() => api.discoverPopularSeries(), (items) => state.copyWith(popularSeries: items));

  Future<void> fetchExpectedMovies() async =>
      _safeSet(() => api.discoverExpectedMovies(), (items) => state.copyWith(expectedMovies: items));

  Future<void> fetchProviderCarousels(String watchRegion) async {
    try {
      final futures = await Future.wait([
        api.discoverProviderMedia(watchProviders: '337', watchRegion: watchRegion),
        api.discoverProviderMedia(watchProviders: '9', watchRegion: watchRegion),
        api.discoverProviderMedia(watchProviders: '350', watchRegion: watchRegion),
        api.discoverProviderMedia(watchProviders: '2303', watchRegion: watchRegion),
        api.discoverProviderMedia(watchProviders: '1899', watchRegion: watchRegion),
      ]);

      final disneyData = futures[0];
      final primeData = futures[1];
      final appleData = futures[2];
      final paramountData = futures[3];
      final hboData = futures[4];

      final seenIds = <int>{};

      List<SeerrDashboardPosterModel> mixAndDeduplicate(
        List<SeerrDashboardPosterModel> movies, 
        List<SeerrDashboardPosterModel> series
      ) {
        final validMovies = movies.where((m) => !seenIds.contains(m.tmdbId)).toList();
        final validSeries = series.where((s) => !seenIds.contains(s.tmdbId)).toList();
        
        final mixed = <SeerrDashboardPosterModel>[];
        int mIdx = 0;
        int sIdx = 0;
        
        while ((mIdx < validMovies.length || sIdx < validSeries.length) && mixed.length < 40) {
          if (mIdx < validMovies.length) {
            final m = validMovies[mIdx++];
            mixed.add(m);
            seenIds.add(m.tmdbId);
          }
          if (sIdx < validSeries.length && mixed.length < 40) {
            final s = validSeries[sIdx++];
            mixed.add(s);
            seenIds.add(s.tmdbId);
          }
        }
        return mixed;
      }

      final disneyPlus = mixAndDeduplicate(disneyData.movies, disneyData.series);
      final primeVideo = mixAndDeduplicate(primeData.movies, primeData.series);
      final appleTv = mixAndDeduplicate(appleData.movies, appleData.series);
      final paramount = mixAndDeduplicate(paramountData.movies, paramountData.series);
      final hboMax = mixAndDeduplicate(hboData.movies, hboData.series);

      state = state.copyWith(
        disneyPlus: disneyPlus,
        primeVideo: primeVideo,
        appleTv: appleTv,
        paramount: paramount,
        hboMax: hboMax,
      );
    } catch (_) {
      return;
    }
  }

  Future<void> fetchExpectedSeries() async =>
      _safeSet(() => api.discoverExpectedSeries(), (items) => state.copyWith(expectedSeries: items));

  Future<SeerrDashboardPosterModel?> _posterForMedia(SeerrMedia media) async {
    final tmdbId = media.tmdbId;
    final tvdbId = media.tvdbId;
    if (tmdbId == null && tvdbId == null) return null;
    return api.fetchDashboardPosterFromIds(tmdbId: tmdbId, tvdbId: tvdbId);
  }

  Future<SeerrDashboardPosterModel?> _posterForRequest(SeerrMediaRequest request) async {
    final media = request.media;
    if (media == null) return null;
    final tmdbId = media.tmdbId;
    final tvdbId = media.tvdbId;
    if (tmdbId == null && tvdbId == null) return null;

    final poster = await api.fetchDashboardPosterFromIds(tmdbId: tmdbId, tvdbId: tvdbId);
    if (poster == null) return null;

    List<int>? requestedSeasons;
    if (poster.mediaInfo?.seasons != null) {
      requestedSeasons = poster.mediaInfo!.seasons!
          .where((season) => season.seasonNumber != null && request.seasons?.contains(season.seasonNumber) == true)
          .map((season) => season.seasonNumber!)
          .toList();
    }

    final requestedByUser = request.requestedBy;
    SeerrUserModel? processedUser;

    if (requestedByUser != null) {
      final avatar = requestedByUser.avatar;
      if (avatar != null && avatar.isNotEmpty) {
        final serverUrl = ref.read(userProvider)?.seerrCredentials?.serverUrl;
        final resolvedAvatar = resolveServerUrl(path: avatar, serverUrl: serverUrl);

        processedUser = resolvedAvatar != avatar ? requestedByUser.copyWith(avatar: resolvedAvatar) : requestedByUser;
      } else {
        processedUser = requestedByUser;
      }
    }

    return poster.copyWith(
      requestedBy: processedUser,
      requestedSeasons: requestedSeasons,
    );
  }

  Future<void> _safeSet(
    Future<List<SeerrDashboardPosterModel>> Function() load,
    SeerrDashboardModel Function(List<SeerrDashboardPosterModel>) apply,
  ) async {
    try {
      final items = await load();
      state = apply(items);
    } catch (_) {
      return;
    }
  }

  Future<List<SeerrDashboardPosterModel>> _postersFrom<T>(
    Iterable<T> items,
    Future<SeerrDashboardPosterModel?> Function(T item) mapper,
  ) async {
    final futures = items.map((item) => mapper(item)).toList();
    final results = await Future.wait(futures);
    return results.whereType<SeerrDashboardPosterModel>().toList(growable: false);
  }

  void clear() => state = const SeerrDashboardModel();
}
