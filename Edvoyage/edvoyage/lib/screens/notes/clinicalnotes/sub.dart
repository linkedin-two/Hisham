import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:edvoyage/_env/notes_env.dart';
import 'package:edvoyage/screens/notes/logo.dart';
import 'package:edvoyage/screens/notes/topbar.dart';

class ClinicalCaseDetailScreen extends StatefulWidget {
  final String categoryName;

  final int caseTitle; // ✅ use ID instead of title
  const ClinicalCaseDetailScreen({
    super.key,
    required this.caseTitle,
    required this.categoryName,
  });

  @override
  State<ClinicalCaseDetailScreen> createState() =>
      _ClinicalCaseDetailScreenState();
}

class _ClinicalCaseDetailScreenState extends State<ClinicalCaseDetailScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, dynamic>? _caseData;
  int _expandedPanelIndex = -1;

  @override
  void initState() {
    super.initState();
    _fetchCaseById();
  }

  Future<void> _fetchCaseById() async {
    try {
      final url = Uri.parse(
        "${BaseUrl.notesApi}clinical-cases/${widget.caseTitle}/",
      );
      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['category']['name'] != widget.categoryName) {
          setState(() {
            _errorMessage = 'NULL';
            _isLoading = false;
          });
          return;
        }

        setState(() {
          _caseData = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Failed to load case (Code: ${response.statusCode})";
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "An error occurred: $e";
        _isLoading = false;
      });
    }
  }

  void _onExpansionChanged(bool isExpanded, int index) {
    setState(() {
      _expandedPanelIndex = isExpanded ? index : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF1B5E20)),
        ),
      );
    }
    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        body: Center(
          child: Text(
            _errorMessage,
            style: const TextStyle(color: Color(0xFFD32F2F)),
          ),
        ),
      );
    }

    final caseData = _caseData!;
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final heroHeight = h * 0.28;
    final headerTitleSize = w * 0.055;
    final headerDoctorSize = w * 0.045;
    final tocTitleSize = w * 0.055;
    final tocItemSize = w * 0.045;
    final sectionTitleSize = w * 0.05;
    final bodySize = w * 0.045;
    final contentPadding = w * 0.045;

    final sections = [
      {'title': 'Gather Equipments', 'content': caseData['gather_equipments']},
      {'title': 'Introduction', 'content': caseData['introduction']},
      {
        'title': 'General Inspection',
        'content': caseData['general_inspection'],
      },
      {'title': 'Closer Inspection', 'content': caseData['closer_inspection']},
      {'title': 'Palpation', 'content': caseData['palpation']},
      {'title': 'Final Examination', 'content': caseData['final_examination']},
      {'title': 'References', 'content': caseData['references'] ?? ''},
    ];

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Poppins'),
      ),
      child: Scaffold(
        appBar: CustomLogoAppBar(),
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Topbar(firstText: 'Clinical', secondText: 'Case'),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: const Color(0xFF008080),
                    expandedHeight: heroHeight,
                    floating: false,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            'assets/oral_cavity.png',
                            fit: BoxFit.cover,
                          ),
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: w * 0.06,
                                    ),
                                    child: Text(
                                      caseData['case_title'] ?? 'Untitled',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        color: Colors.white,
                                        fontSize: headerTitleSize,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: h * 0.01),
                                  Text(
                                    caseData['doctor_name'] ?? '',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      color: Colors.white.withValues(alpha: 0.85),
                                      fontSize: headerDoctorSize,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      if (index == 0) {
                        return _buildTableOfContents(
                          sections,
                          titleSize: tocTitleSize,
                          itemSize: tocItemSize,
                        );
                      }
                      final section = sections[index - 1];
                      return _buildExpansionTile(
                        title: section['title']!,
                        content: section['content']!,
                        index: index,
                        isExpanded: _expandedPanelIndex == index,
                        titleSize: sectionTitleSize,
                        bodySize: bodySize,
                        contentPadding: contentPadding,
                      );
                    }, childCount: sections.length + 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableOfContents(
    List<Map<String, dynamic>> sections, {
    required double titleSize,
    required double itemSize,
  }) {
    return ExpansionTile(
      initiallyExpanded: _expandedPanelIndex == 0,
      onExpansionChanged: (expanded) => _onExpansionChanged(expanded, 0),
      title: Text(
        'Table of contents',
        style: TextStyle(
          fontFamily: 'Poppins',
          color: const Color(0xFF008080),
          fontWeight: FontWeight.w700,
          fontSize: titleSize,
        ),
      ),
      children: sections
          .asMap()
          .entries
          .map(
            (entry) => ListTile(
              title: Text(
                '${entry.key + 1}. ${entry.value['title']}',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: const Color(0xFF008080),
                  fontSize: itemSize,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
              onTap: () {
                _onExpansionChanged(true, entry.key + 1);
              },
            ),
          )
          .toList(),
    );
  }

  Widget _buildExpansionTile({
    required String title,
    required String content,
    required int index,
    required bool isExpanded,
    required double titleSize,
    required double bodySize,
    required double contentPadding,
  }) {
    return ExpansionTile(
      initiallyExpanded: isExpanded,
      onExpansionChanged: (expanded) => _onExpansionChanged(expanded, index),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Poppins',
          color: const Color(0xFF008080),
          fontWeight: FontWeight.w700,
          fontSize: titleSize,
        ),
      ),
      children: [
        Padding(
          padding: EdgeInsets.all(contentPadding),
          child: Text(
            content,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: bodySize,
              height: 1.5,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
