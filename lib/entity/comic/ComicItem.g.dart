// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ComicItem.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ComicItem _$ComicItemFromJson(Map<String, dynamic> json) => ComicItem(
      (json['id'] as num).toInt(),
      (json['filesId'] as num).toInt(),
      json['readTime'] as String?,
      (json['status'] as num).toInt(),
      json['name'] as String,
      (json['total'] as num).toInt(),
      (json['number'] as num?)?.toInt(),
      json['filePath'] as String,
      json['coverPath'] as String?,
    );

Map<String, dynamic> _$ComicItemToJson(ComicItem instance) => <String, dynamic>{
      'id': instance.id,
      'filesId': instance.filesId,
      'readTime': instance.readTime,
      'status': instance.status,
      'name': instance.name,
      'total': instance.total,
      'number': instance.number,
      'filePath': instance.filePath,
      'coverPath': instance.coverPath,
    };
