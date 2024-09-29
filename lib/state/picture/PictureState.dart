import 'package:resourcemanager/common/HttpApi.dart';
import 'package:resourcemanager/models/BaseResult.dart';
import 'package:resourcemanager/models/picture/PictureList.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'PictureState.g.dart';

@riverpod
class PictureState extends _$PictureState {
  @override
  PictureContent build(String? fileId) {
    // 返回初始状态，设置 page 的初始值
    return PictureContent(fileId: fileId, page: 1);
  }

  void getList(String? fileId) async {
    // 尝试解析 fileId 为数字
    int? numberInt = int.tryParse(fileId ?? '-1');
    // 进行 API 请求
    BaseResult baseResult = await HttpApi.request(
      "/picture/getFolderList",
          (json) => PictureList.fromJson(json),
      params: {
        "page": state.page,
        "size": state.limit,
        "picture_id": numberInt
      },
    );

    // 如果请求成功，更新状态
    if (baseResult.code == "2000") {
      final newList = baseResult.result!.data;
      final newPictures = newList.where((item) => item.isFolder == 2).toList();

      print(newList);
      // 更新状态，停止加载状态，并更新数据
      state = state.copyWith(
        list: newList,
        pictures: newPictures,
        count: baseResult.result!.count,
        page: state.page + 1, // 假设要翻页
        isLoading: false,
      );
      // } else {
      //   // 请求失败，停止加载状态
      //   state = state.copyWith(isLoading: false);
    }
  }

  void setCurrent(int current) {
    state.current = current;
  }
}

class PictureContent {
  PictureContent({
    this.list = const [],
    this.pictures = const [],
    this.page = 0,
    this.limit = 50,
    this.count = 0,
    this.current = 0,
    this.fileId,
    this.isLoading = false, // 添加加载状态
  });

  final List<PictureData> list;
  final List<PictureData> pictures;
  final int page;
  final int limit;
  final int count;
  int current;
  final String? fileId;
  final bool isLoading; // 是否正在加载

  PictureContent copyWith({
    List<PictureData>? list,
    List<PictureData>? pictures,
    int? page,
    int? limit,
    int? count,
    int? current,
    String? fileId,
    bool? isLoading,
  }) {
    return PictureContent(
      list: list ?? this.list,
      pictures: pictures ?? this.pictures,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      count: count ?? this.count,
      current: current ?? this.current,
      fileId: fileId ?? this.fileId,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
