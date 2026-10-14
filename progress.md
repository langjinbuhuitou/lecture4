# 进度报告4（第6周·Dart语言基础三：异步、异常与包管理）

> 本文件与雨课堂提交的进度报告内容一致。运行截图未推送到本仓库，随报告单独提交，文中以【截图0X】标注对应位置。

## 一、任务理解

本次作业的必做内容分两块。一是案例复现：跟着实践指南把课堂案例 async_json 完整复现一遍——用 dart create 建项目、dart pub add path 加依赖、把统一数据集 books.json 放到 data/ 目录，实现 Book.fromJson 解析并输出图书总数、各类目数量、借阅量 Top3，最后补上文件缺失的友好报错，每一步对应一次 Git 提交。验收标准是：正常路径统计输出正确，文件缺失路径输出友好提示而不是崩溃堆栈。二是自主实践：在独立文件夹里另建一个项目，完成五项基本要求——把嵌套回调版程序改写成顺序 await 版；文件缺失、字段缺失、类型错误三类异常都有可读提示；JSON 完整字段模型化并做 toJson 的 roundtrip 反向验证；pubspec 依赖全部用 ^ 约束、无冗余依赖、锁定文件已提交；代码里标注 AI 使用情况。独立研究任务（选做）本次不做。

## 二、环境与工具

Windows 11（64 位），Dart SDK 3.13.4，运行目标是命令行程序（终端里 dart run）。编辑器用 VS Code，AI 工具是 TraeCode。远程仓库建在 GitHub（langjinbuhuitou/lecture4）。pub 国内镜像第1课已配好，dart pub add 走镜像下载正常。

## 三、过程记录

1. 在仓库里建 case_reproduction 文件夹，dart create async_json 建案例项目，dart pub add path 加依赖，把统一数据集 books.json（10 条图书记录）复制到 data/ 目录，第一次提交 "feat: dataset & deps ready"。
2. 写 lib/book.dart 的 Book 模型和 bin/async_json.dart 主程序，实现异步读取、jsonDecode 解析、Map 统计各类目数量、排序取 Top3，跑通正常路径后第二次提交 "feat: parse & stats from books.json"。
3. 做故意实验：手工删掉 B004《活着》的 borrowCount 字段，运行后直接崩 TypeError；在 fromJson 里把断言改成可空断言加默认值 0，再跑恢复正常，《活着》按 0 次处理掉出 Top3。再把 books.json 改名验证文件缺失路径，输出"数据文件缺失，请检查data/books.json"。两条路径都确认后第三次提交 "feat: robust missing-field & file handling"。
4. 建 independent_practice 文件夹，dart create async_practice，加 path 依赖，准备三组测试数据（正常、缺字段、类型错误）。
5. 写 bin/callback_vs_await.dart：先按嵌套回调风格写"读配置→读数据→统计"，再改写成顺序 await 版，两个版本输出完全一致。
6. 写主程序 bin/async_practice.dart，一个程序依次处理四个数据文件，把三类异常的可读提示和 roundtrip 验证一次演示完，dart analyze 无警告。分两次提交（"feat: practice project & deps ready"、"feat: callback rewrite & robust json practice"）。
7. git push 到 GitHub，截图取证，写报告。

## 四、关键代码

**代码段1：Book.fromJson（自主实践版，independent_practice/async_practice/lib/book.dart）**

```dart
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
```

逐行解释：jsonDecode 返回的是 dynamic，所以每个字段都要自己断言。开头循环检查 id/title/category 三个关键字段，缺了就直接抛 FormatException 并写明缺哪个、是哪条记录。borrowCount 单独处理：为 null 说明字段缺失，不致命，打印提示后按 0 处理；是 num 就 toInt（JSON 数字可能是 int 或 double，经 num 转换最稳）；其他类型说明数据写错了，抛 FormatException，把字段名、实际类型、值、记录 id 都写进提示方便定位。这段由 TraeCode 生成初稿，我自己喂了正常、缺字段、类型错误三组数据，确认三个分支都按预期走。

**代码段2：异常兜底结构（bin/async_practice.dart 的 main 局部）**

```dart
try {
  final books = await loadBooks(path);
  ...
} on FileSystemException {
  print('[可读提示] 数据文件缺失，请检查 $path 是否存在');
} on FormatException catch (e) {
  print('[可读提示] 数据问题：${e.message}');
} catch (e) {
  print('[可读提示] 未知错误: $e');
}
```

逐行解释：await 处的异步异常会沿 Future 传播到这里被接住。on FileSystemException 精确捕获文件读不了的情况；on FormatException 接 fromJson 主动抛出的数据问题；最后的 catch 兜底，保证任何意外都不会裸抛堆栈给用户。验证方式：把不存在的 not_exist.json 传进去确认走第一个分支，喂类型错误的文件确认走第二个分支。

**代码段3：roundtrip 反向验证（bin/async_practice.dart）**

```dart
bool roundtripOk(Book b) {
  final restored =
      Book.fromJson(jsonDecode(jsonEncode(b.toJson())) as Map<String, dynamic>);
  return restored.id == b.id &&
      restored.title == b.title &&
      restored.category == b.category &&
      restored.borrowCount == b.borrowCount;
}
```

解释：把对象 toJson 成 Map，jsonEncode 成字符串，再 jsonDecode 回来 fromJson，四个字段全相等才算通过，用来验证 fromJson/toJson 是互逆的。6 本书全部验证通过。这段是 TraeCode 建议的验证思路，我核对过逻辑并实际运行确认。

## 五、检查点结果

- 正常路径：async_json 输出"图书总数: 10"，各类目数量为 编程3、文学2、历史2、科幻2、科普1，借阅量 Top3 是 三体（60）、活着（52）、Dart编程实战（45），和我手工对着 books.json 数出来的结果一致。【截图01】
- 文件缺失路径：把 data/books.json 改名后运行，输出"数据文件缺失，请检查data/books.json"，程序正常结束，没有崩溃堆栈。恢复文件后正常路径再次验证通过。【截图04】
- await 在案例中的作用：readAsString 返回的是 Future<String>，await 等它真正读完拿到字符串，同时不阻塞事件循环；如果忘了写 await，拿到的只是 Future 对象而不是字符串内容，是本课最高频错误。

## 六、问题与调试

问题1（真实记录）：做故意实验删掉 B004 的 borrowCount 后，程序崩在 book.dart 的 fromJson，报 "TypeError: Null is not a subtype of type 'num' in type cast"。定位过程：看堆栈最上面一行指向 `(j['borrowCount'] as num).toInt()`，意识到字段被删后 j['borrowCount'] 取到的是 null，null 不能做 as num 断言。解决：改成 `(j['borrowCount'] as num?)?.toInt() ?? 0`——先断言成可空 num，空调用链短路，最后用 ?? 给默认值 0。修复后《活着》按 0 次计入，掉出 Top3，符合预期。【截图02 崩溃堆栈、截图03 修复后输出】

问题2：第一次截 git log 时，cmd 里 git 默认调 more 分页器，这个环境里没有 more，直接报 "unable to execute pager 'more'"。改用 git --no-pager log --oneline 后正常显示。【截图07】

## 七、AI使用记录

全部使用 TraeCode，用途与验证方式如下：

1. 用途：搭 async_json 案例骨架。指令摘要："按实践指南建 async_json 项目，三步分步提交"。输出：项目结构、book.dart、主程序。验证：每一步自己 dart run 跑一遍，统计结果手工对照 books.json 数过一遍。
2. 用途：修复缺字段崩溃。指令摘要："删掉 borrowCount 字段后报 Null is not a subtype of num，怎么改"。输出：可空断言加默认值的写法及解释。验证：改完重跑，确认不再崩溃且该书记为 0 次。
3. 用途：自主实践回调改写。指令摘要："把读配置→读数据→统计的嵌套回调改写成 await 版"。输出：callback_vs_await.dart 两版对照。验证：两版都运行，输出逐行一致。
4. 用途：roundtrip 验证思路。指令摘要："怎么验证 toJson 和 fromJson 互逆"。输出：encode→decode→fromJson 再比四个字段的方案。验证：6 条测试数据全部通过。

代码文件头部都按作业要求写了 AI 辅助标注注释（"本文件在 TraeCode AI 辅助下完成，本人已逐行理解并人工验证"）。

## 八、证据截图

- 【截图01】async_json 正常路径输出：总数 10、各类目数量、借阅量 Top3。
- 【截图02】故意删掉 borrowCount 后的崩溃堆栈（TypeError: Null is not a subtype of num）。
- 【截图03】修复后正常输出，《活着》按 0 次处理掉出 Top3。
- 【截图04】文件缺失时输出友好提示"数据文件缺失，请检查data/books.json"，程序不崩。
- 【截图05】自主实践主程序一轮跑完四组数据：roundtrip 全部通过，字段缺失/类型错误/文件缺失三类异常都有可读提示。
- 【截图06】回调版与 await 版输出完全一致的对照。
- 【截图07】git log 提交记录，分步提交信息齐全。

## 九、自评

- 案例复现 async_json 完整复现：✔（代码与指南一致，可运行）
- 检查点（正常/异常两路均正确输出）：✔（截图01/04）
- Git 规范（每步一次提交、提交信息清晰）：✔（截图07）
- 自主实践1 async/await 改写回调版：✔（两版输出一致，截图06）
- 自主实践2 三类异常可读提示：✔（截图05）
- 自主实践3 完整字段模型化 + roundtrip 反向验证：✔（截图05）
- 自主实践4 pubspec 规范（全部 ^ 约束、无冗余依赖、pubspec.lock 已提交）：✔
- 自主实践5 AI 使用标注：✔（代码注释 + 本报告第七节）
- 独立研究任务（选做）：未做

## 十、一句话收获与下一步计划

收获：await 让异步代码可以像同步代码一样从上往下写，但忘了写 await 拿到的只是 Future 而不是值，这是本课最容易踩的坑。

遗留问题与预习：Stream 目前只会用 await for 消费，对 StreamController 还不熟；下次预习第11课网络请求，重点看异步和 fromJson/toJson 模型类在网络 JSON 解析里怎么直接复用。
