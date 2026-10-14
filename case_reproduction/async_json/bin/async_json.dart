import 'dart:convert';
import 'dart:io';

import 'package:async_json/book.dart';
import 'package:path/path.dart' as p;

/// 课堂案例 async_json 步骤二：异步读取 data/books.json，解析为模型并汇总输出。
Future<void> main() async {
  final file = File(p.join('data', 'books.json'));

  // await 等待文件读完，但不阻塞事件循环
  final text = await file.readAsString();
  final list = jsonDecode(text) as List<dynamic>;
  final books =
      list.map((e) => Book.fromJson(e as Map<String, dynamic>)).toList();

  // 1. 总数
  print('图书总数: ${books.length}');

  // 2. 各类目数量（Map 统计）
  final counts = <String, int>{};
  for (final b in books) {
    counts[b.category] = (counts[b.category] ?? 0) + 1;
  }
  print('各类目数量:');
  counts.forEach((category, n) => print('  $category: $n 本'));

  // 3. 借阅量 Top3
  final sorted = [...books]
    ..sort((a, b) => b.borrowCount.compareTo(a.borrowCount));
  print('借阅量 Top3:');
  for (final b in sorted.take(3)) {
    print('  ${b.title}（${b.category}，${b.borrowCount} 次）');
  }
}
