import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:edvoyage/_env/notes_env.dart';
import 'package:edvoyage/screens/notes/logo.dart';
import 'package:edvoyage/screens/notes/topbar.dart';
import 'package:edvoyage/screens/notes/videonotes/sub.dart'; // VideoTopicsScreen and VideosBySubjectScreen
import 'package:edvoyage/utils/colors/colors.dart';
import 'package:edvoyage/utils/responsive.dart';

// Data model for a Subject
class Subject {
  final int id;
  final String name;
  final int videoCount;

  Subject({required this.id, required this.name, required this.videoCount});

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['subject'] is int
          ? json['subject']
          : int.tryParse(json['subject']?.toString() ?? '0') ?? 0,
      name: json['subject_name']?.toString() ?? 'Unknown',
      videoCount: (json['video_count'] is int)
          ? json['video_count']
          : int.tryParse(json['video_count']?.toString() ?? '0') ?? 0,
    );
  }
}

class VideoSubjectScreen extends StatefulWidget {
  final String categoryName;

  const VideoSubjectScreen({super.key, required this.categoryName});

  @override
  State<VideoSubjectScreen> createState() => _VideoSubjectScreenState();
}

class _VideoSubjectScreenState extends State<VideoSubjectScreen> {
  Measurements? size;
  bool isLoading = true;
  String? _errorMessage;

  List<Subject> subjects = []; // Correct type: List<Subject>

  @override
  void initState() {
    super.initState();
    print('DEBUG VideoSubjectScreen: categoryName=${widget.categoryName}');
    fetchSubjects();
  }

  Future<void> fetchSubjects() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse("${BaseUrl.notesApi}videos/"));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        // Determine where the list is: in decoded['results'] or decoded itself
        List<dynamic> dataList;
        if (decoded is Map<String, dynamic> &&
            decoded.containsKey('results') &&
            decoded['results'] is List) {
          dataList = decoded['results'] as List<dynamic>;
        } else if (decoded is List) {
          dataList = decoded;
        } else {
          // Unexpected structure
          throw Exception('Unexpected response structure when fetching videos');
        }

        // Group by subject_name and count the videos
        final Map<String, List<dynamic>> subjectsMap = {};
        for (var item in dataList) {
          if (item is Map<String, dynamic> &&
              item['category'] != null &&
              item['category']['name'] == widget.categoryName) {
            final subjectName = (item['subject_name'] ?? 'Unknown').toString();
            subjectsMap.putIfAbsent(subjectName, () => []);
            subjectsMap[subjectName]!.add(item);
          }
        }

        final List<Subject> tempSubjects = subjectsMap.entries.map((entry) {
          final subjectName = entry.key;
          final videoList = entry.value;
          // get subject id from the first item that's an int or convertible
          int subjectId = 0;
          for (var v in videoList) {
            if (v is Map<String, dynamic> && v.containsKey('subject')) {
              final raw = v['subject'];
              if (raw is int) {
                subjectId = raw;
                break;
              } else if (raw != null) {
                subjectId = int.tryParse(raw.toString()) ?? 0;
                if (subjectId != 0) break;
              }
            }
          }

          return Subject(
            id: subjectId,
            name: subjectName,
            videoCount: videoList.length,
          );
        }).toList();

        if (tempSubjects.isEmpty) {
          setState(() {
            _errorMessage = 'NULL';
            isLoading = false;
          });
          return;
        }

        setState(() {
          subjects = tempSubjects;
          isLoading = false;
        });
      } else {
        // non-200
        debugPrint(
          'fetchSubjects: HTTP ${response.statusCode} - ${response.body}',
        );
        setState(() {
          isLoading = false;
        });
        throw Exception(
          'Failed to load subjects (status ${response.statusCode})',
        );
      }
    } catch (e, st) {
      debugPrint("Error fetching subjects: $e\n$st");
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildSubjectCard(Subject subject) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final marginH = w * 0.04;
    final marginV = h * 0.012;
    final cardHeight = h * 0.22;
    final titleSize = w * 0.055;
    final chipTextSize = w * 0.045;
    final accentHeight = w * 0.04;
    final chipPaddingH = w * 0.03;
    final chipPaddingV = h * 0.006;
    final chipMarginH = w * 0.045;

    return GestureDetector(
      onTap: () {
        print('DEBUG videonotes/main.dart: Navigating to VideosBySubjectScreen');
        print('DEBUG videonotes/main.dart: categoryName=${widget.categoryName}, subjectName=${subject.name}');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideosBySubjectScreen(
              categoryName: widget.categoryName,
              subjectName: subject.name,
            ),
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
                  subject.name,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: const Icon(Icons.more_vert),
              ),
              const Expanded(child: SizedBox()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: chipMarginH),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: chipPaddingH,
                      vertical: chipPaddingV,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${subject.videoCount} Modules',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w800,
                        fontSize: chipTextSize,
                      ),
                    ),
                  ),
                ),
              ),
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
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final errorSize = w * 0.045;

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Poppins'),
      ),
      child: Scaffold(
        appBar: CustomLogoAppBar(),
        body: Column(
          children: [
            // ADDED: Your Topbar widget
            Topbar(firstText: "Video", secondText: ""),
            // ADDED: Expanded widget to properly size the ListView
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
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
                          padding: EdgeInsets.only(top: h * 0.01),
                          itemCount: subjects.length,
                          itemBuilder: (context, index) {
                            return buildSubjectCard(subjects[index]);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
