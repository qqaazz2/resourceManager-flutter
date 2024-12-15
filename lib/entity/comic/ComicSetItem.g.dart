// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ComicSetItem.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ComicSetItem _$ComicSetItemFromJson(Map<String, dynamic> json) => ComicSetItem(
      (json['id'] as num).toInt(),
      json['name'] as String,
      (json['status'] as num).toInt(),
      json['coverPath'] as String?,
      (json['love'] as num).toInt(),
      (json['readStatus'] as num).toInt(),
      (json['filesId'] as num).toInt(),
    );

Map<String, dynamic> _$ComicSetItemToJson(ComicSetItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'filesId': instance.filesId,
      'name': instance.name,
      'status': instance.status,
      'coverPath': instance.coverPath,
      'love': instance.love,
      'readStatus': instance.readStatus,
    };
