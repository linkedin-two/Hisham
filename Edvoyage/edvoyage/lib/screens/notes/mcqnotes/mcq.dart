import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:edvoyage/_env/notes_env.dart';
import 'package:edvoyage/screens/notes/logo.dart';

// ------------------- DATA MODELS -------------------
// Note: For larger apps, it's best practice to move these model classes
// into their own file (e.g., 'models/mcq_models.dart').

class Option {
  final int id;
  final String text;
  final bool isCorrect;

  Option({required this.id, required this.text, required this.isCorrect});

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      id: json['id'] ?? 0,
      text: json['text'] ?? '',
      isCorrect: json['is_correct'] ?? false,
    );
  }
}

class Question {
  final int id;
  final String text;
  final List<Option> options;

  Question({required this.id, required this.text, required this.options});

  factory Question.fromJson(Map<String, dynamic> json) {
    var optionsFromJson = json['options'] as List? ?? [];
    List<Option> optionsList =
        optionsFromJson.map((o) => Option.fromJson(o)).toList();

    return Question(
      id: json['id'] ?? 0,
      text: json['text'] ?? 'No question text',
      options: optionsList,
    );
  }
}

// ------------------- QUIZ SCREEN WIDGET -------------------

class QuizScreen extends StatefulWidget {
  final String moduleTitle;

  const QuizScreen({super.key, required this.moduleTitle});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  List<Question> _questions = [];

  final PageController _pageController = PageController();
  int _currentIndex = 0;
  // Map to store selected option ID for each question's index
  final Map<int, int> _selectedAnswers = {};

  @override
  void initState() {
    super.initState();
    _fetchAndFilterQuizData();
  }

  Future<void> _fetchAndFilterQuizData() async {
    try {
      final url = Uri.parse("${BaseUrl.notesApi}mcqs/");
      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        List<dynamic> allModules;
        if (decoded is List) {
          allModules = decoded;
        } else if (decoded is Map && decoded['results'] is List) {
          allModules = decoded['results'];
        } else {
          allModules = [];
        }

        final moduleData = allModules.firstWhere(
          (module) => module['title'] == widget.moduleTitle,
          orElse: () => null,
        );

        if (moduleData != null) {
          final List<dynamic> questionsJson = moduleData['questions'] ?? [];
          setState(() {
            _questions =
                questionsJson.map((q) => Question.fromJson(q)).toList();
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = "Module '${widget.moduleTitle}' not found.";
            _isLoading = false;
          });
        }
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
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ✅ MODIFIED: Prevents changing an answer once it has been selected.
  void _onOptionSelected(int questionIndex, int optionId) {
    // If question has already been answered, do nothing.
    if (_selectedAnswers.containsKey(questionIndex)) {
      return;
    }
    setState(() {
      _selectedAnswers[questionIndex] = optionId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final pagePadding = w * 0.05;
    final questionSize = w * 0.05;
    final optionSize = w * 0.045;
    final optionLabelSize = w * 0.045;
    final headerTitleSize = w * 0.055;
    final headerPaddingH = w * 0.06;
    final headerPaddingV = h * 0.02;
    final optionMarginV = h * 0.012;
    final optionPadding = w * 0.04;
    final footerPaddingH = w * 0.06;
    final footerPaddingV = h * 0.02;
    final footerCounterSize = w * 0.045;
    final closeIconSize = w * 0.07;
    final buttonPaddingH = w * 0.08;
    final buttonPaddingV = h * 0.015;

    return Scaffold(
      appBar: CustomLogoAppBar(),
      backgroundColor: Colors.grey.shade100,
      body: Theme(
        data: ThemeData(
          scaffoldBackgroundColor: Colors.grey.shade200,
          fontFamily: 'Poppins',
        ),
        child: _buildBody(
          pagePadding: pagePadding,
          questionSize: questionSize,
          optionSize: optionSize,
          optionLabelSize: optionLabelSize,
          headerTitleSize: headerTitleSize,
          headerPaddingH: headerPaddingH,
          headerPaddingV: headerPaddingV,
          optionMarginV: optionMarginV,
          optionPadding: optionPadding,
          footerPaddingH: footerPaddingH,
          footerPaddingV: footerPaddingV,
          footerCounterSize: footerCounterSize,
          closeIconSize: closeIconSize,
          buttonPaddingH: buttonPaddingH,
          buttonPaddingV: buttonPaddingV,
        ),
      ),
    );
  }

  Widget _buildBody({
    required double pagePadding,
    required double questionSize,
    required double optionSize,
    required double optionLabelSize,
    required double headerTitleSize,
    required double headerPaddingH,
    required double headerPaddingV,
    required double optionMarginV,
    required double optionPadding,
    required double footerPaddingH,
    required double footerPaddingV,
    required double footerCounterSize,
    required double closeIconSize,
    required double buttonPaddingH,
    required double buttonPaddingV,
  }) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(pagePadding),
          child: Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.red,
              fontSize: optionSize,
            ),
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Center(
        child: Text(
          "No questions found for this module.",
          style: TextStyle(fontSize: optionSize),
        ),
      );
    }

    return Column(
      children: [
        _buildAppBar(
          titleSize: headerTitleSize,
          paddingH: headerPaddingH,
          paddingV: headerPaddingV,
          closeIconSize: closeIconSize,
        ),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _questions.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final question = _questions[index];
              return SingleChildScrollView(
                padding: EdgeInsets.all(pagePadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        question.text,
                        style: TextStyle(
                          fontSize: questionSize,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF333333),
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    ...question.options.asMap().entries.map((entry) {
                      int optionIndex = entry.key;
                      Option option = entry.value;
                      final optionLabel =
                          '${String.fromCharCode(65 + optionIndex)} - ';
                      return _buildOption(
                        index,
                        option,
                        optionLabel,
                        marginV: optionMarginV,
                        padding: optionPadding,
                        labelSize: optionLabelSize,
                        optionSize: optionSize,
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        ),
        _buildFooter(
          paddingH: footerPaddingH,
          paddingV: footerPaddingV,
          counterSize: footerCounterSize,
          buttonPaddingH: buttonPaddingH,
          buttonPaddingV: buttonPaddingV,
        ),
      ],
    );
  }

  Widget _buildAppBar({
    required double titleSize,
    required double paddingH,
    required double paddingV,
    required double closeIconSize,
  }) {
    return Padding(
      padding:
          EdgeInsets.fromLTRB(paddingH, paddingV, paddingH * 0.3, paddingV),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.moduleTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFF008080),
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              size: closeIconSize,
              color: Colors.grey.shade700,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  // ✅ MODIFIED: This widget now contains all the logic for displaying
  // correct (green), incorrect (red), and pending (white) answers.
  Widget _buildOption(
    int questionIndex,
    Option option,
    String optionLabel, {
    required double marginV,
    required double padding,
    required double labelSize,
    required double optionSize,
  }) {
    final bool isAnswered = _selectedAnswers.containsKey(questionIndex);
    final int? selectedOptionId = _selectedAnswers[questionIndex];

    Color cardColor = Colors.white;
    Color textColor = const Color(0xFF333333);
    BorderSide border = BorderSide(color: Colors.grey.shade300, width: 1);

    if (isAnswered) {
      bool isCorrectOption = option.isCorrect;
      bool isSelectedOption = option.id == selectedOptionId;

      if (isCorrectOption) {
        // If the option is the correct one, always make it green.
        cardColor = Colors.green;
        textColor = Colors.white;
        border = BorderSide.none;
      } else if (isSelectedOption && !isCorrectOption) {
        // If this was the user's selected but incorrect choice, make it red.
        cardColor = Colors.red;
        textColor = Colors.white;
        border = BorderSide.none;
      } else {
        // This is an unselected, incorrect option on an answered question. Grey it out.
        cardColor = Colors.grey.shade200;
        textColor = Colors.grey.shade600;
        border = BorderSide(color: Colors.grey.shade300, width: 1);
      }
    }

    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: marginV),
      color: cardColor, // Use the determined color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: border, // Use the determined border
      ),
      child: InkWell(
        onTap: () => _onOptionSelected(questionIndex, option.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                optionLabel,
                style: TextStyle(
                  fontSize: labelSize,
                  fontWeight: FontWeight.bold,
                  color: textColor, // Use the determined text color
                ),
              ),
              Expanded(
                child: Text(
                  option.text,
                  style: TextStyle(
                    fontSize: optionSize,
                    color: textColor, // Use the determined text color
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter({
    required double paddingH,
    required double paddingV,
    required double counterSize,
    required double buttonPaddingH,
    required double buttonPaddingV,
  }) {
    bool isLastQuestion = _currentIndex == _questions.length - 1;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: paddingH, vertical: paddingV),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            spreadRadius: 0,
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: _currentIndex == 0
                ? null
                : () => _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF008080),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: buttonPaddingH,
                vertical: buttonPaddingV,
              ),
            ),
            child: const Text('PREV'),
          ),
          Text(
            '${_currentIndex + 1} / ${_questions.length}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: counterSize,
            ),
          ),
          ElevatedButton(
            onPressed: isLastQuestion
                ? null
                : () => _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF008080),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: buttonPaddingH,
                vertical: buttonPaddingV,
              ),
            ),
            child: Text(isLastQuestion ? 'FINISH' : 'NEXT'),
          ),
        ],
      ),
    );
  }
}
