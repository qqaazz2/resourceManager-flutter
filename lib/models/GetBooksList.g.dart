// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'GetBooksList.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetBooksList _$GetBooksListFromJson(Map<String, dynamic> json) => GetBooksList(
      (json['data'] as List<dynamic>)
          .map((e) => Data.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$GetBooksListToJson(GetBooksList instance) =>
    <String, dynamic>{
      'data': instance.data,
      'count': instance.count,
    };

Data _$DataFromJson(Map<String, dynamic> json) => Data(
      (json['id'] as num).toInt(),
      json['name'] as String,
      (json['read_num'] as num).toInt(),
      (json['count'] as num).toInt(),
      json['add_time'] as String,
      json['author'] as String,
      json['illustrator'] as String,
      (json['status'] as num).toInt(),
      json['cover'] as String?,
      json['last_read'] as String?,
    );

Map<String, dynamic> _$DataToJson(Data instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'read_num': instance.readNum,
      'count': instance.count,
      'add_time': instance.addTime,
      'author': instance.author,
      'illustrator': instance.illustrator,
      'status': instance.status,
      'cover': instance.cover,
      'last_read': instance.lastRead,
    };
