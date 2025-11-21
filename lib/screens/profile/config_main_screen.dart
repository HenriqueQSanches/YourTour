import 'package:flutter/material.dart';
import '../settings/language_page.dart';
import '../settings/help_page.dart';
import '../settings/user_data_page.dart';
import '../favorites/favorites_screen.dart';
import '../../screens/home/home_screen.dart'; // Caminho corrigido para a HomeScreen
import '../../login_screen.dart';
import '../../services/session_manager.dart';
import '../../i18n/strings.dart';

class ConfigMainScreen extends StatelessWidget {
  const ConfigMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0, // Remove a altura padrão do AppBar
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF3E5F5),
              Color(0xFFE1BEE7),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            // Header unificado com AppBar - AGORA MENOR
            _buildUnifiedHeader(context),
            // Lista de opções
            Expanded(
              child: _buildSettingsList(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnifiedHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 40, // Reduzido de 50 para 40
        left: 16,
        right: 16,
        bottom: 12, // Reduzido de 16 para 12
      ),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        image: DecorationImage(
          image: AssetImage(
              'assets/images/Aesthetic pictures - Aesthetic wallpapers - AI pictures 179.jpg'),
          fit: BoxFit.cover,
        ),
        color: Color.fromRGBO(0, 0, 0, 0.4),
      ),
      child: Column(
        children: [
          // Botão de voltar e título Configurações
          Row(
            children: [
              // Botão de voltar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((0.3 * 255).round()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () {
                    // Navega para a HomeScreen
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomeScreen()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 20,
                  ),
                  padding: const EdgeInsets.all(4),
                ),
              ),
              const SizedBox(width: 12),
              // Título Configurações
              Text(
                S.of(context).t('app.settings'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20, // Reduzido de 24 para 20
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 10,
                      color: Colors.black45,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12), // Reduzido de 20 para 12
          // Logo do YouTour - MENOR
          Container(
            width: 60, // Reduzido de 80 para 60
            height: 60, // Reduzido de 80 para 60
            child: Image.asset(
              'assets/images/youtour.png',
              width: 50, // Reduzido de 70 para 50
              height: 50, // Reduzido de 70 para 50
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.travel_explore,
                  size: 30, // Reduzido de 40 para 30
                  color: Colors.white,
                );
              },
            ),
          ),
          const SizedBox(height: 8), // Reduzido de 12 para 8
          // Texto YouTour
          const Text(
            'YouTour',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18, // Reduzido de 20 para 18
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
              shadows: [
                Shadow(
                  blurRadius: 10,
                  color: Colors.black45,
                  offset: Offset(2, 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Sua jornada, nossa paixão',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11, // Reduzido de 12 para 11
              fontStyle: FontStyle.italic,
              shadows: [
                Shadow(
                  blurRadius: 8,
                  color: Colors.black45,
                  offset: Offset(1, 1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10), // Reduzido de 16 para 10
          // Informações do usuário - MENOR
          _buildUserInfo(),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    final user = SessionManager.currentUser;
    return Container(
      padding: const EdgeInsets.all(10), // Reduzido de 12 para 10
      decoration: BoxDecoration(
        color: Colors.black.withAlpha((0.3 * 255).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha((0.3 * 255).round())),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18, // Reduzido de 20 para 18
            backgroundColor: Colors.white,
            backgroundImage: NetworkImage(
              'https://images.unsplash.com/photo-1473172707857-f9e276582ab6?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&h=200&q=80',
            ),
          ),
          const SizedBox(width: 8), // Reduzido de 10 para 8
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.userName ?? 'Usuário',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13, // Reduzido de 14 para 13
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 5,
                        color: Colors.black45,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user?.userEmail ?? '',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10, // Reduzido de 11 para 10
                    shadows: [
                      Shadow(
                        blurRadius: 5,
                        color: Colors.black45,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Sem botão de edição nesta tela (somente leitura)
        ],
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context) {
    final List<SettingItem> settings = [
      SettingItem(
        title: S.of(context).t('app.favorites'),
        icon: Icons.favorite,
        color: const Color(0xFFE91E63),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FavoritesScreen()),
          );
        },
      ),
      SettingItem(
        title: S.of(context).t('app.language'),
        icon: Icons.language,
        color: const Color(0xFF9C27B0),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LanguagePage()),
          );
        },
      ),
      SettingItem(
        title: S.of(context).t('app.help_policies'),
        icon: Icons.help_outline,
        color: const Color(0xFF673AB7),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HelpPage()),
          );
        },
      ),
      SettingItem(
        title: S.of(context).t('app.my_data'),
        icon: Icons.person_outline,
        color: const Color(0xFF5E35B1),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UserDataPage()),
          );
        },
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Seção de Configurações
        _buildSectionTitle(S.of(context).t('app.settings')),
        ...settings.map((item) => _buildSettingItem(item, context)),

        const SizedBox(height: 8),

        // Botão Sair
        _buildLogoutButton(context),

        const SizedBox(height: 20),

        // Informações da versão
        _buildVersionInfo(),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF6A1B9A),
        ),
      ),
    );
  }

  Widget _buildSettingItem(SettingItem item, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: item.color.withAlpha((0.1 * 255).round()),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            item.icon,
            color: item.color,
            size: 20,
          ),
        ),
        title: Text(
          item.title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: item.onTap,
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Logo pequena - SEM FUNDO
            SizedBox(
              width: 40,
              height: 40,
              child: Image.asset(
                'assets/images/youtour.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.travel_explore,
                    color: Color(0xFF6A1B9A),
                    size: 20,
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'YouTour',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF6A1B9A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Versão 1.0.0',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '© 2024 YouTour. Todos os direitos reservados.',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.red.withAlpha((0.2 * 255).round())),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.red.withAlpha((0.1 * 255).round()),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.logout,
            color: Colors.red,
            size: 20,
          ),
        ),
        title: const Text(
          'Sair',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: Colors.red,
          ),
        ),
        onTap: () {
          _showLogoutDialog(context);
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sair do App'),
          content: const Text('Tem certeza que deseja sair do YouTour?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: const Text(
                'Sair',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}

class SettingItem {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  SettingItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  }