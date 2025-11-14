import 'package:flutter/material.dart';
import 'package:you_tour_app/screens/profile/profile_screen.dart';
import 'location_details_screen.dart';
import '../widgets/filter_option.dart';
import '../../data/mock_data.dart';
import 'package:instagram_chat/screens/chat_list_screen.dart';

class SearchLocationContent extends StatefulWidget {
  const SearchLocationContent({super.key});

  @override
  State<SearchLocationContent> createState() => _SearchLocationContentState();
}

class _SearchLocationContentState extends State<SearchLocationContent> {
  final PageController _nearbyController =
      PageController(viewportFraction: 0.8);
  final PageController _placesController =
      PageController(viewportFraction: 0.8);

  void _openLocationDetails(
      BuildContext context, Map<String, dynamic> location, bool isNearby) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            LocationDetailsScreen(location: location, isNearby: isNearby),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              _buildSearchField(),
              const SizedBox(height: 24),
              _buildNearbySection(context),
              const SizedBox(height: 24),
              _buildFiltersSection(),
              const SizedBox(height: 24),
              _buildPlacesToVisitSection(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF6A1B9A),
            Color(0xFF8E24AA),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 60),
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon:
                    const Icon(Icons.airplanemode_active, color: Colors.white),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChatListScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                tooltip: 'Chat',
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Your Tour',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfileScreen()),
                  );
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: const Icon(Icons.person,
                      color: Color(0xFF6A1B9A), size: 24),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'YourTour',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6A1B9A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Descubra lugares incríveis',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF6A1B9A),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6A1B9A).withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Pesquise seu local...',
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: Color(0xFF6A1B9A)),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbySection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.location_on, color: Color(0xFF6A1B9A), size: 24),
              SizedBox(width: 8),
              Text(
                'Locais por perto',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6A1B9A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 240,
            child: PageView.builder(
              controller: _nearbyController,
              scrollDirection: Axis.horizontal,
              itemCount: nearbyLocations.length,
              itemBuilder: (context, index) {
                final location = nearbyLocations[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      _openLocationDetails(context, location, true);
                    },
                    child: _buildLocationCard(location, true),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          _buildPageIndicators(_nearbyController, nearbyLocations.length),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.filter_list, color: Color(0xFF6A1B9A), size: 24),
              SizedBox(width: 8),
              Text(
                'Filtros',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6A1B9A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: const [
              FilterOption(title: '📍 Raio de distância'),
              SizedBox(height: 8),
              FilterOption(title: '💵 Preço'),
              SizedBox(height: 8),
              FilterOption(title: '🎯 Inclusos'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlacesToVisitSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.explore, color: Color(0xFF6A1B9A), size: 24),
              SizedBox(width: 8),
              Text(
                'Locais para conhecer',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6A1B9A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 240,
            child: PageView.builder(
              controller: _placesController,
              scrollDirection: Axis.horizontal,
              itemCount: placesToVisit.length,
              itemBuilder: (context, index) {
                final place = placesToVisit[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      _openLocationDetails(context, place, false);
                    },
                    child: _buildLocationCard(place, false),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          _buildPageIndicators(_placesController, placesToVisit.length),
        ],
      ),
    );
  }

  Widget _buildPageIndicators(PageController controller, int itemCount) {
    return StreamBuilder<int>(
      stream: Stream.periodic(const Duration(milliseconds: 100), (_) {
        return controller.hasClients ? controller.page?.round() ?? 0 : 0;
      }),
      builder: (context, snapshot) {
        final currentPage = snapshot.data ?? 0;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(itemCount, (index) {
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: currentPage == index
                    ? const Color(0xFF6A1B9A)
                    : Colors.grey[300],
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildLocationCard(Map<String, dynamic> location, bool showRating) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagem com overlay gradiente
          Stack(
            children: [
              Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  image: DecorationImage(
                    image: AssetImage(location['image']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Overlay gradiente
              Container(
                height: 140,
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
                      const Color(0xFF6A1B9A).withOpacity(0.7),
                    ],
                  ),
                ),
              ),
              // Badge de desconto
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE91E63),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'PROMO',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // Rating
              if (showRating)
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        ...List.generate(5, (starIndex) {
                          return Icon(
                            Icons.star,
                            size: 14,
                            color: starIndex < location['rating']
                                ? Colors.amber
                                : Colors.grey[300],
                          );
                        }),
                        const SizedBox(width: 4),
                        Text(
                          '${location['rating']}.0',
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
          // Conteúdo do card
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location['name'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6A1B9A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  location['description'],
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // Preços
                Row(
                  children: [
                    Text(
                      location['price'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      location['discountPrice'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6A1B9A),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6A1B9A).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        location['installments'].split('x')[0] + 'x',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6A1B9A),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Botão de ação
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _openLocationDetails(context, location, showRating);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A1B9A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Ver Detalhes',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nearbyController.dispose();
    _placesController.dispose();
    super.dispose();
  }
}