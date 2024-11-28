import 'package:resourcemanager/common/HttpApi.dart';
import 'package:resourcemanager/entity/ListData.dart';
import 'package:resourcemanager/entity/book/BookItem.dart';
import 'package:resourcemanager/entity/book/BookList.dart';
import 'package:resourcemanager/entity/book/SeriesCover.dart';
import 'package:resourcemanager/entity/book/SeriesCoverList.dart';
import 'package:resourcemanager/entity/book/SeriesItem.dart';
import 'package:resourcemanager/entity/book/SeriesContent.dart';
import 'package:resourcemanager/entity/book/SeriesContent.dart';
import 'package:resourcemanager/entity/BaseResult.dart';
import 'package:resourcemanager/models/picture/PictureList.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'SeriesContentState.g.dart';

@riverpod
class SeriesContentState extends _$SeriesContentState {
  int page = 0;
  late int seriesId;

  @override
  SeriesContent build(id) {
    seriesId = id;
    return SeriesContent(seriesItem: null, bookItem: []);
  }

  void getData(int fileId) async {
    Future.wait([
      getDetails(seriesId),
      getBookList(fileId),
    ]).then((results) {
      BaseResult baseResult = results[0];
      BaseResult baseResult1 = results[1];
      if (baseResult.code == "2000" && baseResult1.code == "2000") {
        final newList = baseResult1.result!.data;
        state = SeriesContent(seriesItem: baseResult.result, bookItem: newList);
      }
    });
  }

  Future<BaseResult> getDetails(int id) async {
    BaseResult baseResult = await HttpApi.request(
      "/series/getDetails",
      (json) => SeriesItem.fromJson(json),
      params: {
        "id": id,
      },
    );
    return baseResult;
  }

  Future<BaseResult> getBookList(int fileId) async {
    BaseResult baseResult = await HttpApi.request(
      "/book/getList",
      (json) => BookList.fromJson(json),
      params: {
        "page": page,
        "size": 8,
        "id": fileId,
      },
    );
    return baseResult;
  }

  void setLove() async {
    int love = state.seriesItem!.love == 1 ? 2 : 1;
    BaseResult baseResult =
        await HttpApi.request("/series/updateLove", () => {}, params: {
      'id': state.seriesItem!.id,
      'love': love,
    });
    if (baseResult.code == "2000") {
      state.seriesItem!.love = love;
      state = SeriesContent(
          seriesItem: state.seriesItem, bookItem: state.bookItem ?? []);
    }
  }

  void setCover(BookItem bookItem) async {
    BaseResult baseResult =
        await HttpApi.request("/series/updateCover", () => {}, params: {
      'id': state.seriesItem!.id,
      'coverId': bookItem.coverId,
    });
    if (baseResult.code == "2000") {
      state.seriesItem!.filePath = bookItem.coverPath;
      state = SeriesContent(
          seriesItem: state.seriesItem, bookItem: state.bookItem ?? []);
    }
  }

  Future<void> updateData(SeriesItem seriesItem) async {
    BaseResult baseResult = await HttpApi.request(
        "/series/updateData", () => {},
        method: "post", successMsg: true, params: seriesItem.toJson());
    if (baseResult.code == "2000") {
      state = state.copyWith(
          seriesItem: seriesItem, bookItem: state.bookItem ?? []);
    }
  }

  Future<SeriesCoverList> getCoverList() async {
    BaseResult baseResult = await HttpApi.request(
      "/book/getCoverList",
      (json) => SeriesCoverList.fromJson(json),
      params: {
        "page": page,
        "size": 8,
        "id": state.seriesItem!.filesId,
      },
    );
    if (baseResult.code == "2000") {
      return baseResult.result!;
    }
    return SeriesCoverList([]);
  }

  void updateProgress(BookItem bookItem) async {
    BaseResult baseResult = await HttpApi.request(
        "/book/updateProgress", (json) => json,
        method: "post", successMsg: true, params: bookItem.toJson());
    if (baseResult.code == "2000") {
      BookItem item = BookItem.fromJson(baseResult.result['book']);
      state.seriesItem?.overStatus = baseResult.result['status'] ? 2 : 1;

      if (state.bookItem != null && state.bookItem!.isNotEmpty) {
        int index = 0;
        for (BookItem value in state.bookItem!) {
          if (value.id == item.id) break;
          index++;
        }

        state.bookItem![index] = item;
      }

      state = state.copyWith(
          seriesItem: state.seriesItem, bookItem: state.bookItem ?? []);
    }
  }

  void updateLastReadTime(int seriesId) async {
    BaseResult baseResult = await HttpApi.request(
        "/series/updateLastReadTime", (json) => json,
        successMsg: true, params: {"id": seriesId});
    if (baseResult.code == "2000") {
      state.seriesItem?.lastReadTime = baseResult.result;
      state = state.copyWith(
          seriesItem: state.seriesItem, bookItem: state.bookItem ?? []);
    }
  }
}
