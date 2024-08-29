import 'package:flutter/material.dart';
import 'package:resourcemanager/common/HttpApi.dart';
import 'package:resourcemanager/models/BaseResult.dart';
import 'package:resourcemanager/models/picture/PictureList.dart';

class PictureListState extends ChangeNotifier {
  List<PictureData> list = [];
  List<PictureData> pictures = [];
  int page = 0;
  int limit = 50;
  int count = 0;
  int current = 0;

  void init() {
    list = [];
    pictures = [];
    page = 0;
    count = 0;
    current = 0;
  }

  void getList(String? fileId) async {
    int? numberInt = int.tryParse(fileId ?? '-1');
    BaseResult baseResult = await HttpApi.request(
        "/picture/getFolderList", (json) => PictureList.fromJson(json),
        params: {"page": page, "size": 50, "picture_id": numberInt});

    if (baseResult.code == "2000") {
      list.addAll(baseResult.result!.data);
      count = baseResult.result!.count;
      pictures = list.where((item) => item.isFolder == 2).toList();
      page++;
      notifyListeners();
    }
  }

  void setCurrent(int current) {
    this.current = current;
    notifyListeners();
  }

  void setLove(index) async {
    int love = list[index].love == 1 ? 2 : 1;
    BaseResult baseResult = await HttpApi.request("/picture/setLove", () => {},
        method: "post",
        params: {
          'id': list[index].id,
          'love': love,
        });
    if (baseResult.code == "2000") {
      list[index].love = love;
      notifyListeners();
    }
  }

  void setDisplay(index, display) async {
    BaseResult baseResult = await HttpApi.request(
        "/picture/setDisplay", () => {},
        method: "post",
        params: {
          'id': list[index].id,
          'display': display,
        });
    if (baseResult.code != "2000") {
      list[index].display = display;
      notifyListeners();
    }
  }

  void editData(index, name, author) async {
    print(name);
    print(author);
    BaseResult baseResult = await HttpApi.request("/picture/editData", () => {},
        method: "post",
        successMsg: true,
        params: {
          'id': list[index].id,
          'name': name,
          'author': author,
        });
    if (baseResult.code == "2000") {
      PictureData pictureData = list[index];
      pictureData.author = author;
      pictureData.modifiableName = name;
      notifyListeners();
    }
  }
}
