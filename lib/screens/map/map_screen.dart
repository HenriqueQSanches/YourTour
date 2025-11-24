import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:you_tour_app/services/map_location_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  static const LatLng _initialCenter = LatLng(-23.5505, -46.6333);
  static const String _nominatimEmail = 'sanches.hdigital@gmail.com';
  static const String _nominatimUserAgent = 'YouTour/1.0 (sanches.hdigital@gmail.com)';
  List<Marker> _markers = [
    const Marker(
      point: _initialCenter,
      width: 40,
      height: 40,
      child: Icon(
        Icons.location_on,
        size: 40,
        color: Color(0xFF6A1B9A),
      ),
    ),
  ];

  Future<void> _searchPlace() async {
    final String query = _searchController.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite um local para buscar')),
      );
      return;
    }
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
          'User-Agent': _nominatimUserAgent,
          'Accept-Language': 'pt-BR',
          'Referer': 'https://youtour.app',
        },
      );
      if (response.statusCode != 200) {
        final String body = response.body;
        final String snippet =
            body.isEmpty ? '' : (body.length > 140 ? '${body.substring(0, 140)}...' : body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro na busca: ${response.statusCode} ${snippet.isNotEmpty ? "- $snippet" : ""}')),
        );
        return;
      }
      final List<dynamic> results = jsonDecode(response.body) as List<dynamic>;
      if (results.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nenhum resultado encontrado')),
        );
        return;
      }
      final Map<String, dynamic> place =
          results.first as Map<String, dynamic>;
      final double lat = double.parse(place['lat'] as String);
      final double lon = double.parse(place['lon'] as String);
      final LatLng target = LatLng(lat, lon);

      FocusScope.of(context).unfocus();
      _mapController.move(target, 14);
      setState(() {
        _markers = [
          Marker(
            point: target,
            width: 40,
            height: 40,
            child: const Icon(
              Icons.location_on,
              size: 40,
              color: Color(0xFF6A1B9A),
            ),
          ),
        ];
      });
      MapLocationState.setLocation(target, query);
      try {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final String key = 'recent_searches';
        final List<String> existing = prefs.getStringList(key) ?? <String>[];
        final Map<String, dynamic> newEntry = {
          'label': query,
          'lat': lat,
          'lon': lon,
        };
        final List<Map<String, dynamic>> decoded = existing
            .map<Map<String, dynamic>>(
                (s) => jsonDecode(s) as Map<String, dynamic>)
            .where((e) => e['label'] != query)
            .toList();
        decoded.insert(0, newEntry);
        final List<String> encoded = decoded.take(8).map(jsonEncode).toList();
        await prefs.setStringList(key, encoded);
      } catch (_) {}
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao buscar local: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchController.text = MapLocationState.currentLabel.value;
      final LatLng c = MapLocationState.currentCenter.value;
      _mapController.move(c, 12);
      setState(() {
        _markers = [
          Marker(
            point: c,
            width: 40,
            height: 40,
            child: const Icon(
              Icons.location_on,
              size: 40,
              color: Color(0xFF6A1B9A),
            ),
          ),
        ];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 60,
              left: 16,
              right: 16,
              bottom: 20,
            ),
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
            child: const Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.map, color: Colors.white, size: 24),
                    SizedBox(width: 12),
                    Text(
                      'Mapa de Lugares',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Encontre os melhores lugares no mapa',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Color(0xFF6A1B9A)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Buscar no mapa...',
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                              textInputAction: TextInputAction.search,
                              onSubmitted: (_) => _searchPlace(),
                            ),
                          ),
                          InkWell(
                            onTap: _searchPlace,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6A1B9A),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.search,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: _initialCenter,
                            initialZoom: 12,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.yourtour',
                            ),
                            MarkerLayer(
                              markers: _markers,
                            ),
                          ],
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
    );
  }

  Widget _buildMapFilter(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF6A1B9A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
