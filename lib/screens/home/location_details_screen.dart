import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:you_tour_app/services/map_location_state.dart';
import 'package:you_tour_app/services/navigation_state.dart';
import 'package:latlong2/latlong.dart';

class LocationDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> location;
  final bool isNearby;

  const LocationDetailsScreen({
    super.key,
    required this.location,
    required this.isNearby,
  });

  @override
  State<LocationDetailsScreen> createState() => _LocationDetailsScreenState();
}

class _LocationDetailsScreenState extends State<LocationDetailsScreen> {
  List<String> _photoUrls = [];
  bool _loading = false;
  String? _address;

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    await Future.wait([
      _fetchAddressIfPossible(),
      _fetchPhotosIfPossible(),
    ]);
  }

  Future<void> _fetchAddressIfPossible() async {
    final double? lat = (widget.location['lat'] as num?)?.toDouble();
    final double? lon = (widget.location['lon'] as num?)?.toDouble();
    if (lat == null || lon == null) return;
    try {
      final Uri uri = Uri.https(
        'nominatim.openstreetmap.org',
        '/reverse',
        <String, String>{
          'lat': '$lat',
          'lon': '$lon',
          'format': 'jsonv2',
          'email': 'sanches.hdigital@gmail.com',
        },
      );
      final http.Response res = await http.get(uri, headers: const {
        'User-Agent': 'YouTour/1.0 (sanches.hdigital@gmail.com)',
        'Accept-Language': 'pt-BR',
      });
      if (res.statusCode != 200) return;
      final Map<String, dynamic> data =
          jsonDecode(res.body) as Map<String, dynamic>;
      final String? display = data['display_name'] as String?;
      if (display != null) {
        setState(() {
          _address = display;
        });
      }
    } catch (_) {}
  }

  Future<void> _fetchPhotosIfPossible() async {
    final double? lat = (widget.location['lat'] as num?)?.toDouble();
    final double? lon = (widget.location['lon'] as num?)?.toDouble();
    if (lat == null || lon == null) return;

    setState(() {
      _loading = true;
    });

    final String? osmImage = widget.location['osm_image'] as String?;
    if (osmImage != null && osmImage.isNotEmpty) {
      final List<String> urlsFromTag =
          await _tryResolveOsmImageTag(osmImage.trim());
      if (urlsFromTag.isNotEmpty) {
        setState(() {
          _photoUrls = urlsFromTag;
          _loading = false;
        });
        return;
      }
    }
    final String? wikidataId = widget.location['wikidata'] as String?;
    if (wikidataId != null && wikidataId.isNotEmpty) {
      final String? p18Url = await _tryFetchWikidataP18(wikidataId);
      if (p18Url != null) {
        setState(() {
          _photoUrls = [p18Url];
          _loading = false;
        });
        return;
      }
    }
    final String? wikipediaTag = widget.location['wikipedia'] as String?;
    if (wikipediaTag != null && wikipediaTag.isNotEmpty) {
      final String? wikiPhoto = await _tryFetchWikipediaPhoto(wikipediaTag);
      if (wikiPhoto != null) {
        setState(() {
          _photoUrls = [wikiPhoto];
          _loading = false;
        });
        return;
      }
    }

    final Uri uri = Uri.parse(
        'https://commons.wikimedia.org/w/api.php?action=query&generator=geosearch&ggscoord=$lat|$lon&ggsradius=10000&ggslimit=20&prop=pageimages&piprop=thumbnail%7Coriginal&pithumbsize=1200&format=json');
    try {
      final http.Response res = await http.get(uri, headers: const {
        'User-Agent': 'YouTour/1.0 (sanches.hdigital@gmail.com)',
      });
      if (res.statusCode != 200) {
        await _fetchPhotosFallback(lat, lon);
        return;
      }
      final Map<String, dynamic> data =
          jsonDecode(res.body) as Map<String, dynamic>;
      final Map<String, dynamic>? pages =
          (data['query'] as Map<String, dynamic>?)?['pages']
              as Map<String, dynamic>?;
      if (pages == null) {
        await _fetchPhotosFallback(lat, lon);
        return;
      }
      final List<String> urls = [];
      for (final entry in pages.values) {
        final Map<String, dynamic> p = entry as Map<String, dynamic>;
        final Map<String, dynamic>? thumb = p['thumbnail'] as Map<String, dynamic>?;
        final Map<String, dynamic>? original = p['original'] as Map<String, dynamic>?;
        final String? url = (original?['source'] as String?) ?? (thumb?['source'] as String?);
        if (url != null) {
          urls.add(url);
        }
      }
      if (urls.isNotEmpty) {
        setState(() {
          _photoUrls = urls;
          _loading = false;
        });
      } else {
        await _fetchPhotosFallback(lat, lon);
      }
    } catch (_) {
      await _fetchPhotosFallback(lat, lon);
    }
  }

  Future<List<String>> _tryResolveOsmImageTag(String value) async {
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return [value];
    }
    if (value.startsWith('File:')) {
      final String encoded = Uri.encodeFull(value);
      final Uri uri = Uri.parse(
          'https://commons.wikimedia.org/w/api.php?action=query&titles=$encoded&prop=imageinfo&iiprop=url&iiurlwidth=1200&format=json');
      try {
        final http.Response res = await http.get(uri, headers: const {
          'User-Agent': 'YouTour/1.0 (sanches.hdigital@gmail.com)',
        });
        if (res.statusCode != 200) return [];
        final Map<String, dynamic> data =
            jsonDecode(res.body) as Map<String, dynamic>;
        final Map<String, dynamic>? pages =
            (data['query'] as Map<String, dynamic>?)?['pages']
                as Map<String, dynamic>?;
        if (pages == null) return [];
        for (final entry in pages.values) {
          final Map<String, dynamic> p = entry as Map<String, dynamic>;
          final List<dynamic>? ii = p['imageinfo'] as List<dynamic>?;
          if (ii == null || ii.isEmpty) continue;
          final Map<String, dynamic> info = ii.first as Map<String, dynamic>;
          final String? url =
              (info['thumburl'] as String?) ?? (info['url'] as String?);
          if (url != null) return [url];
        }
      } catch (_) {
        return [];
      }
    }
    if (value.startsWith('Category:')) {
      try {
        final String encoded = Uri.encodeFull(value);
        final Uri uri = Uri.parse(
            'https://commons.wikimedia.org/w/api.php?action=query&generator=categorymembers&gcmtype=file&gcmtitle=$encoded&gcmlimit=12&prop=imageinfo&iiprop=url&iiurlwidth=1200&format=json');
        final http.Response res = await http.get(uri, headers: const {
          'User-Agent': 'YouTour/1.0 (sanches.hdigital@gmail.com)',
        });
        if (res.statusCode != 200) return [];
        final Map<String, dynamic> data =
            jsonDecode(res.body) as Map<String, dynamic>;
        final Map<String, dynamic>? pages =
            (data['query'] as Map<String, dynamic>?)?['pages']
                as Map<String, dynamic>?;
        if (pages == null) return [];
        final List<String> urls = [];
        for (final entry in pages.values) {
          final Map<String, dynamic> p = entry as Map<String, dynamic>;
          final List<dynamic>? ii = p['imageinfo'] as List<dynamic>?;
          if (ii == null || ii.isEmpty) continue;
          final Map<String, dynamic> info = ii.first as Map<String, dynamic>;
          final String? url =
              (info['thumburl'] as String?) ?? (info['url'] as String?);
          if (url != null) urls.add(url);
        }
        return urls;
      } catch (_) {
        return [];
      }
    }
    return [];
  }

  Future<String?> _tryFetchWikipediaPhoto(String wikipediaTag) async {
    try {
      final int idx = wikipediaTag.indexOf(':');
      if (idx <= 0) return null;
      final String lang = wikipediaTag.substring(0, idx);
      final String title = wikipediaTag.substring(idx + 1);
      final String encodedTitle = Uri.encodeFull(title);
      final Uri uri = Uri.parse(
          'https://$lang.wikipedia.org/w/api.php?action=query&prop=pageimages&pithumbsize=1200&titles=$encodedTitle&format=json');
      final http.Response res = await http.get(uri, headers: const {
        'User-Agent': 'YouTour/1.0 (sanches.hdigital@gmail.com)',
      });
      if (res.statusCode != 200) return null;
      final Map<String, dynamic> data =
          jsonDecode(res.body) as Map<String, dynamic>;
      final Map<String, dynamic>? pages =
          (data['query'] as Map<String, dynamic>?)?['pages']
              as Map<String, dynamic>?;
      if (pages == null) return null;
      for (final entry in pages.values) {
        final Map<String, dynamic> p = entry as Map<String, dynamic>;
        final Map<String, dynamic>? thumb =
            p['thumbnail'] as Map<String, dynamic>?;
        final String? url = thumb?['source'] as String?;
        if (url != null) return url;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<String?> _tryFetchWikidataP18(String qid) async {
    try {
      final String id = qid.startsWith('Q') ? qid : 'Q$qid';
      final Uri wd = Uri.parse(
          'https://www.wikidata.org/w/api.php?action=wbgetentities&ids=$id&props=claims&format=json');
      final http.Response res = await http.get(wd, headers: const {
        'User-Agent': 'YouTour/1.0 (sanches.hdigital@gmail.com)',
      });
      if (res.statusCode != 200) return null;
      final Map<String, dynamic> data =
          jsonDecode(res.body) as Map<String, dynamic>;
      final Map<String, dynamic>? entities =
          data['entities'] as Map<String, dynamic>?;
      if (entities == null) return null;
      final Map<String, dynamic>? ent = entities[id] as Map<String, dynamic>?;
      if (ent == null) return null;
      final Map<String, dynamic>? claims =
          ent['claims'] as Map<String, dynamic>?;
      if (claims == null) return null;
      final List<dynamic>? p18 = claims['P18'] as List<dynamic>?;
      if (p18 == null || p18.isEmpty) return null;
      final Map<String, dynamic> mainsnak =
          (p18.first as Map<String, dynamic>)['mainsnak']
              as Map<String, dynamic>;
      final Map<String, dynamic>? datavalue =
          mainsnak['datavalue'] as Map<String, dynamic>?;
      final String? filename = datavalue?['value'] as String?; // e.g., Some.jpg
      if (filename == null) return null;
      final String fileTitle =
          filename.startsWith('File:') ? filename : 'File:$filename';
      final String encoded = Uri.encodeFull(fileTitle);
      final Uri uri = Uri.parse(
          'https://commons.wikimedia.org/w/api.php?action=query&titles=$encoded&prop=imageinfo&iiprop=url&iiurlwidth=1200&format=json');
      final http.Response res2 = await http.get(uri, headers: const {
        'User-Agent': 'YouTour/1.0 (sanches.hdigital@gmail.com)',
      });
      if (res2.statusCode != 200) return null;
      final Map<String, dynamic> data2 =
          jsonDecode(res2.body) as Map<String, dynamic>;
      final Map<String, dynamic>? pages =
          (data2['query'] as Map<String, dynamic>?)?['pages']
              as Map<String, dynamic>?;
      if (pages == null) return null;
      for (final entry in pages.values) {
        final Map<String, dynamic> p = entry as Map<String, dynamic>;
        final List<dynamic>? ii = p['imageinfo'] as List<dynamic>?;
        if (ii == null || ii.isEmpty) continue;
        final Map<String, dynamic> info = ii.first as Map<String, dynamic>;
        final String? url =
            (info['thumburl'] as String?) ?? (info['url'] as String?);
        if (url != null) return url;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _fetchPhotosFallback(double lat, double lon) async {
    try {
      // 1) Pega páginas próximas e lista de arquivos (images)
      final Uri listImages = Uri.parse(
          'https://commons.wikimedia.org/w/api.php?action=query&generator=geosearch&ggscoord=$lat|$lon&ggsradius=8000&ggslimit=20&prop=images&format=json');
      final http.Response res1 = await http.get(listImages, headers: const {
        'User-Agent': 'YouTour/1.0 (sanches.hdigital@gmail.com)',
      });
      if (res1.statusCode != 200) {
        setState(() {
          _loading = false;
        });
        return;
      }
      final Map<String, dynamic> data1 =
          jsonDecode(res1.body) as Map<String, dynamic>;
      final Map<String, dynamic>? pages1 =
          (data1['query'] as Map<String, dynamic>?)?['pages']
              as Map<String, dynamic>?;
      if (pages1 == null) {
        setState(() {
          _loading = false;
        });
        return;
      }
      final Set<String> fileTitles = <String>{};
      for (final entry in pages1.values) {
        final Map<String, dynamic> p = entry as Map<String, dynamic>;
        final List<dynamic>? imgs = p['images'] as List<dynamic>?;
        if (imgs == null) continue;
        for (final img in imgs) {
          final Map<String, dynamic> im = img as Map<String, dynamic>;
          final String? title = im['title'] as String?; // "File:...."
          if (title != null && title.startsWith('File:')) {
            fileTitles.add(title);
          }
        }
      }
      if (fileTitles.isEmpty) {
        setState(() {
          _loading = false;
        });
        return;
      }

      // 2) Busca URL direta dessas imagens
      final String titlesParam = fileTitles.take(12).join('|');
      final Uri imagesInfo = Uri.parse(
          'https://commons.wikimedia.org/w/api.php?action=query&titles=$titlesParam&prop=imageinfo&iiprop=url&iiurlwidth=1200&format=json');
      final http.Response res2 = await http.get(imagesInfo, headers: const {
        'User-Agent': 'YouTour/1.0 (sanches.hdigital@gmail.com)',
      });
      if (res2.statusCode != 200) {
        setState(() {
          _loading = false;
        });
        return;
      }
      final Map<String, dynamic> data2 =
          jsonDecode(res2.body) as Map<String, dynamic>;
      final Map<String, dynamic>? pages2 =
          (data2['query'] as Map<String, dynamic>?)?['pages']
              as Map<String, dynamic>?;
      final List<String> urls = <String>[];
      if (pages2 != null) {
        for (final entry in pages2.values) {
          final Map<String, dynamic> p = entry as Map<String, dynamic>;
          final List<dynamic>? ii = p['imageinfo'] as List<dynamic>?;
          if (ii == null || ii.isEmpty) continue;
          final Map<String, dynamic> info = ii.first as Map<String, dynamic>;
          final String? url = (info['thumburl'] as String?) ?? (info['url'] as String?);
          if (url != null) urls.add(url);
        }
      }
      setState(() {
        _photoUrls = urls;
        _loading = false;
      });

      // 3) Se ainda vazio, tenta Wikipedia geosearch (pt -> en)
      if (urls.isEmpty) {
        final String? wikiGeo =
            await _tryFetchWikipediaGeoPhoto(lat: lat, lon: lon);
        if (wikiGeo != null) {
          setState(() {
            _photoUrls = [wikiGeo];
            _loading = false;
          });
        }
      }
    } catch (_) {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<String?> _tryFetchWikipediaGeoPhoto({required double lat, required double lon}) async {
    Future<String?> attempt(String lang) async {
      final Uri uri = Uri.parse(
          'https://$lang.wikipedia.org/w/api.php?action=query&prop=pageimages&generator=geosearch&ggscoord=$lat|$lon&ggsradius=8000&ggslimit=10&pithumbsize=1200&format=json');
      final http.Response res = await http.get(uri, headers: const {
        'User-Agent': 'YouTour/1.0 (sanches.hdigital@gmail.com)',
      });
      if (res.statusCode != 200) return null;
      final Map<String, dynamic> data =
          jsonDecode(res.body) as Map<String, dynamic>;
      final Map<String, dynamic>? pages =
          (data['query'] as Map<String, dynamic>?)?['pages']
              as Map<String, dynamic>?;
      if (pages == null) return null;
      for (final entry in pages.values) {
        final Map<String, dynamic> p = entry as Map<String, dynamic>;
        final Map<String, dynamic>? thumb = p['thumbnail'] as Map<String, dynamic>?;
        final String? url = thumb?['source'] as String?;
        if (url != null) return url;
      }
      return null;
    }

    return await attempt('pt') ?? await attempt('en');
  }

  @override
  Widget build(BuildContext context) {
    final location = widget.location;
    final bool hasNetworkHero = _photoUrls.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  Positioned.fill(
                    child: hasNetworkHero
                        ? CachedNetworkImage(
                            imageUrl: _photoUrls.first,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            location['image'],
                            fit: BoxFit.cover,
                          ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            const Color(0xFF6A1B9A).withAlpha((0.8 * 255).round()),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            backgroundColor: const Color(0xFF6A1B9A),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFF3E5F5),
                    Colors.white,
                  ],
                ),
              ),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      location['name'],
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF6A1B9A),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF6A1B9A),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Code: ${location['code']}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if ((location['lat'] as num?) != null &&
                                  (location['lon'] as num?) != null) ...[
                                Row(
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        final double lat = (location['lat'] as num).toDouble();
                                        final double lon = (location['lon'] as num).toDouble();
                                        MapLocationState.setLocation(
                                          LatLng(lat, lon),
                                          location['name'] as String? ?? 'Local',
                                        );
                                        NavigationState.currentTabIndex.value = 3;
                                        Navigator.pop(context);
                                      },
                                      icon: const Icon(Icons.map_outlined, size: 18),
                                      label: const Text('Ver no mapa'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF6A1B9A),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        elevation: 0,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                              ],
                              if (_address != null) ...[
                                Row(
                                  children: [
                                    const Icon(Icons.place,
                                        color: Color(0xFF6A1B9A), size: 20),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        _address!,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                              ],
                              if (location['opening_hours'] != null) ...[
                                Row(
                                  children: [
                                    const Icon(Icons.access_time, color: Color(0xFF6A1B9A), size: 20),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        location['opening_hours'] as String,
                                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                              ],
                              if (location['phone'] != null) ...[
                                Row(
                                  children: [
                                    const Icon(Icons.phone, color: Color(0xFF6A1B9A), size: 20),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        location['phone'] as String,
                                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                              ],
                              if (location['website'] != null) ...[
                                Row(
                                  children: [
                                    const Icon(Icons.public, color: Color(0xFF6A1B9A), size: 20),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        location['website'] as String,
                                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                              ],
                              if (widget.isNearby) ...[
                                Row(
                                  children: [
                                    ...List.generate(5, (starIndex) {
                                      return Icon(
                                        Icons.star,
                                        size: 20,
                                        color: starIndex < location['rating']
                                            ? Colors.amber
                                            : Colors.grey[300],
                                      );
                                    }),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${location['reviews']} Avaliações',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      '${location['questions']} Perguntas',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                              ],
                              Text(
                                location['fullDescription'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      if (_loading)
                        const Center(child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ))
                      else if (_photoUrls.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            'Galeria',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6A1B9A),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 200,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _photoUrls.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final String url = _photoUrls[index];
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: CachedNetworkImage(
                                    imageUrl: url,
                                    fit: BoxFit.cover,
                                    placeholder: (context, _) =>
                                        Container(color: Colors.grey[300]),
                                    errorWidget: (context, _, __) =>
                                        Container(color: Colors.grey[300]),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.celebration,
                                      color: Color(0xFF6A1B9A), size: 24),
                                  SizedBox(width: 8),
                                  Text(
                                    'Características',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF6A1B9A),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: location['features'].map<Widget>((feature) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF6A1B9A)
                                          .withAlpha((0.1 * 255).round()),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0xFF6A1B9A)
                                            .withAlpha((0.3 * 255).round()),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.check_circle,
                                            color: Color(0xFF6A1B9A), size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          feature,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF6A1B9A),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
