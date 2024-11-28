import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:resourcemanager/routes/book/BookRead.dart';

class TextPage extends StatefulWidget {
  const TextPage({super.key, required this.list});

  final List<TextContent> list;

  @override
  State<TextPage> createState() => TextPageState();
}

class TextPageState extends State<TextPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.list
          .where((textContent) => textContent.type != 5)
          .map((textContent) {
        if (textContent.type == 1) {
          return Text(
            textContent.value,
            style: const TextStyle(fontSize: 15),
          );
        } else if (textContent.type == 2) {
          print(textContent.value);
          return Text(
            textContent.value,
            style: const TextStyle(fontSize: 30),
          );
        } else if (textContent.type == 3) {
          return Expanded(
              child: Center(
            child: Image.file(File(textContent.value)),
          ));
        } else {
          return const Text("");
        }
      }).toList(),
    );
  }
}
