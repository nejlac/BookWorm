import 'package:json_annotation/json_annotation.dart';

part 'genre.g.dart';
@JsonSerializable()
class Genre {
  final int id;
  final String name;
  final String? description;

  Genre({
    this.id = 0,
    this.name = '',
    this.description,
  });
  factory Genre.fromJson(Map<String, dynamic> json) => _$GenreFromJson(json);
}