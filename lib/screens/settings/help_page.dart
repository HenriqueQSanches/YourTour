import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajuda & Políticas'),
        backgroundColor: const Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.security, color: Color(0xFF6A1B9A), size: 24),
                    SizedBox(width: 12),
                    Text(
                      'Políticas e Termos do YouTour',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6A1B9A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildPolicySection(
                    'Política de Privacidade',
                    Icons.privacy_tip,
                    '''
O YouTour valoriza sua privacidade e está comprometido em proteger suas informações pessoais. Coletamos apenas informações necessárias para fornecer nossos serviços de turismo.

**Informações Coletadas:**
- Dados de perfil (nome, email)
- Preferências de viagem
- Histórico de buscas
- Localização (quando permitido)

**Uso das Informações:**
- Personalizar recomendações
- Melhorar nossos serviços
- Enviar notificações relevantes

Seus dados nunca são compartilhados com terceiros sem seu consentimento.
                      ''',
                  ),
                  const SizedBox(height: 16),
                  _buildPolicySection(
                    'Termos de Uso',
                    Icons.description,
                    '''
Ao usar o YouTour, você concorda com nossos termos de serviço:

**Responsabilidades do Usuário:**
- Fornecer informações precisas
- Respeitar os direitos de propriedade intelectual
- Não usar o app para atividades ilegais

**Serviços:**
- O YouTour fornece recomendações de turismo
- Não nos responsabilizamos por serviços de terceiros
- Preços e disponibilidade sujeitos a alterações

Podemos atualizar estes termos periodicamente.
                      ''',
                  ),
                  const SizedBox(height: 16),
                  _buildPolicySection(
                    'Política de Cookies',
                    Icons.cookie,
                    '''
Utilizamos cookies e tecnologias similares para melhorar sua experiência:

**Tipos de Cookies:**
- Essenciais: funcionalidades básicas
- Preferências: lembrar suas configurações
- Analytics: entender como você usa o app
- Marketing: mostrar anúncios relevantes

Você pode gerenciar suas preferências de cookies nas configurações.
                      ''',
                  ),
                  const SizedBox(height: 16),
                  _buildContactSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicySection(String title, IconData icon, String content) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF6A1B9A), size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6A1B9A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.help_outline, color: Color(0xFF6A1B9A), size: 20),
                SizedBox(width: 8),
                Text(
                  'Precisa de Ajuda?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6A1B9A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildContactItem('Email: suporte@youtour.com', Icons.email),
            _buildContactItem('Telefone: (11) 9999-9999', Icons.phone),
            _buildContactItem('Site: www.youtour.com', Icons.language),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}