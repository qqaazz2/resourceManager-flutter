import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:resourcemanager/common/HttpApi.dart';
import 'package:resourcemanager/main.dart';

import '../../models/BaseResult.dart';

class BooksForm extends StatefulWidget {
  const BooksForm({super.key, required this.booksID});

  final int booksID;

  @override
  State<StatefulWidget> createState() => BooksFormState();
}

class BooksFormState extends State<BooksForm> {
  @override
  Widget build(BuildContext context) {
    late String _name;
    late String _author;
    late String _illustrator;
    int _status = 1;
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
                padding: EdgeInsets.only(bottom: 60),
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
                        onSaved: (value) {
                          _name = value!;
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
                          _author = value!;
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
                          _illustrator = value!;
                        },
                      ),
                    ),
                    StatefulBuilder(builder: (context, _setState) {
                      return Container(
                          margin: const EdgeInsets.only(bottom: 10, left: 20),
                          width: width - 40,
                          height: 57,
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
                                  value: _status,
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
                                      _status = value!;
                                    });
                                  },
                                ),
                              )
                            ],
                          ));
                    }),
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      width: width,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      height: 60,
                      child: TextFormField(
                        initialValue: "0",
                        readOnly: true,
                        decoration: const InputDecoration(
                            labelText: "书籍数量",
                            hintText: "请输入书籍数量",
                            prefixIcon: Icon(
                              Icons.library_books,
                              size: 18,
                            )),
                        validator: (value) {
                          if (value!.trim().isEmpty) return "请输入书籍数量";
                          return null;
                        },
                      ),
                    ),
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
                            "/books/addBooks", (json) => {},
                            method: "post",
                            params: {
                              "name": _name,
                              "author": _author,
                              "illustrator": _illustrator,
                              "status": _status
                            });
                        if (baseResult.code == "2000") Navigator.of(context).pop();
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
