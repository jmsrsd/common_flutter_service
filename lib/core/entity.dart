import 'repository.dart';

class Entity {
  final Repository repository;

  Entity.of(this.repository);

  Future<void> init() async {
    await repository.init();
  }

  String identifier(String table, String key) {
    if (browse(table).contains(key) == false) return '$table:$key:$key';

    return repository
        .browse()
        .where((element) => element.contains('$table:$key'))
        .toList()
        .first;
  }

  String recent(String table) {
    final keys = repository
        .browse()
        .where((element) => element.contains('$table:'))
        .map((e) => e.split(':')[2])
        .toList();

    keys.sort((a, b) => int.parse(a).compareTo(int.parse(b)));

    try {
      return keys.last;
    } catch (e) {
      return '0';
    }
  }

  List<String> browse(
    String table, {
    String created = '0',
    String updated = '0',
  }) {
    return repository.browse().where((element) {
      return element.contains(table);
    }).map((e) {
      return e.split(':');
    }).where((element) {
      final parsedCreated = int.parse(element.elementAt(1));
      final parsedUpdated = int.parse(element.elementAt(2));

      final afterCreated = parsedCreated > int.parse(created);
      final afterUpdated = parsedUpdated > int.parse(updated);

      return afterCreated && afterUpdated;
    }).map((e) {
      return e.elementAt(1);
    }).toList();
  }

  Map<String, dynamic> read(String table, String key) {
    return repository.read(identifier(table, key));
  }

  void edit(String table, String key, Map<String, dynamic> value) {
    delete(table, key);

    var updated = '${int.parse(recent(table)) + 1}';

    if (int.parse(key) > int.parse(updated)) updated = key;

    repository.edit('$table:$key:$updated', value);
  }

  String add(String table) {
    final key = '${DateTime.now().microsecondsSinceEpoch}';

    edit(table, key, {});

    return key;
  }

  void delete(String table, String key) {
    try {
      repository.delete(identifier(table, key));
    } finally {}
  }
}
