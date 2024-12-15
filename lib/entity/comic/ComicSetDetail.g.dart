// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ComicSetDetail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ComicSetDetail _$ComicSetDetailFromJson(Map<String, dynamic> json) =>
    ComicSetDetail(
      (json['id'] as num).toInt(),
      json['name'] as String,
      json['author'] as String?,
      (json['status'] as num).toInt(),
      json['note'] as String?,
      json['press'] as String?,
      json['language'] as String?,
      json['lastReadTime'] as String?,
      (json['love'] as num).toInt(),
      (json['comicCount'] as num).toInt(),
      (json['readStatus'] as num).toInt(),
      json['coverPath'] as String?,
    );

Map<String, dynamic> _$ComicSetDetailToJson(ComicSetDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'author': instance.author,
      'status': instance.status,
      'note': instance.note,
      'press': instance.press,
      'language': instance.language,
      'lastReadTime': instance.lastReadTime,
      'love': instance.love,
      'comicCount': instance.comicCount,
      'readStatus': instance.readStatus,
      'coverPath': instance.coverPath,
    };
