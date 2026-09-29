import 'package:flutter/material.dart';
import 'description.dart';
import 'final.dart';
import 'data.dart';
import 'package:edvoyage/screens/notes/logo.dart';

class FlashcardsScreenTwo extends StatefulWidget {
  final String subjectName;
  final String categoryName;

  const FlashcardsScreenTwo({
    super.key,
    required this.subjectName,
    required this.categoryName,
  });

  @override
  State<FlashcardsScreenTwo> createState() => _FlashcardsScreenTwoState();
}

class _FlashcardsScreenTwoState extends State<FlashcardsScreenTwo> {
  final List<String> subSubjects = [];
  String? _errorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubSubjects();
  }

  Future<void> _loadSubSubjects() async {
    try {
      var data = await fetchFlashcards();

      if (data == null) {
        setState(() {
          _errorMessage = 'NULL';
          _isLoading = false;
        });
        return;
      }

      List<dynamic> jsonData;
      if (data is Map && data.containsKey('results')) {
        jsonData = data['results'];
      } else if (data is List) {
        jsonData = data;
      } else {
        jsonData = [];
      }

      final filtered = jsonData.where(
        (item) =>
            item['category'] != null &&
            item['category']['name'] == widget.categoryName &&
            item['subject_name'] == widget.subjectName,
      );

      final tempSubSubjects = filtered
          .map((item) => item['sub_subject_name']?.toString())
          .where((name) => name != null && name.isNotEmpty)
          .toSet()
          .toList();

      if (tempSubSubjects.isEmpty) {
        setState(() {
          _errorMessage = 'NULL';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        subSubjects
          ..clear()
          ..addAll(tempSubSubjects.cast<String>());
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'NULL';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null) {
      final w = MediaQuery.of(context).size.width;
      return Scaffold(
        appBar: CustomLogoAppBar(),
        body: Center(
          child: Text(
            _errorMessage!,
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.red,
              fontSize: w * 0.045,
            ),
          ),
        ),
      );
    }

    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final double iconSize = w * 0.06;
    final double textSize = w * 0.045;
    final marginH = w * 0.04;
    final marginV = h * 0.012;
    final paddingH = w * 0.045;
    final paddingTop = h * 0.018;
    final paddingBottom = h * 0.02;
    final accentHeight = w * 0.04;

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Poppins'),
      ),
      child: Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: CustomLogoAppBar() as PreferredSizeWidget,

      // --- Modernized UI ---
      body: ListView.builder(
        padding: EdgeInsets.all(marginH),
        itemCount: subSubjects.length,
        itemBuilder: (context, index) {
          final sub = subSubjects[index];

          return InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () async {
              final data = await fetchFlashcards();
              if (!context.mounted || data == null) return;

              List<dynamic> jsonData;
              if (data is Map && data.containsKey('results')) {
                jsonData = data['results'];
              } else if (data is List) {
                jsonData = data;
              } else {
                jsonData = [];
              }

              final matching = jsonData.where(
                (item) =>
                    item['category'] != null &&
                    item['category']['name'] == widget.categoryName &&
                    item['subject_name'] == widget.subjectName &&
                    item['sub_subject_name'] == sub,
              );

              final hasNonEmptyDescription = matching.any((item) {
                final desc = item['description']?.toString() ?? '';
                return desc.isNotEmpty;
              });

              final hasImages = matching.any(
                (item) =>
                    item['images'] is List && (item['images'] as List).isNotEmpty,
              );

              if (!hasNonEmptyDescription && hasImages) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FlashcardsScreenFour(
                      description: '',
                      subSubjectName: sub,
                      subjectName: widget.subjectName,
                      categoryName: widget.categoryName,
                    ),
                  ),
                );
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FlashcardsScreenThree(
                    subSubjectName: sub,
                    subjectName: widget.subjectName,
                    categoryName: widget.categoryName,
                  ),
                ),
              );
            },
            child: Card(
              margin: EdgeInsets.symmetric(vertical: marginV, horizontal: marginH * 0.5),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Padding(
                    padding: EdgeInsets.fromLTRB(paddingH, paddingTop, paddingH, paddingBottom),
                    child: Text(
                      sub,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: textSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  // Right-side icon row
                  Padding(
                    padding: EdgeInsets.fromLTRB(paddingH, 0, paddingH, h * 0.014),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: iconSize,
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ),

                  // Teal bottom accent
                  Container(
                    height: accentHeight,
                    decoration: const BoxDecoration(
                      color: Colors.teal,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      ),
    );
  }
}
