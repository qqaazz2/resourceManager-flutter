import 'package:json_annotation/json_annotation.dart';
import 'package:resourcemanager/entity/ListData.dart';
import 'package:resourcemanager/entity/book/BookItem.dart';
import 'package:resourcemanager/entity/book/SeriesItem.dart';
import 'package:resourcemanager/entity/comic/ComicItem.dart';
import 'package:resourcemanager/entity/comic/ComicSetDetail.dart';

@JsonSerializable()
class ComicSetContent extends Object {
  ComicSetDetail? comicSetDetail;

  ListData<ComicItem>? listData;

  ComicSetContent({required this.comicSetDetail,required this.listData});

  ComicSetContent copyWith({
    ComicSetDetail? comicSetDetail,
    ListData<ComicItem>? listData,
  }) {
    return ComicSetContent(comicSetDetail: comicSetDetail ?? this.comicSetDetail, listData: listData ?? this.listData);
  }
}
