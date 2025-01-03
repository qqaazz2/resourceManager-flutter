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
    return PictureContent(fileId: fileId, page: 1, list: [], pictures: []);
  }

  void reload(String? fileId) {
    state.page = 1;
    state.list = [];
    getList(fileId);
  }

  void getList(String? fileId) async {
    int? numberInt = int.tryParse(fileId ?? '-1');
    BaseResult baseResult = await HttpApi.request(
      "/picture/getFolderList",
      (json) => PictureList.fromJson(json),
      params: {"page": state.page, "limit": 50, "picture_id": numberInt},
    );

    if (baseResult.code == "2000") {
      List<PictureData> newList = baseResult.result!.data;
      state.list.addAll(newList);
      if (newList.isEmpty) return;
      final newPictures = newList.where((item) => item.isFolder == 2).toList();
      state.pictures.addAll(newPictures);
      print(state.list.length);
      state = state.copyWith(
        list: state.list,
        pictures: state.pictures,
        count: baseResult.result!.count,
        page: state.page + 1,
        isLoading: false,
      );
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

  void setDisplay(id, display) async {
    BaseResult baseResult = await HttpApi.request(
        "/picture/setDisplay", () => {},
        method: "post",
        params: {
          'id': id,
          'display': display,
        });
    if (baseResult.code == "2000") {
      for (int i = 0; i < state.list.length; i++) {
        if (state.list[i].id == id) {
          state.list[i].display = display;
          state = state.copyWith(list: state.list);
          break;
        }
      }
    }
  }

  void editData(id, name, author) async {
    BaseResult baseResult = await HttpApi.request("/picture/editData", () => {},
        method: "post",
        successMsg: true,
        params: {
          'id': id,
          'name': name,
          'author': author,
        });
    if (baseResult.code == "2000") {
      for (int i = 0; i < state.list.length; i++) {
        if (state.list[i].id == id) {
          state.list[i].author = author;
          state.list[i].fileName = name;
          state = state.copyWith(list: state.list);
          break;
        }
      }
    }
  }

  Future<List<PictureData>> randomData() async {
    BaseResult baseResult = await HttpApi.request(
        "/picture/getRandList",
        (json) => (json as List<dynamic>)
            .map((e) => PictureData.fromJson(e as Map<String, dynamic>))
            .toList(),
        params: {"limit": 10});

    if (baseResult.code == "2000") {
      return baseResult.result;
    }

    return [];
  }

  void scanning(String? fileId) async {
    BaseResult baseResult =
        await HttpApi.request("/picture/scanning", () => {}, params: {});
    if (baseResult.code == "2000") {
      // getList(fileId);
    }
  }

  Future<void> getTimeLineList() async{
    BaseResult baseResult = await HttpApi.request(
      "/picture/getTimeLineList",
      (json) => PictureList.fromJson(json),
      params: {"page": state.page, "limit": 50},
    );

    if (baseResult.code == "2000") {
      List<PictureData> newList = baseResult.result!.data;
      if (newList.isEmpty) return;
      state.list.addAll(newList);

      state = state.copyWith(
        list: state.list,
        pictures: [],
        count: baseResult.result!.count,
        page: state.page + 1,
      );
    }
  }
}

class PictureContent {
  PictureContent({
    required this.list,
    required this.pictures,
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
