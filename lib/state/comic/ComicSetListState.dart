import 'package:resourcemanager/common/HttpApi.dart';
import 'package:resourcemanager/entity/BaseListResult.dart';
import 'package:resourcemanager/entity/ListData.dart';
import 'package:resourcemanager/entity/book/SeriesItem.dart';
import 'package:resourcemanager/entity/BaseResult.dart';
import 'package:resourcemanager/entity/comic/ComicSetDetail.dart';
import 'package:resourcemanager/entity/comic/ComicSetItem.dart';
import 'package:resourcemanager/models/picture/PictureList.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ComicSetListState.g.dart';

@riverpod
class ComicSetListState extends _$ComicSetListState {
  @override
  ListData<ComicSetItem> build() {
    return ListData(50, 1, 0, 0, []);
  }

  void scanning() async {
    BaseResult baseResult =
        await HttpApi.request("/comic/scanning", () => {}, params: {});
    if (baseResult.code == "2000") {
      // getList(fileId);
    }
  }

  void reload() {
    state.data = [];
    state.page = 1;
    getList();
  }

  void getList() async {
    BaseListResult<ComicSetItem> baseResult =
        await HttpApi.request<ComicSetItem>(
            "/comic/getList", (json) => ComicSetItem.fromJson(json),
            params: {
              "page": state.page,
              "limit": state.limit,
            },
            isList: true);

    // 如果请求成功，更新状态
    if (baseResult.code == "2000") {
      state.data?.addAll(baseResult.result?.data as Iterable<ComicSetItem>);
      state = state.copyWith(
          page: baseResult.result?.page += 1,
          limit: baseResult.result?.limit,
          pages: baseResult.result?.pages,
          count: baseResult.result?.count,
          data: state.data);
    }
  }

  void setLove(int id, int love) async {
    int newLove = love == 1 ? 2 : 1;
    BaseResult baseResult =
        await HttpApi.request("/comic/setLove", (json) => {}, params: {
      "id": id,
      "love": newLove,
    });

    // 如果请求成功，更新状态
    if (baseResult.code == "2000" && state.data != null) {
      int index = 0;
      for (ComicSetItem comicSetItem in state.data!) {
        if (comicSetItem.id == id) break;
        index++;
      }

      state.data![index].love = newLove;
      state = state.copyWith(data: state.data);
    }
  }

  Future<ComicSetDetail?> getDetail(int id, int index) async {
    BaseResult baseResult = await HttpApi.request(
        "/comic/getDetail", (json) => ComicSetDetail.fromJson(json),
        params: {
          "id": id,
        });

    // 如果请求成功，更新状态
    if (baseResult.code == "2000") {
      return baseResult.result;
    }

    return null;
  }

  Future<void> updateData(ComicSetDetail comicDetail, int? index) async {
    print("comicDetail${comicDetail.toJson()}");
    BaseResult baseResult = await HttpApi.request("/comic/updateData", () => {},
        method: "post", successMsg: true, params: comicDetail.toJson());
    // 如果请求成功，更新状态
    if (baseResult.code == "2000" && index != null) {
      int index = 0;
      for (ComicSetItem comicSetItem in state.data!) {
        if (comicSetItem.id == comicDetail.id) break;
        index++;
      }

      setData(index,comicDetail);
    }
  }

  void setData(int index, ComicSetDetail comicDetail) {
    if (state.data?[index] != null) {
      ComicSetItem comicSetItem = ComicSetItem(
          comicDetail.id,
          comicDetail.name,
          comicDetail.status,
          state.data?[index].coverPath,
          comicDetail.love,
          comicDetail.readStatus,
          state.data![index].filesId);
      state.data![index] = comicSetItem;
      state = state.copyWith(data: state.data);
    }
  }
}
