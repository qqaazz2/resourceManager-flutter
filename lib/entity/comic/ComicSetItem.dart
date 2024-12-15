import 'package:json_annotation/json_annotation.dart';

part 'ComicSetItem.g.dart';


@JsonSerializable()
class ComicSetItem extends Object {

  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'filesId')
  int filesId;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'status')
  int status;

  @JsonKey(name: 'coverPath')
  String? coverPath;

  @JsonKey(name: 'love')
  int love;

  @JsonKey(name: 'readStatus')
  int readStatus;

  ComicSetItem(this.id,this.name,this.status,this.coverPath,this.love,this.readStatus,this.filesId);

  factory ComicSetItem.fromJson(Map<String, dynamic> srcJson) => _$ComicSetItemFromJson(srcJson);

  Map<String, dynamic> toJson() => _$ComicSetItemToJson(this);
}