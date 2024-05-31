import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:resourcemanager/models/GetBooksList.dart';

import '../../common/HttpApi.dart';
import '../../models/BaseResult.dart';
import 'BooksDetails.dart';

class BooksList extends StatefulWidget {
  const BooksList({super.key});

  @override
  State<StatefulWidget> createState() => BooksListState();
}

class BooksListState extends State<BooksList> {
  Data books = BooksDetailsState.booksState.books;
  void upload() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['epub']);
    if (result!.count > 0) {
      List<MultipartFile> files = [];
      for (PlatformFile platformFile in result.files) {
        List<int> fileBytes = platformFile.bytes!;
        MultipartFile file = MultipartFile.fromBytes(
          fileBytes,
          filename: platformFile.name, // 文件名
        );
        files.add(file);
      }

      FormData formData = FormData.fromMap({
        'files': files,
        'name': books.name,
        'id': books.id,
      });
      BaseResult baseResult = await HttpApi.request(
          "/booksDetails/upload", (json) => {},
          method: "post", formData: formData);
      if (baseResult.code == "2000") {

      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text.rich(TextSpan(
                children: [TextSpan(text: "该系列图书有(册)："), TextSpan(text: "0")])),
            OutlinedButton.icon(
              onPressed: () => upload(),
              label: const Text("上传书籍"),
              icon: const Icon(Icons.add_link),
            ),
          ],
        ),
        Expanded(child: Text("123"))
      ],
    );
  }
}
