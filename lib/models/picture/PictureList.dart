import 'package:json_annotation/json_annotation.dart';

part 'PictureList.g.dart';

@JsonSerializable()
class PictureList extends Object {
  @JsonKey(name: 'limit')
  int limit;

  @JsonKey(name: 'page')
  int page;

  @JsonKey(name: 'pages')
  int pages;

  @JsonKey(name: 'count')
  int count;

  @JsonKey(name: 'data')
  List<PictureData> data;

  PictureList(
    this.limit,
    this.page,
    this.pages,
    this.count,
    this.data,
  );

  factory PictureList.fromJson(Map<String, dynamic> srcJson) =>
      _$PictureListFromJson(srcJson);

  Map<String, dynamic> toJson() => _$PictureListToJson(this);
}

@JsonSerializable()
class PictureData extends Object {
  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'modifiableName')
  String modifiableName;

  @JsonKey(name: 'fileName')
  String fileName;

  @JsonKey(name: 'filePath')
  String filePath;

  @JsonKey(name: 'cover')
  String? cover;

  @JsonKey(name: 'fileSize')
  int fileSize;

  @JsonKey(name: 'pictureId')
  int? pictureId;

  @JsonKey(name: 'love')
  int? love;

  @JsonKey(name: 'display')
  int? display;

  @JsonKey(name: 'author')
  String? author;

  @JsonKey(name: 'width')
  int? width;

  @JsonKey(name: 'height')
  int? height;

  @JsonKey(name: 'mp')
  double? mp;

  @JsonKey(name: 'isFolder')
  int isFolder;

  @JsonKey(name: 'createTime')
  String? createTime;

  PictureData(this.id,this.isFolder,this.modifiableName,this.fileName,this.filePath,this.pictureId,this.love,this.display,this.width,this.height,this.mp,this.fileSize,this.createTime,);

  factory PictureData.fromJson(Map<String, dynamic> srcJson) =>
      _$PictureDataFromJson(srcJson);

  Map<String, dynamic> toJson() => _$PictureDataToJson(this);
}
