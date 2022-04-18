import 'dart:convert';

import 'package:dcli/dcli.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart' as paths;

class Storage {
  late final String table;

  bool _initialized = false;
  bool get initialized => _initialized;

  Storage.of(String table, {bool test = false}) {
    this.table = table + (test ? '.test' : '');
  }

  String get path {
    final context = paths.windows;
    const projectname = 'common_flutter_service';
    const dirname = 'storage';

    var result = context.absolute(DartScript.self.pathToScriptDirectory);
    result = result.substring(0, result.lastIndexOf(projectname));
    result = paths.join(result, projectname, dirname);

    return context.normalize(result);
  }

  Future<Box<String>> open() async {
    return Hive.openBox<String>(table);
  }

  Future<void> init() async {
    if (_initialized) return;

    Hive.init(path);
    await open();

    _initialized = true;
  }

  Future<void> clear() async {
    final source = await open();
    await source.clear();
  }

  Future<List<String>> browse() async {
    final source = await open();
    return source.keys.map((e) => '$e').toList();
  }

  Future<Map<String, dynamic>> read(String key) async {
    final source = await open();
    final encoded = source.get(key) ?? jsonEncode({});
    final decoded = jsonDecode(encoded) as Map;

    return decoded.cast<String, dynamic>();
  }

  Future<void> edit(String key, Map<String, dynamic> value) async {
    final source = await open();
    await source.put(key, jsonEncode(value));
  }

  Future<String> add() async {
    final key = '${DateTime.now().microsecondsSinceEpoch}';

    await edit(key, {});

    return key;
  }

  Future<void> delete(String key) async {
    final source = await open();
    await source.delete(key);
  }
}
