import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:edvoyage/screens/notes/clinicalnotes/main.dart';
import 'package:edvoyage/_env/notes_env.dart';
import 'package:edvoyage/screens/notes/flashcardnotes/main.dart';
import 'package:edvoyage/screens/notes/logo.dart';
import 'package:edvoyage/screens/notes/mcqnotes/main.dart';
import 'package:edvoyage/screens/notes/videonotes/main.dart';
// import 'package:edvoyage/widgets/explore_courses/app_bar.dart';

class NotesScreen extends StatefulWidget {
  final String className;
  const NotesScreen({super.key, required this.className});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final bool _isLoading = false;
  int _VideoTotalCount = 0;
  int _VideoUniqueCount = 0;
  int _mcqCount = 0;
  int _mcqSubjectCount = 0;
  final int _clinicalCaseCount = 0;
  final int _flashcardTotalCount = 0;
  final int _flashcardUniqueCount = 0;
  int _subjectNamesCount = 0;
  int _clinicalTotalCount = 0;
  int _flashCardUniqueCount = 0;
  int _flashCardTotalCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchVideoStats();
    _fetchMcqStats();
    _fetchClinicalCases();
    _fetchFlashCards();
  }

  Future<void> _fetchVideoStats() async {
    try {
      final response = await http.get(Uri.parse("${BaseUrl.notesApi}videos/"));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        var subjectNames = data
            .where((video) => video['category']["name"] == widget.className)
            .map((video) => video['subject_name'])
            .toSet();

        var videoUrls = data
            .where((video) => video['category']["name"] == widget.className)
            .map((video) => video['video_url'])
            .toList();

        setState(() {
          _VideoUniqueCount = subjectNames.length;
          _VideoTotalCount = videoUrls.length;
        });
      } else {
        print("Failed to load video stats. Status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching video stats: $e");
    }
  }

  Future<void> _fetchMcqStats() async {
    try {
      final response = await http.get(Uri.parse("${BaseUrl.notesApi}mcqs/"));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        var subjectNames = data
            .where((mcq) => mcq['category']["name"] == widget.className)
            .map((mcq) => mcq['subject']['name'])
            .toSet();

        var mcqQuestions = data
            .where(
              (mcq) =>
                  mcq['category']["name"] == widget.className &&
                  mcq['questions'] != null &&
                  (mcq['questions'] as List).isNotEmpty,
            )
            .map((mcq) => mcq['questions'])
            .toList();

        setState(() {
          _mcqSubjectCount = subjectNames.length;
          _mcqCount = mcqQuestions.length;
        });
      } else {
        print("Failed to load MCQ stats. Status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching MCQ stats: $e");
    }
  }

  Future<void> _fetchClinicalCases() async {
    try {
      final response = await http.get(
        Uri.parse("${BaseUrl.notesApi}clinical-cases/"),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        var subjectNames = data
            .where(
              (caseItem) => caseItem['category']["name"] == widget.className,
            )
            .map((caseItem) => caseItem['subject_name'])
            .toSet();

        var clinicalCases = data
            .where(
              (caseItem) => caseItem['category']["name"] == widget.className,
            )
            .toList();

        setState(() {
          _subjectNamesCount = subjectNames.length;
          _clinicalTotalCount = clinicalCases.length;
        });
      } else {
        print("Failed to load clinical cases. Status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching Clinical Cases: $e");
    }
  }

  Future<void> _fetchFlashCards() async {
    try {
      final response = await http.get(
        Uri.parse("${BaseUrl.notesApi}flashcards/"),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        var subjectNames = data
            .where((card) => card['category']["name"] == widget.className)
            .map((card) => card['subject_name'])
            .toSet();

        var flashCards = data
            .where((card) => card['category']["name"] == widget.className)
            .toList();

        setState(() {
          _flashCardUniqueCount = subjectNames.length;
          _flashCardTotalCount = flashCards.length;
        });
      } else {
        print("Failed to load flashcards. Status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching Flashcards: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF008080);
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final pagePadding = w * 0.04;
    final sectionGap = h * 0.02;

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(
          fontFamily: "Poppins",
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: CustomLogoAppBar(),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: sectionGap),
                
                // Class Name Header
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: h * 0.015, horizontal: w * 0.04),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.className,
                    style: TextStyle(
                      fontSize: w * 0.05,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                SizedBox(height: sectionGap),

                // Video Card
                NoteCard(
                  title: 'Video',
                  leftSubtitle: _isLoading
                      ? 'Loading...'
                      : '$_VideoUniqueCount Subjects',
                  rightSubtitle: _isLoading ? '' : '$_VideoTotalCount Videos',
                  navigateTo: VideoSubjectScreen(
                    categoryName: widget.className,
                  ),
                  onTapDebug: () => print('DEBUG main.dart: Video card tapped, className=${widget.className}'),
                ),

                // MCQ Card
                NoteCard(
                  title: 'MCQs',
                  leftSubtitle: _isLoading
                      ? 'Loading...'
                      : '$_mcqSubjectCount Topics',
                  rightSubtitle: _isLoading ? '' : '$_mcqCount MCQs',
                  navigateTo: McqSubjectsScreen(categoryName: widget.className),
                ),

                if (widget.className == "NEET PG")
                  NoteCard(
                    title: 'Clinical Case',
                    leftSubtitle: _isLoading
                        ? 'Loading...'
                        : '$_subjectNamesCount Subjects',
                    rightSubtitle: _isLoading
                        ? ''
                        : '$_clinicalTotalCount Clinical Cases',
                    navigateTo: ClinicalCasesScreen(
                      categoryName: widget.className,
                    ),
                  ),

                // Flash Card
                NoteCard(
                  title: 'Flash Card',
                  leftSubtitle: _isLoading
                      ? 'Loading...'
                      : '$_flashCardUniqueCount Subjects',
                  rightSubtitle: _isLoading
                      ? ''
                      : '$_flashCardTotalCount Flash Cards',
                  navigateTo: FlashcardsScreenOne(
                    categoryName: widget.className,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NoteCard extends StatelessWidget {
  final String title;
  final String leftSubtitle;
  final String rightSubtitle;
  final Widget navigateTo;
  final VoidCallback? onTapDebug;

  const NoteCard({
    super.key,
    required this.title,
    required this.leftSubtitle,
    required this.rightSubtitle,
    required this.navigateTo,
    this.onTapDebug,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF008080);
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final titleSize = w * 0.055;
    final subtitleSize = w * 0.045;
    final cardHeight = MediaQuery.of(context).size.height * 0.20;
    final accentHeight = w * 0.04;
    final contentGap = h * 0.012;
    final cardOuterPaddingV = h * 0.012;
    final subtitleRowPaddingH = w * 0.045;

    return GestureDetector(
      onTap: () {
        onTapDebug?.call();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => navigateTo),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: cardOuterPaddingV),
        child: Card(
          elevation: 2,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: SizedBox(
            height: cardHeight,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text(
                    title,
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: const Icon(Icons.more_vert),
                ),
                const Spacer(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: subtitleRowPaddingH),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        leftSubtitle,
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: subtitleSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        rightSubtitle,
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: subtitleSize,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: contentGap),
                Container(
                  height: accentHeight,
                  width: double.infinity,
                  color: primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
