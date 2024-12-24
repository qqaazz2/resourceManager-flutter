import 'package:flutter/material.dart';
import 'package:resourcemanager/common/Global.dart';
import 'package:resourcemanager/common/HttpApi.dart';
import 'package:resourcemanager/entity/BaseListResult.dart';
import 'package:resourcemanager/entity/ListData.dart';
import 'package:resourcemanager/entity/UserInfo.dart';
import 'package:resourcemanager/entity/book/SeriesItem.dart';
import 'package:resourcemanager/entity/BaseResult.dart';
import 'package:resourcemanager/entity/comic/ComicItem.dart';
import 'package:resourcemanager/entity/comic/ComicSetDetail.dart';
import 'package:resourcemanager/entity/comic/ComicSetItem.dart';
import 'package:resourcemanager/models/picture/PictureList.dart';
import 'package:resourcemanager/state/comic/ComicSetDetailState.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ThemeState.g.dart';

@riverpod
class ThemeState extends _$ThemeState {
  @override
  Setting build() {
    return Global.setting;
  }

  void changeTheme() {
    Global.setLight();
    state = state.copyWith(light: Global.setting.light);
  }

  void changeBaseUrl(String url) {
    Global.setBaseUrl(url);
    state = state.copyWith(baseUrl: Global.setting.baseUrl);
  }

  void changeUserInfo(UserInfo userInfo) {
    Global.setUserInfo(userInfo);
    state = state.copyWith(userInfo: state.userInfo);
  }

  Future<bool> changeMystery({required int mystery, String? mysteryPassword}) async {
    // BaseResult baseResult = await HttpApi.request(
    //   "/series/getList",
    //   (json) => SeriesList.fromJson(json),
    //   params: {
    //     "page": state.page,
    //     "limit": state.limit,
    //     "id": -1,
    //   },
    // );
    //
    // // 如果请求成功，更新状态
    // if (baseResult.code == "2000") {
    //   List<SeriesItem> newList = [];
    //   newList.addAll(state.data);
    //   newList.addAll(baseResult.result!.data);
    //
    //   SeriesList seriesList = SeriesList(8, state.page + 1,
    //       baseResult.result!.pages, baseResult.result!.count, newList);
    //   state = seriesList;
    // }

    BaseResult baseResult = await HttpApi.request(params: {
      "mystery": mystery,
      "mysteryPassword": mysteryPassword,
    }, "/user/changeMystery", (json) => UserInfo.fromJson(json));
    if ("2000" == baseResult.code) {
      Global.setMystery(mystery);
      state.userInfo ??= Global.setting.userInfo;
      state.userInfo!.mystery = mystery;
      state = state.copyWith(userInfo: state.userInfo);
      return true;
    }

    return false;
  }
}
