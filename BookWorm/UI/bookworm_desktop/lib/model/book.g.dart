part of 'book.dart';
Book _$BookFromJson(Map<String, dynamic> json) => Book(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      bookState: json['bookState'] as String? ?? 'Accepted',
      publicationYear: (json['publicationYear'] as num?)?.toInt() ?? 2000,
      pageCount: (json['pageCount'] as num?)?.toInt() ?? 0,
      authorName: json['authorName'] as String? ?? '',
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$BookToJson(Book instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'bookState': instance.bookState,
      'publicationYear': instance.publicationYear,
      'pageCount': instance.pageCount,
      'authorName': instance.authorName,
      'genres': instance.genres,
    };