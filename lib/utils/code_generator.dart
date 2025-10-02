import 'dart:math';

class CodeGenerator {
  static const int _codeLength = 6;
  static const int _expiryMinutes = 15;

  /// Gera um código aleatório de 6 dígitos
  static String generateResetCode() {
    final random = Random();
    final code = StringBuffer();
    
    for (int i = 0; i < _codeLength; i++) {
      code.write(random.nextInt(10));
    }
    
    return code.toString();
  }

  /// Gera a data de expiração do código (15 minutos a partir de agora)
  static String generateExpiryTime() {
    final now = DateTime.now();
    final expiry = now.add(Duration(minutes: _expiryMinutes));
    return expiry.toIso8601String();
  }

  /// Verifica se um código expirou
  static bool isCodeExpired(String expiryTime) {
    try {
      final expiry = DateTime.parse(expiryTime);
      return DateTime.now().isAfter(expiry);
    } catch (e) {
      print('🔴 [CODE_GENERATOR] Erro ao verificar expiração: $e');
      return true; // Se não conseguir parsear, considera expirado
    }
  }

  /// Valida se o código tem o formato correto (6 dígitos)
  static bool isValidCodeFormat(String code) {
    if (code.length != _codeLength) return false;
    
    // Verifica se todos os caracteres são dígitos
    return RegExp(r'^\d{6}$').hasMatch(code);
  }

  /// Calcula o tempo restante até a expiração em minutos
  static int getRemainingMinutes(String expiryTime) {
    try {
      final expiry = DateTime.parse(expiryTime);
      final now = DateTime.now();
      final difference = expiry.difference(now);
      
      if (difference.isNegative) return 0;
      
      return difference.inMinutes;
    } catch (e) {
      print('🔴 [CODE_GENERATOR] Erro ao calcular tempo restante: $e');
      return 0;
    }
  }
}
