import 'package:resourcemanager/common/HttpApi.dart';
import 'package:resourcemanager/entity/BaseListResult.dart';
import 'package:resourcemanager/entity/ListData.dart';
import 'package:resourcemanager/entity/book/SeriesItem.dart';
import 'package:resourcemanager/entity/BaseResult.dart';
import 'package:resourcemanager/entity/comic/ComicSetDetail.dart';
import 'package:resourcemanager/entity/comic/ComicSetItem.dart';
import 'package:resourcemanager/models/picture/PictureList.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ComicSetDetailState.g.dart';

@riverpod
class ComicSetDetailState extends _$ComicSetDetailState {
  @override
  ComicSetDetail? build() {
    return null;
  }

  void getDetail(int id) async {
    BaseResult baseResult = await HttpApi.request(
        "/comic/getDetail", (json) => ComicSetDetail.fromJson(json),
        params: {
          "id": id,
        });

    // 如果请求成功，更新状态
    if (baseResult.code == "2000") {
      state = baseResult.result;
    }
  }

  void setLove(int id) async {
    int newLove = state!.love == 1 ? 2 : 1;
    BaseResult baseResult =
        await HttpApi.request("/comic/setLove", (json) => {}, params: {
      "id": id,
      "love": newLove,
    });

    // 如果请求成功，更新状态
    if (baseResult.code == "2000") {
      print("asdadasdasd");
      state = state!.copyWith(love: newLove);
    }
  }

  Future<void> updateData(ComicSetDetail comicDetail) async {
    BaseResult baseResult = await HttpApi.request("/comic/updateData", () => {},
        method: "post", successMsg: true, params: comicDetail.toJson());
    // 如果请求成功，更新状态
    if (baseResult.code == "2000") {
      state = comicDetail;
    }
  }

  void updateReadStatus(int readStatus) {
    if (readStatus != state!.readStatus) {
      state = state!.copyWith(readStatus: readStatus);
    }
  }
}
