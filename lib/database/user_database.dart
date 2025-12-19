import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:learningday1/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDatabase {
  static final UserDatabase instance = UserDatabase._init();
  static Database? _database;

  UserDatabase._init();

  Future<Database?> get database async {
    if (kIsWeb) return null; // No SQLite on web
    if (_database != null) return _database!;
    _database = await _initDB('users.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const textTypeNullable = 'TEXT';
    const intType = 'INTEGER DEFAULT 0';

    await db.execute('''
      CREATE TABLE users (
        id $idType,
        name $textType,
        email $textType,
        avatar $textTypeNullable,
        needsSync $intType
      )
    ''');
  }

  // Web: Save to SharedPreferences
  Future<void> _saveToPrefsWeb(List<User> users) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(users.map((e) => e.toMap()).toList());
    await prefs.setString('users', encodedData);
  }

  // Web: Load from SharedPreferences
  Future<List<User>> _loadFromPrefsWeb() async {
    final prefs = await SharedPreferences.getInstance();
    final String? usersString = prefs.getString('users');
    if (usersString != null) {
      final List<dynamic> jsonList = jsonDecode(usersString);
      return jsonList.map((e) => User.fromMap(e)).toList();
    }
    return [];
  }

  // Create
  Future<User> create(User user) async {
    if (kIsWeb) {
      // Web: Use SharedPreferences
      final users = await _loadFromPrefsWeb();
      final newUser = user.id == null
          ? user.copyWith(id: DateTime.now().millisecondsSinceEpoch)
          : user;
      users.insert(0, newUser);
      await _saveToPrefsWeb(users);
      return newUser;
    } else {
      // Mobile: Use SQLite
      final db = await instance.database;
      final id = await db!.insert('users', user.toMap());
      return user.copyWith(id: id);
    }
  }

  // Read single user
  Future<User?> readUser(int id) async {
    if (kIsWeb) {
      final users = await _loadFromPrefsWeb();
      try {
        return users.firstWhere((u) => u.id == id);
      } catch (e) {
        return null;
      }
    } else {
      final db = await instance.database;
      final maps = await db!.query('users', where: 'id = ?', whereArgs: [id]);

      if (maps.isNotEmpty) {
        return User.fromMap(maps.first);
      } else {
        return null;
      }
    }
  }

  // Read all users
  Future<List<User>> readAllUsers() async {
    if (kIsWeb) {
      return await _loadFromPrefsWeb();
    } else {
      final db = await instance.database;
      const orderBy = 'id DESC';
      final result = await db!.query('users', orderBy: orderBy);
      return result.map((json) => User.fromMap(json)).toList();
    }
  }

  // Update
  Future<int> update(User user) async {
    if (kIsWeb) {
      final users = await _loadFromPrefsWeb();
      final index = users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        users[index] = user;
        await _saveToPrefsWeb(users);
        return 1;
      }
      return 0;
    } else {
      final db = await instance.database;
      return db!.update(
        'users',
        user.toMap(),
        where: 'id = ?',
        whereArgs: [user.id],
      );
    }
  }

  // Delete
  Future<int> delete(int id) async {
    if (kIsWeb) {
      final users = await _loadFromPrefsWeb();
      final initialLength = users.length;
      users.removeWhere((u) => u.id == id);
      await _saveToPrefsWeb(users);
      return initialLength - users.length;
    } else {
      final db = await instance.database;
      return await db!.delete('users', where: 'id = ?', whereArgs: [id]);
    }
  }

  // Check if user exists by ID
  Future<bool> userExists(int id) async {
    if (kIsWeb) {
      final users = await _loadFromPrefsWeb();
      return users.any((u) => u.id == id);
    } else {
      final db = await instance.database;
      final result = await db!.query('users', where: 'id = ?', whereArgs: [id]);
      return result.isNotEmpty;
    }
  }

  // Get last synced user ID (for pagination)
  Future<int> getLastSyncedId() async {
    if (kIsWeb) {
      final users = await _loadFromPrefsWeb();
      if (users.isEmpty) return 0;
      return users.map((u) => u.id ?? 0).reduce((a, b) => a > b ? a : b);
    } else {
      final db = await instance.database;
      final result = await db!.rawQuery('SELECT MAX(id) as maxId FROM users');
      final maxId = result.first['maxId'];
      return maxId != null ? maxId as int : 0;
    }
  }

  // Get users that need to be synced to API
  Future<List<User>> getPendingSyncUsers() async {
    if (kIsWeb) {
      final users = await _loadFromPrefsWeb();
      return users.where((u) => u.needsSync).toList();
    } else {
      final db = await instance.database;
      final result = await db!.query(
        'users',
        where: 'needsSync = ?',
        whereArgs: [1],
      );
      return result.map((json) => User.fromMap(json)).toList();
    }
  }

  Future close() async {
    if (!kIsWeb) {
      final db = await instance.database;
      db?.close();
    }
  }
}
