import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:edvoyage/utils/colors/colors.dart';
import 'package:edvoyage/_env/env.dart';
import 'package:edvoyage/widgets/botttom_nav.dart';

class UniversityFavouritesPage extends StatefulWidget {
  final String searchQuery;
  final String sortOption;
  final bool embedded;
  const UniversityFavouritesPage({
    super.key,
    this.searchQuery = '',
    this.sortOption = 'Recent',
    this.embedded = false,
  });

  @override
  _UniversityFavouritesPageState createState() =>
      _UniversityFavouritesPageState();
}

class _UniversityFavouritesPageState extends State<UniversityFavouritesPage> {
  List<dynamic> _allFavourites = [];
  List<dynamic> _filteredFavourites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFavourites();
  }

  @override
  void didUpdateWidget(covariant UniversityFavouritesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery ||
        oldWidget.sortOption != widget.sortOption) {
      _recompute();
    }
  }

  DateTime? _tryParseDate(dynamic raw) {
    if (raw == null) return null;
    if (raw is DateTime) return raw;
    final s = raw.toString().trim();
    if (s.isEmpty) return null;
    try {
      return DateTime.tryParse(s);
    } catch (_) {
      return null;
    }
  }

  double? _tryParseDouble(dynamic raw) {
    if (raw == null) return null;
    if (raw is num) return raw.toDouble();
    final s = raw.toString().trim();
    if (s.isEmpty) return null;
    return double.tryParse(s);
  }

  int? _tryParseInt(dynamic raw) {
    if (raw == null) return null;
    if (raw is num) return raw.toInt();
    final s = raw.toString().trim();
    if (s.isEmpty) return null;
    return int.tryParse(s);
  }

  String _buildLocation(Map<String, dynamic> university) {
    final city = university['city']?.toString();
    final state = university['state']?.toString();
    final country = university['country']?.toString();
    
    final parts = <String>[];
    if (city != null && city.isNotEmpty && city != 'null') parts.add(city);
    if (state != null && state.isNotEmpty && state != 'null') parts.add(state);
    if (country != null && country.isNotEmpty && country != 'null') parts.add(country);
    
    if (parts.isEmpty) return 'Unknown location';
    return parts.join(', ');
  }

  List<dynamic> _sortedCopy(List<dynamic> input) {
    final list = List<dynamic>.from(input);
    final option = (widget.sortOption).trim();

    if (option == 'Alphabetical') {
      list.sort((a, b) {
        final ua = a['university'];
        final ub = b['university'];
        final na =
            (ua is Map ? (ua['name'] ?? '') : '').toString().toLowerCase();
        final nb =
            (ub is Map ? (ub['name'] ?? '') : '').toString().toLowerCase();
        return na.compareTo(nb);
      });
      return list;
    }

    if (option == 'Recent') {
      final dates = <DateTime?>[];
      for (final item in list) {
        dates.add(_tryParseDate(item['created_at']) ??
            _tryParseDate(item['createdAt']) ??
            _tryParseDate(item['updated_at']) ??
            _tryParseDate(item['updatedAt']) ??
            _tryParseDate(item['added_at']) ??
            _tryParseDate(item['addedAt']));
      }
      if (dates.whereType<DateTime>().isEmpty) return input;
      list.sort((a, b) {
        final da = _tryParseDate(a['created_at']) ??
            _tryParseDate(a['createdAt']) ??
            _tryParseDate(a['updated_at']) ??
            _tryParseDate(a['updatedAt']) ??
            _tryParseDate(a['added_at']) ??
            _tryParseDate(a['addedAt']);
        final db = _tryParseDate(b['created_at']) ??
            _tryParseDate(b['createdAt']) ??
            _tryParseDate(b['updated_at']) ??
            _tryParseDate(b['updatedAt']) ??
            _tryParseDate(b['added_at']) ??
            _tryParseDate(b['addedAt']);
        if (da == null && db == null) return 0;
        if (da == null) return 1;
        if (db == null) return -1;
        return db.compareTo(da);
      });
      return list;
    }

    if (option == 'Rating') {
      final ratings = <double?>[];
      for (final item in list) {
        final uni = item['university'];
        if (uni is Map) {
          ratings.add(_tryParseDouble(uni['average_rating']) ??
              _tryParseDouble(uni['rating']) ??
              _tryParseDouble(uni['avg_rating']));
        } else {
          ratings.add(null);
        }
      }
      if (ratings.whereType<double>().isEmpty) return input;
      list.sort((a, b) {
        final ua = a['university'];
        final ub = b['university'];
        final ra = ua is Map
            ? (_tryParseDouble(ua['average_rating']) ??
                _tryParseDouble(ua['rating']) ??
                _tryParseDouble(ua['avg_rating']))
            : null;
        final rb = ub is Map
            ? (_tryParseDouble(ub['average_rating']) ??
                _tryParseDouble(ub['rating']) ??
                _tryParseDouble(ub['avg_rating']))
            : null;
        if (ra == null && rb == null) return 0;
        if (ra == null) return 1;
        if (rb == null) return -1;
        return rb.compareTo(ra);
      });
      return list;
    }

    if (option == 'Popularity') {
      final pops = <int?>[];
      for (final item in list) {
        final uni = item['university'];
        if (uni is Map) {
          pops.add(_tryParseInt(uni['popularity']) ??
              _tryParseInt(uni['views']) ??
              _tryParseInt(uni['total_students']) ??
              _tryParseInt(uni['followers_count']) ??
              _tryParseInt(uni['applications_count']));
        } else {
          pops.add(null);
        }
      }
      if (pops.whereType<int>().isEmpty) return input;
      list.sort((a, b) {
        final ua = a['university'];
        final ub = b['university'];
        final pa = ua is Map
            ? (_tryParseInt(ua['popularity']) ??
                _tryParseInt(ua['views']) ??
                _tryParseInt(ua['total_students']) ??
                _tryParseInt(ua['followers_count']) ??
                _tryParseInt(ua['applications_count']))
            : null;
        final pb = ub is Map
            ? (_tryParseInt(ub['popularity']) ??
                _tryParseInt(ub['views']) ??
                _tryParseInt(ub['total_students']) ??
                _tryParseInt(ub['followers_count']) ??
                _tryParseInt(ub['applications_count']))
            : null;
        if (pa == null && pb == null) return 0;
        if (pa == null) return 1;
        if (pb == null) return -1;
        return pb.compareTo(pa);
      });
      return list;
    }

    return input;
  }

  void _recompute() {
    final q = widget.searchQuery.trim().toLowerCase();
    print("🔍 DEBUG _recompute: searchQuery='$q', _allFavourites.length=${_allFavourites.length}");
    final sortedAll = _sortedCopy(_allFavourites);
    print("🔍 DEBUG _recompute: sortedAll.length=${sortedAll.length}");
    final filtered = q.isEmpty
        ? sortedAll
        : sortedAll.where((favItem) {
            final university = favItem['university'];
            final nameRaw = university is Map ? (university['name'] ?? '') : '';
            final name = nameRaw.toString().trim().toLowerCase();
            return name.startsWith(q);
          }).toList();
    print("🔍 DEBUG _recompute: filtered.length=${filtered.length}");

    setState(() {
      _filteredFavourites = filtered;
    });
  }

  Future<void> fetchFavourites() async {
    try {
      final response = await http.get(Uri.parse(BaseUrl.favouriteUniversities));

      print("Status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);

        // Check if 'data' exists (API returns {data: {data: [...], count: N}})
        if (json.containsKey('data')) {
          final responseData = json['data'];
          print("🔍 DEBUG: responseData type = ${responseData.runtimeType}");
          print("🔍 DEBUG: responseData = $responseData");
          List<dynamic> dataList = [];
          if (responseData is Map && responseData['data'] is List) {
            dataList = responseData['data'] as List<dynamic>;
            print("🔍 DEBUG: Extracted nested list with ${dataList.length} items");
          } else if (responseData is List) {
            dataList = responseData;
            print("🔍 DEBUG: responseData is direct List with ${dataList.length} items");
          } else {
            print("🔍 DEBUG: Could not extract list from responseData");
          }
          print("🎓 DEBUG: ${dataList.length} universities fetched");
          setState(() {
            _allFavourites = dataList;
            _filteredFavourites = List<dynamic>.from(dataList);
          });
          _recompute();
        } else {
          print("⚠️ 'data' key not found in JSON");
        }
      } else {
        throw Exception('Failed to load favourites');
      }
    } catch (e) {
      print("Error fetching favourites: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildCard(dynamic favItem) {
    final university = favItem['university'];
    final String logoUrl = university['logo'] ?? university['logo_url'] ?? '';
    
    String fullImageUrl = '';
    if (logoUrl.isNotEmpty) {
      if (logoUrl.contains('edvoyage.work.gd/media/')) {
        fullImageUrl = '${BaseUrl.mediaUrl}${logoUrl.substring(logoUrl.indexOf('media/') + 6)}';
      } else if (logoUrl.contains('localhost:8000/media/')) {
        fullImageUrl = '${BaseUrl.mediaUrl}${logoUrl.substring(logoUrl.indexOf('media/') + 6)}';
      } else if (logoUrl.startsWith('http')) {
        fullImageUrl = logoUrl;
      } else {
        var cleanPath = logoUrl.startsWith('/') ? logoUrl.substring(1) : logoUrl;
        if (cleanPath.startsWith('media/')) {
          cleanPath = cleanPath.substring(6);
        }
        fullImageUrl = '${BaseUrl.mediaUrl}$cleanPath';
      }
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 6,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: primaryColor.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            /// Left: Image (20%)
            Expanded(
              flex: 2,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  fullImageUrl,
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, size: 50),
                ),
              ),
            ),

            const SizedBox(width: 12),

            /// Middle: Text (60%)
            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    university['name'] ?? 'No name',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _buildLocation(university),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Estd. ${university['estd_year'] ?? university['founded_year'] ?? 'N/A'}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            /// Right: Love Icon (20%)
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerRight,
                child: const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("🔍 DEBUG build: embedded=${widget.embedded}, _isLoading=$_isLoading, _filteredFavourites.length=${_filteredFavourites.length}");
    if (widget.embedded) {
      if (_isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      if (_filteredFavourites.isEmpty) {
        return const Center(child: Text("No favourites found."));
      }
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _filteredFavourites.length,
        itemBuilder: (context, index) {
          return _buildCard(_filteredFavourites[index]);
        },
      );
    }
    return Scaffold(
      bottomNavigationBar: BottomButton(
        onTap: () {},
        selectedIndex: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredFavourites.isEmpty
              ? const Center(child: Text("No favourites found."))
              : ListView.builder(
                  itemCount: _filteredFavourites.length,
                  itemBuilder: (context, index) {
                    return _buildCard(_filteredFavourites[index]);
                  },
                ),
    );
  }
}
