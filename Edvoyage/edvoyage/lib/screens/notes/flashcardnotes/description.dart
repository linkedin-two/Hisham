import 'package:flutter/material.dart';
import 'final.dart';
import 'package:edvoyage/screens/notes/logo.dart';
import 'data.dart';

class FlashcardsScreenThree extends StatefulWidget {
  final String subSubjectName;
  final String subjectName;
  final String categoryName;

  const FlashcardsScreenThree({
    super.key,
    required this.subSubjectName,
    required this.subjectName,
    required this.categoryName,
  });

  @override
  State<FlashcardsScreenThree> createState() => _FlashcardsScreenThreeState();
}

class _FlashcardsScreenThreeState extends State<FlashcardsScreenThree> {
  final List<String> descriptions = [];
  String? _errorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDescriptions();
  }

  Future<void> _loadDescriptions() async {
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
            item['subject_name'] == widget.subjectName &&
            item['sub_subject_name'] == widget.subSubjectName,
      );

      final tempDescriptions = filtered
          .map((item) => item['description']?.toString())
          .where((d) => d != null && d.isNotEmpty)
          .toSet()
          .toList();

      if (tempDescriptions.isEmpty) {
        final hasImages = filtered.any(
          (item) =>
              item['images'] is List && (item['images'] as List).isNotEmpty,
        );
        if (hasImages && mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => FlashcardsScreenFour(
                  description: '',
                  subSubjectName: widget.subSubjectName,
                  subjectName: widget.subjectName,
                  categoryName: widget.categoryName,
                ),
              ),
            );
          });
          return;
        }
        setState(() {
          _errorMessage = 'No flashcards available';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        descriptions
          ..clear()
          ..addAll(tempDescriptions.cast<String>());
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
    final fontSize = w * 0.045;
    final iconSize = w * 0.06;
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
        appBar: CustomLogoAppBar(),
        body: ListView.builder(
          padding: EdgeInsets.all(marginH),
          itemCount: descriptions.length,
          itemBuilder: (context, index) {
            final description = descriptions[index];

            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FlashcardsScreenFour(
                      description: description,
                      subSubjectName: widget.subSubjectName,
                      subjectName: widget.subjectName,
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
                        description,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: fontSize,
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

//           return Padding(
//             padding: const EdgeInsets.only(bottom: 12),
//             child: Card(
//               elevation: 2,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: ListTile(
//                 contentPadding:
//                     const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
//                 title: Text(
//                   description,
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 trailing: const Icon(Icons.arrow_forward_ios_rounded),
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => FlashcardsScreenFour(
//                         description: description,
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
