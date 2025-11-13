import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      String path = join(await getDatabasesPath(), 'youtour.db');
      return await openDatabase(
        path,
        version: 2,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      print('Erro ao inicializar banco de dados: $e');
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        userId INTEGER PRIMARY KEY AUTOINCREMENT,
        userName TEXT NOT NULL,
        userEmail TEXT NOT NULL UNIQUE,
        userPhone TEXT NOT NULL,
        userBirth TEXT NOT NULL,
        userGender TEXT NOT NULL,
        userCountry TEXT NOT NULL,
        userPassword TEXT,
        isForget INTEGER DEFAULT 0,
        resetCode TEXT,
        codeExpiry TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE users ADD COLUMN isForget INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE users ADD COLUMN resetCode TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN codeExpiry TEXT');
      
      await db.execute('ALTER TABLE users ADD COLUMN userPassword_new TEXT');
      await db.execute('UPDATE users SET userPassword_new = userPassword');
      await db.execute('ALTER TABLE users DROP COLUMN userPassword');
      await db.execute('ALTER TABLE users RENAME COLUMN userPassword_new TO userPassword');
    }
  }

  // Inserir um novo usuário
  Future<int> insertUser(User user) async {
    try {
      print('🔵 [DATABASE] Iniciando insertUser...');
      final db = await database;
      print('🔵 [DATABASE] Banco obtido, inserindo usuário...');
      int result = await db.insert('users', user.toMap());
      print('🔵 [DATABASE] Usuário inserido com sucesso, ID: $result');
      return result;
    } catch (e) {
      print('🔴 [DATABASE] Erro ao inserir usuário: $e');
      rethrow;
    }
  }

  // Buscar todos os usuários
  Future<List<User>> getAllUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) {
      return User.fromMap(maps[i]);
    });
  }

  // Buscar usuário por ID
  Future<User?> getUserById(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // Buscar usuário por email
  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'userEmail = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // Atualizar usuário
  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'userId = ?',
      whereArgs: [user.userId],
    );
  }

  // Deletar usuário
  Future<int> deleteUser(int userId) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  // Verificar se email já existe
  Future<bool> emailExists(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'userEmail = ?',
      whereArgs: [email],
    );
    return maps.isNotEmpty;
  }


  Future<bool> requestPasswordReset(String email, String resetCode, String codeExpiry) async {
    try {
      final db = await database;
      int result = await db.update(
        'users',
        {
          'isForget': 1,
          'userPassword': null,
          'resetCode': resetCode,
          'codeExpiry': codeExpiry,
        },
        where: 'userEmail = ?',
        whereArgs: [email],
      );
      return result > 0;
    } catch (e) {
      print('🔴 [DATABASE] Erro ao solicitar reset de senha');
      return false;
    }
  }

  Future<bool> verifyResetCode(String email, String code) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'userEmail = ? AND resetCode = ? AND codeExpiry > ?',
        whereArgs: [email, code, DateTime.now().toIso8601String()],
      );
      return maps.isNotEmpty;
    } catch (e) {
      print('🔴 [DATABASE] Erro ao verificar código de reset: $e');
      return false;
    }
  }

  Future<bool> resetPassword(String email, String newPassword) async {
    try {
      final db = await database;
      int result = await db.update(
        'users',
        {
          'isForget': 0,
          'userPassword': newPassword,
          'resetCode': null,
          'codeExpiry': null,
        },
        where: 'userEmail = ?',
        whereArgs: [email],
      );
      return result > 0;
    } catch (e) {
      print('🔴 [DATABASE] Erro ao resetar senha: $e');
      return false;
    }
  }

  Future<bool> clearResetData(String email) async {
    try {
      final db = await database;
      int result = await db.update(
        'users',
        {
          'isForget': 0,
          'resetCode': null,
          'codeExpiry': null,
        },
        where: 'userEmail = ?',
        whereArgs: [email],
      );
      return result > 0;
    } catch (e) {
      print('🔴 [DATABASE] Erro ao limpar dados de reset: $e');
      return false;
    }
  }

  // Fechar o banco de dados
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
