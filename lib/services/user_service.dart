import '../models/user.dart';
import '../database/database_helper.dart';

class UserService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Criar um novo usuário
  Future<int> createUser(User user) async {
    try {
      print('🔵 [USER_SERVICE] Iniciando createUser para: ${user.userEmail}');
      
      // Verificar se o email já existe
      print('🔵 [USER_SERVICE] Verificando se email existe...');
      bool emailExists = await _databaseHelper.emailExists(user.userEmail);
      print('🔵 [USER_SERVICE] Email existe: $emailExists');
      
      if (emailExists) {
        print('🔴 [USER_SERVICE] Email já cadastrado');
        throw Exception('Email já cadastrado');
      }
      
      print('🔵 [USER_SERVICE] Inserindo usuário no banco...');
      int userId = await _databaseHelper.insertUser(user);
      print('🔵 [USER_SERVICE] Usuário inserido com ID: $userId');
      
      return userId;
    } catch (e) {
      print('🔴 [USER_SERVICE] Erro ao criar usuário: $e');
      throw Exception('Erro ao criar usuário: $e');
    }
  }

  // Buscar todos os usuários
  Future<List<User>> getAllUsers() async {
    try {
      return await _databaseHelper.getAllUsers();
    } catch (e) {
      throw Exception('Erro ao buscar usuários: $e');
    }
  }

  // Buscar usuário por ID
  Future<User?> getUserById(int userId) async {
    try {
      return await _databaseHelper.getUserById(userId);
    } catch (e) {
      throw Exception('Erro ao buscar usuário: $e');
    }
  }

  // Buscar usuário por email
  Future<User?> getUserByEmail(String email) async {
    try {
      return await _databaseHelper.getUserByEmail(email);
    } catch (e) {
      throw Exception('Erro ao buscar usuário por email: $e');
    }
  }

  // Atualizar usuário
  Future<bool> updateUser(User user) async {
    try {
      if (user.userId == null) {
        throw Exception('ID do usuário é obrigatório para atualização');
      }
      
      int result = await _databaseHelper.updateUser(user);
      return result > 0;
    } catch (e) {
      throw Exception('Erro ao atualizar usuário: $e');
    }
  }

  // Deletar usuário
  Future<bool> deleteUser(int userId) async {
    try {
      int result = await _databaseHelper.deleteUser(userId);
      return result > 0;
    } catch (e) {
      throw Exception('Erro ao deletar usuário: $e');
    }
  }

  // Verificar se email existe
  Future<bool> emailExists(String email) async {
    try {
      return await _databaseHelper.emailExists(email);
    } catch (e) {
      throw Exception('Erro ao verificar email: $e');
    }
  }

  // Autenticar usuário (login)
  Future<User?> authenticateUser(String email, String password) async {
    try {
      User? user = await getUserByEmail(email);
      if (user != null && user.userPassword == password) {
        return user;
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao autenticar usuário: $e');
    }
  }

  // Validar dados do usuário
  String? validateUserData(User user) {
    if (user.userName.isEmpty) {
      return 'Nome é obrigatório';
    }
    if (user.userEmail.isEmpty || !user.userEmail.contains('@')) {
      return 'Email válido é obrigatório';
    }
    if (user.userPhone.isEmpty) {
      return 'Telefone é obrigatório';
    }
    if (user.userBirth.isEmpty) {
      return 'Data de nascimento é obrigatória';
    }
    if (user.userGender.isEmpty) {
      return 'Gênero é obrigatório';
    }
    if (user.userCountry.isEmpty) {
      return 'País é obrigatório';
    }
    if (user.userPassword.isEmpty || user.userPassword.length < 6) {
      return 'Senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }
}
