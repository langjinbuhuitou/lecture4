/// 图书模型类，字段与统一数据集一致：id、title、category、borrowCount。
/// fromJson/toJson 手写，不依赖代码生成。
class Book {
  final String id, title, category;
  final int borrowCount;

  Book({
    required this.id,
    required this.title,
    required this.category,
    required this.borrowCount,
  });

  factory Book.fromJson(Map<String, dynamic> j) => Book(
        id: j['id'] as String,
        title: j['title'] as String,
        category: j['category'] as String,
        // JSON 数字可能是 int 或 double，先断言为 num 再 toInt 最稳；
        // 字段缺失时默认 0，避免 null 断言崩溃
        borrowCount: (j['borrowCount'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'borrowCount': borrowCount,
      };
}
