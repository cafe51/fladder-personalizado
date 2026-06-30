import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fladder/providers/settings/client_settings_provider.dart';
import 'package:fladder/seerr/tmdb_models.dart';

final tmdbImagesProvider = FutureProvider.family<TmdbImagesResponse?, ({String type, int id})>((ref, arg) async {
  final apiKey = ref.watch(clientSettingsProvider.select((s) => s.tmdbApiKey));
  if (apiKey == null || apiKey.trim().isEmpty) return null;

  // type can be 'movie' or 'tv'
  final url = Uri.parse('https://api.themoviedb.org/3/${arg.type}/${arg.id}/images?api_key=${apiKey.trim()}&include_image_language=null');

  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return TmdbImagesResponse.fromJson(json);
    }
  } catch (e) {
    // Ignore errors for now, it's just an optional carousel
  }
  return null;
});
