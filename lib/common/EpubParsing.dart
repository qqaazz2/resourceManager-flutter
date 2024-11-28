import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:xml/xml.dart';

class EpubParsing {
  late final files;
  Future<List<String>?> parseEpubFromBytes(List<int> epubBytes) async {
    try {
      // 1. 解压二进制流
      files = await extractEpubFromBytes(epubBytes);

      // 2. 定位 content.opf
      final opfPath = locateOpfFile(files);

      // 3. 解析 content.opf
      final opfContent = utf8.decode(files[opfPath]!);
      final opfData = parseOpf(opfContent);

      // // 4. 读取章节内容
      final chapters =
          readChapters(files, opfData['manifest'], opfData['spine']);
      //
      // 输出章节内容
      return chapters;
    } catch (e) {
      print('Error: $e');
    }
    return null;
  }

  Future<Map<String, List<int>>> extractEpubFromBytes(
      List<int> epubBytes) async {
    final archive = ZipDecoder().decodeBytes(epubBytes);
    final extractedFiles = <String, List<int>>{};

    for (final file in archive) {
      if (file.isFile) {
        extractedFiles[file.name] = file.content as List<int>;
      }
    }

    return extractedFiles;
  }

  String locateOpfFile(Map<String, List<int>> files) {
    final containerPath = 'META-INF/container.xml';
    if (!files.containsKey(containerPath)) {
      throw Exception('container.xml not found!');
    }

    final containerContent = utf8.decode(files[containerPath]!);
    final document = XmlDocument.parse(containerContent);
    final opfPath =
        document.findAllElements('rootfile').first.getAttribute('full-path');
    if (opfPath == null) {
      throw Exception('OPF file path not found in container.xml!');
    }

    return opfPath;
  }

  Map<String, dynamic> parseOpf(String opfContent) {
    final document = XmlDocument.parse(opfContent);

    // 解析 manifest
    Map<String, String> manifest = {};
    for (final item in document.findAllElements('item')) {
      final id = item.getAttribute('id');
      final href = item.getAttribute('href');
      if (id != null && href != null) {
        manifest[id] = href;
      }
    }
    manifest.forEach((key, value) {
      print(value);
    });
    // 解析 spine
    final spine = document
        .findAllElements('itemref')
        .map((itemRef) {
          return itemRef.getAttribute('idref');
        })
        .where((idref) => idref != null)
        .toList();

    return {'manifest': manifest, 'spine': spine};
  }

  List<String> readChapters(
    Map<String, List<int>> files,
    Map<String, String> manifest,
    List<String?> spine,
  ) {
    final chapters = <String>[];

    for (final idref in spine) {
      String? relativePath = manifest[idref];
      if (relativePath == null) {
        print('Warning: idref $idref not found in manifest.');
        continue;
      }

      relativePath = Uri.decodeFull(relativePath);
      print(relativePath);
      final chapterFile = files["OEBPS/$relativePath"];
      if (chapterFile == null) {
        print('Warning: Chapter file not found: $relativePath');
        continue;
      }

      final content = utf8.decode(chapterFile);
      chapters.add(content);
    }

    return chapters;
  }

  List<int>? getImage(String path){
    return files["OEBPS/$path"];
  }
}