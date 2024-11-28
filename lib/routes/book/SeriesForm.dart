import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:resourcemanager/entity/book/SeriesItem.dart';
import 'package:resourcemanager/main.dart';
import 'package:resourcemanager/state/book/SeriesContentState.dart';
import 'package:resourcemanager/state/book/SeriesListState.dart';
import 'package:resourcemanager/widgets/ListTitleWidget.dart';

class SeriesForm extends ConsumerStatefulWidget {
  SeriesForm(
      {super.key,
      required this.seriesItem,
      required this.index,
      this.seriesId = -1});

  SeriesItem seriesItem;
  int index;
  int seriesId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => SeriesFormState();
}

class SeriesFormState extends ConsumerState<SeriesForm> {
  Map<int, String> overMap = {1: "连载中", 2: "完结", 3: "弃坑"};
  Map<int, String> readMap = {1: "未读", 2: "已读", 3: "在读"};

  List<DropdownMenuEntry<int>> _buildMenuList(map) {
    List<DropdownMenuEntry<int>> list = [];
    map.forEach((v, k) {
      list.add(DropdownMenuEntry(value: v, label: k));
    });
    return list;
  }

  Future<void> editData(
      BuildContext context, SeriesItem seriesItem, int index) async {
    bool status = Form.of(context).validate();
    if (status) {
      try {
        Form.of(context).save();
        if (widget.seriesId == -1) {
          await ref
              .read(seriesListStateProvider.notifier)
              .updateData(seriesItem, index);
        } else {
          await ref
              .read(seriesContentStateProvider(widget.seriesId).notifier)
              .updateData(seriesItem);
        }
        Navigator.of(context).pop();
      } catch (error) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.seriesId == -1) {
      final state = ref.watch(seriesListStateProvider);
    } else {
      final state = ref.watch(seriesContentStateProvider(widget.seriesId));
    }
    // SeriesItem seriesItem =
    return MediaQuery.of(context).size.width > MyApp.width
        ? SimpleDialog(
            children: [getForm()],
          )
        : getForm();
  }

  Widget getForm() {
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
              child: GestureDetector(
                  onTap: () => {
                        if (widget.seriesId == -1)
                          {
                            ref
                                .read(seriesListStateProvider.notifier)
                                .setLove(widget.index)
                          }
                        else
                          {
                            ref
                                .read(
                                    seriesContentStateProvider(widget.seriesId)
                                        .notifier)
                                .setLove()
                          }
                      },
                  child: Icon(
                    widget.seriesItem.love == 1
                        ? Icons.favorite_border
                        : Icons.favorite,
                    size: 25,
                    color: Colors.redAccent,
                  )),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text("书籍数量:${widget.seriesItem.num}"),
            ),
            Text("最后阅读时间:${widget.seriesItem.lastReadTime ?? "无"}"),
          ]),
          Expanded(
              child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                    initialValue: widget.seriesItem.name,
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
                    onSaved: (value) => widget.seriesItem.name = value!,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                    initialValue: widget.seriesItem.author,
                    decoration: const InputDecoration(
                        labelText: "系列作者",
                        hintText: "请输入系列作者",
                        prefixIcon: Icon(
                          Icons.person,
                          size: 18,
                        )),
                    onSaved: (value) => widget.seriesItem.author = value,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                    maxLines: 5,
                    initialValue: widget.seriesItem.profile,
                    decoration: const InputDecoration(
                        labelText: "系列简介",
                        hintText: "请输入系列简介",
                        prefixIcon: Icon(
                          Icons.content_paste_rounded,
                          size: 18,
                        )),
                    onSaved: (value) => widget.seriesItem.profile = value,
                  ),
                ),
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
                      initialSelection: widget.seriesItem.overStatus,
                      onSelected: (value) =>
                          widget.seriesItem.overStatus = value!,
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
                      initialSelection: widget.seriesItem.status,
                      onSelected: (value) => widget.seriesItem.status = value!,
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
                            editData(context, widget.seriesItem, widget.index),
                        child: const Text("确认"));
                  }))
            ],
          )
        ],
      )),
    );
  }
}
