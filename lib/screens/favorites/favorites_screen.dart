import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../screens/home/home_screen.dart'; // Import da home screen

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // Lista de favoritos - agora é mutável para poder adicionar/remover
  List<FavoriteItem> favorites = [
    FavoriteItem(
      title: 'Rio de Janeiro',
      subtitle: 'Brasil',
      imageUrl:
          'https://images.unsplash.com/photo-1483729558449-99ef09a8c325?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&h=300&q=80',
      rating: 4.8,
      category: 'Praia',
    ),
    FavoriteItem(
      title: 'Paris',
      subtitle: 'França',
      imageUrl:
          'https://media.staticontent.com/media/pictures/01512cb2-8e58-47ca-addf-c8aadbfcde82',
      rating: 4.9,
      category: 'Cidade',
    ),
    FavoriteItem(
      title: 'Machu Picchu',
      subtitle: 'Peru',
      imageUrl:
          'https://images.unsplash.com/photo-1587595431973-160d0d94add1?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&h=300&q=80',
      rating: 4.7,
      category: 'Histórico',
    ),
    FavoriteItem(
      title: 'Santorini',
      subtitle: 'Grécia',
      imageUrl:
          'https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&h=300&q=80',
      rating: 4.9,
      category: 'Ilha',
    ),
    FavoriteItem(
      title: 'Tokyo',
      subtitle: 'Japão',
      imageUrl:
          'https://cdnfrontdoor.travelconline.com/images/fit-in/2000x0/filters:quality(75):strip_metadata():format(webp)/https%3A%2F%2Ffrontdoor.travelconline.com%2Fimagenes%2FK3JpqxcG9OIw-5BresIITLnjpeg.jpeg',
      rating: 4.8,
      category: 'Metrópole',
    ),
  ];

  // Método para remover um favorito
  void _removeFavorite(int index) {
    setState(() {
      final removedItem = favorites.removeAt(index);
      _showRemovedSnackbar(context, removedItem.title, index, removedItem);
    });
  }

  // Método para adicionar um favorito de volta (desfazer)
  void _addFavoriteBack(FavoriteItem item, int originalIndex) {
    setState(() {
      favorites.insert(originalIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF3E5F5),
                ),
                child: _buildContent(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: const BoxDecoration(
        color: Color(0xFF6A1B9A),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              // Volta para a tela inicial usando Navigator.pushReplacement
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) =>
                      const HomeScreen(), // Navega para HomeScreen
                ),
              );
            },
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            tooltip: 'Voltar',
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Favoritos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // Espaço vazio para manter o balanceamento
          const SizedBox(width: 48), // Mesma largura do IconButton
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.favorite, color: Color(0xFF6A1B9A), size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Seus Destinos Favoritos',
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
            child: _buildFavoritesList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(BuildContext context) {
    if (favorites.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final favorite = favorites[index];
        return _buildFavoriteCard(favorite, context, index);
      },
    );
  }

  Widget _buildFavoriteCard(
      FavoriteItem favorite, BuildContext context, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.network(
                  favorite.imageUrl,
                  width: double.infinity,
                  height: 160,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 160,
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.photo,
                        color: Colors.grey,
                        size: 50,
                      ),
                    );
                  },
                ),
              ),
              // Gradient Overlay
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withAlpha((0.6 * 255).round()),
                    ],
                  ),
                ),
              ),
              // Favorite Icon - Agora com funcionalidade de remover
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () {
                    _showRemoveFavoriteDialog(context, favorite.title, index);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha((0.6 * 255).round()),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                ),
              ),
              // Category Badge
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha((0.7 * 255).round()),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    favorite.category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              // Rating
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha((0.7 * 255).round()),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      ...List.generate(5, (starIndex) {
                        return Icon(
                          Icons.star,
                          size: 14,
                          color: starIndex < favorite.rating.floor()
                              ? Colors.amber
                              : Colors.grey[400],
                        );
                      }),
                      const SizedBox(width: 4),
                      Text(
                        '${favorite.rating}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Content Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  favorite.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6A1B9A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  favorite.subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _showDetailsDialog(context, favorite);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF6A1B9A),
                          side: const BorderSide(color: Color(0xFF6A1B9A)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Detalhes',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _showPlanTripDialog(context, favorite.title);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6A1B9A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Viajar',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.favorite_border,
            size: 80,
            color: Color(0xFF6A1B9A),
          ),
          const SizedBox(height: 20),
          const Text(
            'Nenhum favorito ainda',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6A1B9A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione destinos aos favoritos para vê-los aqui',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Volta para a home screen
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A1B9A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Explorar Destinos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRemoveFavoriteDialog(
      BuildContext context, String title, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remover Favorito'),
          content: Text('Deseja remover $title dos seus favoritos?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _removeFavorite(index);
                Navigator.of(context).pop();
              },
              child: const Text(
                'Remover',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDetailsDialog(BuildContext context, FavoriteItem favorite) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  favorite.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6A1B9A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  favorite.subtitle,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.category,
                        size: 20, color: Color(0xFF6A1B9A)),
                    const SizedBox(width: 8),
                    Text(
                      'Categoria: ${favorite.category}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, size: 20, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(
                      'Avaliação: ${favorite.rating}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A1B9A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Fechar'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPlanTripDialog(BuildContext context, String destination) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Planejar Viagem',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6A1B9A),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Clique no botão abaixo para planejar sua viagem:'),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF6A1B9A),
                          side: const BorderSide(color: Color(0xFF6A1B9A)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final Uri url = Uri.parse(
                              'https://123milhas.com/?srsltid=AfmBOopTQ2CyDnd86k2gBvi7IFduAN37Xnez3unMOG1A-lr6_nGPlwLw');
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                            Navigator.of(context).pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6A1B9A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Abrir Site'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRemovedSnackbar(BuildContext context, String title,
      int originalIndex, FavoriteItem removedItem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title removido dos favoritos'),
        backgroundColor: const Color(0xFF6A1B9A),
        action: SnackBarAction(
          label: 'Desfazer',
          textColor: Colors.white,
          onPressed: () {
            _addFavoriteBack(removedItem, originalIndex);
          },
        ),
      ),
    );
  }
}

class FavoriteItem {
  final String title;
  final String subtitle;
  final String imageUrl;
  final double rating;
  final String category;

  FavoriteItem({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.rating,
    required this.category,
  });
}
