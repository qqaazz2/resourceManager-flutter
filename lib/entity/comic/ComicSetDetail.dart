import 'package:json_annotation/json_annotation.dart';

part 'ComicSetDetail.g.dart';


@JsonSerializable()
class ComicSetDetail extends Object {

  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'author')
  String? author;

  @JsonKey(name: 'status')
  int status;

  @JsonKey(name: 'note')
  String? note;

  @JsonKey(name: 'press')
  String? press;

  @JsonKey(name: 'language')
  String? language;

  @JsonKey(name: 'lastReadTime')
  String? lastReadTime;

  @JsonKey(name: 'love')
  int love;

  @JsonKey(name: 'comicCount')
  int comicCount;

  @JsonKey(name: 'readStatus')
  int readStatus;

  @JsonKey(name: 'coverPath')
  String? coverPath;

  ComicSetDetail(this.id,this.name,this.author,this.status,this.note,this.press,this.language,this.lastReadTime,this.love,this.comicCount,this.readStatus,this.coverPath);

  factory ComicSetDetail.fromJson(Map<String, dynamic> srcJson) => _$ComicSetDetailFromJson(srcJson);

  Map<String, dynamic> toJson() => _$ComicSetDetailToJson(this);

  ComicSetDetail copyWith({
    int? id,
    String? name,
    String? author,
    int? status,
    String? note,
    String? press,
    String? language,
    String? lastReadTime,
    int? love,
    int? comicCount,
    int? readStatus,
    String? coverPath,
  }) {
    return ComicSetDetail(
      id ?? this.id,
      name ?? this.name,
      author ?? this.author,
      status ?? this.status,
      note ?? this.note,
      press ?? this.press,
      language ?? this.language,
      lastReadTime ?? this.lastReadTime,
      love ?? this.love,
      comicCount ?? this.comicCount,
      readStatus ?? this.readStatus,
      coverPath ?? this.coverPath,
    );
  }
}