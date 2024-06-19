import 'package:json_annotation/json_annotation.dart';
part 'GetBooksList.g.dart';

@JsonSerializable()
class GetBooksList extends Object {

  @JsonKey(name: 'data')
  List<Data> data;

  @JsonKey(name: 'count')
  int count;

  GetBooksList(this.data,this.count,);

  factory GetBooksList.fromJson(Map<String, dynamic> srcJson) => _$GetBooksListFromJson(srcJson);

  Map<String, dynamic> toJson() => _$GetBooksListToJson(this);

}


@JsonSerializable()
class Data extends Object {

  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'read_num')
  int readNum;

  @JsonKey(name: 'count')
  int count;

  @JsonKey(name: 'add_time')
  String addTime;

  @JsonKey(name: 'author')
  String author;

  @JsonKey(name: 'illustrator')
  String illustrator;

  @JsonKey(name: 'status')
  int status;

  @JsonKey(name: 'cover')
  String? cover;

  @JsonKey(name: 'last_read')
  String? lastRead;

  Data(this.id,this.name,this.readNum,this.count,this.addTime,this.author,this.illustrator,this.status,this.cover,this.lastRead,);

  factory Data.fromJson(Map<String, dynamic> srcJson) => _$DataFromJson(srcJson);

  Map<String, dynamic> toJson() => _$DataToJson(this);

}
