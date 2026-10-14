/// 图书模型类（自主实践版），字段与统一数据集一致：id、title、category、borrowCount。
/// 本文件在 TraeCode AI 辅助下完成：由 AI 给出初稿，本人逐行核对并运行验证。
class Book {
  final String id, title, category;
  final int borrowCount;

  Book({
    required this.id,
    required this.title,
    required this.category,
    required this.borrowCount,
  });

  /// 从 JSON Map 构造 Book。
  /// 异常约定（自主实践要求2：三类异常都要有可读提示）：
  /// - 字段缺失：borrowCount 缺失时默认 0 并提示；其余关键字段缺失抛 FormatException（可读信息）；
  /// - 类型错误：borrowCount 不是数字时抛 FormatException，说明字段名与实际类型/值。
  factory Book.fromJson(Map<String, dynamic> j) {
    for (final key in ['id', 'title', 'category']) {
      if (j[key] == null) {
        throw FormatException('字段缺失: $key（记录: ${j['id'] ?? '未知id'}）');
      }
    }

    final raw = j['borrowCount'];
    final int count;
    if (raw == null) {
      print('  [提示] ${j['id']} 缺少 borrowCount 字段，按 0 处理');
      count = 0;
    } else if (raw is num) {
      // JSON 数字可能是 int 或 double，统一经 num 转换最稳
      count = raw.toInt();
    } else {
      throw FormatException(
          '字段类型错误: borrowCount 应为数字，实际是 ${raw.runtimeType}（值: $raw，记录: ${j['id']}）');
    }

    return Book(
      id: j['id'] as String,
      title: j['title'] as String,
      category: j['category'] as String,
      borrowCount: count,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'borrowCount': borrowCount,
      };

  @override
  String toString() => '$title（$category，$borrowCount 次）';
}
