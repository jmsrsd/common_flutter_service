import 'storage.dart';

class Repository {
  final String table;
  final bool test;

  final cache = <String, Map<String, dynamic>>{};
  final queue = <Future<void> Function()>[];

  int get length => queue.length;

  Repository.of(this.table, {this.test = false}) {
    Future(() async {
      while (true) {
        await Future.delayed(Duration.zero);

        if (queue.isNotEmpty) {
          await queue.first();
          queue.removeAt(0);
        }
      }
    });
  }

  Storage get storage {
    return Storage.of(table, test: test);
  }

  Future<void> sync() async {
    while (true) {
      await Future.delayed(Duration.zero);
      if (queue.isEmpty) break;
    }
  }

  Future<void> init() async {
    await storage.init();

    if (test) await storage.clear();

    await sync();

    cache.clear();

    final keys = await storage.browse();

    for (final key in keys) {
      cache[key] = await storage.read(key);
    }
  }

  List<String> browse() {
    return cache.keys.toList();
  }

  Map<String, dynamic> read(String key) {
    return cache[key] ?? {};
  }

  void edit(String key, Map<String, dynamic> value) {
    cache[key] = value;

    queue.add(() async {
      await storage.edit(key, value);
    });
  }

  String add() {
    final key = '${DateTime.now().microsecondsSinceEpoch}';

    cache[key] = {};

    edit(key, read(key));

    return key;
  }

  void delete(String key) {
    cache.remove(key);

    queue.add(() async {
      await storage.delete(key);
    });
  }
}
