import 'package:edzkool/utils/authenticated_http.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:edzkool/screens/notes/clinicalnotes/sub.dart';
import 'package:edzkool/_env/notes_env.dart';
import 'package:edzkool/screens/notes/logo.dart';
import 'package:edzkool/screens/notes/topbar.dart';

// 1. DATA MODEL: Represents a single clinical case from the API
class ClinicalCase {
  final int id;
  final String caseTitle;
  final String doctorName;
  // subjectName is no longer in the API response but we keep the model flexible
  // by giving it a default value in fromJson.
  final String subjectName;
  final String gatherEquipments;
  final String introduction;
  final String generalInspection;
  final String closerInspection;
  final String palpation;
  final String finalExamination;
  final String? references;
  final DateTime createdAt;

  ClinicalCase({
    required this.id,
    required this.caseTitle,
    required this.doctorName,
    required this.subjectName,
    required this.gatherEquipments,
    required this.introduction,
    required this.generalInspection,
    required this.closerInspection,
    required this.palpation,
    required this.finalExamination,
    this.references,
    required this.createdAt,
  });

  factory ClinicalCase.fromJson(Map<String, dynamic> json) {
    return ClinicalCase(
      id: json['id'] ?? 0,
      caseTitle: json['case_title'] ?? 'No Title',
      doctorName: json['doctor_name'] ?? 'N/A',
      subjectName:
          json['subject_name'] ?? 'N/A', // Handles missing field gracefully
      gatherEquipments: json['gather_equipments'] ?? '',
      introduction: json['introduction'] ?? '',
      generalInspection: json['general_inspection'] ?? '',
      closerInspection: json['closer_inspection'] ?? '',
      palpation: json['palpation'] ?? '',
      finalExamination: json['final_examination'] ?? '',
      references: json['references'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}

// 2. MAIN WIDGET: The screen that fetches and displays the data
class ClinicalCasesScreen extends StatefulWidget {
  final String categoryName;

  const ClinicalCasesScreen({super.key, required this.categoryName});

  @override
  State<ClinicalCasesScreen> createState() => _ClinicalCasesScreenState();
}

class _ClinicalCasesScreenState extends State<ClinicalCasesScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  List<ClinicalCase> _cases = [];
  // The subjectCounts map is no longer needed

  @override
  void initState() {
    super.initState();
    _fetchClinicalCases();
  }

  Future<void> _fetchClinicalCases() async {
    try {
      final url = Uri.parse("${BaseUrl.notesApi}clinical-cases/");
      final response = await AuthenticatedHttp.get(url).timeout(const Duration(seconds: 15));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> data = decoded is List
            ? decoded
            : (decoded['results'] is List ? decoded['results'] : []);
        final List<ClinicalCase> cases = data
            .where(
              (item) =>
                  item['category'] != null &&
                  item['category']['name'] == widget.categoryName,
            )
            .map((json) => ClinicalCase.fromJson(json))
            .toList();
        if (cases.isEmpty) {
          setState(() {
            _errorMessage = 'NULL';
            _isLoading = false;
          });
          return;
        }

        // The subject counting logic is no longer needed.

        setState(() {
          _cases = cases;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Failed to load data (Code: ${response.statusCode})";
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

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Poppins'),
      ),
      child: Scaffold(
        // ✅ MODIFIED: AppBar title updated
        appBar: CustomLogoAppBar(),
        backgroundColor: Colors.white,
        body: _buildBody(),
      ),
    );
  }

  // In clinical_cases_screen.dart

  Widget _buildBody() {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final listPaddingTop = h * 0.01;
    final cardMarginH = w * 0.04;
    final cardMarginV = h * 0.012;
    final paddingH = w * 0.045;
    final paddingTop = h * 0.018;
    final paddingBottom = h * 0.02;
    final titleSize = w * 0.055;
    final doctorSize = w * 0.045;
    final errorSize = w * 0.045;
    final accentHeight = w * 0.04;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          _errorMessage,
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.red,
            fontSize: errorSize,
          ),
        ),
      );
    }

    return Column(
      children: [
        Topbar(firstText: 'Clinical', secondText: 'Cases'),
        Expanded(
          child: ListView.builder(
            itemCount: _cases.length,
            padding: EdgeInsets.only(top: listPaddingTop),
            itemBuilder: (context, index) {
              final clinicalCase = _cases[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClinicalCaseDetailScreen(
                        caseTitle: clinicalCase.id,
                        categoryName: widget.categoryName,
                      ),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          paddingH,
                          paddingTop,
                          paddingH,
                          paddingBottom,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              clinicalCase.caseTitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: titleSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: h * 0.01),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                clinicalCase.doctorName,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: doctorSize,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // ✅ Green bottom border
                      Container(
                        height: accentHeight,
                        width: double.infinity,
                        color: const Color(0xFF144787),
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
