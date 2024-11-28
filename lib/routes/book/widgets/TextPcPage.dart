import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:resourcemanager/routes/book/BookRead.dart';

class TextPcPage extends StatefulWidget {
  const TextPcPage({super.key, required this.list, required this.list2});

  final List<TextContent> list;
  final List<TextContent> list2;

  @override
  State<TextPcPage> createState() => TextPcPageState();
}

class TextPcPageState extends State<TextPcPage> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        item(widget.list),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: const BoxDecoration(color: Colors.grey),
          width: 1,
        ),
        item(widget.list2)
      ],
    );
  }

  Widget item(List<TextContent> list) {
    return Expanded(
        child: list.isEmpty
            ? const SizedBox()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: list[0].type == 3
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: list
                    .where((textContent) => textContent.type != 5)
                    .map((textContent) {
                  if (textContent.type == 1) {
                    return Text(
                      textContent.value,
                      style: const TextStyle(fontSize: 15),
                    );
                  } else if (textContent.type == 2) {
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
              ));
  }
}
