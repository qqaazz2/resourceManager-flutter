import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:resourcemanager/common/HttpApi.dart';
import 'package:resourcemanager/main.dart';
import 'package:resourcemanager/entity/BaseResult.dart';
import 'package:resourcemanager/models/GetBooksDetailsList.dart';
import 'package:resourcemanager/state/BooksState.dart';

class BooksContent extends StatefulWidget {
  const BooksContent({super.key});

  @override
  State<StatefulWidget> createState() => BooksContentState();
}

class BooksContentState extends State<BooksContent> {
  @override
  Widget build(BuildContext context) {
    BooksState booksState = Provider.of<BooksState>(context);
    Details details = booksState.details;
    bool sort = false;
    return Form(
        child: SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          SingleChildScrollView(
            child: LayoutBuilder(builder: (context, constraints) {
              double width = constraints.maxWidth > MyApp.width
                  ? constraints.maxWidth / 2
                  : constraints.maxWidth;
              return Padding(
                  padding: const EdgeInsets.only(bottom: 60),
                  child: Wrap(alignment: WrapAlignment.spaceBetween, children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      width: width,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      height: 60,
                      child: TextFormField(
                          initialValue: details.name,
                          decoration: const InputDecoration(
                              labelText: "书籍名称",
                              hintText: "请输入书籍名称",
                              prefixIcon: Icon(
                                Icons.book_rounded,
                                size: 18,
                              )),
                          validator: (value) {
                            if (value!.trim().isEmpty) return "请输入书籍名称";
                            return null;
                          },
                          onSaved: (value) => details.name = value!),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      width: width,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      height: 60,
                      child: TextFormField(
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp("[0-9.]")),
                          ],
                          keyboardType: TextInputType.number,
                          initialValue: details.sort.toString(),
                          decoration: const InputDecoration(
                              labelText: "序号",
                              hintText: "请输入序号",
                              prefixIcon: Icon(
                                Icons.sort,
                                size: 18,
                              )),
                          validator: (value) {
                            if (value!.trim().isEmpty) return "请输入序号";
                            return null;
                          },
                          onSaved: (value) {
                            if(details.sort != int.parse(value!))sort = true;
                            details.sort = int.parse(value);
                          }),
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
                                  value: details.status,
                                  underline: Container(height: 0),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 1,
                                      child: Text('未读'),
                                    ),
                                    DropdownMenuItem(
                                      value: 2,
                                      child: Text('已读'),
                                    ),
                                    DropdownMenuItem(
                                      value: 3,
                                      child: Text('在读'),
                                    )
                                  ],
                                  onChanged: (int? value) {
                                    _setState(() {
                                      details.status = value!;
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
                        // initialValue: details.readTime,
                        readOnly: true,
                        decoration: const InputDecoration(
                            labelText: "阅读时间",
                            prefixIcon: Icon(
                              Icons.access_time,
                              size: 18,
                            )),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      width: width,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      height: 60,
                      child: TextFormField(
                        initialValue: details.url,
                        readOnly: true,
                        decoration: const InputDecoration(
                            labelText: "书籍路径",
                            prefixIcon: Icon(
                              Icons.link,
                              size: 18,
                            )),
                      ),
                    ),
                  ]));
            }),
          ),
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
                            "/booksDetails/edit", (json) => json,
                            method: "post",
                            params: {
                              "id": details.id,
                              "name": details.name,
                              "sort": details.sort,
                              "status": details.status,
                            });
                        if (baseResult.code == "2000") {
                          booksState.changeDetailsState(sort: sort);
                          Navigator.of(context).pop();
                        }
                      }
                    },
                    child: const Text("保存"));
              },
            ),
          )
        ],
      ),
    ));
  }
}
