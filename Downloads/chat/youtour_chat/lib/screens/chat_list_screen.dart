import 'package:flutter/material.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: CustomScrollView(
        slivers: [
          // AppBar moderna com gradiente
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF6E44FF),
                      Color(0xFF8A2DE2),
                      Color(0xFF4A00E0),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // BOTÃO DE VOLTA ADICIONADO AQUI
                            Container(
  width: 44,
  height: 44,
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.2),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        // TODO: Implementar funcionalidade em outra tela
      },
      child: const Icon(
        Icons.arrow_back_ios_new_rounded,
        color: Colors.white,
        size: 20,
      ),
    ),
  ),
),
                            const SizedBox(width: 12),
                            
                            // TEXTO "CONVERSAS" (agora sem Column extra)
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Conversas',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '5 mensagens não lidas',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // ÍCONE DE PERFIL
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Lista de conversas
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return _buildChatItem(context, index);
              },
              childCount: 5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, int index) {
    final names = [
      'Ana Silva',
      'Carlos Santos', 
      'Marina Costa',
      'João Pereira',
      'Beatriz Lima',
    ];
    final lastMessages = [
      'Olá! Como você está? 👋',
      'Vamos marcar aquela viagem? 📅',
      'Obrigada pela ajuda! 💜',
      'Adorei o passeio :) 📁',
      'Amanhã nos vemos! 😊',
    ];
    final times = ['10:30', '09:15', 'Ontem', '12/03', '11/03'];
    final unreadCounts = [2, 0, 1, 0, 3];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(contactName: names[index]),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 175, 161, 255),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.05),
              ),
            ),
            child: Row(
              children: [
                // Avatar com gradiente
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _getAvatarGradient(index),
                    boxShadow: [
                      BoxShadow(
                        color: _getAvatarColor(index).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      names[index][0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Conteúdo da conversa
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            names[index],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            times[index],
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lastMessages[index],
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Notificação de mensagens não lidas
                if (unreadCounts[index] > 0) ...[
                  const SizedBox(width: 12),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF6E44FF),
                          Color(0xFF8A2DE2),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        unreadCounts[index].toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  LinearGradient _getAvatarGradient(int index) {
    final gradients = [
      const LinearGradient(
        colors: [Color(0xFF6E44FF), Color(0xFF8A2DE2)],
      ),
      const LinearGradient(
        colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
      ),
      const LinearGradient(
        colors: [Color(0xFF4776E6), Color(0xFF8E54E9)],
      ),
      const LinearGradient(
        colors: [Color(0xFF834D9B), Color(0xFFD04ED6)],
      ),
      const LinearGradient(
        colors: [Color(0xFF1A2980), Color(0xFF26D0CE)],
      ),
    ];
    return gradients[index % gradients.length];
  }

  Color _getAvatarColor(int index) {
    final colors = [
      const Color(0xFF6E44FF),
      const Color(0xFF4A00E0),
      const Color(0xFF4776E6),
      const Color(0xFF834D9B),
      const Color(0xFF1A2980),
    ];
    return colors[index % colors.length];
  }
}