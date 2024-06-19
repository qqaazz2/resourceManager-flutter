// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'GetBooksDetailsList.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetBooksDetailsList _$GetBooksDetailsListFromJson(Map<String, dynamic> json) =>
    GetBooksDetailsList(
      (json['data'] as List<dynamic>)
          .map((e) => Details.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['count'] as int,
    );

Map<String, dynamic> _$GetBooksDetailsListToJson(
        GetBooksDetailsList instance) =>
    <String, dynamic>{
      'data': instance.data,
      'count': instance.count,
    };

Details _$DetailsFromJson(Map<String, dynamic> json) => Details(
      json['id'] as int,
      json['books_id'] as int,
      json['sort'] as int,
      json['status'] as int,
      json['add_time'] as String,
      json['cover'] as String,
      json['name'] as String,
      json['url'] as String,
      (json['progress'] as num).toDouble(),
    )..readTime = json['read_time'] as String?;

Map<String, dynamic> _$DetailsToJson(Details instance) => <String, dynamic>{
      'id': instance.id,
      'books_id': instance.booksId,
      'sort': instance.sort,
      'status': instance.status,
      'add_time': instance.addTime,
      'read_time': instance.readTime,
      'cover': instance.cover,
      'name': instance.name,
      'url': instance.url,
      'progress': instance.progress,
    };
