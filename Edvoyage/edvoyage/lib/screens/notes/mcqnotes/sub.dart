import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:edvoyage/_env/notes_env.dart';
import 'package:edvoyage/screens/notes/logo.dart';
import 'package:edvoyage/screens/notes/mcqnotes/mcq.dart';
import 'package:edvoyage/screens/notes/topbar.dart';

// 1. Model Class for the MCQ Module (No changes needed here)
class McqModule {
  final int id;
  final String title;
  final String subjectName;
  final bool isFree;
  final String logoUrl;
  final int questionCount;

  McqModule({
    required this.id,
    required this.title,
    required this.subjectName,
    required this.isFree,
    required this.logoUrl,
    required this.questionCount,
  });

  factory McqModule.fromJson(Map<String, dynamic> json) {
    final questions = json['questions'] as List<dynamic>?;
    print("Module ${json['id']} has ${questions?.length ?? 0} questions");

    return McqModule(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'No Title',
      subjectName: json['subject']?['name'] ?? 'Unknown Subject',
      isFree: json['is_free'] ?? false,
      logoUrl: json['logo'] ?? '',
      questionCount: questions?.length ?? 0, // ✅ counts properly
    );
  }
}

// 2. StatefulWidget for the Screen
class McqModulesScreen extends StatefulWidget {
  final String subjectName;

  const McqModulesScreen({super.key, required this.subjectName});

  @override
  State<McqModulesScreen> createState() => _McqModulesScreenState();
}

class _McqModulesScreenState extends State<McqModulesScreen> {
  bool _isLoading = true;
  List<McqModule> _filteredModules = [];
  String _errorMessage = ''; // Variable to hold error messages for the UI

  @override
  void initState() {
    super.initState();
    _fetchAndFilterModules();
  }

  // 3. Method to fetch and filter data
  Future<void> _fetchAndFilterModules() async {
    final url = Uri.parse("${BaseUrl.notesApi}mcqs/");

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      // ✅ IMPROVEMENT: Check if the widget is still in the tree before calling setState
      if (!mounted) return;

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        // Extract only the list from `results`
        List<dynamic> data;
        if (decoded is List) {
          data = decoded;
        } else if (decoded is Map && decoded['results'] is List) {
          data = decoded['results'];
        } else {
          data = [];
        }

        final List<McqModule> modules = data
            .map((json) => McqModule.fromJson(json))
            .where((module) => module.subjectName == widget.subjectName)
            .toList();

        setState(() {
          _filteredModules = modules;
          _isLoading = false;
        });
      } else {
        // Handle server errors more gracefully
        setState(() {
          _errorMessage = "Failed to load data (Code: ${response.statusCode})";
          _isLoading = false;
        });
      }
    } catch (e) {
      // Handle network or other errors more gracefully
      if (!mounted) return;
      setState(() {
        _errorMessage = "An error occurred: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Poppins'),
      ),
      child: Scaffold(
        appBar: CustomLogoAppBar(),
        // ✅ IMPROVEMENT: Better UI feedback for loading, empty, and error states
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final listPadding = w * 0.02;
    final cardMarginH = w * 0.04;
    final cardMarginV = h * 0.012;
    final paddingH = w * 0.045;
    final paddingV = h * 0.018;
    final titleSize = w * 0.055;
    final subtitleSize = w * 0.045;
    final errorSize = w * 0.045;
    final thumbSize = w * 0.22;
    final iconSize = w * 0.055;
    final badgeSize = w * 0.1;
    final accentHeight = w * 0.04;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: w * 0.06,
            vertical: h * 0.02,
          ),
          child: Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.red,
              fontSize: errorSize,
            ),
          ),
        ),
      );
    }

    if (_filteredModules.isEmpty) {
      return Center(
        child: Text(
          "No modules found for this subject.",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: errorSize,
          ),
        ),
      );
    }

    // ✅ FIX: The itemBuilder is now correctly placed inside a ListView.builder widget.
    return Column(
      children: [
        Topbar(firstText: "MCQ", secondText: widget.subjectName),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(listPadding),
            itemCount: _filteredModules.length,
            itemBuilder: (context, index) {
              final module = _filteredModules[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizScreen(moduleTitle: module.title),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Card(
                  elevation: 2,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  margin: EdgeInsets.symmetric(
                    horizontal: cardMarginH,
                    vertical: cardMarginV,
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: paddingH,
                          vertical: paddingV,
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: SizedBox(
                                width: thumbSize,
                                height: thumbSize,
                                child: Image.network(
                                  module.logoUrl,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.0,
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey.shade200,
                                      child: const Icon(
                                        Icons.school,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            SizedBox(width: w * 0.04),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    module.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold,
                                      fontSize: titleSize,
                                      color: const Color(0xFF008080),
                                    ),
                                  ),
                                  SizedBox(height: h * 0.01),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.timer_outlined,
                                        color: Colors.grey.shade600,
                                        size: iconSize,
                                      ),
                                      SizedBox(width: w * 0.01),
                                      Text(
                                        "${module.questionCount} MCQs",
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          color: Colors.grey.shade700,
                                          fontSize: subtitleSize,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: w * 0.02),
                            module.isFree
                                ? Image.asset(
                                    'assets/crown.png',
                                    width: badgeSize,
                                    height: badgeSize,
                                  )
                                : SvgPicture.asset(
                                    'assets/lock.svg',
                                    width: badgeSize,
                                    height: badgeSize,
                                  ),
                          ],
                        ),
                      ),
                      Container(
                        height: accentHeight,
                        width: double.infinity,
                        color: const Color(0xFF008080),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
