import 'package:resourcemanager/common/HttpApi.dart';
import 'package:resourcemanager/entity/BaseResult.dart';
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
      // 更新状态，停止加载状态，并更新数据
      state = state.copyWith(
        list: newList,
        pictures: newPictures,
        count: baseResult.result!.count,
        page: state.page + 1,
        // 假设要翻页
        isLoading: false,
      );
      // } else {
      //   // 请求失败，停止加载状态
      //   state = state.copyWith(isLoading: false);
    }
  }

  void setCurrent(int current) {
    state = state.copyWith(current: current);
  }

  void setLove(index) async {
    int love = state.list[index].love == 1 ? 2 : 1;
    BaseResult baseResult = await HttpApi.request("/picture/setLove", () => {},
        method: "post",
        params: {
          'id': state.list[index].id,
          'love': love,
        });
    if (baseResult.code == "2000") {
      List<PictureData> list = state.list;
      list[index].love = love;
      state = state.copyWith(list: list);
    }
  }

  void setDisplay(index, display) async {
    BaseResult baseResult = await HttpApi.request(
        "/picture/setDisplay", () => {},
        method: "post",
        params: {
          'id': state.list[index].id,
          'display': display,
        });
    if (baseResult.code == "2000") {
      List<PictureData> list = state.list;
      list[index].display = display;
      state = state.copyWith(list: list);
    }
  }

  void editData(index, name, author) async {
    BaseResult baseResult = await HttpApi.request("/picture/editData", () => {},
        method: "post",
        successMsg: true,
        params: {
          'id': state.list[index].id,
          'name': name,
          'author': author,
        });
    if (baseResult.code == "2000") {
      state.list[index].author = author;
      state.list[index].modifiableName = name;
    }
  }

  Future<void> randomData() async {
    BaseResult baseResult = await HttpApi.request(
        "/picture/getRandList",
        (json) => (json as List<dynamic>)
            .map((e) => PictureData.fromJson(e as Map<String, dynamic>))
            .toList(),
        params: {"limit": 10});

    if (baseResult.code == "2000") {
      state.current = 0;
      state.pictures = baseResult.result!;
    }
  }

  void scanning(String? fileId) async {
    BaseResult baseResult =
        await HttpApi.request("/picture/scanning", () => {}, params: {});
    if (baseResult.code == "2000") {
      // getList(fileId);
    }
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

  List<PictureData> list;
  List<PictureData> pictures;
  int page;
  int limit;
  int count;
  int current;
  String? fileId;
  bool isLoading; // 是否正在加载

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
