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
    if (kIsWeb) {
      throw UnsupportedError('SQLite não funciona na web! Use mobile ou desktop para testar.');
    }
    
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      String path = join(await getDatabasesPath(), 'youtour.db');
      return await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
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
        userPassword TEXT NOT NULL
      )
    ''');
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

  // Fechar o banco de dados
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
