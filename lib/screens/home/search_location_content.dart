import 'package:flutter/material.dart';
import 'package:you_tour_app/screens/profile/user_profile_screen.dart';
import 'location_details_screen.dart';
import '../../data/mock_data.dart';
import '../../i18n/strings.dart';
import 'package:instagram_chat/screens/chat_list_screen.dart';
import 'package:you_tour_app/services/map_location_state.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchLocationContent extends StatefulWidget {
  const SearchLocationContent({super.key});

  @override
  State<SearchLocationContent> createState() => _SearchLocationContentState();
}

class _SearchLocationContentState extends State<SearchLocationContent> {
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _nearbyDynamic = [];
  bool _loadingNearby = false;
  String _currentArea = '';
  final TextEditingController _searchCtrl = TextEditingController();
  List<Map<String, dynamic>> _recent = [];

  static const List<String> _overpassEndpoints = [
    'https://overpass.kumi.systems/api/interpreter',
    'https://overpass-api.de/api/interpreter',
    'https://overpass.openstreetmap.ru/api/interpreter',
  ];
  static const String _userAgent = 'YouTour/1.0 (sanches.hdigital@gmail.com)';
  static const String _nominatimEmail = 'sanches.hdigital@gmail.com';

  @override
  void initState() {
    super.initState();
    MapLocationState.currentCenter.addListener(_onLocationChanged);
    MapLocationState.currentLabel.addListener(_onLabelChanged);
    _currentArea = MapLocationState.currentLabel.value;
    _searchCtrl.text = _currentArea;
    _fetchNearby(MapLocationState.currentCenter.value);
    _loadRecent();
  }

  void _onLabelChanged() {
    setState(() {
      _currentArea = MapLocationState.currentLabel.value;
    });
  }

  void _onLocationChanged() {
    final LatLng center = MapLocationState.currentCenter.value;
    _fetchNearby(center);
  }

  Future<void> _fetchNearby(LatLng center) async {
    setState(() {
      _loadingNearby = true;
    });
    final String query = '''
[out:json][timeout:25];
(
  node["tourism"~"attraction|museum|artwork|gallery|viewpoint"](around:2500, ${center.latitude}, ${center.longitude});
  node["historic"](around:2500, ${center.latitude}, ${center.longitude});
  node["leisure"="park"](around:2500, ${center.latitude}, ${center.longitude});
  node["amenity"~"theatre|arts_centre"](around:2500, ${center.latitude}, ${center.longitude});
);
out body 30;
''';
    Future<List<Map<String, dynamic>>> attempt(String endpoint) async {
      final http.Response res = await http.post(
        Uri.parse(endpoint),
        headers: <String, String>{
          'User-Agent': _userAgent,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {'data': query},
      );
      if (res.statusCode != 200) {
        throw Exception('Overpass error ${res.statusCode}');
      }
      final Map<String, dynamic> data =
          jsonDecode(res.body) as Map<String, dynamic>;
      final List<dynamic> elements = (data['elements'] as List<dynamic>? ?? []);
      final List<Map<String, dynamic>> mapped = elements
          .whereType<Map<String, dynamic>>()
          .map<Map<String, dynamic>>((e) {
        final Map<String, dynamic> tags =
            (e['tags'] as Map<String, dynamic>? ?? {});
        final double? lat = (e['lat'] as num?)?.toDouble();
        final double? lon = (e['lon'] as num?)?.toDouble();
        final String name =
            (tags['name'] as String?) ?? (tags['tourism'] as String? ?? 'Ponto turístico');
        final String type = tags['tourism'] as String? ??
            tags['historic'] as String? ??
            tags['leisure'] as String? ??
            tags['amenity'] as String? ??
            'atração';
        final String? osmImage = tags['image'] as String?;
        final String? wikipedia = tags['wikipedia'] as String?;
        final String? wikidata = tags['wikidata'] as String?;
        final String? openingHours = tags['opening_hours'] as String?;
        final String? phone = (tags['phone'] as String?) ?? (tags['contact:phone'] as String?);
        final String? website = tags['website'] as String?;
        return {
          'name': name,
          'rating': 4,
          'image': 'assets/images/youtour.png',
          'description': 'Categoria: $type',
          'fullDescription':
              'Lugar interessante próximo de $_currentArea. Categoria OSM: $type.',
          'reviews': 120,
          'questions': 10,
          'code': 'OSM-${e['id']}',
          if (lat != null) 'lat': lat,
          if (lon != null) 'lon': lon,
          if (osmImage != null) 'osm_image': osmImage,
          if (wikipedia != null) 'wikipedia': wikipedia,
          if (wikidata != null) 'wikidata': wikidata,
          if (openingHours != null) 'opening_hours': openingHours,
          if (phone != null) 'phone': phone,
          if (website != null) 'website': website,
          'features': [
            'Popular para turistas',
            'Acesso público',
            'Perto da sua área'
          ],
        };
      }).toList();
      return mapped;
    }
    try {
      List<Map<String, dynamic>> result = [];
      for (final endpoint in _overpassEndpoints) {
        try {
          result = await attempt(endpoint);
          if (result.isNotEmpty) break;
        } catch (_) {
          continue;
        }
      }
      setState(() {
        _nearbyDynamic = result;
        _loadingNearby = false;
      });
    } catch (_) {
      setState(() {
        _loadingNearby = false;
        _nearbyDynamic = [];
      });
    }
  }

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

  void _openPhotoGallery(BuildContext context, Map<String, dynamic> location) {
    showDialog(
      context: context,
      builder: (context) => PhotoGalleryDialog(location: location),
    );
  }

  Future<void> _loadRecent() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<String> saved = prefs.getStringList('recent_searches') ?? <String>[];
      final List<Map<String, dynamic>> items = saved
          .map<Map<String, dynamic>>((s) => jsonDecode(s) as Map<String, dynamic>)
          .toList();
      setState(() {
        _recent = items;
      });
    } catch (_) {}
  }

  Future<void> _searchArea() async {
    final String query = _searchCtrl.text.trim();
    if (query.isEmpty) return;
    try {
      final Uri uri = Uri.https(
        'nominatim.openstreetmap.org',
        '/search',
        <String, String>{
          'q': query,
          'format': 'jsonv2',
          'limit': '1',
          'email': _nominatimEmail,
        },
      );
      final http.Response response = await http.get(
        uri,
        headers: <String, String>{
          'User-Agent': _userAgent,
          'Accept-Language': 'pt-BR',
          'Referer': 'https://youtour.app',
        },
      );
      if (response.statusCode != 200) return;
      final List<dynamic> results = jsonDecode(response.body) as List<dynamic>;
      if (results.isEmpty) return;
      final Map<String, dynamic> first = results.first as Map<String, dynamic>;
      final double lat = double.parse(first['lat'] as String);
      final double lon = double.parse(first['lon'] as String);
      MapLocationState.setLocation(LatLng(lat, lon), query);
      _loadRecent();
    } catch (_) {
      // ignora erros silenciosamente na busca da home
    }
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
                decoration: const BoxDecoration(color: Color(0xFFF3E5F5)),
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: _buildWelcomeSection(),
                    ),
                    SliverToBoxAdapter(
                      child: _buildSearchField(),
                    ),
                    SliverToBoxAdapter(
                      child: _buildSectionTitle(
                        icon: Icons.location_on,
                        title: S.of(context).t('home.nearby'),
                      ),
                    ),
                    if (_recent.isNotEmpty)
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 44,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _recent.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final r = _recent[index];
                              return ActionChip(
                                label: Text(r['label'] as String? ?? '', overflow: TextOverflow.ellipsis),
                                backgroundColor: const Color(0xFF6A1B9A).withAlpha((0.1 * 255).round()),
                                onPressed: () {
                                  final double? lat = (r['lat'] as num?)?.toDouble();
                                  final double? lon = (r['lon'] as num?)?.toDouble();
                                  final String label = r['label'] as String? ?? '';
                                  if (lat != null && lon != null) {
                                    MapLocationState.setLocation(LatLng(lat, lon), label);
                                  }
                                  _searchCtrl.text = label;
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    if (_loadingNearby)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      )
                    else if (_nearbyDynamic.isNotEmpty)
                      _buildHorizontalLocationList(_nearbyDynamic, true)
                    else
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                          child: Text(
                            'Nenhum ponto turístico encontrado nesta área.',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                      ),
                    SliverToBoxAdapter(
                      child: _buildSectionTitle(
                        icon: Icons.explore,
                        title: S.of(context).t('home.to_visit'),
                      ),
                    ),
                    _buildHorizontalLocationList(placesToVisit, false),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 20),
                    ),
                  ],
                ),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Tela Inicial',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChatListScreen(),
                    ),
                  );
                },
                icon:
                    const Icon(Icons.chat_bubble_outline, color: Colors.white),
                tooltip: 'Chat',
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserProfileScreen(),
                    ),
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

  Widget _buildWelcomeSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent,
            ),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: Image.asset(
                  'assets/images/OIG3-removebg-preview.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            S.of(context).t('home.welcome_sub'),
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF6A1B9A),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6A1B9A).withAlpha((0.1 * 255).round()),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchCtrl,
          decoration: InputDecoration(
            hintText: S.of(context).t('home.search_hint'),
            hintStyle: const TextStyle(color: Colors.grey),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF6A1B9A)),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _searchArea(),
        ),
      ),
    );
  }

  Widget _buildSectionTitle({required IconData icon, required String title}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6A1B9A).withAlpha((0.1 * 255).round()),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF6A1B9A), size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6A1B9A),
            ),
          ),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildHorizontalLocationList(
      List<Map<String, dynamic>> locations, bool showRating) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 260,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: locations.length,
          itemBuilder: (context, index) {
            final location = locations[index];
            return Container(
              width: 280,
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: _buildModernLocationCard(location, showRating),
            );
          },
        ),
      ),
    );
  }

  Widget _buildModernLocationCard(
      Map<String, dynamic> location, bool showRating) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _openPhotoGallery(context, location),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                        Colors.black.withAlpha((0.6 * 255).round()),
                      ],
                    ),
                  ),
                ),
                if (showRating)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha((0.7 * 255).round()),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          ...List.generate(5, (starIndex) {
                            return Icon(
                              Icons.star,
                              size: 12,
                              color: starIndex < location['rating']
                                  ? Colors.amber
                                  : Colors.grey[400],
                            );
                          }),
                          const SizedBox(width: 3),
                          Text(
                            '${location['rating']}.0',
                            style: const TextStyle(
                              fontSize: 11,
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          location['name'],
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D2D2D),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          location['description'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
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
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Ver Detalhes',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class PhotoGalleryDialog extends StatefulWidget {
  final Map<String, dynamic> location;

  const PhotoGalleryDialog({super.key, required this.location});

  @override
  State<PhotoGalleryDialog> createState() => _PhotoGalleryDialogState();
}

class _PhotoGalleryDialogState extends State<PhotoGalleryDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.location['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Single Photo - Removido o PageView
          Container(
            height: 400,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                widget.location['image'],
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[800],
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.photo, color: Colors.white, size: 50),
                          SizedBox(height: 8),
                          Text(
                            'Imagem não encontrada',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Footer
          Container(
            height: 60,
            padding: const EdgeInsets.only(bottom: 10),
            child: const Center(
              child: Text(
                'Toque para fechar',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
