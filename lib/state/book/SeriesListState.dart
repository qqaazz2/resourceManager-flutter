import 'package:resourcemanager/common/HttpApi.dart';
import 'package:resourcemanager/entity/book/SeriesItem.dart';
import 'package:resourcemanager/entity/book/SeriesList.dart';
import 'package:resourcemanager/entity/book/SeriesList.dart';
import 'package:resourcemanager/entity/BaseResult.dart';
import 'package:resourcemanager/models/picture/PictureList.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'SeriesListState.g.dart';

@riverpod
class SeriesListState extends _$SeriesListState {
  @override
  SeriesList build() {
    return SeriesList(50, 1, 0, 0, []);
  }

  void reload() {
    state.page = 1;
    state.data = [];
    getList();
  }

  void getList() async {
    BaseResult baseResult = await HttpApi.request(
      "/series/getList",
      (json) => SeriesList.fromJson(json),
      params: {
        "page": state.page,
        "limit": state.limit,
        "id": -1,
      },
    );

    // 如果请求成功，更新状态
    if (baseResult.code == "2000") {
      List<SeriesItem> newList = [];
      newList.addAll(state.data);
      newList.addAll(baseResult.result!.data);

      SeriesList seriesList = SeriesList(8, state.page + 1,
          baseResult.result!.pages, baseResult.result!.count, newList);
      state = seriesList;
    }
  }

  void setLove(index) async {
    int love = state.data[index].love == 1 ? 2 : 1;
    BaseResult baseResult =
        await HttpApi.request("/series/updateLove", () => {}, params: {
      'id': state.data[index].id,
      'love': love,
    });
    if (baseResult.code == "2000") {
      state.data[index].love = love;
      state = state.copyWith(
          data: state.data,
          page: state.page,
          limit: state.limit,
          pages: state.pages,
          count: state.count);
    }
  }

  void scanning() async {
    BaseResult baseResult =
        await HttpApi.request("/book/scanning", () => {}, params: {});
    if (baseResult.code == "2000") {
      // getList(fileId);
    }
  }

  Future<void> updateData(SeriesItem seriesItem, int index) async {
    BaseResult baseResult = await HttpApi.request(
        "/series/updateData", () => {},
        method: "post", successMsg: true, params: seriesItem.toJson());
    if (baseResult.code == "2000") {
      state.data[index] = seriesItem;
      state = state.copyWith(
          data: state.data,
          page: state.page,
          limit: state.limit,
          pages: state.pages,
          count: state.count);
    }
  }

  void setData(SeriesItem seriesItem) {
    int index = 0;
    for (SeriesItem item in state.data) {
      if (item.id == seriesItem.id) break;
      index++;
    }

    state.data[index] = seriesItem;
    state = state.copyWith(
        data: state.data,
        page: state.page,
        limit: state.limit,
        pages: state.pages,
        count: state.count);
  }
}
