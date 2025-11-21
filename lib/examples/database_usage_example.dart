// Exemplo de uso do banco de dados SQLite
import 'package:flutter/foundation.dart';
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
      debugPrint('Usuário criado com ID: $userId');
    } catch (e) {
      debugPrint('Erro ao criar usuário: $e');
    }
  }

  // Exemplo de como buscar todos os usuários
  Future<void> getAllUsersExample() async {
    try {
      List<User> users = await _userService.getAllUsers();
      debugPrint('Total de usuários: ${users.length}');
      for (User user in users) {
        debugPrint('ID: ${user.userId}, Nome: ${user.userName}, Email: ${user.userEmail}');
      }
    } catch (e) {
      debugPrint('Erro ao buscar usuários: $e');
    }
  }

  // Exemplo de como buscar usuário por email
  Future<void> getUserByEmailExample() async {
    try {
      User? user = await _userService.getUserByEmail('joao@email.com');
      if (user != null) {
        debugPrint('Usuário encontrado: ${user.userName}');
      } else {
        debugPrint('Usuário não encontrado');
      }
    } catch (e) {
      debugPrint('Erro ao buscar usuário: $e');
    }
  }

  // Exemplo de como autenticar usuário
  Future<void> authenticateUserExample() async {
    try {
      User? user = await _userService.authenticateUser('joao@email.com', 'senha123');
      if (user != null) {
        debugPrint('Login bem-sucedido: ${user.userName}');
      } else {
        debugPrint('Credenciais inválidas');
      }
    } catch (e) {
      debugPrint('Erro na autenticação: $e');
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
          debugPrint('Usuário atualizado com sucesso');
        } else {
          debugPrint('Falha ao atualizar usuário');
        }
      }
    } catch (e) {
      debugPrint('Erro ao atualizar usuário: $e');
    }
  }

  // Exemplo de como deletar usuário
  Future<void> deleteUserExample() async {
    try {
      User? user = await _userService.getUserByEmail('joao@email.com');
      if (user != null && user.userId != null) {
        bool success = await _userService.deleteUser(user.userId!);
        if (success) {
          debugPrint('Usuário deletado com sucesso');
        } else {
          debugPrint('Falha ao deletar usuário');
        }
      }
    } catch (e) {
      debugPrint('Erro ao deletar usuário: $e');
    }
  }

  // Exemplo de como verificar se email existe
  Future<void> checkEmailExistsExample() async {
    try {
      bool exists = await _userService.emailExists('joao@email.com');
      debugPrint('Email existe: $exists');
    } catch (e) {
      debugPrint('Erro ao verificar email: $e');
    }
  }
}
