import 'dart:async';

/// 自主实践要求1：把嵌套回调版程序改写为顺序 await 版。
/// 场景自拟：读配置 -> 按配置读数据 -> 统计输出。
/// 本文件在 TraeCode AI 辅助下完成：改写思路由 AI 建议，本人核对运行结果一致。

// ---------- 改写前：嵌套回调版（作业页附的写法风格） ----------

void loadConfigCallback(void Function(String config) onDone) {
  Timer(const Duration(milliseconds: 300), () => onDone('config-v1'));
}

void loadDataCallback(String config, void Function(List<int> data) onDone) {
  Timer(const Duration(milliseconds: 300), () => onDone([10, 20, 30]));
}

void runCallbackVersion() {
  print('--- 回调版（改写前） ---');
  loadConfigCallback((config) {
    print('回调: 拿到配置 $config');
    loadDataCallback(config, (data) {
      print('回调: 拿到数据 $data');
      final total = data.fold<int>(0, (a, b) => a + b);
      print('回调: 统计结果 total=$total');
    });
  });
}

// ---------- 改写后：顺序 await 版 ----------

Future<String> loadConfig() async {
  await Future.delayed(const Duration(milliseconds: 300));
  return 'config-v1';
}

Future<List<int>> loadData(String config) async {
  await Future.delayed(const Duration(milliseconds: 300));
  return [10, 20, 30];
}

Future<void> runAwaitVersion() async {
  print('--- await 版（改写后） ---');
  final config = await loadConfig(); // 等待但不阻塞事件循环
  print('await: 拿到配置 $config');
  final data = await loadData(config);
  print('await: 拿到数据 $data');
  final total = data.fold<int>(0, (a, b) => a + b);
  print('await: 统计结果 total=$total');
}

Future<void> main() async {
  runCallbackVersion();
  // 回调版是定时器触发的，先等它跑完再演示 await 版，避免输出交错
  await Future.delayed(const Duration(seconds: 1));
  await runAwaitVersion();
}
