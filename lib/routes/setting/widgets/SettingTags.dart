import 'package:flutter/material.dart';

class SettingTags extends StatefulWidget {
  const SettingTags({super.key});

  @override
  State<SettingTags> createState() => SettingTagsState();
}

class SettingTagsState extends State<SettingTags> {
  @override
  Widget build(BuildContext context) {
    return const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text(
            "热门标签",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          )),
      Expanded(
          child: SingleChildScrollView(
        child: Wrap(
          children: [
            TagBox(num: 50, text: '还在完善中'),
            TagBox(num: 50, text: '还在完善中'),
            TagBox(num: 50, text: '还在完善中'),
            TagBox(num: 50, text: '还在完善中'),
            TagBox(num: 50, text: '还在完善中'),
            TagBox(num: 50, text: '还在完善中'),
            TagBox(num: 50, text: '还在完善中'),
            TagBox(num: 50, text: '还在完善中'),
            TagBox(num: 50, text: '还在完善中'),
            TagBox(num: 50, text: '还在完善中'),
            TagBox(num: 50, text: '还在完善中'),
            TagBox(num: 50, text: '还在完善中'),
            TagBox(num: 50, text: '还在完善中'),
            TagBox(num: 50, text: '还在完善中'),
            TagBox(num: 50, text: '还在完善中'),
            TagBox(num: 50, text: '还在完善中'),
            TagBox(num: 50, text: '还在完善中'),
            TagBox(num: 50, text: '还在完善中'),
            TagBox(num: 50, text: '还在完善中'),
            TagBox(num: 50, text: '还在完善中'),
            TagBox(num: 50, text: '还在完善中'),
            TagBox(num: 50, text: '还在完善中'),
            TagBox(num: 50, text: '还在完善中'),
            TagBox(num: 50, text: '还在完善中'),
            TagBox(num: 50, text: '还在完善中'),
            TagBox(num: 50, text: '还在完善中'),
            TagBox(num: 50, text: '还在完善中'),
            TagBox(num: 50, text: '还在完善中'),
            TagBox(num: 50, text: '还在完善中'),
            TagBox(num: 50, text: '还在完善中'),
            TagBox(num: 50, text: '还在完善中'),
            TagBox(num: 50, text: '还在完善中'),
            TagBox(num: 50, text: '还在完善中'),
            TagBox(num: 50, text: '还在完善中'),
            TagBox(num: 50, text: '还在完善中'),
            TagBox(num: 10, text: '这个是假数据')
          ],
        ),
      ))
    ]);
  }
}

class TagBox extends StatelessWidget {
  final String text;
  final int num;

  const TagBox({super.key, required this.text, required this.num});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Theme.of(context).primaryColorLight.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.only(right: 10, bottom: 10),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: Text("$text   $num"));
  }
}
