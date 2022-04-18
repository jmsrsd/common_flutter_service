import 'package:common_flutter_service/core/storage.dart';
import 'package:test/test.dart';

void main() async {
  // setup
  final database = Storage.of('storage', test: true);
  await database.init();
  await database.clear();

  test('$Storage', () async {
    // given database path, return storage directory within project
    expect(database.path, contains(r'\common_flutter_service\storage'));

    // given empty, when browse, return empty list
    expect(await database.browse(), equals(<String>[]));

    // given empty, when add, return new a value's key
    final key = await database.add();
    expect(await database.browse(), equals([key]));

    // given a value is existed, when edit, return edited value
    final value = <String, dynamic>{'key': 'value'};
    await database.edit(key, value);
    expect(await database.read(key), equals(value));

    // given a value is existed, when delete, return empty
    await database.delete(key);
    expect(await database.browse(), equals(<String>[]));
  });
}
