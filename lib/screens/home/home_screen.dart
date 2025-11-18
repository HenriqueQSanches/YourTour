import 'package:flutter/material.dart';
import 'package:you_tour_app/screens/profile/config_main_screen.dart';
import 'search_location_content.dart';
import '../favorites/favorites_screen.dart';
import '../map/map_screen.dart';
import '../feed/feed_screen.dart'; // Importe a tela de feed
import '../../i18n/strings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const SearchLocationContent(),
    const FeedScreen(), // Adicione a tela de feed
    const FavoritesScreen(),
    const MapScreen(),
    const ConfigMainScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF6A1B9A),
      unselectedItemColor: Colors.grey[600],
      selectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: S.of(context).t('nav.home'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.feed), // Ícone para feed
          label: S
              .of(context)
              .t('nav.feed'), // Você precisará adicionar esta tradução
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.favorite),
          label: S.of(context).t('nav.favorites'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.map),
          label: S.of(context).t('nav.map'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings),
          label: S.of(context).t('nav.settings'),
        ),
      ],
    );
  }
}
