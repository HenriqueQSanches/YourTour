import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class EmailService {
  // Para desenvolvimento, vamos simular o envio de e-mail
  // Em produção, você deve integrar com um serviço real como SendGrid, Mailgun, etc.
  
  static const String _apiKey = 'YOUR_EMAIL_SERVICE_API_KEY';
  static const String _fromEmail = 'noreply@youtour.com';
  static const String _serviceUrl = 'https://api.emailservice.com/send';

  /// Envia e-mail com código de reset de senha
  static Future<bool> sendPasswordResetCode(String toEmail, String resetCode) async {
    try {
      debugPrint('🔵 [EMAIL_SERVICE] Enviando código de reset para: $toEmail');
      
      // Para desenvolvimento, vamos simular o envio
      // Em produção, substitua por uma chamada real à API de e-mail
      await _simulateEmailSending(toEmail, resetCode);
      
      debugPrint('✅ [EMAIL_SERVICE] E-mail enviado com sucesso');
      return true;
    } catch (e) {
      debugPrint('🔴 [EMAIL_SERVICE] Erro ao enviar e-mail: $e');
      return false;
    }
  }

  /// Simula o envio de e-mail (apenas para desenvolvimento)
  static Future<void> _simulateEmailSending(String toEmail, String resetCode) async {
    // Simula delay de rede
    await Future.delayed(Duration(seconds: 2));
    
    debugPrint('📧 [EMAIL_SERVICE] === E-MAIL SIMULADO ===');
    debugPrint('📧 Para: $toEmail');
    debugPrint('📧 Assunto: Código de Redefinição de Senha - YourTour');
    debugPrint('📧 Conteúdo:');
    debugPrint('📧 Seu código de redefinição de senha é: $resetCode');
    debugPrint('📧 Este código expira em 15 minutos.');
    debugPrint('📧 Se você não solicitou esta redefinição, ignore este e-mail.');
    debugPrint('📧 ================================');
  }

  /// Método para produção - integração com serviço real de e-mail
  static Future<bool> _sendRealEmail(String toEmail, String resetCode) async {
    try {
      final response = await http.post(
        Uri.parse(_serviceUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'to': toEmail,
          'from': _fromEmail,
          'subject': 'Código de Redefinição de Senha - YourTour',
          'html': _generateEmailHtml(resetCode),
          'text': _generateEmailText(resetCode),
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('🔴 [EMAIL_SERVICE] Erro na API de e-mail: $e');
      return false;
    }
  }

  /// Gera HTML do e-mail
  static String _generateEmailHtml(String resetCode) {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <title>Redefinição de Senha - YourTour</title>
    </head>
    <body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
        <div style="text-align: center; margin-bottom: 30px;">
            <h1 style="color: #2E7D32;">YourTour</h1>
        </div>
        
        <div style="background-color: #f5f5f5; padding: 20px; border-radius: 8px; margin-bottom: 20px;">
            <h2 style="color: #333; margin-top: 0;">Redefinição de Senha</h2>
            <p style="color: #666; line-height: 1.6;">
                Você solicitou a redefinição da sua senha. Use o código abaixo para continuar:
            </p>
            
            <div style="background-color: #fff; padding: 20px; border-radius: 4px; text-align: center; margin: 20px 0;">
                <h1 style="color: #2E7D32; font-size: 32px; letter-spacing: 5px; margin: 0;">$resetCode</h1>
            </div>
            
            <p style="color: #666; font-size: 14px;">
                ⏰ Este código expira em <strong>15 minutos</strong>
            </p>
        </div>
        
        <div style="background-color: #fff3cd; padding: 15px; border-radius: 4px; border-left: 4px solid #ffc107;">
            <p style="margin: 0; color: #856404; font-size: 14px;">
                <strong>⚠️ Importante:</strong> Se você não solicitou esta redefinição, ignore este e-mail. 
                Sua senha permanecerá inalterada.
            </p>
        </div>
        
        <div style="text-align: center; margin-top: 30px; color: #999; font-size: 12px;">
            <p>Este é um e-mail automático, não responda.</p>
            <p>© 2024 YourTour. Todos os direitos reservados.</p>
        </div>
    </body>
    </html>
    ''';
  }

  /// Gera texto simples do e-mail
  static String _generateEmailText(String resetCode) {
    return '''
YourTour - Redefinição de Senha

Você solicitou a redefinição da sua senha. Use o código abaixo para continuar:

CÓDIGO: $resetCode

Este código expira em 15 minutos.

IMPORTANTE: Se você não solicitou esta redefinição, ignore este e-mail. 
Sua senha permanecerá inalterada.

Este é um e-mail automático, não responda.
© 2024 YourTour. Todos os direitos reservados.
    ''';
  }

  /// Valida formato de e-mail
  static bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }
}
