import 'dart:convert';
import 'dart:math';

import 'repository.dart';

import 'encryptor.dart';

class Authentication {
  final Repository repository;

  Authentication.of(this.repository);

  Encryptor get encryptor {
    return Encryptor();
  }

  Future<void> init() async {
    await repository.init();
  }

  String login(String username, String password) {
    final key = 'user:$username';
    var validUser = false;

    try {
      final user = repository.read(key);

      final validUsername = user['username'] == username;
      final validPassword = user['password'] == encryptor.encrypt(password);

      final expired = DateTime.fromMicrosecondsSinceEpoch(
        int.tryParse(user['expired'] ?? '') ?? 0,
      );

      final validExpired = expired.isBefore(DateTime.now());

      validUser = validUsername && validPassword && validExpired;
    } catch (e) {
      validUser = false;
    }

    switch (validUser) {
      case true:
        final user = repository.read(key);

        var expired = DateTime.fromMicrosecondsSinceEpoch(
          int.tryParse(user['expired'] ?? '') ?? 0,
        );

        if (expired.isAfter(DateTime.now())) {
          return '';
        } else {
          expired = DateTime.now().add(const Duration(minutes: 5));

          edit(username, encryptor.encrypt(password), expired);
        }

        return packUser(repository.read(key));
      default:
        return '';
    }
  }

  void logout(String token) {
    if (validateToken(token) == false) return;

    final user = unpackToken(token);
    final username = user['username'] as String;
    final password = user['password'] as String;

    edit(username, password);
  }

  void register(String username, String password) {
    final key = 'user:$username';
    final user = repository.read(key);
    final registered = (user['password'] ?? '') != '';
    final unregistered = registered == false;

    if (unregistered) {
      edit(username, encryptor.encrypt(password));
    }
  }

  bool validateToken(String token) {
    try {
      return validateUser(unpackToken(token));
    } catch (e) {
      return false;
    }
  }

  bool validateUser(Map<String, dynamic> user) {
    try {
      final username = user['username'] as String;
      final password = user['password'] as String;
      final key = 'user:$username';

      final validUser = repository.read(key);

      final validUsername = validUser['username'] == username;
      final validPassword = validUser['password'] == password;

      final expired = DateTime.fromMicrosecondsSinceEpoch(
        int.tryParse(validUser['expired'] ?? '') ?? 0,
      );

      final validExpired = expired.isAfter(DateTime.now());

      return validUsername && validPassword && validExpired;
    } catch (e) {
      return false;
    }
  }

  Map<String, dynamic> unpackToken(String token) {
    final decrypted = encryptor.decrypt(token);
    final decoded = jsonDecode(decrypted) as Map;
    return decoded.cast<String, dynamic>();
  }

  String packUser(Map<String, dynamic> user) {
    return encryptor.encrypt(jsonEncode(secureUser(user)));
  }

  Map<String, dynamic> secureUser(Map<String, dynamic> user) {
    final entries = <MapEntry<String, dynamic>>[
      MapEntry('username', user['username']),
      MapEntry('password', user['password']),
      MapEntry('expired', user['expired']),
    ];

    final securedLength = (entries.length * 1.5).ceil();

    for (var i = entries.length; i < securedLength; i = entries.length) {
      final securedKey = '${Random.secure().nextDouble()}';
      final securedValue = '${Random.secure().nextDouble()}';
      final securedEntry = MapEntry(securedKey, securedValue);

      entries.insert(Random().nextInt(i), securedEntry);
    }

    entries.sort((a, b) => Random().nextInt(3) - 1);

    return Map.fromEntries(entries);
  }

  void edit(String username, String password, [DateTime? expired]) {
    final key = 'user:$username';

    expired = expired ?? DateTime.fromMicrosecondsSinceEpoch(0);

    final user = {
      'username': username,
      'password': password,
      'expired': '${expired.microsecondsSinceEpoch}',
    };

    repository.edit(key, user);
  }
}
