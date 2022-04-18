import 'package:common_flutter_service/core/authentication.dart';
import 'package:common_flutter_service/core/repository.dart';
import 'package:test/test.dart';

void main() async {
  // setup
  final repository = Repository.of('authentication', test: true);
  final authentication = Authentication.of(repository);
  await authentication.init();
  const username = 'username';
  const password = 'password';

  test('$Authentication', () async {
    // given unregistered, return invalid token
    final invalidToken = authentication.login(username, password);
    expect(invalidToken, equals(''));

    // given registered, return valid token
    authentication.register(username, password);
    final validToken = authentication.login(username, password);
    expect(validToken, isNot(equals(invalidToken)));

    // given registered, when password is wrong, return invalid token
    const wrongPassword = 'wrongPassword';
    authentication.register(username, wrongPassword);
    expect(
      authentication.login(username, wrongPassword),
      equals(invalidToken),
    );

    // given valid token, return valid token is valid
    expect(authentication.validateToken(validToken), equals(true));

    // given invalid token, return invalid token is invalid
    expect(authentication.validateToken(invalidToken), equals(false));

    // given logged in, when login, return invalid token
    expect(authentication.login(username, password), equals(invalidToken));

    // given logged in, when logout, return valid token is invalid
    authentication.logout(validToken);
    expect(authentication.validateToken(validToken), equals(false));

    // given logged out, when login, return new valid token
    final newValidToken = authentication.login(username, password);
    expect(newValidToken, isNot(equals(invalidToken)));
    expect(newValidToken, isNot(equals(validToken)));

    // given new valid token, return new valid token is valid
    expect(authentication.validateToken(newValidToken), equals(true));
  });
}
