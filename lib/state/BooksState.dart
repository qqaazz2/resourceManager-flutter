import 'package:flutter/material.dart';
import 'package:resourcemanager/models/GetBooksDetailsList.dart';
import 'package:resourcemanager/models/GetBooksList.dart';
import 'package:resourcemanager/routes/books/BooksDetails.dart';

import '../common/HttpApi.dart';
import '../entity/BaseResult.dart';

class BooksState with ChangeNotifier {
  Data books = Data(0, "", 0, 0, "", "", "", 1, "", "");
  List<Data> booksList = [];
  int listNum = 0;
  int page = 1;
  int count = 0;
  int currentIndex = 0;

  List<Details> detailsList = [];
  int detailsPage = 1;
  int detailsCount = 0;
  bool isLoading = false;
  late Details details;
  int currentDetailsIndex = 0;

  void initList() {
    page = 1;
    listNum = 0;
    currentIndex = 0;
    booksList = [];
  }

  void clearBooks() {
    books = Data(0, "", 0, 0, "", "", "", 1, "", "");
  }

  void getList(size, {int? sortFiled, String? sort}) async {
    BaseResult baseResult = await HttpApi.request(
        "/books/getList", (json) => GetBooksList.fromJson(json),
        params: {
          "page": page,
          "size": size,
          "sortFiled": sortFiled,
          "sort": sort,
        });

    if (baseResult.code == "2000") {
      booksList.addAll(baseResult.result!.data);
      listNum += booksList.length;
      count = baseResult.result!.count;
      page++;
      notifyListeners();
    }
  }

  static void showDetails(
      bool isPc, BuildContext context, Data? books, int detailsID) {
    if (isPc) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
                child: BooksDetails(
              books: books,
              detailsID: detailsID,
            ));
          });
    } else {
      showModalBottomSheet<int>(
        context: context,
        builder: (BuildContext context) {
          return BooksDetails(
            books: books,
            detailsID: detailsID,
          );
        },
      );
    }
  }

  void addBooks(Data books) {
    count += 1;
    booksList.insert(0, books);
    notifyListeners();
  }

  void setBooks(Data books, int index) {
    this.books = books;
    currentIndex = index;
    initDetails();
  }

  void getDetailsList() async {
    BaseResult baseResult = await HttpApi.request(
        "/booksDetails/getDetailsList",
        (json) => GetBooksDetailsList.fromJson(json),
        params: {
          "id": books.id,
          "page": detailsPage,
          "size": 24,
        });
    if (baseResult.code == "2000") {
      detailsCount = baseResult.result.count;
      detailsList.addAll(baseResult.result.data);
      books.count = detailsCount;
      detailsPage++;
      isLoading = false;
      changeState();
    }
  }

  void deleteDetails(List<Details> list) {
    for (int i = 0; i < list.length; i++) {
      if (list[i].status != 2) books.readNum--;
      detailsList.remove(list[i]);
    }
    books.count -= list.length;
    detailsCount = books.count;
    changeState();
  }

  void setDetails(Details d, int index) {
    details = d;
    currentDetailsIndex = index;
  }

  void initDetails() {
    detailsList = [];
    detailsPage = 1;
    detailsCount = 0;
  }

  void changeState() {
    booksList[currentIndex] = books;
    notifyListeners();
  }

  void changeDetailsState({bool sort = false}) {
    print(details.progress);
    if (details.status == 1) {
      details.progress = 0;
    } else if (details.status == 2){
      details.progress = 1;
    }
    print(details.progress);
    detailsList[currentDetailsIndex] = details;
    if(sort)sortDetailsList();
    notifyListeners();
  }

  void sortDetailsList() {
    detailsList.sort((left, right) => left.sort.compareTo(right.sort));
  }

  //page侧边栏状态
  int sort = 1;
  int status = 1;
  bool sortStatus = true;

  void changeDrawer(int status, int sort, bool sortStatus) {
    this.status = status;
    this.sort = sort;
    this.sortStatus = sortStatus;
  }
}
