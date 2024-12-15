import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:resourcemanager/entity/book/SeriesItem.dart';
import 'package:resourcemanager/entity/comic/ComicSetDetail.dart';
import 'package:resourcemanager/main.dart';
import 'package:resourcemanager/state/book/SeriesContentState.dart';
import 'package:resourcemanager/state/book/SeriesListState.dart';
import 'package:resourcemanager/state/comic/ComicSetDetailState.dart';
import 'package:resourcemanager/state/comic/ComicSetListState.dart';
import 'package:resourcemanager/widgets/ListTitleWidget.dart';

class ComicSetForm extends ConsumerStatefulWidget {
  const ComicSetForm({super.key, required this.index, required this.id});

  final int index;
  final int id;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => ComicSetFormState();
}

class ComicSetFormState extends ConsumerState<ComicSetForm> {
  Map<int, String> overMap = {1: "连载中", 2: "完结", 3: "有生之年", 4: "弃坑"};
  Map<int, String> readMap = {1: "未读", 2: "已读", 3: "在读"};

  List<DropdownMenuEntry<int>> _buildMenuList(map) {
    List<DropdownMenuEntry<int>> list = [];
    map.forEach((v, k) {
      list.add(DropdownMenuEntry(value: v, label: k));
    });
    return list;
  }

  Future<void> editData(
      BuildContext context, ComicSetDetail comicSetDetail, int index) async {
    bool status = Form.of(context).validate();
    if (status) {
      try {
        Form.of(context).save();
        if (index != -1) {
          await ref
              .read(comicSetListStateProvider.notifier)
              .updateData(comicSetDetail, index);
        }else{
          await ref.read(comicSetDetailStateProvider.notifier).updateData(comicSetDetail);
        }
        Navigator.of(context).pop();
      } catch (error) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: ref
            .read(comicSetListStateProvider.notifier)
            .getDetail(widget.id, widget.index),
        builder:
            (BuildContext context, AsyncSnapshot<ComicSetDetail?> snapshot) {
          // 请求已结束
          if (snapshot.connectionState == ConnectionState.done) {
            return MediaQuery.of(context).size.width > MyApp.width
                ? SimpleDialog(
                    children: [getForm(snapshot.data!)],
                  )
                : getForm(snapshot.data!);
          } else {
            // 请求未结束，显示loading
            return const Align(
              child: SizedBox(
                width: 150,
                height: 150,
                child: CircularProgressIndicator(),
              ),
            );
          }
        });
  }

  Widget getForm(ComicSetDetail comicSetDetail) {
    double size =
        MediaQuery.of(context).size.width > MyApp.width ? 600 : double.infinity;
    return Container(
      color: Theme.of(context).dialogBackgroundColor,
      height: size,
      padding: const EdgeInsets.only(right: 20, left: 20, bottom: 20),
      width: size,
      child: Form(
          child: Column(
        children: [
          Container(
              width: size,
              margin: const EdgeInsets.only(top: 5, bottom: 20),
              child: const Text(
                "修改详情",
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 25),
              )),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text("漫画数量:${comicSetDetail.comicCount}"),
            ),
            Text("最后阅读时间:${comicSetDetail.lastReadTime ?? "无"}"),
          ]),
          Expanded(
              child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                    initialValue: comicSetDetail.name,
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
                    onSaved: (value) => comicSetDetail.name = value!,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                    initialValue: comicSetDetail.author,
                    decoration: const InputDecoration(
                        labelText: "系列作者",
                        hintText: "请输入系列作者",
                        prefixIcon: Icon(
                          Icons.person,
                          size: 18,
                        )),
                    onSaved: (value) => comicSetDetail.author = value,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                    initialValue: comicSetDetail.note,
                    maxLines: 5,
                    decoration: const InputDecoration(
                        labelText: "系列概要",
                        hintText: "请输入系列概要",
                        prefixIcon: Icon(
                          Icons.note,
                          size: 18,
                        )),
                    onSaved: (value) => comicSetDetail.note = value,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                    initialValue: comicSetDetail.press,
                    decoration: const InputDecoration(
                        labelText: "系列出版社",
                        hintText: "请输入系列出版社",
                        prefixIcon: Icon(
                          Icons.bookmark,
                          size: 18,
                        )),
                    onSaved: (value) => comicSetDetail.press = value,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                    initialValue: comicSetDetail.language,
                    decoration: const InputDecoration(
                        labelText: "系列语言",
                        hintText: "请输入系列语言",
                        prefixIcon: Icon(
                          Icons.language,
                          size: 18,
                        )),
                    onSaved: (value) => comicSetDetail.language = value,
                  ),
                ),
                ListTitleWidget(
                    icon: const Icon(Icons.favorite),
                    title: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Text("收藏状态",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          )),
                    ),
                    content: DropdownMenu(
                      width: 200,
                      dropdownMenuEntries: _buildMenuList({1: "未收藏", 2: "已收藏"}),
                      initialSelection: comicSetDetail.love,
                      onSelected: (value) => comicSetDetail.love = value!,
                    )),
                ListTitleWidget(
                    icon: const Icon(Icons.update),
                    title: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Text("连载状态",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface)),
                    ),
                    content: DropdownMenu(
                      width: 200,
                      dropdownMenuEntries: _buildMenuList(overMap),
                      initialSelection: comicSetDetail.status,
                      onSelected: (value) => comicSetDetail.status = value!,
                    )),
                ListTitleWidget(
                    icon: const Icon(Icons.menu_book),
                    title: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Text("阅读状态",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          )),
                    ),
                    content: DropdownMenu(
                      width: 200,
                      dropdownMenuEntries: _buildMenuList(readMap),
                      initialSelection: comicSetDetail.readStatus,
                      onSelected: (value) => comicSetDetail.readStatus = value!,
                    )),
              ],
            ),
          )),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("取消")),
              Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Builder(builder: (context) {
                    return ElevatedButton(
                        onPressed: () =>
                            editData(context, comicSetDetail, widget.index),
                        child: const Text("确认"));
                  }))
            ],
          )
        ],
      )),
    );
  }
}
