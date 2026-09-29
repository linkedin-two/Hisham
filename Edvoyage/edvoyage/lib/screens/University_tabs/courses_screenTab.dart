import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:edvoyage/utils/colors/colors.dart';
import 'package:edvoyage/_env/env.dart';
import 'package:edvoyage/utils/api_response_handler.dart';
import 'package:edvoyage/providers/user_email_provider.dart';

class CoursesScreenTab extends ConsumerStatefulWidget {
  final int universityId;

  const CoursesScreenTab({super.key, required this.universityId});
  @override
  ConsumerState<CoursesScreenTab> createState() => _CoursesScreenTabState();
}

class _CoursesScreenTabState extends ConsumerState<CoursesScreenTab> {
  late Future<List<dynamic>> coursesFuture;
  Map<int, bool> favouriteStatus = {};
  // define and initialize courses variable
  late List<dynamic> courses = [];
  Future<void> refreshFavouriteStatus() async {
    final status = await fetchFavouriteStatus();
    if (mounted) {
      setState(() {
        favouriteStatus = status;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // No need to refresh here - initState handles it
  }

  @override
  void initState() {
    super.initState();
    // Load both courses and favourites, then build UI
    coursesFuture = _loadCoursesAndFavourites();
  }

  Future<List<dynamic>> _loadCoursesAndFavourites() async {
    // Fetch both in parallel
    final courses = await fetchCourses(widget.universityId);
    final favStatus = await fetchFavouriteStatus();

    // Store favourites and return courses
    setState(() {
      favouriteStatus = favStatus;
    });

    print(
        '✅ DEBUG: Loaded ${courses.length} courses, ${favStatus.length} favourites');
    return courses;
  }

  Future<Map<int, bool>> fetchFavouriteStatus() async {
    try {
      final currentUserEmail = ref.read(userEmailProvider);
      print('🔍 DEBUG GET FAVOURITES: email=$currentUserEmail');
      
      final response = await http.get(
        Uri.parse(BaseUrl.favouriteCourses),
        headers: {
          'x-user-email': currentUserEmail ?? '',
        },
      );

      if (response.statusCode == 200) {
        final envelope = ApiResponseHandler.parseResponse(
          response.body,
          (data) => data,
        );
        if (!envelope.isSuccess) {
          print('❌ DEBUG: API returned isSuccess=false');
          return <int, bool>{};
        }

        final rawData = envelope.data;
        print('🔍 DEBUG: Raw envelope.data type: ${rawData.runtimeType}, value: $rawData');
        
        // Handle nested data structure: {data: {data: [...], count: ...}}
        final List<dynamic> items;
        if (rawData is Map<String, dynamic> && rawData.containsKey('data')) {
          final nestedData = rawData['data'];
          items = nestedData is List ? nestedData : ApiResponse.extractList(nestedData);
        } else {
          items = ApiResponse.extractList(rawData);
        }
        print('🔍 DEBUG: Favorites API returned ${items.length} items');
        
        final Map<int, bool> status = {};
        for (var item in items) {
          final course = item['course'];
          final rawId = course['id'];
          final courseId = rawId is int ? rawId : int.parse(rawId.toString());
          print('🔍 DEBUG: Storing favorite courseId=$courseId (raw=$rawId, type=${rawId.runtimeType})');
          status[courseId] = true;
        }

        print('🔍 DEBUG: Final favouriteStatus map: $status');
        return status;
      } else {
        print('❌ DEBUG: Favorites API failed with status ${response.statusCode}');
        throw Exception('Failed to load favourite status');
      }
    } catch (e) {
      print('❌ DEBUG: Error fetching favourite status: $e');
      return <int, bool>{};
    }
  }

  Future<List<dynamic>> fetchCourses(int universityId) async {
    try {
      print('🔍 DEBUG: Fetching courses for university ID: $universityId');

      // Use the correct courses API endpoint
      final response = await http.get(
        Uri.parse('${BaseUrl.allCourses}?university_id=$universityId'),
      );

      print('🔍 DEBUG: Courses API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final envelope = ApiResponseHandler.parseResponse(
          response.body,
          (data) => data,
        );
        if (!envelope.isSuccess) {
          return [];
        }

        final extracted = ApiResponse.extractList(envelope.data);
        print('🔍 DEBUG: Extracted courses count: ${extracted.length}');
        return extracted;
      } else {
        print(
            '🔍 DEBUG: API request failed with status: ${response.statusCode}');
        throw Exception('Failed to load courses: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('🔍 DEBUG: Error fetching courses: $e');
      throw Exception('Failed to load courses: $e');
    }
  }

  String formatDuration(String? duration) {
    if (duration == null) return 'N/A';

    switch (duration) {
      case '1_year':
        return '1 Year';
      case '2_years':
        return '2 Years';
      case '3_years':
        return '3 Years';
      case '4_years':
        return '4 Years';
      case '6_months':
        return '6 Months';
      case '1_semester':
        return '1 Semester';
      default:
        return duration.replaceAll('_', ' ').toUpperCase();
    }
  }

  String formatLevel(String? level) {
    if (level == null) return 'N/A';

    switch (level) {
      case 'undergraduate':
        return 'Undergraduate';
      case 'postgraduate':
        return 'Postgraduate';
      case 'phd':
        return 'PhD';
      case 'diploma':
        return 'Diploma';
      case 'certificate':
        return 'Certificate';
      default:
        return level.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final w = size.width;
    final h = size.height;

    final padSm = (w * 0.02).clamp(6.0, 12.0);
    final padMd = (w * 0.03).clamp(10.0, 16.0);
    final cardMargin = (w * 0.025).clamp(8.0, 14.0);
    final cardPad = (w * 0.03).clamp(10.0, 16.0);

    final titleFs = (w * 0.04).clamp(14.0, 18.0);
    final bodyFs = (w * 0.032).clamp(12.0, 14.0);
    final smallFs = (w * 0.03).clamp(11.0, 13.0);
    final chipFs = (w * 0.026).clamp(10.0, 12.0);

    final bigIcon = (w * 0.12).clamp(36.0, 52.0);
    final starIcon = (w * 0.035).clamp(12.0, 16.0);
    final gapSm = (h * 0.01).clamp(6.0, 12.0);
    final gapXsW = (w * 0.008).clamp(2.0, 6.0);

    return Scaffold(
      backgroundColor: color3,
      body: FutureBuilder<List<dynamic>>(
        future: coursesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Cprimary,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: bigIcon,
                  ),
                  SizedBox(height: gapSm),
                  Text(
                    'Error loading courses',
                    style: TextStyle(
                      fontSize: titleFs,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: (gapSm * 0.5).clamp(4.0, 8.0)),
                  Text(
                    '${snapshot.error}',
                    style: TextStyle(
                      fontSize: smallFs,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school_outlined,
                    color: Colors.grey,
                    size: bigIcon,
                  ),
                  SizedBox(height: gapSm),
                  Text(
                    'No courses available',
                    style: TextStyle(
                      fontSize: titleFs,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: (gapSm * 0.5).clamp(4.0, 8.0)),
                  Text(
                    'This university has not added any courses yet.',
                    style: TextStyle(
                      fontSize: smallFs,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          for (var i in snapshot.data!) {
            var typeOfI = i['university_id']?.runtimeType;
            var typeOfWidget = widget.universityId.runtimeType;
            print('Comparing types: $typeOfI vs $typeOfWidget');

            print(
                'Comparing course university ID: ${i['university_id']} with widget university ID: ${widget.universityId}');
          }

          // Filter courses by university ID

          courses = snapshot.data!
              .where((course) =>
                  course['university_id']?.toString() ==
                  widget.universityId.toString())
              .toList();

          // loop through courses and print their university IDs
          for (var course in courses) {
            print(
                'Current favourite status for course ${course['id']}: ${favouriteStatus[course['id']]}');
          }

          print('🔍 DEBUG: Building courses list with $courses courses');

          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              print(
                  '🔍 DEBUG: Building course $index: ${course['name'] ?? 'Unknown'}');

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
                margin: EdgeInsets.all(cardMargin),
                child: Padding(
                  padding: EdgeInsets.all(cardPad),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row 1: Name, Code, Rating
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              course['name'] ?? 'Unknown Course',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: titleFs,
                                color: Cprimary,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (course['code'] != null)
                            Text(
                              course['code'],
                              style: TextStyle(
                                fontSize: smallFs,
                                color: grey3,
                              ),
                            ),
                          SizedBox(width: padSm),
                          if (course['average_rating'] != null)
                            Row(
                              children: [
                                Icon(Icons.star,
                                    size: starIcon, color: Colors.orange),
                                SizedBox(width: gapXsW),
                                Text(
                                  '${course['average_rating']}/5',
                                  style: TextStyle(
                                      fontSize: smallFs, color: Colors.orange),
                                ),
                              ],
                            ),
                        ],
                      ),
                      SizedBox(height: (gapSm * 0.5).clamp(4.0, 10.0)),

                      Row(
                        children: [
                          if (course['university_name'] != null)
                            Expanded(
                              child: Text(
                                course['university_name'],
                                style:
                                    TextStyle(fontSize: smallFs, color: grey3),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          if (course['level'] != null)
                            Expanded(
                              child: Text(
                                'Level: ${formatLevel(course['level'])}',
                                style:
                                    TextStyle(fontSize: smallFs, color: grey3),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: (gapSm * 0.5).clamp(4.0, 10.0)),

                      // Row 3: Duration, Applications
                      Row(
                        children: [
                          if (course['duration'] != null)
                            Expanded(
                              child: Text(
                                'Duration: ${formatDuration(course['duration'])}',
                                style:
                                    TextStyle(fontSize: smallFs, color: grey3),
                              ),
                            ),
                          if (course['total_applications'] != null)
                            Expanded(
                              child: Text(
                                'Applications: ${course['total_applications']}',
                                style:
                                    TextStyle(fontSize: smallFs, color: grey3),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: (gapSm * 0.5).clamp(4.0, 10.0)),

                      // Row 4: Remaining details
                      if (course['short_description'] != null ||
                          course['description'] != null)
                        Text(
                          course['short_description'] ??
                              course['description'] ??
                              '',
                          style: TextStyle(fontSize: bodyFs),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      SizedBox(height: (gapSm * 0.5).clamp(4.0, 10.0)),

                      // Tuition & Credits
                      Row(
                        children: [
                          if (course['tuition_fee'] != null)
                            Expanded(
                              child: Text(
                                'Tuition: \$${course['tuition_fee']} ${course['currency'] ?? 'USD'}',
                                style: TextStyle(
                                  fontSize: smallFs,
                                  color: Cprimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          if (course['credits'] != null)
                            Expanded(
                              child: Text(
                                'Credits: ${course['credits']}',
                                style:
                                    TextStyle(fontSize: smallFs, color: grey3),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: (gapSm * 0.5).clamp(4.0, 10.0)),

                      // Badges
                      SizedBox(height: padSm),

                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Wrap(
                            spacing: 8,
                            children: [
                              if (course['status'] != null)
                                Chip(
                                  label: Text(course['status'].toUpperCase(),
                                      style: TextStyle(
                                          fontSize: chipFs,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                  backgroundColor: course['status'] == 'active'
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                              if (course['is_featured'] == true)
                                Chip(
                                  label: Text('FEATURED',
                                      style: TextStyle(
                                          fontSize: chipFs,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                  backgroundColor: Colors.blue,
                                ),
                              if (course['is_popular'] == true)
                                Chip(
                                  label: Text('POPULAR',
                                      style: TextStyle(
                                          fontSize: chipFs,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                  backgroundColor: Colors.orange,
                                ),
                            ],
                          ),
                          Builder(builder: (context) {
                            final courseIdRaw = course['id'];
                            final courseIdInt = courseIdRaw is int ? courseIdRaw : int.tryParse(courseIdRaw.toString()) ?? 0;
                            final isFav = favouriteStatus[courseIdInt] ?? false;
                            print('🔍 DEBUG BUTTON: courseIdRaw=$courseIdRaw (type=${courseIdRaw.runtimeType}), courseIdInt=$courseIdInt, isFav=$isFav, map=$favouriteStatus');

                            return (isFav)
                                ? OutlinedButton(
                                    style: ButtonStyle(
                                      backgroundColor: WidgetStateProperty.all(
                                          Colors.redAccent),
                                    ),
                                    onPressed: () async {
                                      final courseId = course['id'] is int
                                          ? course['id']
                                          : int.tryParse(
                                                  course['id'].toString()) ??
                                              0;
                                      final currentUserEmail =
                                          ref.read(userEmailProvider);
                                      print(
                                          '🔍 DEBUG FOLLOW BUTTON: courseId=$courseId, email=$currentUserEmail');
                                      if (currentUserEmail == null ||
                                          currentUserEmail.isEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'No email found. Please login again.'),
                                          ),
                                        );
                                        return;
                                      }
                                      print(
                                          'Current user email: $currentUserEmail');

                                      try {
                                        final response = await http.post(
                                          Uri.parse(BaseUrl.favouriteCourses),
                                          headers: {
                                            'Content-Type': 'application/json'
                                          },
                                          body: jsonEncode({
                                            'course_id': courseId,
                                            'user_email': currentUserEmail,
                                          }),
                                        );

                                        if (response.statusCode == 200 ||
                                            response.statusCode == 201) {
                                          final responseData =
                                              jsonDecode(response.body);
                                          print('Response data: $responseData');
                                          final action =
                                              responseData['data']?['action'];
                                          print('Action from backend: $action');
                                          setState(() {
                                            favouriteStatus[courseId] =
                                                action == 'added';
                                          });

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(action == 'added'
                                                  ? 'Course followed'
                                                  : 'Course unfollowed'),
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Failed: ${response.body}')),
                                          );
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(content: Text('Error: $e')),
                                        );
                                      }
                                    },
                                    child: Text(
                                      'Unfollow',
                                      style: TextStyle(color: whiteColor),
                                    ),
                                  )
                                : OutlinedButton(
                                    style: ButtonStyle(
                                        backgroundColor: WidgetStateProperty.all(
                                            primaryColor)),
                                    onPressed: () async {
                                      final courseId = course['id'] is int
                                          ? course['id']
                                          : int.tryParse(
                                                  course['id'].toString()) ??
                                              0;
                                      final currentUserEmail =
                                          ref.read(userEmailProvider);
                                      print(
                                          '🔍 DEBUG FOLLOW BUTTON (Follow): courseId=$courseId, email=$currentUserEmail');
                                      if (currentUserEmail == null ||
                                          currentUserEmail.isEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'No email found. Please login again.'),
                                          ),
                                        );
                                        return;
                                      }

                                      try {
                                        final response = await http.post(
                                          Uri.parse(BaseUrl.favouriteCourses),
                                          headers: {
                                            'Content-Type': 'application/json'
                                          },
                                          body: jsonEncode({
                                            'course_id': courseId,
                                            'user_email': currentUserEmail,
                                          }),
                                        );

                                        if (response.statusCode == 200 ||
                                            response.statusCode == 201) {
                                          final responseData =
                                              jsonDecode(response.body);
                                          print('Response data: $responseData');
                                          final action =
                                              responseData['data']?['action'];
                                          print('Action from backend: $action');
                                          setState(() {
                                            favouriteStatus[courseId] =
                                                action == 'added';
                                          });

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(action == 'added'
                                                  ? 'Course followed'
                                                  : 'Course unfollowed'),
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Failed: ${response.body}')),
                                          );
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(content: Text('Error: $e')),
                                        );
                                      }
                                    },
                                    child: Text('Follow',
                                        style: TextStyle(color: whiteColor)),
                                  );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
