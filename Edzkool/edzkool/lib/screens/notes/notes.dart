import 'package:edzkool/utils/authenticated_http.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:edzkool/utils/app_log.dart';
import 'package:http/http.dart' as http;
import 'package:edzkool/_env/notes_env.dart';
import 'package:edzkool/screens/notes/logo.dart';
import 'package:edzkool/screens/notes/main.dart';
import 'package:edzkool/screens/notes/topbar.dart';
// VideoTopicsScreen
import 'package:edzkool/utils/colors/colors.dart';
import 'package:edzkool/utils/responsive.dart';

// Data model for a Category
class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(id: json['id'], name: json['name']);
  }
}

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  Measurements? size;
  bool isLoading = true;
  List<Category> categories = [];

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      AppLog.debug('DEBUG: Fetching categories from ${BaseUrl.notesApi}categories/');
      final response = await AuthenticatedHttp.get(
        Uri.parse("${BaseUrl.notesApi}categories/"),
      );

      AppLog.debug('DEBUG: Categories API status: ${response.statusCode}');
      AppLog.debug('DEBUG: Categories API body: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        AppLog.debug('DEBUG: Decoded type: ${decoded.runtimeType}');
        
        // Handle the actual response format
        List<dynamic> data = [];
        
        if (decoded is List) {
          // Direct list response (after pagination fix)
          data = decoded;
          AppLog.debug('DEBUG: Response is direct list, length: ${data.length}');
        } else if (decoded is Map<String, dynamic>) {
          // Check if it's the wrapped API response
          if (decoded.containsKey('data')) {
            final innerData = decoded['data'];
            if (innerData is List) {
              data = innerData;
              AppLog.debug('DEBUG: Found data as List, length: ${data.length}');
            } else if (innerData is Map && innerData.containsKey('data')) {
              final nestedData = innerData['data'];
              data = nestedData is List ? nestedData : [];
              AppLog.debug('DEBUG: Found nested data, length: ${data.length}');
            }
          } else if (decoded.containsKey('results')) {
            data = decoded['results'] is List ? decoded['results'] : [];
            AppLog.debug('DEBUG: Found results, length: ${data.length}');
          }
        }

        AppLog.debug('DEBUG: Final data length: ${data.length}');
        if (data.isNotEmpty) {
          AppLog.debug('DEBUG: First item: ${data[0]}');
        }

        final List<Category> tempCategories =
            data.map((json) => Category.fromJson(json)).toList();

        AppLog.debug('DEBUG: Parsed categories count: ${tempCategories.length}');

        setState(() {
          categories = tempCategories;
          isLoading = false;
        });
      } else {
        AppLog.debug('DEBUG: API error: ${response.statusCode}');
        throw Exception('Failed to load categories');
      }
    } catch (e, st) {
      AppLog.debug('DEBUG: Error fetching categories: $e');
      AppLog.debug('DEBUG: Stack trace: $st');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildCategoryCard(Category category) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final marginH = w * 0.04;
    final marginV = h * 0.012;
    final cardHeight = h * 0.22;
    final titleSize = w * 0.055;
    final accentHeight = w * 0.04;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NotesScreen(className: category.name),
          ),
        );
      },
      child: Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        margin: EdgeInsets.symmetric(vertical: marginV, horizontal: marginH),
        child: SizedBox(
          height: cardHeight,
          width: double.infinity,
          child: Column(
            children: [
              ListTile(
                title: Text(
                  category.name,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: const Icon(Icons.more_vert),
              ),
              const Expanded(child: SizedBox()),
              SizedBox(height: h * 0.02),
              Container(
                height: accentHeight,
                width: double.infinity,
                color: primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    size = Measurements(MediaQuery.of(context).size);

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Poppins'),
      ),
      child: Scaffold(
        appBar: CustomLogoAppBar(),
        body: Column(
          children: [
            Topbar(firstText: "Edvoyage", secondText: "Notes"),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 10),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        return buildCategoryCard(categories[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
