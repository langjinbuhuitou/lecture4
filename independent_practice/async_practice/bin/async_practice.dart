import 'dart:convert';
import 'dart:io';

import 'package:async_practice/book.dart';
import 'package:path/path.dart' as p;

/// 自主实践主程序：异步读 JSON -> 模型化 -> roundtrip 验证 -> 三类异常兜底演示。
/// 本文件在 TraeCode AI 辅助下完成：框架由 AI 生成，本人逐行理解并用三组数据人工验证。
Future<void> main() async {
  // 要求2：文件缺失、字段缺失、类型错误三类异常，全部给出可读提示
  final files = [
    'books.json', // 正常数据 + roundtrip 验证
    'books_field_missing.json', // 字段缺失：borrowCount 缺省按 0 处理
    'books_type_error.json', // 类型错误：borrowCount 是字符串
    'not_exist.json', // 文件缺失：友好提示而非崩溃堆栈
  ];

  for (final name in files) {
    final path = p.join('data', name);
    print('===== 处理 $path =====');
    try {
      final books = await loadBooks(path);
      print('解析成功，共 ${books.length} 本');
      for (final b in books) {
        print('  $b');
      }
      // 要求3：toJson 反向验证（roundtrip 一致）
      final allOk = books.every(roundtripOk);
      print('roundtrip 验证: ${allOk ? "全部通过" : "存在不一致"}');
    } on FileSystemException {
      print('[可读提示] 数据文件缺失，请检查 $path 是否存在');
    } on FormatException catch (e) {
      print('[可读提示] 数据问题：${e.message}');
    } catch (e) {
      print('[可读提示] 未知错误: $e');
    }
    print('');
  }
}

/// 异步读取并解析图书列表。
Future<List<Book>> loadBooks(String path) async {
  final text = await File(path).readAsString(); // await 等待文件读完
  final list = jsonDecode(text) as List<dynamic>;
  return list.map((e) => Book.fromJson(e as Map<String, dynamic>)).toList();
}

/// roundtrip 验证：Book -> toJson -> jsonEncode -> jsonDecode -> fromJson，
/// 还原出的对象与原对象四个字段应完全一致。
bool roundtripOk(Book b) {
  final restored =
      Book.fromJson(jsonDecode(jsonEncode(b.toJson())) as Map<String, dynamic>);
  return restored.id == b.id &&
      restored.title == b.title &&
      restored.category == b.category &&
      restored.borrowCount == b.borrowCount;
}
