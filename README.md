# lecture4

移动应用开发课程·第6周课堂作业四（Dart语言基础三：异步、异常与包管理）。

## 仓库结构

- `case_reproduction/async_json/`：课堂案例复现。异步读取 `data/books.json`，解析为 Book 模型并输出总数、各类目数量、借阅量 Top3；文件缺失时给出友好提示。
- `independent_practice/`：自主实践项目。async/await 改写回调、三类异常兜底、JSON 模型类 roundtrip 验证、pubspec 依赖规范。

## 运行方式

```bash
cd case_reproduction/async_json
dart pub get
dart run
```

```bash
cd independent_practice/async_practice
dart pub get
dart run
```

## 提交记录

按实践指南分步提交，详见 `git log`。
