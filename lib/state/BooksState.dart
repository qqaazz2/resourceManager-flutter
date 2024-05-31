import 'package:flutter/material.dart';
import 'package:resourcemanager/models/GetBooksList.dart';

import '../common/HttpApi.dart';
import '../models/BaseResult.dart';

class BooksState with ChangeNotifier {
  Data books = Data(0, "", 0, 0, "", "", "", 1);
  List<Data> booksList = [];
  int listNum = 0;
  int page = 1;
  int count = 0;

  void getList(size) async {
    BaseResult baseResult = await HttpApi.request(
        "/books/getList", (json) => GetBooksList.fromJson(json),
        params: {
          "page": page,
          "size": size,
        });

    if (baseResult.code == "2000") {
      booksList.addAll(baseResult.result!.data);
      listNum += booksList.length;
      count = baseResult.result!.count;
      page++;
      notifyListeners();
    }
  }

  void addBooks(Data books) {
    count += 1;
    booksList.insert(0, books);
    notifyListeners();
  }

  void setBooks(Data books){
    this.books = books;
  }
}
