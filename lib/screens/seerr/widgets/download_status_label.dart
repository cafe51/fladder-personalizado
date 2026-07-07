import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fladder/models/seerr/seerr_dashboard_model.dart';
import 'package:fladder/seerr/seerr_models.dart';
import 'package:fladder/util/localization_helper.dart';
import 'package:fladder/providers/transmission_provider.dart';

class DownloadStatusLabel extends ConsumerWidget {
  final SeerrDashboardPosterModel poster;
  final List<int>? filterSeasons;

  const DownloadStatusLabel({
    required this.poster,
    this.filterSeasons,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final standardDownloads = poster.mediaInfo?.downloadStatus ?? [];
    final fourKDownloads = poster.mediaInfo?.downloadStatus4k ?? [];
    final allDownloads = [...standardDownloads, ...fourKDownloads];

    final relevantDownloads = filterSeasons != null && filterSeasons!.isNotEmpty
        ? allDownloads.where((d) => filterSeasons!.contains(d.episode?.seasonNumber)).toList()
        : allDownloads;

    try {
        if (poster.title.toLowerCase().contains("gladi") || poster.title.toLowerCase().contains("glad")) {
            final debugStr = "Gladiador Debug:\n" +
              "mediaStatus: ${poster.mediaStatus}\n" +
              "relevantDownloads length: ${relevantDownloads.length}\n" +
              "downloads: ${relevantDownloads.map((d) => 'id: ${d.downloadId}, size: ${d.size}, title: ${d.title}').join(' | ')}\n";
            
            // ignore: avoid_print
            print("FLADDER_DEBUG: $debugStr");
        }
    } catch (_) {}

    num totalSize = 0;
    num totalRemaining = 0;

    for (final download in relevantDownloads) {
      if (download.size != null) {
        totalSize += download.size!;
        totalRemaining += download.sizeLeft ?? 0;
      }
    }

    final hasDownloads = relevantDownloads.isNotEmpty || totalSize > 0 || poster.mediaStatus == SeerrMediaStatus.processing;
    final percentage = (hasDownloads && totalSize > 0) ? ((totalSize - totalRemaining) / totalSize) * 100 : 0.0;

    String normalizeTitle(String? s) {
      if (s == null) return '';
      return s.toLowerCase().replaceAll(RegExp(r'[\.\-\_ \:]'), '');
    }

    if (hasDownloads) {
      String downloadLabel = context.localized.processing;
      double displayPercentage = percentage / 100;
      
      final transmissionTorrents = ref.watch(transmissionProvider);
      Map<String, dynamic>? activeTorrent;
      
      bool isMatch(Map<String, dynamic> t, String? downloadTitle) {
          final tName = normalizeTitle(t['name']);
          final dTitle = normalizeTitle(downloadTitle);
          final pTitle = normalizeTitle(poster.title);

          if (dTitle.isNotEmpty && tName.contains(dTitle)) return true;
          if (pTitle.isNotEmpty && tName.contains(pTitle)) return true;

          // Smart fallback: Year + Prefix match
          final year = poster.releaseYear;
          if (year != null && year.isNotEmpty && tName.contains(year)) {
              final prefixLen = pTitle.length > 4 ? 4 : pTitle.length;
              if (prefixLen >= 3 && tName.contains(pTitle.substring(0, prefixLen))) {
                  return true;
              }
          }
          return false;
      }

      // Match B: 100% TMDB/TVDB ID Matching via sidecar text files (User's Strategy)
      bool isMatchByIds(Map<String, dynamic> t) {
          final tmdbId = poster.tmdbId.toString(); // tmdbId is never null since it's int
          final tvdbId = poster.mediaInfo?.tvdbId?.toString();
          
          final apiTmdbId = t['tmdbId']?.toString();
          final apiTvdbId = t['tvdbId']?.toString();
          
          if (apiTmdbId != null && apiTmdbId == tmdbId) return true;
          if (apiTvdbId != null && tvdbId != null && apiTvdbId == tvdbId) return true;
          
          // Fallback if Radarr wrote it to the torrent name manually (which it usually doesn't, but just in case)
          final tName = t['name']?.toString() ?? '';
          final dDir = t['downloadDir']?.toString() ?? '';
          if (tName.contains('id=$tmdbId') || tName.contains('tmdb-$tmdbId') || tName.contains('tmdbid=$tmdbId') || tName.contains('[$tmdbId]')) return true;
          if (dDir.contains('id=$tmdbId') || dDir.contains('tmdb-$tmdbId') || dDir.contains('tmdbid=$tmdbId') || dDir.contains('[$tmdbId]')) return true;
          return false;
      }

      // Match C: Title Fallback (Aprimorado)
      bool isMatchByTitle(Map<String, dynamic> t) {
          final tNameRaw = t['name']?.toString().toLowerCase() ?? '';
          
          // Limpa pontuações tanto do nome do torrent quanto do título do pôster
          final tNameClean = tNameRaw.replaceAll(RegExp(r'[^a-z0-9]'), ' ');
          final pTitleClean = poster.title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), ' ');
          
          // Separa as palavras do título do Jellyseerr
          final words = pTitleClean.split(' ').where((w) => w.isNotEmpty).toList();
          if (words.isEmpty) return false;
          
          // Exige que TODAS as palavras do título estejam no nome do torrent
          bool allWordsMatch = true;
          for (final word in words) {
              if (!tNameClean.contains(word)) {
                  allWordsMatch = false;
                  break;
              }
          }
          
          if (!allWordsMatch) return false;
          
          // Se as palavras bateram, vamos checar o ano (se for filme)
          if (poster.type == SeerrMediaType.movie) {
              final releaseYear = poster.releaseYear;
              if (releaseYear != null && releaseYear.isNotEmpty && int.tryParse(releaseYear) != null) {
                  final yearInt = int.parse(releaseYear);
                  // Verifica o ano exato, o ano anterior ou o ano seguinte (tolerância comum de releases)
                  final hasYear = tNameClean.contains(yearInt.toString()) || 
                                  tNameClean.contains((yearInt - 1).toString()) || 
                                  tNameClean.contains((yearInt + 1).toString());
                  
                  // Se tem o ano na string do torrent, perfeito. 
                  // Se não tem nenhum ano na string do torrent, deixamos passar (alguns torrents não tem ano).
                  // Mas se tiver um ano totalmente diferente, a gente confia no match se o título for longo.
                  if (!hasYear && words.length < 3) {
                      // Títulos curtos sem o ano batendo são perigosos.
                      return false;
                  }
              }
          }
          
          return true;
      }

      for (final download in relevantDownloads) {
          // Match A: By Size or Hash Substring (Bulletproof integration with Radarr/Jellyseerr)
          for (final t in transmissionTorrents) {
              final tSize = t['totalSize'] as num?;
              if (tSize != null && tSize > 0 && download.size != null && download.size == tSize) {
                  activeTorrent = t as Map<String, dynamic>?;
                  break;
              }
              
              final hash = t['hashString']?.toString().toLowerCase();
              final dId = download.downloadId?.toLowerCase();
              if (hash != null && hash.isNotEmpty && dId != null && dId.isNotEmpty) {
                  if (dId.contains(hash) || hash.contains(dId)) {
                      activeTorrent = t as Map<String, dynamic>?;
                      break;
                  }
              }
          }
          
          // Match B: TMDB/TVDB ID Exact Match
          if (activeTorrent == null) {
              for (final t in transmissionTorrents) {
                  if (isMatchByIds(t)) {
                      activeTorrent = t as Map<String, dynamic>?;
                      break;
                  }
              }
          }
          
          // Match C: Title Fallback (only if TMDB match failed)
          if (activeTorrent == null) {
              for (final t in transmissionTorrents) {
                  if (isMatchByTitle(t)) {
                      activeTorrent = t as Map<String, dynamic>?;
                      break;
                  }
              }
          }
          
          if (activeTorrent != null) break;
      }

      // Seerr às vezes não tem o download ainda, mas está em processando.
      if (activeTorrent == null && poster.mediaStatus == SeerrMediaStatus.processing) {
          for (final t in transmissionTorrents) {
              if (isMatchByIds(t)) {
                  activeTorrent = t as Map<String, dynamic>?;
                  break;
              }
          }
          if (activeTorrent == null) {
              for (final t in transmissionTorrents) {
                  if (isMatchByTitle(t)) {
                      activeTorrent = t as Map<String, dynamic>?;
                      break;
                  }
              }
          }
      }

      if (activeTorrent != null) {
          final pct = activeTorrent['percentDone'] as num? ?? 0.0;
          displayPercentage = pct / 100;
          final speed = activeTorrent['rateDownload_mb'] as num? ?? 0;
          final eta = activeTorrent['eta_str'] ?? '';
          
          if (speed > 0) {
              downloadLabel = '${pct.toStringAsFixed(1)}% • ${speed.toStringAsFixed(1)} MB/s • $eta';
          } else {
              downloadLabel = '${pct.toStringAsFixed(1)}% • Parado';
          }
      } else {
          if (poster.type == SeerrMediaType.tvshow && relevantDownloads.isNotEmpty) {
            final firstDownload = relevantDownloads.first;
            final seasonNum = firstDownload.episode?.seasonNumber;
            final episodeNum = firstDownload.episode?.episodeNumber;

            if (seasonNum != null && episodeNum != null) {
              downloadLabel = '${context.localized.processing} S${seasonNum}E$episodeNum';
            }
          }
      }

      return Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                value: displayPercentage,
                strokeWidth: 2,
                backgroundColor: theme.colorScheme.onPrimaryContainer.withAlpha(50),
                valueColor: AlwaysStoppedAnimation(
                  theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            Flexible(
              child: Text(
                downloadLabel,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: poster.displayStatusColor,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        poster.displayStatusLabel(context),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: Colors.white,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }
}
