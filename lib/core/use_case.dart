import 'repository.dart';

class UseCase {
  final Repository repository;

  UseCase.of(this.repository);

  Future<void> init() async {
    await repository.init();
  }
}
