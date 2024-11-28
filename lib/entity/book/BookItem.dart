import 'package:json_annotation/json_annotation.dart';

part 'BookItem.g.dart';


@JsonSerializable()
class BookItem extends Object {

  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'coverId')
  int? coverId;

  @JsonKey(name: 'filePath')
  String filePath;

  @JsonKey(name: 'isFolder')
  int isFolder;

  @JsonKey(name: 'progress')
  double progress;

  @JsonKey(name: 'name')
  String? name;

  @JsonKey(name: 'author')
  String? author;

  @JsonKey(name: 'profile')
  String? profile;

  @JsonKey(name: 'publishing')
  String? publishing;

  @JsonKey(name: 'status')
  Object? status;

  @JsonKey(name: 'coverPath')
  String? coverPath;

  @JsonKey(name: 'parentId')
  int? parentId;

  @JsonKey(name: 'readTagNum')
  int readTagNum;

  BookItem(this.id,this.filePath,this.isFolder,this.progress,this.name,this.author,this.profile,this.publishing,this.status,this.coverPath,this.parentId,this.readTagNum);

  factory BookItem.fromJson(Map<String, dynamic> srcJson) => _$BookItemFromJson(srcJson);

  Map<String, dynamic> toJson() => _$BookItemToJson(this);

}