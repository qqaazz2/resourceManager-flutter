import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:resourcemanager/common/HttpApi.dart';
import 'package:resourcemanager/main.dart';
import 'package:resourcemanager/entity/BaseResult.dart';
import 'package:resourcemanager/models/picture/PictureList.dart';
import 'package:resourcemanager/state/picture/PictureListState.dart';
import 'package:resourcemanager/state/picture/PictureState.dart';

class PictureForm extends ConsumerStatefulWidget {
  const PictureForm(
      {super.key,
      required this.voidCallback,
      this.id,
      required this.currentValue});

  final VoidCallback voidCallback;
  final String? id;
  final int currentValue;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => PictureFormState();
}

class PictureFormState extends ConsumerState<PictureForm> {
  late PictureData pictureData;
  late TextEditingController nameController;
  late TextEditingController authorController;

  @override
  void initState() {
    super.initState();
  }

  Map<int, String> map = {1: "未展示", 2: "已展示", 3: "永不展示"};

  @override
  Widget build(BuildContext context) {
    ValueNotifier<bool> isEdit = ValueNotifier(false);
    // final pictureState =
    final pictureState = ref.watch(pictureStateProvider(widget.id));
    pictureData = pictureState.list[widget.currentValue];
    nameController = TextEditingController(text: pictureData.fileName);
    authorController = TextEditingController(text: pictureData.author);
    return Container(
      color: const Color(0xFF202124),
      height: double.infinity,
      width: 300,
      child: DefaultTextStyle(
        style: const TextStyle(color: Colors.white),
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 50, horizontal: 10),
                child: Form(
                    child: Column(
                  children: [
                    ValueListenableBuilder(
                        valueListenable: isEdit,
                        builder: (context, value, child) {
                          return Column(
                            children: [
                              TextFormField(
                                style: const TextStyle(color: Colors.white),
                                maxLines: 1,
                                maxLength: 200,
                                readOnly: value == false,
                                decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.title),
                                    hintText: "请输入图片名称",
                                    labelText: "图片名称",
                                    labelStyle: TextStyle(color: Colors.white)),
                                validator: (v) =>
                                    v!.trim().isNotEmpty ? null : "文件名称不可为空",
                                controller: nameController,
                              ),
                              TextFormField(
                                style: const TextStyle(color: Colors.white),
                                maxLines: 1,
                                maxLength: 30,
                                readOnly: value == false,
                                decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.person),
                                    hintText: "请输入画师/作者",
                                    labelText: "画师/作者",
                                    labelStyle: TextStyle(color: Colors.white)),
                                controller: authorController,
                              ),
                              if (value)
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    ElevatedButton(
                                        onPressed: () => isEdit.value = false,
                                        child: const Text("退出编辑")),
                                    Builder(builder: (context) {
                                      return ElevatedButton(
                                          onPressed: () =>
                                              editData(context, pictureData.id),
                                          child: const Text("编辑保存"));
                                    })
                                  ],
                                )
                            ],
                          );
                        }),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                            onPressed: () => isEdit.value = true,
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.white,
                            )),
                        IconButton(
                            icon: Icon(
                              Icons.star,
                              color: pictureData.love == 2
                                  ? Colors.white
                                  : Colors.red,
                            ),
                            onPressed: () => ref
                                .read(pictureStateProvider(widget.id).notifier)
                                .setLove(widget.currentValue))
                      ],
                    ),
                    getListTitle(
                        const Icon(Icons.dashboard),
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: const Text("每日随机"),
                        ),
                        DropdownMenu(
                          width: 200,
                          textStyle: const TextStyle(color: Colors.white),
                          dropdownMenuEntries: _buildMenuList(),
                          initialSelection: pictureData.display,
                          onSelected: (value) => ref
                              .read(pictureStateProvider(widget.id).notifier)
                              .setDisplay(pictureData.id, value),
                        )),
                    getListTitle(
                        const Icon(Icons.all_inbox),
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: const Text("大小信息"),
                        ),
                        getSizeWidget()),
                    getListTitle(
                        const Icon(Icons.date_range),
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: const Text("创建时间"),
                        ),
                        Text(pictureData.createTime ?? ""))
                  ],
                )),
              ),
              Positioned(
                  right: 0,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      size: 30,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ))
            ],
          ),
        ),
      ),
    );
  }

  Widget getListTitle(Icon icon, Widget title, Widget content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: ListTile(
        titleAlignment: ListTileTitleAlignment.titleHeight,
        titleTextStyle: const TextStyle(fontSize: 15),
        subtitleTextStyle: const TextStyle(color: Colors.white),
        iconColor: Colors.white,
        textColor: Colors.white,
        leading: icon,
        subtitle: content,
        title: title,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget getSizeWidget() {
    return Text.rich(TextSpan(children: [
      TextSpan(text: "${pictureData.width}x${pictureData.height}  "),
      TextSpan(
          text:
              "${(pictureData.fileSize / (1024 * 1024)).toDouble().toStringAsFixed(2)}MB "),
      TextSpan(text: "${pictureData.mp}MP "),
    ]));
  }

  List<DropdownMenuEntry<int>> _buildMenuList() {
    List<DropdownMenuEntry<int>> list = [];
    map.forEach((v, k) {
      list.add(DropdownMenuEntry(value: v, label: k));
    });
    return list;
  }

  void editData(BuildContext context, current) {
    bool status = Form.of(context).validate();
    if (status) {
      ref
          .read(pictureStateProvider(widget.id).notifier)
          .editData(current, nameController.text, authorController.text);
    }
  }
}
