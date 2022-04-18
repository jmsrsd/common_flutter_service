import 'package:common_flutter_service/core/repository.dart';
import 'package:test/test.dart';

void main() async {
  // setup
  const table = 'repository';
  final repository = Repository.of(table, test: true);
  await repository.init();
  final storage = repository.storage;

  test('$Repository', () async {
    expect(repository.table, equals(table));
    expect(repository.test, equals(true));

    expect(await storage.browse(), equals(<String>[]));
    expect(repository.browse(), equals(<String>[]));

    final key = repository.add();
    expect(repository.browse(), equals([key]));

    await repository.sync();
    expect(await storage.browse(), equals([key]));

    final value = <String, dynamic>{'key': 'value'};
    repository.edit(key, value);
    expect(repository.read(key), equals(value));

    await repository.sync();
    expect(await storage.read(key), equals(value));

    repository.delete(key);
    expect(repository.browse(), equals(<String>[]));

    await repository.sync();
    expect(await storage.browse(), equals(<String>[]));
  });
}
