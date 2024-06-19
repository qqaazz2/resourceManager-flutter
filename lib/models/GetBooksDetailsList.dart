import 'package:json_annotation/json_annotation.dart';

part 'GetBooksDetailsList.g.dart';

@JsonSerializable()
class GetBooksDetailsList extends Object {
  @JsonKey(name: 'data')
  List<Details> data;

  @JsonKey(name: 'count')
  int count;

  GetBooksDetailsList(
    this.data,
    this.count,
  );

  factory GetBooksDetailsList.fromJson(Map<String, dynamic> srcJson) =>
      _$GetBooksDetailsListFromJson(srcJson);

  Map<String, dynamic> toJson() => _$GetBooksDetailsListToJson(this);
}

@JsonSerializable()
class Details extends Object {
  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'books_id')
  int booksId;

  @JsonKey(name: 'sort')
  int sort;

  @JsonKey(name: 'status')
  int status;

  @JsonKey(name: 'add_time')
  String addTime;

  @JsonKey(name: 'read_time')
  String? readTime;

  @JsonKey(name: 'cover')
  String cover;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'url')
  String url;

  @JsonKey(name: "progress")
  double progress;

  Details(this.id, this.booksId, this.sort, this.status, this.addTime,
      this.cover, this.name, this.url, this.progress);

  factory Details.fromJson(Map<String, dynamic> srcJson) =>
      _$DetailsFromJson(srcJson);

  Map<String, dynamic> toJson() => _$DetailsToJson(this);
}
