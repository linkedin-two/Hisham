import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:edvoyage/utils/api_response_handler.dart';
import 'package:edvoyage/utils/colors/colors.dart';
import 'package:edvoyage/_env/notes_env.dart';
import 'package:edvoyage/screens/notes/logo.dart';
import 'package:edvoyage/screens/notes/topbar.dart';

class PreviousYearPapersNotesScreen extends StatefulWidget {
  const PreviousYearPapersNotesScreen({super.key});

  @override
  _PreviousYearPapersNotesScreenState createState() =>
      _PreviousYearPapersNotesScreenState();
}

class _PreviousYearPapersNotesScreenState
    extends State<PreviousYearPapersNotesScreen> {
  late Future<List<Map<String, dynamic>>> papersTopicsFuture;
  int _selectedIndex = 3; // Notes tab is active

  @override
  void initState() {
    super.initState();
    papersTopicsFuture = fetchPapersTopics();
  }

  /// Fetches Previous Year Papers topics data from the API
  /// API Endpoint: GET /api/v1/notes/categories/previous_papers/topics/
  Future<List<Map<String, dynamic>>> fetchPapersTopics() async {
    try {
      final response = await http.get(
        Uri.parse(
          '${BaseUrl.baseUrl}/notes/categories/previous_papers/topics/',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print(
        'Previous Year Papers Topics API Response Status: ${response.statusCode}',
      );
      print('Previous Year Papers Topics API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final topics = ApiResponseHandler.parseListResponse(
          response.body,
          (json) => json,
        );
        print('Successfully fetched Previous Year Papers topics from API');
        return topics;
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        throw Exception(
          'Failed to load Previous Year Papers topics: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching Previous Year Papers topics: $e');
      // Return default data structure if API fails
      return [
        {
          'id': 1,
          'title': 'USMLE Step 1 Papers',
          'description': 'Previous year USMLE Step 1 examination papers',
          'papers_count': 25,
          'is_featured': true,
          'order': 1,
        },
        {
          'id': 2,
          'title': 'USMLE Step 2 CK Papers',
          'description': 'Previous year USMLE Step 2 CK examination papers',
          'papers_count': 20,
          'is_featured': false,
          'order': 2,
        },
        {
          'id': 3,
          'title': 'PLAB 1 Papers',
          'description': 'Previous year PLAB 1 examination papers',
          'papers_count': 18,
          'is_featured': false,
          'order': 3,
        },
        {
          'id': 4,
          'title': 'PLAB 2 Papers',
          'description': 'Previous year PLAB 2 examination papers',
          'papers_count': 15,
          'is_featured': false,
          'order': 4,
        },
        {
          'id': 5,
          'title': 'AMC Papers',
          'description': 'Previous year Australian Medical Council papers',
          'papers_count': 22,
          'is_featured': false,
          'order': 5,
        },
        {
          'id': 6,
          'title': 'MCCQE Papers',
          'description': 'Previous year Medical Council of Canada papers',
          'papers_count': 16,
          'is_featured': false,
          'order': 6,
        },
        {
          'id': 7,
          'title': 'FMGE Papers',
          'description':
              'Previous year Foreign Medical Graduate Examination papers',
          'papers_count': 30,
          'is_featured': false,
          'order': 7,
        },
        {
          'id': 8,
          'title': 'NEET PG Papers',
          'description': 'Previous year NEET PG examination papers',
          'papers_count': 28,
          'is_featured': false,
          'order': 8,
        },
      ];
    }
  }

  /// Builds individual Previous Year Papers topic cards
  Widget _buildPapersTopicCard(Map<String, dynamic> topic) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final marginH = w * 0.04;
    final marginV = h * 0.012;
    final paddingH = w * 0.045;
    final paddingV = h * 0.016;
    final titleSize = w * 0.05;
    final countSize = w * 0.04;
    final accentHeight = w * 0.04;

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      margin: EdgeInsets.symmetric(vertical: marginV, horizontal: marginH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: paddingH, vertical: paddingV),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    topic['title'] ?? 'Unknown Topic',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${topic['papers_count'] ?? 0} Papers',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: countSize,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF008080),
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
    );
  }

  /// Builds bottom navigation bar
  Widget _buildBottomNavigation() {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final navHeight = h * 0.14;
    final radius = w * 0.06;

    return Container(
      height: navHeight,
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(radius),
          topRight: Radius.circular(radius),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(0, 'assets/frame.png', 'Profile'),
          _buildNavItem(1, 'assets/diamonds.png', 'Diamond'),
          _buildNavItem(2, 'assets/Group 98.png', 'Y'),
          _buildNavItem(3, 'assets/book.png', 'Notes', isActive: true),
          _buildNavItem(4, 'assets/airplane.png', 'Travel'),
        ],
      ),
    );
  }

  /// Builds individual navigation items
  Widget _buildNavItem(
    int index,
    String iconPath,
    String label, {
    bool isActive = false,
  }) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final iconSize = w * 0.065;
    final indicatorH = h * 0.004;
    final indicatorW = w * 0.05;
    final indicatorTop = h * 0.006;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ImageIcon(
            AssetImage(iconPath),
            color: isActive ? secondaryColor : whiteColor,
            size: iconSize,
          ),
          if (isActive)
            Container(
              margin: EdgeInsets.only(top: indicatorTop),
              height: indicatorH,
              width: indicatorW,
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final titleSize = w * 0.05;
    final subtitleSize = w * 0.04;
    final errorPadding = w * 0.06;
    final gapSmall = h * 0.01;
    final gapMedium = h * 0.02;

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Poppins'),
      ),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: CustomLogoAppBar(),
        body: SafeArea(
          child: Column(
            children: [
              Topbar(firstText: 'Notes', secondText: 'Previous Year Papers'),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: papersTopicsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(errorPadding),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Failed to load content',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: titleSize,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: gapSmall),
                              Text(
                                'Please check your connection',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: subtitleSize,
                                  color: Colors.black54,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: gapMedium),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    papersTopicsFuture = fetchPapersTopics();
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF008080),
                                ),
                                child: const Text(
                                  'Retry',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final topics = snapshot.data ?? [];

                    return ListView.builder(
                      padding: EdgeInsets.only(top: h * 0.01),
                      itemCount: topics.length,
                      itemBuilder: (context, index) {
                        return _buildPapersTopicCard(topics[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
