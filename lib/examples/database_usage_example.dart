// Exemplo de uso do banco de dados SQLite
import '../models/user.dart';
import '../services/user_service.dart';

class DatabaseUsageExample {
  final UserService _userService = UserService();

  // Exemplo de como criar um usuário
  Future<void> createUserExample() async {
    try {
      User newUser = User(
        userName: 'João Silva',
        userEmail: 'joao@email.com',
        userPhone: '11999999999',
        userBirth: '15/03/1990',
        userGender: 'Masculino',
        userCountry: 'Brasil',
        userPassword: 'senha123',
      );

      int userId = await _userService.createUser(newUser);
      print('Usuário criado com ID: $userId');
    } catch (e) {
      print('Erro ao criar usuário: $e');
    }
  }

  // Exemplo de como buscar todos os usuários
  Future<void> getAllUsersExample() async {
    try {
      List<User> users = await _userService.getAllUsers();
      print('Total de usuários: ${users.length}');
      for (User user in users) {
        print('ID: ${user.userId}, Nome: ${user.userName}, Email: ${user.userEmail}');
      }
    } catch (e) {
      print('Erro ao buscar usuários: $e');
    }
  }

  // Exemplo de como buscar usuário por email
  Future<void> getUserByEmailExample() async {
    try {
      User? user = await _userService.getUserByEmail('joao@email.com');
      if (user != null) {
        print('Usuário encontrado: ${user.userName}');
      } else {
        print('Usuário não encontrado');
      }
    } catch (e) {
      print('Erro ao buscar usuário: $e');
    }
  }

  // Exemplo de como autenticar usuário
  Future<void> authenticateUserExample() async {
    try {
      User? user = await _userService.authenticateUser('joao@email.com', 'senha123');
      if (user != null) {
        print('Login bem-sucedido: ${user.userName}');
      } else {
        print('Credenciais inválidas');
      }
    } catch (e) {
      print('Erro na autenticação: $e');
    }
  }

  // Exemplo de como atualizar usuário
  Future<void> updateUserExample() async {
    try {
      // Primeiro, buscar o usuário
      User? user = await _userService.getUserByEmail('joao@email.com');
      if (user != null) {
        // Atualizar dados
        User updatedUser = user.copyWith(
          userName: 'João Silva Santos',
          userPhone: '11988888888',
        );

        bool success = await _userService.updateUser(updatedUser);
        if (success) {
          print('Usuário atualizado com sucesso');
        } else {
          print('Falha ao atualizar usuário');
        }
      }
    } catch (e) {
      print('Erro ao atualizar usuário: $e');
    }
  }

  // Exemplo de como deletar usuário
  Future<void> deleteUserExample() async {
    try {
      User? user = await _userService.getUserByEmail('joao@email.com');
      if (user != null && user.userId != null) {
        bool success = await _userService.deleteUser(user.userId!);
        if (success) {
          print('Usuário deletado com sucesso');
        } else {
          print('Falha ao deletar usuário');
        }
      }
    } catch (e) {
      print('Erro ao deletar usuário: $e');
    }
  }

  // Exemplo de como verificar se email existe
  Future<void> checkEmailExistsExample() async {
    try {
      bool exists = await _userService.emailExists('joao@email.com');
      print('Email existe: $exists');
    } catch (e) {
      print('Erro ao verificar email: $e');
    }
  }
}
