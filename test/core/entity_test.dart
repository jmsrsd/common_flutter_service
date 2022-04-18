import 'package:common_flutter_service/core/entity.dart';
import 'package:common_flutter_service/core/repository.dart';
import 'package:test/test.dart';

void main() async {
  // setup
  final repository = Repository.of('entity', test: true);
  final entity = Entity.of(repository);
  await entity.init();
  const table = 'table';
  const otherTable = 'otherTable';
  final keys = <String>[];

  test('$Entity', () async {
    expect(entity.browse(table), equals(<String>[]));

    keys.add(entity.add(table));
    expect(entity.browse(table), equals([keys[0]]));

    expect(entity.browse(otherTable), equals([]));

    expect(entity.read(table, keys[0]), equals({}));

    final value = <String, dynamic>{'key': 'value'};
    entity.edit(table, keys[0], value);
    expect(entity.read(table, keys[0]), equals(value));

    keys.add(entity.add(table));
    expect(entity.browse(table), equals([keys[0], keys[1]]));

    expect(entity.browse(table, created: keys[0]), equals([keys[1]]));

    entity.edit(table, keys[0], value);
    expect(entity.browse(table, updated: keys[1]), equals([keys[0]]));

    entity.delete(table, keys[0]);
    expect(entity.browse(table, updated: keys[1]), equals([]));

    expect(entity.browse(table), equals([keys[1]]));
  });
}
