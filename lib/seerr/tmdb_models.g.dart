// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tmdb_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TmdbImagesResponse _$TmdbImagesResponseFromJson(Map<String, dynamic> json) =>
    TmdbImagesResponse(
      id: (json['id'] as num?)?.toInt(),
      backdrops: (json['backdrops'] as List<dynamic>?)
          ?.map((e) => TmdbImage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

TmdbImage _$TmdbImageFromJson(Map<String, dynamic> json) => TmdbImage(
      filePath: json['file_path'] as String?,
      aspectRatio: (json['aspect_ratio'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toInt(),
      width: (json['width'] as num?)?.toInt(),
      voteAverage: (json['vote_average'] as num?)?.toDouble(),
      voteCount: (json['vote_count'] as num?)?.toInt(),
    );
