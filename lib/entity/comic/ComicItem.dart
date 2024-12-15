import 'package:json_annotation/json_annotation.dart';

part 'ComicItem.g.dart';


@JsonSerializable()
class ComicItem extends Object {

  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'filesId')
  int filesId;

  @JsonKey(name: 'readTime')
  String? readTime;

  @JsonKey(name: 'status')
  int status;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'total')
  int total;

  @JsonKey(name: 'number')
  int? number;

  @JsonKey(name: 'filePath')
  String filePath;

  @JsonKey(name: 'coverPath')
  String? coverPath;

  ComicItem(this.id,this.filesId,this.readTime,this.status,this.name,this.total,this.number,this.filePath,this.coverPath);

  factory ComicItem.fromJson(Map<String, dynamic> srcJson) => _$ComicItemFromJson(srcJson);

  Map<String, dynamic> toJson() => _$ComicItemToJson(this);
}