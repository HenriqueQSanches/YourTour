import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/post.dart';
import '../models/comment.dart';

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
      final db = await openDatabase(
        path,
        version: 3,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );

      // Safety: ensure necessary tables exist (useful if DB was corrupted or migrated incorrectly)
      await _ensureTables(db);
      return db;
    } catch (e) {
      debugPrint('Erro ao inicializar banco de dados: $e');
      rethrow;
    }
  }

  Future<void> _ensureTables(Database db) async {
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS posts(
          postId INTEGER PRIMARY KEY AUTOINCREMENT,
          userId INTEGER NOT NULL,
          caption TEXT,
          imagePath TEXT,
          location TEXT,
          timestamp TEXT,
          likes INTEGER DEFAULT 0
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS comments(
          commentId INTEGER PRIMARY KEY AUTOINCREMENT,
          postId INTEGER NOT NULL,
          userId INTEGER NOT NULL,
          text TEXT,
          timestamp TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS post_likes(
          postId INTEGER NOT NULL,
          userId INTEGER NOT NULL,
          PRIMARY KEY (postId, userId)
        )
      ''');
    } catch (e) {
      debugPrint('🔴 [DATABASE] Erro ao garantir tabelas: $e');
    }
  }

  // Stream para notificar atualizações no feed (posts/likes/comments)
  final StreamController<void> _postsController = StreamController<void>.broadcast();

  Stream<void> get postsStream => _postsController.stream;

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
    // Criar tabela de posts
    await db.execute('''
      CREATE TABLE posts(
        postId INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        caption TEXT,
        imagePath TEXT,
        location TEXT,
        timestamp TEXT,
        likes INTEGER DEFAULT 0
      )
    ''');
    // Criar tabela de comentários
    await db.execute('''
      CREATE TABLE comments(
        commentId INTEGER PRIMARY KEY AUTOINCREMENT,
        postId INTEGER NOT NULL,
        userId INTEGER NOT NULL,
        text TEXT,
        timestamp TEXT
      )
    ''');

    // Criar tabela de likes (por usuário)
    await db.execute('''
      CREATE TABLE post_likes(
        postId INTEGER NOT NULL,
        userId INTEGER NOT NULL,
        PRIMARY KEY (postId, userId)
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
    if (oldVersion < 3) {
      // Adiciona tabela de posts na versão 3
      await db.execute('''
        CREATE TABLE IF NOT EXISTS posts(
          postId INTEGER PRIMARY KEY AUTOINCREMENT,
          userId INTEGER NOT NULL,
          caption TEXT,
          imagePath TEXT,
          location TEXT,
          timestamp TEXT,
          likes INTEGER DEFAULT 0
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS comments(
          commentId INTEGER PRIMARY KEY AUTOINCREMENT,
          postId INTEGER NOT NULL,
          userId INTEGER NOT NULL,
          text TEXT,
          timestamp TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS post_likes(
          postId INTEGER NOT NULL,
          userId INTEGER NOT NULL,
          PRIMARY KEY (postId, userId)
        )
      ''');
    }
  }

  // Inserir um novo post
  Future<int> insertPost(Post post) async {
    try {
      final db = await database;
      int id = await db.insert('posts', post.toMap());
      try {
        _postsController.add(null);
      } catch (_) {}
      return id;
    } catch (e) {
      debugPrint('🔴 [DATABASE] Erro ao inserir post: $e');
      rethrow;
    }
  }

  // Buscar todos os posts (ordem decrescente por timestamp)
  Future<List<Post>> getAllPosts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'posts',
      orderBy: 'timestamp DESC',
    );
    return List.generate(maps.length, (i) => Post.fromMap(maps[i]));
  }

  // Buscar posts de um usuário
  Future<List<Post>> getPostsByUser(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'posts',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
    );
    return List.generate(maps.length, (i) => Post.fromMap(maps[i]));
  }

  // Comentários
  Future<int> insertComment(Comment comment) async {
    try {
      final db = await database;
      int id = await db.insert('comments', comment.toMap());
      debugPrint('🔵 [DATABASE] Comentário inserido id=$id for postId=${comment.postId}');
      try {
        _postsController.add(null);
      } catch (_) {}
      return id;
    } catch (e) {
      debugPrint('🔴 [DATABASE] Erro ao inserir comentário: $e');
      rethrow;
    }
  }

  Future<List<Comment>> getCommentsByPost(int postId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'comments',
      where: 'postId = ?',
      whereArgs: [postId],
      orderBy: 'timestamp DESC',
    );
    return List.generate(maps.length, (i) => Comment.fromMap(maps[i]));
  }

  // Likes (por usuário)
  Future<void> addLike(int postId, int userId) async {
    try {
      final db = await database;
      await db.insert('post_likes', {'postId': postId, 'userId': userId}, conflictAlgorithm: ConflictAlgorithm.replace);
      debugPrint('🔵 [DATABASE] Like adicionado postId=$postId userId=$userId');
      try {
        _postsController.add(null);
      } catch (_) {}
    } catch (e) {
      debugPrint('🔴 [DATABASE] Erro ao adicionar like: $e');
      rethrow;
    }
  }

  Future<void> removeLike(int postId, int userId) async {
    try {
      final db = await database;
      await db.delete('post_likes', where: 'postId = ? AND userId = ?', whereArgs: [postId, userId]);
      debugPrint('🔵 [DATABASE] Like removido postId=$postId userId=$userId');
      try {
        _postsController.add(null);
      } catch (_) {}
    } catch (e) {
      debugPrint('🔴 [DATABASE] Erro ao remover like: $e');
      rethrow;
    }
  }

  Future<int> getLikesCount(int postId) async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as c FROM post_likes WHERE postId = ?', [postId]);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<bool> userLiked(int postId, int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'post_likes',
      where: 'postId = ? AND userId = ?',
      whereArgs: [postId, userId],
    );
    return maps.isNotEmpty;
  }

  // Inserir um novo usuário
  Future<int> insertUser(User user) async {
    try {
      debugPrint('🔵 [DATABASE] Iniciando insertUser...');
      final db = await database;
      debugPrint('🔵 [DATABASE] Banco obtido, inserindo usuário...');
      int result = await db.insert('users', user.toMap());
      debugPrint('🔵 [DATABASE] Usuário inserido com sucesso, ID: $result');
      return result;
    } catch (e) {
      debugPrint('🔴 [DATABASE] Erro ao inserir usuário: $e');
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
      debugPrint('🔴 [DATABASE] Erro ao solicitar reset de senha');
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
      debugPrint('🔴 [DATABASE] Erro ao verificar código de reset: $e');
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
      debugPrint('🔴 [DATABASE] Erro ao resetar senha: $e');
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
      debugPrint('🔴 [DATABASE] Erro ao limpar dados de reset: $e');
      return false;
    }
  }

  // Fechar o banco de dados
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
