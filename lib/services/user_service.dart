import '../models/user.dart';
import '../database/database_helper.dart';
import '../services/email_service.dart';
import '../utils/code_generator.dart';

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
      if (user != null && user.userPassword == password && !user.isForget) {
        return user;
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao autenticar usuário: $e');
    }
  }

  // Solicitar reset de senha
  Future<bool> requestPasswordReset(String email) async {
    try {
      print('🔵 [USER_SERVICE] Iniciando reset de senha para: $email');
      
      // Validar formato do e-mail
      if (!EmailService.isValidEmail(email)) {
        throw Exception('Formato de e-mail inválido');
      }
      
      // Verificar se o e-mail existe
      User? user = await getUserByEmail(email);
      if (user == null) {
        throw Exception('E-mail não encontrado');
      }
      
      // Verificar se o usuário já está em processo de reset
      if (user.isForget) {
        throw Exception('Já existe uma solicitação de reset pendente para este e-mail');
      }
      
      // Gerar código e tempo de expiração
      String resetCode = CodeGenerator.generateResetCode();
      String codeExpiry = CodeGenerator.generateExpiryTime();
      
      print('🔵 [USER_SERVICE] Código gerado: $resetCode');
      print('🔵 [USER_SERVICE] Expira em: $codeExpiry');
      
      // Atualizar banco de dados
      bool dbSuccess = await _databaseHelper.requestPasswordReset(email, resetCode, codeExpiry);
      if (!dbSuccess) {
        throw Exception('Erro ao atualizar dados no banco');
      }
      
      // Enviar e-mail
      bool emailSuccess = await EmailService.sendPasswordResetCode(email, resetCode);
      if (!emailSuccess) {
        // Se falhar o e-mail, limpar os dados de reset
        await _databaseHelper.clearResetData(email);
        throw Exception('Erro ao enviar e-mail');
      }
      
      print('✅ [USER_SERVICE] Reset de senha solicitado com sucesso');
      return true;
    } catch (e) {
      print('🔴 [USER_SERVICE] Erro ao solicitar reset de senha');
      throw Exception('Erro ao solicitar reset de senha');
    }
  }

  // Verificar código de reset
  Future<bool> verifyResetCode(String email, String code) async {
    try {
      print('🔵 [USER_SERVICE] Verificando código para: $email');
      
      // Validar formato do código
      if (!CodeGenerator.isValidCodeFormat(code)) {
        throw Exception('Formato de código inválido');
      }
      
      // Verificar código no banco
      bool isValid = await _databaseHelper.verifyResetCode(email, code);
      if (!isValid) {
        throw Exception('Código inválido ou expirado');
      }
      
      print('✅ [USER_SERVICE] Código verificado com sucesso');
      return true;
    } catch (e) {
      print('🔴 [USER_SERVICE] Erro ao verificar código: $e');
      throw Exception('Erro ao verificar código: $e');
    }
  }

  // Redefinir senha
  Future<bool> resetPassword(String email, String newPassword) async {
    try {
      print('🔵 [USER_SERVICE] Redefinindo senha para: $email');
      
      // Validar nova senha
      if (newPassword.isEmpty || newPassword.length < 6) {
        throw Exception('Senha deve ter pelo menos 6 caracteres');
      }
      
      // Verificar se o usuário está em processo de reset
      User? user = await getUserByEmail(email);
      if (user == null || !user.isForget) {
        throw Exception('Solicitação de reset não encontrada');
      }
      
      // Atualizar senha no banco
      bool success = await _databaseHelper.resetPassword(email, newPassword);
      if (!success) {
        throw Exception('Erro ao atualizar senha');
      }
      
      print('✅ [USER_SERVICE] Senha redefinida com sucesso');
      return true;
    } catch (e) {
      print('🔴 [USER_SERVICE] Erro ao redefinir senha: $e');
      throw Exception('Erro ao redefinir senha: $e');
    }
  }

  // Limpar dados de reset (para casos de erro ou cancelamento)
  Future<bool> clearResetData(String email) async {
    try {
      return await _databaseHelper.clearResetData(email);
    } catch (e) {
      print('🔴 [USER_SERVICE] Erro ao limpar dados de reset: $e');
      return false;
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
    if (user.userPassword == null || user.userPassword!.isEmpty || user.userPassword!.length < 6) {
      return 'Senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }
}
