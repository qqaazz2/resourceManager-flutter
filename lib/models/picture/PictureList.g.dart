// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'PictureList.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PictureList _$PictureListFromJson(Map<String, dynamic> json) => PictureList(
      (json['limit'] as num).toInt(),
      (json['page'] as num).toInt(),
      (json['pages'] as num).toInt(),
      (json['count'] as num).toInt(),
      (json['data'] as List<dynamic>)
          .map((e) => PictureData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PictureListToJson(PictureList instance) =>
    <String, dynamic>{
      'limit': instance.limit,
      'page': instance.page,
      'pages': instance.pages,
      'count': instance.count,
      'data': instance.data,
    };

PictureData _$PictureDataFromJson(Map<String, dynamic> json) => PictureData(
      (json['id'] as num).toInt(),
      (json['isFolder'] as num).toInt(),
      json['modifiableName'] as String,
      json['fileName'] as String,
      json['filePath'] as String,
      (json['pictureId'] as num?)?.toInt(),
      (json['love'] as num?)?.toInt(),
      (json['display'] as num?)?.toInt(),
      (json['width'] as num?)?.toInt(),
      (json['height'] as num?)?.toInt(),
      (json['mp'] as num?)?.toDouble(),
      (json['fileSize'] as num).toInt(),
      json['createTime'] as String?,
    )
      ..cover = json['cover'] as String?
      ..author = json['author'] as String?;

Map<String, dynamic> _$PictureDataToJson(PictureData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'modifiableName': instance.modifiableName,
      'fileName': instance.fileName,
      'filePath': instance.filePath,
      'cover': instance.cover,
      'fileSize': instance.fileSize,
      'pictureId': instance.pictureId,
      'love': instance.love,
      'display': instance.display,
      'author': instance.author,
      'width': instance.width,
      'height': instance.height,
      'mp': instance.mp,
      'isFolder': instance.isFolder,
      'createTime': instance.createTime,
    };
