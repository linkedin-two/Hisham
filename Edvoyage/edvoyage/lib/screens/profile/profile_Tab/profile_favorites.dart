
import 'package:edvoyage/_env/env.dart';
import 'package:edvoyage/utils/api_response_handler.dart';
import 'package:edvoyage/utils/colors/colors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../exploreUniversity_screen/exploreUniversitiesScreen.dart';
import 'coursestabforprofile.dart';
import 'universitytabforprofile.dart';

class ProfileFevourites extends StatefulWidget {
  const ProfileFevourites({super.key});

  @override
  _ProfileFevouritesState createState() => _ProfileFevouritesState();
}

class _ProfileFevouritesState extends State<ProfileFevourites>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  late double _w;
  late double _h;
  late double _padH;
  late double _padV;
  late double _padMd;
  late double _padSm;
  late double _gapSm;
  late double _gapXs;
  late double _iconMd;
  late double _iconSm;
  late double _titleFs;
  late double _subTitleFs;
  late double _bodyFs;
  late double _smallFs;

  final TextEditingController _headerSearchController = TextEditingController();
  final Map<int, TextEditingController> _tabSearchControllers = {
    0: TextEditingController(),
    1: TextEditingController(),
  };

  // State management
  int _selectedTabIndex = 0;
  bool _isSearchVisible = false;
  String _searchQuery = '';
  String _selectedSortOption = 'Recent';

  // Tab-specific state management
  final Map<int, bool> _tabSearchVisible = {0: false, 1: false};
  final Map<int, String> _tabSearchQuery = {0: '', 1: ''};
  final Map<int, String> _tabSortOption = {0: '', 1: ''};

  int universityCount = 0;
  int courseCount = 0;
  bool isLoading = false;

  // Tab data with badges
  final List<Map<String, dynamic>> _tabs = [
    {
      'title': 'University',
      'icon': Icons.school,
      'color': primaryColor,
    },
    {
      'title': 'Courses',
      'icon': Icons.book,
      'color': secondaryColor,
    },
  ];

  final List<String> _sortOptions = [
    'Recent',
    'Alphabetical',
    'Rating',
    'Popularity',
  ];

  @override
  void initState() {
    super.initState();
    fetchBookmarksCount();
    _tabController = TabController(length: 2, vsync: this);
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _headerSearchController.dispose();
    for (final c in _tabSearchControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
    _tabController.animateTo(index);
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (!_isSearchVisible) {
        _headerSearchController.clear();
        _searchQuery = '';
      }
    });
  }

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _toggleTabSearch(int tabIndex) {
    setState(() {
      _tabSearchVisible[tabIndex] = !(_tabSearchVisible[tabIndex] ?? false);
      if (!(_tabSearchVisible[tabIndex] ?? false)) {
        _tabSearchControllers[tabIndex]?.clear();
        _tabSearchQuery[tabIndex] = '';
      }
    });
  }

  void _updateTabSearchQuery(int tabIndex, String query) {
    setState(() {
      _tabSearchQuery[tabIndex] = query;
    });
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildSortBottomSheet(),
    );
  }

  void _showTabSortOptions(int tabIndex) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildTabSortBottomSheet(tabIndex),
    );
  }

  Widget _buildSortBottomSheet() {
    return Container(
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: grey1,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title
          Padding(
            padding: EdgeInsets.all(_padMd),
            child: Row(
              children: [
                Icon(Icons.sort, color: primaryColor, size: _iconMd),
                SizedBox(width: _gapXs),
                Text(
                  'Sort By',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: _subTitleFs,
                    fontWeight: FontWeight.w600,
                    color: titlecolor,
                  ),
                ),
              ],
            ),
          ),
          // Sort options
          ..._sortOptions.map((option) => _buildSortOption(option)),
          SizedBox(height: _gapSm),
        ],
      ),
    );
  }

  Widget _buildTabSortBottomSheet(int tabIndex) {
    return Container(
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: grey1,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title
          Padding(
            padding: EdgeInsets.all(_padMd),
            child: Row(
              children: [
                Icon(Icons.sort,
                    color: _tabs[tabIndex]['color'], size: _iconMd),
                SizedBox(width: _gapXs),
                Text(
                  'Sort ${_tabs[tabIndex]['title']} Favorites',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: _subTitleFs,
                    fontWeight: FontWeight.w600,
                    color: titlecolor,
                  ),
                ),
              ],
            ),
          ),
          // Sort options
          ..._sortOptions
              .map((option) => _buildTabSortOption(option, tabIndex)),
          SizedBox(height: _gapSm),
        ],
      ),
    );
  }

  Widget _buildSortOption(String option) {
    final isSelected = option == _selectedSortOption;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSortOption = option;
        });
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: _padH, vertical: _padV),
        margin: EdgeInsets.symmetric(
            horizontal: _padH, vertical: (_gapXs * 0.3).clamp(3.0, 6.0)),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: _bodyFs,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? primaryColor : titlecolor,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: primaryColor,
                size: _iconSm,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> fetchBookmarksCount() async {
    try {
      int universityCount = 0;
      int courseCount = 0;
      // 1. Fetch Universities
      final uniResponse = await http.get(
        Uri.parse("${BaseUrl.baseUrlApi}/api/v1/bookmarks/universities/"),
        headers: {'Content-Type': 'application/json'},
      );

      if (uniResponse.statusCode == 200) {
        final uniEnvelope = ApiResponseHandler.parseResponse(
          uniResponse.body,
          (data) => data,
        );
        if (uniEnvelope.isSuccess && uniEnvelope.data is List) {
          universityCount = (uniEnvelope.data as List).length;
          print("🎓 University Count = $universityCount");
        }
      }

      // 2. Fetch Courses
      final courseResponse = await http.get(
        Uri.parse("${BaseUrl.baseUrlApi}/api/v1/bookmarks/courses/"),
        headers: {'Content-Type': 'application/json'},
      );

      if (courseResponse.statusCode == 200) {
        final courseEnvelope = ApiResponseHandler.parseResponse(
          courseResponse.body,
          (data) => data,
        );
        if (courseEnvelope.isSuccess && courseEnvelope.data is List) {
          courseCount = (courseEnvelope.data as List).length;
          print("📘 Course Count = $courseCount");
        }
      }

      // 3. Update UI if inside a widget
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print("❌ Error fetching bookmarks: $e");
    }
  }

  Widget _buildTabSortOption(String option, int tabIndex) {
    final current = (_tabSortOption[tabIndex] ?? '').isNotEmpty
        ? (_tabSortOption[tabIndex] ?? '')
        : _selectedSortOption;
    final isSelected = option == current;
    return GestureDetector(
      onTap: () {
        setState(() {
          _tabSortOption[tabIndex] = option;
        });
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: _padH, vertical: _padV),
        margin: EdgeInsets.symmetric(
          horizontal: _padH,
          vertical: (_gapXs * 0.3).clamp(3.0, 6.0),
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? _tabs[tabIndex]['color'].withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _tabs[tabIndex]['color'] : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: _bodyFs,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? _tabs[tabIndex]['color'] : titlecolor,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: _tabs[tabIndex]['color'],
                size: _iconSm,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: _padH, vertical: _padV),
      decoration: BoxDecoration(
        color: whiteColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main header row
          Row(
            children: [
              // Title with gradient
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, secondaryColor],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: _padMd,
                      vertical: (_padSm * 0.8).clamp(6.0, 10.0),
                    ),
                    child: Text(
                      'Favorites',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: _titleFs,
                        fontWeight: FontWeight.w700,
                        color: whiteColor,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: _gapXs),
              // Search button
              GestureDetector(
                onTap: _toggleSearch,
                child: Container(
                  padding: EdgeInsets.all(_padSm),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _isSearchVisible ? Icons.close : Icons.search,
                    color: primaryColor,
                    size: _iconMd,
                  ),
                ),
              ),
              SizedBox(width: (_gapXs * 0.7).clamp(6.0, 10.0)),
              // Sort button
              GestureDetector(
                onTap: _showSortOptions,
                child: Container(
                  padding: EdgeInsets.all(_padSm),
                  decoration: BoxDecoration(
                    color: secondaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.sort,
                    color: secondaryColor,
                    size: _iconMd,
                  ),
                ),
              ),
            ],
          ),
          // Search bar (animated)
          if (_isSearchVisible) ...[
            SizedBox(height: _gapSm),
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: _padMd,
                    vertical: (_padSm * 0.7).clamp(6.0, 10.0)),
                decoration: BoxDecoration(
                  color: grey1.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: primaryColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: grey3, size: _iconSm),
                    SizedBox(width: _gapXs),
                    Expanded(
                      child: TextField(
                        controller: _headerSearchController,
                        onChanged: _updateSearchQuery,
                        decoration: InputDecoration(
                          hintText: 'Search favorites...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: _bodyFs,
                            color: grey3,
                          ),
                        ),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: _bodyFs,
                          color: titlecolor,
                        ),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _headerSearchController.clear();
                          _updateSearchQuery('');
                        },
                        child: Icon(Icons.clear, color: grey3, size: _iconSm),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: _padH, vertical: _padV),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: _tabs.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> tab = entry.value;
          print(tab);
          bool isSelected = index == _selectedTabIndex;

          return Expanded(
            child: GestureDetector(
              onTap: () => _onTabTapped(index),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? tab['color'].withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Icon and badgesort

                    SizedBox(height: 8),
                    // Title
                    Text(
                      tab['title'],
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: _bodyFs,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? tab['color'] : grey3,
                      ),
                    ),
                    // Animated underline
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      margin: EdgeInsets.only(top: 8),
                      height: 3,
                      width: isSelected ? (_w * 0.12).clamp(28.0, 44.0) : 0,
                      decoration: BoxDecoration(
                        color: tab['color'],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContent() {
    return Expanded(
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: TabBarView(
            controller: _tabController,
            children: [
              // University Tab
              _buildTabContent(0, 'University', Icons.school, primaryColor),
              // Courses Tab
              _buildTabContent(1, 'Courses', Icons.book, secondaryColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(
      int tabIndex, String title, IconData icon, Color color) {
    bool isSearchVisible = _tabSearchVisible[tabIndex] ?? false;
    String searchQuery = _tabSearchQuery[tabIndex] ?? '';

    final effectiveQuery =
        (searchQuery.isNotEmpty ? searchQuery : _searchQuery).trim();

    final tabSort = _tabSortOption[tabIndex] ?? '';
    final effectiveSort = (tabSort.isNotEmpty ? tabSort : _selectedSortOption);

    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: _padH),
        child: Column(
          children: [
            // Tab content header with search and filter
            Container(
              padding: EdgeInsets.all(_padMd),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Header row
                  Row(
                    children: [
                      Icon(icon, color: color, size: _iconMd),
                      SizedBox(width: _gapXs),
                      Expanded(
                        child: Text(
                          '$title Favorites',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: _subTitleFs,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ),
                      Text(
                        tabIndex == 0
                            ? '$universityCount items'
                            : '$courseCount items',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: _bodyFs,
                          color: grey3,
                        ),
                      ),
                      SizedBox(width: _gapXs),
                      // Search button for this tab
                      GestureDetector(
                        onTap: () => _toggleTabSearch(tabIndex),
                        child: Container(
                          padding:
                              EdgeInsets.all((_padSm * 0.8).clamp(6.0, 10.0)),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isSearchVisible ? Icons.close : Icons.search,
                            color: color,
                            size: _iconSm,
                          ),
                        ),
                      ),
                      SizedBox(width: (_gapXs * 0.7).clamp(6.0, 10.0)),
                      // Sort button for this tab
                      GestureDetector(
                        onTap: () => _showTabSortOptions(tabIndex),
                        child: Container(
                          padding:
                              EdgeInsets.all((_padSm * 0.8).clamp(6.0, 10.0)),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.sort,
                            color: color,
                            size: _iconSm,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Search bar for this tab
                  if (isSearchVisible) ...[
                    SizedBox(height: _gapXs),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: _padMd,
                          vertical: (_padSm * 0.7).clamp(6.0, 10.0)),
                      decoration: BoxDecoration(
                        color: whiteColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: color.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: color, size: _iconSm),
                          SizedBox(width: (_gapXs * 0.7).clamp(6.0, 10.0)),
                          Expanded(
                            child: TextField(
                              controller: _tabSearchControllers[tabIndex],
                              onChanged: (query) =>
                                  _updateTabSearchQuery(tabIndex, query),
                              decoration: InputDecoration(
                                hintText: 'Search $title favorites...',
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: _smallFs,
                                  color: grey3,
                                ),
                              ),
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: _smallFs,
                                color: titlecolor,
                              ),
                            ),
                          ),
                          if (searchQuery.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _tabSearchControllers[tabIndex]?.clear();
                                _updateTabSearchQuery(tabIndex, '');
                              },
                              child: Icon(Icons.clear,
                                  color: color, size: _iconSm),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: _gapSm),
            // Explore Universities Button
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 16),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExploreUniversitiesScreen(),
                    ),
                  );
                },
                icon: Icon(
                  Icons.explore,
                  color: whiteColor,
                  size: 20,
                ),
                label: Text(
                  'Explore $title',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: whiteColor,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: whiteColor,
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
            // Content area
            tabIndex == 0
                ? UniversityFavouritesPage(
                    searchQuery: effectiveQuery,
                    sortOption: effectiveSort,
                    embedded: true,
                  )
                : profilecourses(
                    searchQuery: effectiveQuery,
                    sortOption: effectiveSort,
                    embedded: true,
                  ),
            SizedBox(height: _gapSm),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    _w = size.width;
    _h = size.height;

    _padH = (_w * 0.05).clamp(12.0, 24.0);
    _padV = (_h * 0.02).clamp(10.0, 18.0);
    _padMd = (_w * 0.04).clamp(12.0, 20.0);
    _padSm = (_w * 0.03).clamp(8.0, 14.0);
    _gapSm = (_h * 0.02).clamp(10.0, 16.0);
    _gapXs = (_w * 0.03).clamp(8.0, 14.0);

    _iconMd = (_w * 0.06).clamp(20.0, 28.0);
    _iconSm = (_w * 0.05).clamp(18.0, 24.0);

    _titleFs = (_w * 0.055).clamp(18.0, 24.0);
    _subTitleFs = (_w * 0.045).clamp(16.0, 20.0);
    _bodyFs = (_w * 0.035).clamp(13.0, 16.0);
    _smallFs = (_w * 0.03).clamp(11.0, 13.0);

    return Scaffold(
      backgroundColor: color3,
      body: SafeArea(
        child: Column(
          children: [
            // Tab Bar
            _buildTabBar(),
            // Content
            _buildContent(),
          ],
        ),
      ),
      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add new favorite functionality
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Add to favorites functionality coming soon!'),
              backgroundColor: primaryColor,
            ),
          );
        },
        backgroundColor: primaryColor,
        child: Icon(Icons.favorite, color: whiteColor),
      ),
    );
  }
}
