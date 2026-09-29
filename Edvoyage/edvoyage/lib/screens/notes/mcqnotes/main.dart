import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:edvoyage/_env/notes_env.dart';
import 'package:edvoyage/screens/notes/logo.dart';
import 'package:edvoyage/screens/notes/topbar.dart';

// Make sure to create this new file and widget as shown in the next step
import 'sub.dart';

class McqSubject {
  final String subjectName;
  final int moduleCount;

  McqSubject({required this.subjectName, required this.moduleCount});

  factory McqSubject.fromJson(Map<String, dynamic> json) {
    return McqSubject(
      subjectName: json['subject']?['name'] ?? 'Unknown',
      moduleCount: 1, // default, will be aggregated later
    );
  }

  @override
  String toString() =>
      "McqSubject(subjectName: $subjectName, modules: $moduleCount)";
}

class McqSubjectsScreen extends StatefulWidget {
  final String categoryName;

  const McqSubjectsScreen({super.key, required this.categoryName});

  @override
  State<McqSubjectsScreen> createState() => _McqSubjectsScreenState();
}

class _McqSubjectsScreenState extends State<McqSubjectsScreen> {
  bool isLoading = true;
  List<McqSubject> mcqSubjects = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchMcqSubjects();
  }

  Future<void> fetchMcqSubjects() async {
    try {
      final response = await http.get(Uri.parse("${BaseUrl.notesApi}mcqs/"));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List<dynamic> data;
        if (decoded is List) {
          data = decoded;
        } else if (decoded is Map && decoded['results'] is List) {
          data = decoded['results'];
        } else {
          data = [];
        }

        List<McqSubject> allSubjects = data
            .where(
              (item) =>
                  item['category'] != null &&
                  item['category']['name'] == widget.categoryName,
            )
            .map((json) => McqSubject.fromJson(json))
            .toList();

        Map<String, int> subjectCounts = {};
        for (var subject in allSubjects) {
          subjectCounts[subject.subjectName] =
              (subjectCounts[subject.subjectName] ?? 0) + 1;
        }

        List<McqSubject> uniqueSubjects = subjectCounts.entries
            .map(
              (entry) =>
                  McqSubject(subjectName: entry.key, moduleCount: entry.value),
            )
            .toList();
        if (uniqueSubjects.isEmpty) {
          setState(() {
            _errorMessage = 'NULL';

            isLoading = false;
          });
          return;
        }

        setState(() {
          mcqSubjects = uniqueSubjects;
          isLoading = false;
        });

        debugPrint("Unique MCQ Subjects: $uniqueSubjects");
      } else {
        throw Exception("Failed to load MCQ subjects");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint("Error fetching MCQ subjects: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final marginH = w * 0.04;
    final marginV = h * 0.012;
    final paddingH = w * 0.045;
    final paddingV = h * 0.018;
    final titleSize = w * 0.055;
    final subtitleSize = w * 0.045;
    final errorSize = w * 0.045;
    final accentHeight = w * 0.04;

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Poppins'),
      ),
      child: Scaffold(
        appBar: CustomLogoAppBar(),
        body: Column(
          children: [
            Topbar(firstText: "MCQs", secondText: "Subjects"),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty
                      ? Center(
                          child: Text(
                            'NULL',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: errorSize,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: mcqSubjects.length,
                          itemBuilder: (context, index) {
                            final subject = mcqSubjects[index];

                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => McqModulesScreen(
                                      subjectName: subject.subjectName,
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
                                  horizontal: marginH,
                                  vertical: marginV,
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: paddingH,
                                        vertical: paddingV,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              subject.subjectName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.bold,
                                                fontSize: titleSize,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: w * 0.03),
                                          Text(
                                            "${subject.moduleCount} MCQs",
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: subtitleSize,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.grey.shade600,
                                            ),
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
        ),
      ),
    );
  }
}
