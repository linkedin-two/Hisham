import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:edvoyage/utils/api_response_handler.dart';
import 'package:edvoyage/utils/colors/colors.dart';
import 'package:edvoyage/_env/notes_env.dart';
import 'package:edvoyage/screens/notes/logo.dart';
import 'package:edvoyage/screens/notes/topbar.dart';

class ResponsivePreviousYearPapersNotesScreen extends StatefulWidget {
  const ResponsivePreviousYearPapersNotesScreen({super.key});

  @override
  _ResponsivePreviousYearPapersNotesScreenState createState() =>
      _ResponsivePreviousYearPapersNotesScreenState();
}

class _ResponsivePreviousYearPapersNotesScreenState
    extends State<ResponsivePreviousYearPapersNotesScreen> {
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
        'Responsive Previous Year Papers Topics API Response Status: ${response.statusCode}',
      );
      print(
        'Responsive Previous Year Papers Topics API Response Body: ${response.body}',
      );

      if (response.statusCode == 200) {
        final topics = ApiResponseHandler.parseListResponse(
          response.body,
          (json) => json,
        );
        print(
          'Successfully fetched responsive Previous Year Papers topics from API',
        );
        return topics;
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        throw Exception(
          'Failed to load Previous Year Papers topics: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching responsive Previous Year Papers topics: $e');
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
  Widget _buildPapersTopicCard(
    Map<String, dynamic> topic,
    BuildContext context,
  ) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final marginH = w * 0.04;
    final marginV = h * 0.012;
    final paddingH = w * 0.045;
    final paddingTop = h * 0.018;
    final paddingBottom = h * 0.02;
    final titleSize = w * 0.055;
    final bodySize = w * 0.045;
    final accentHeight = w * 0.04;

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      margin: EdgeInsets.symmetric(horizontal: marginH, vertical: marginV),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              paddingH,
              paddingTop,
              paddingH,
              paddingBottom,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    topic['title'] ?? 'Unknown Topic',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                SizedBox(width: w * 0.03),
                Text(
                  '${topic['papers_count'] ?? 0} Papers',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: bodySize,
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
    );
  }

  /// Builds bottom navigation bar
  Widget _buildBottomNavigation(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Container(
      height: isTablet ? 100 : 80,
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isTablet ? 25 : 20),
          topRight: Radius.circular(isTablet ? 25 : 20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(0, 'assets/frame.png', 'Profile', context),
          _buildNavItem(1, 'assets/diamonds.png', 'Diamond', context),
          _buildNavItem(2, 'assets/Group 98.png', 'Y', context),
          _buildNavItem(3, 'assets/book.png', 'Notes', context, isActive: true),
          _buildNavItem(4, 'assets/airplane.png', 'Travel', context),
        ],
      ),
    );
  }

  /// Builds individual navigation items
  Widget _buildNavItem(
    int index,
    String iconPath,
    String label,
    BuildContext context, {
    bool isActive = false,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

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
            size: isTablet ? 28 : 24,
          ),
          if (isActive)
            Container(
              margin: EdgeInsets.only(top: isTablet ? 6 : 4),
              height: isTablet ? 3 : 2,
              width: isTablet ? 25 : 20,
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
    final isLandscape = w > h;

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Poppins'),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomLogoAppBar(),
        body: SafeArea(
          child: Column(
            children: [
              Topbar(firstText: 'Previous Papers', secondText: ''),
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
                          padding: EdgeInsets.all(w * 0.06),
                          child: Text(
                            'Failed to load content',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: w * 0.045,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      );
                    }

                    final topics = snapshot.data ?? [];
                    if (topics.isEmpty) {
                      return Center(
                        child: Text(
                          'No papers found',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: w * 0.045,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                      );
                    }

                    if (isLandscape && w > 700) {
                      return GridView.builder(
                        padding: EdgeInsets.only(top: h * 0.01),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 2.8,
                          crossAxisSpacing: w * 0.04,
                          mainAxisSpacing: h * 0.02,
                        ),
                        itemCount: topics.length,
                        itemBuilder: (context, index) {
                          return _buildPapersTopicCard(topics[index], context);
                        },
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.only(top: h * 0.01),
                      itemCount: topics.length,
                      itemBuilder: (context, index) {
                        return _buildPapersTopicCard(topics[index], context);
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
