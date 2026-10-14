import 'dart:convert';
import 'dart:io';

import 'package:async_json/book.dart';
import 'package:path/path.dart' as p;

/// 课堂案例 async_json 步骤三：异常路径处理。
/// 文件缺失时给出友好提示而不是崩溃堆栈；JSON 解析失败也有可读信息。
Future<void> main() async {
  final path = p.join('data', 'books.json');
  try {
    // await 等待文件读完，但不阻塞事件循环
    final text = await File(path).readAsString();
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
  } on FileSystemException {
    // 精确捕获：文件读不了
    print('数据文件缺失，请检查data/books.json');
  } catch (e) {
    // 兜底：JSON 格式错误等其他问题
    print('数据格式有误，解析失败: $e');
  } finally {
    // 无论成败都执行（本案例无需额外清理）
  }
}
