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

part 'ThemeState.g.dart';

@riverpod
class ThemeState extends _$ThemeState {
  @override
  bool build() {
    return false;
  }

  void changeTheme(){
    state = !state;
  }
}
