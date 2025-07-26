import 'package:json_annotation/json_annotation.dart';

part 'author.g.dart';

@JsonSerializable()
class Author {
  final int id;
  final String name;
  final String biography;
  final DateTime dateOfBirth;
  final DateTime? dateOfDeath;
  final int countryId;
  final String countryName;
  final String? photoUrl;
  final String authorState;

  Author({
    this.id = 0,
    this.name = '',
    this.biography = '',
    required this.dateOfBirth,
    this.dateOfDeath,
    this.countryId = 0,
    this.countryName = '',
    this.photoUrl,
    this.authorState='',
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    print('[Author.fromJson] photoUrl: \\${json['photoUrl']}');
    return _$AuthorFromJson(json);
  }
  Map<String, dynamic> toJson() => _$AuthorToJson(this);
} 