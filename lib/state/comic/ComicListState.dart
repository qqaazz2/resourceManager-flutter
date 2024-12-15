import 'package:resourcemanager/common/HttpApi.dart';
import 'package:resourcemanager/entity/BaseListResult.dart';
import 'package:resourcemanager/entity/ListData.dart';
import 'package:resourcemanager/entity/book/SeriesItem.dart';
import 'package:resourcemanager/entity/BaseResult.dart';
import 'package:resourcemanager/entity/comic/ComicItem.dart';
import 'package:resourcemanager/entity/comic/ComicSetDetail.dart';
import 'package:resourcemanager/entity/comic/ComicSetItem.dart';
import 'package:resourcemanager/models/picture/PictureList.dart';
import 'package:resourcemanager/state/comic/ComicSetDetailState.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ComicListState.g.dart';

@riverpod
class ComicListState extends _$ComicListState {
  @override
  ListData<ComicItem> build() {
    return ListData(50, 1, 0, 0, []);
  }

  void reload() {
    state.data = [];
    state.page = 1;
  }

  Future<void> getList(int filesId) async {
    BaseListResult<ComicItem> baseResult = await HttpApi.request<ComicItem>(
        "/comic/getComicList", (json) => ComicItem.fromJson(json),
        params: {
          "page": state.page,
          "limit": state.limit,
          "id": filesId,
        },
        isList: true);

    // 如果请求成功，更新状态
    if (baseResult.code == "2000") {
      state.data?.addAll(baseResult.result?.data as Iterable<ComicItem>);
      state = state.copyWith(
          page: baseResult.result?.page += 1,
          limit: baseResult.result?.limit,
          pages: baseResult.result?.pages,
          count: baseResult.result?.count,
          data: state.data);
    }
  }

  Future<dynamic> getPageList(String path) async {
    BaseResult baseResult =
        await HttpApi.request("/comic/getPageList", (json) => json, params: {
      "path": path,
    });

    // 如果请求成功，更新状态
    if (baseResult.code == "2000") {
      return baseResult.result;
    }

    return [];
  }

  Future<ComicItem?> getByIndex(int index) async {
    if (state.count < index) return null;

    if (state.data!.length < index) {
      await getList(state.data![0].id);
    }

    return state.data![index];
  }

  int getCount() {
    return state.count;
  }

  void updateNumber(int id, int filesId, bool over, int num, int index,{isChange = false}) async {
    BaseResult baseResult =
        await HttpApi.request("/comic/updateNumber", (json) => json, params: {
      "id": id,
      "filesId": filesId,
      "over": over,
      "num": num,
    });

    // 如果请求成功，更新状态
    if (baseResult.code == "2000") {
      bool isTrue = baseResult.result as bool;
      int status = over ? 2 : 3;
      if (state.data![index].status != status) {
        state.data![index].status = status;
      }
      ref
          .read(comicSetDetailStateProvider.notifier)
          .updateReadStatus(isTrue ? 2 : 3);

      if(isChange) state = state.copyWith(data: state.data);
      // return baseResult.result;
    }
  }
}
