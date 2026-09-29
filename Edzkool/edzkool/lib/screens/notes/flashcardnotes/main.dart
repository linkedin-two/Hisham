import 'package:flutter/material.dart';
import 'package:edzkool/utils/app_log.dart';
import 'subsubject.dart';
import 'data.dart';
import 'package:edzkool/screens/notes/logo.dart';

class FlashcardsScreenOne extends StatefulWidget {
  final String categoryName;
  const FlashcardsScreenOne({super.key, required this.categoryName});

  @override
  State<FlashcardsScreenOne> createState() => _FlashcardsScreenOneState();
}

class _FlashcardsScreenOneState extends State<FlashcardsScreenOne> {
  List<String> _subjects = [];
  String? _errorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFlashcardsData();
  }

  Future<void> _loadFlashcardsData() async {
    try {
      AppLog.debug('DEBUG: Flashcards - categoryName = ${widget.categoryName}');
      var data = await fetchFlashcards();

      AppLog.debug('DEBUG: Flashcards - API data type: ${data.runtimeType}');

      if (data == null) {
        setState(() {
          _errorMessage = 'Failed to load flashcards data.';
          _isLoading = false;
        });
        return;
      }

      // Handle both list and map structure
      List<dynamic> jsonData;
      if (data is Map && data.containsKey('results')) {
        jsonData = data['results'];
        AppLog.debug('DEBUG: Flashcards - Using paginated results, count: ${jsonData.length}');
      } else if (data is List) {
        jsonData = data;
        AppLog.debug('DEBUG: Flashcards - Using plain list, count: ${jsonData.length}');
      } else {
        AppLog.debug('DEBUG: Flashcards - Unexpected data type: ${data.runtimeType}');
        jsonData = [];
      }

      // Debug: print first item structure
      if (jsonData.isNotEmpty) {
        AppLog.debug('DEBUG: Flashcards - First item: ${jsonData[0]}');
      }

      final filteredSubjects = jsonData
          .where(
            (item) {
              final category = item['category'];
              final matches = category != null && category['name'] == widget.categoryName;
              if (!matches) {
                AppLog.debug('DEBUG: Flashcards - Filtering out item, category: ${category?['name']}, looking for: ${widget.categoryName}');
              }
              return matches;
            },
          )
          .map((item) => item['subject_name']?.toString())
          .where((name) => name != null && name.isNotEmpty)
          .toSet()
          .toList();

      AppLog.debug('DEBUG: Flashcards - Filtered subjects count: ${filteredSubjects.length}');
      AppLog.debug('DEBUG: Flashcards - Filtered subjects: $filteredSubjects');

      if (filteredSubjects.isEmpty) {
        setState(() {
          _errorMessage = 'No flashcards for ${widget.categoryName}';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _subjects = filteredSubjects.cast<String>();
        _isLoading = false;
      });
    } catch (e, st) {
      AppLog.debug('DEBUG: Flashcards - Error: $e\n$st');
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final titleSize = w * 0.055;
    final marginH = w * 0.04;
    final marginV = h * 0.012;
    final paddingH = w * 0.045;
    final paddingTop = h * 0.018;
    final paddingBottom = h * 0.02;
    final iconSize = w * 0.06;
    final accentHeight = w * 0.04;

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Poppins'),
      ),
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: CustomLogoAppBar(),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(
                    child: Text(
                      'NULL',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: w * 0.045,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(marginH * 0.5),
                    itemCount: _subjects.length,
                    itemBuilder: (context, index) {
                      final subject = _subjects[index];

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FlashcardsScreenTwo(
                                subjectName: subject,
                                categoryName: widget.categoryName,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(15),
                        child: Card(
                          margin: EdgeInsets.symmetric(
                            vertical: marginV,
                            horizontal: marginH * 0.5,
                          ),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                  paddingH,
                                  paddingTop,
                                  paddingH,
                                  paddingBottom,
                                ),
                                child: Text(
                                  subject,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: titleSize,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),

                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                  paddingH,
                                  0,
                                  paddingH,
                                  h * 0.014,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon(
                                      Icons.arrow_forward,
                                      size: iconSize,
                                      color: Colors.teal,
                                    ),
                                  ],
                                ),
                              ),

                              // Teal accent bar
                              Container(
                                height: accentHeight,
                                decoration: const BoxDecoration(
                                  color: Colors.teal,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(8),
                                    bottomRight: Radius.circular(8),
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
