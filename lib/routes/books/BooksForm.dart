import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resourcemanager/common/HttpApi.dart';
import 'package:resourcemanager/main.dart';
import 'package:resourcemanager/models/GetBooksList.dart';
import 'package:resourcemanager/routes/books/BooksDetails.dart';
import 'package:resourcemanager/state/BooksState.dart';

import '../../entity/BaseResult.dart';

class BooksForm extends StatefulWidget {
  const BooksForm({super.key});

  @override
  State<StatefulWidget> createState() => BooksFormState();
}

class BooksFormState extends State<BooksForm> {
  @override
  Widget build(BuildContext context) {
    Data books = Provider.of<BooksState>(context).books;
    TextEditingController textEditingController = TextEditingController(text: "${books.count}");
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Form(
          child: Stack(
        children: [
          SingleChildScrollView(child: LayoutBuilder(
            builder: (context, constraints) {
              double width = constraints.maxWidth > MyApp.width
                  ? constraints.maxWidth / 2
                  : constraints.maxWidth;
              return Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: Wrap(
                  direction: Axis.horizontal,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      width: width,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      height: 60,
                      child: TextFormField(
                        decoration: const InputDecoration(
                            labelText: "系列名称",
                            hintText: "请输入系列名称",
                            prefixIcon: Icon(
                              Icons.drive_file_rename_outline_sharp,
                              size: 18,
                            )),
                        validator: (value) {
                          if (value!.trim().isEmpty) return "请输入系列名称";
                          return null;
                        },
                        initialValue: books.name,
                        onSaved: (value) {
                          books.name = value!;
                        },
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      width: width,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      height: 60,
                      child: TextFormField(
                        decoration: const InputDecoration(
                            labelText: "作者",
                            hintText: "请输入作者",
                            prefixIcon: Icon(
                              Icons.person,
                              size: 18,
                            )),
                        validator: (value) {
                          if (value!.trim().isEmpty) return "请输入作者";
                          return null;
                        },
                        onSaved: (value) {
                          books.author = value!;
                        },
                        initialValue: books.author,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      width: width,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      height: 60,
                      child: TextFormField(
                        decoration: const InputDecoration(
                            labelText: "插画师",
                            hintText: "请输入插画师",
                            prefixIcon: Icon(
                              Icons.person,
                              size: 18,
                            )),
                        validator: (value) {
                          if (value!.trim().isEmpty) return "请输入插画师";
                          return null;
                        },
                        onSaved: (value) {
                          books.illustrator = value!;
                        },
                        initialValue: books.illustrator,
                      ),
                    ),
                    StatefulBuilder(builder: (context, _setState) {
                      return Container(
                          margin: const EdgeInsets.only(bottom: 10, left: 20),
                          width: width - 40,
                          height: 50,
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Theme.of(context).primaryColor))),
                          child: Row(
                            children: [
                              const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Icon(Icons.filter_list, size: 18)),
                              Expanded(
                                child: DropdownButton<int>(
                                  value: books.status,
                                  underline: Container(height: 0),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 1,
                                      child: Text('连载中'),
                                    ),
                                    DropdownMenuItem(
                                      value: 2,
                                      child: Text('已完结'),
                                    ),
                                    DropdownMenuItem(
                                      value: 3,
                                      child: Text('弃坑'),
                                    )
                                  ],
                                  onChanged: (int? value) {
                                    _setState(() {
                                      books.status = value!;
                                    });
                                  },
                                ),
                              )
                            ],
                          ));
                    }),
                  ],
                ),
              );
            },
          )),
          Positioned(
            bottom: 10,
            right: 10,
            child: Builder(
              builder: (context) {
                return ElevatedButton(
                    onPressed: () async {
                      Form.of(context).save();
                      bool status = Form.of(context).validate();
                      if (status) {
                        BaseResult baseResult = await HttpApi.request(
                            books.id == 0
                                ? "/books/addBooks"
                                : "/books/editBooks",
                            (json) => json,
                            method: "post",
                            params: {
                              if (books.id != 0) "id": books.id,
                              "name": books.name,
                              "author": books.author,
                              "illustrator": books.illustrator,
                              "status": books.status
                            });
                        if (baseResult.code == "2000") {
                          if (books.id == 0) {
                            books.id = baseResult.result;
                            BooksDetailsState.booksState.addBooks(books);
                          }else{
                            BooksDetailsState.booksState.changeState();
                          }
                          Navigator.of(context).pop();
                        }
                      }
                    },
                    child: const Text("提交"));
              },
            ),
          )
        ],
      )),
    );
  }
}
