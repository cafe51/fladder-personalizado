import 'package:json_annotation/json_annotation.dart';

part 'tmdb_models.g.dart';

@JsonSerializable(createToJson: false)
class TmdbImagesResponse {
  final int? id;
  final List<TmdbImage>? backdrops;

  TmdbImagesResponse({
    this.id,
    this.backdrops,
  });

  factory TmdbImagesResponse.fromJson(Map<String, dynamic> json) => _$TmdbImagesResponseFromJson(json);
}

@JsonSerializable(createToJson: false)
class TmdbImage {
  @JsonKey(name: 'file_path')
  final String? filePath;
  @JsonKey(name: 'aspect_ratio')
  final double? aspectRatio;
  final int? height;
  final int? width;
  @JsonKey(name: 'vote_average')
  final double? voteAverage;
  @JsonKey(name: 'vote_count')
  final int? voteCount;

  TmdbImage({
    this.filePath,
    this.aspectRatio,
    this.height,
    this.width,
    this.voteAverage,
    this.voteCount,
  });

  factory TmdbImage.fromJson(Map<String, dynamic> json) => _$TmdbImageFromJson(json);
}
