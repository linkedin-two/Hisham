import 'package:edzkool/utils/authenticated_http.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:edzkool/utils/app_log.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/avatar.dart';
import '../../utils/colors/colors.dart';
import '../../utils/responsive.dart';
import 'Devoyage_screen.dart';
// import 'application_screen.dart';
import 'couese.dart';
import 'package:http/http.dart' as http;

import '../../_env/env.dart';
import 'package:edzkool/utils/api_response_handler.dart';

class CourseDetails extends StatefulWidget {
  const CourseDetails({
    super.key,
  });

  static const routeName = '/search-screen';
  final String courseName = '';

  @override
  _CourseDetailsState createState() => _CourseDetailsState();
}

String universityname = '';
String universitylocation = '';
String universitywebsite = '';
String universityProfileImage = '';
String universityLogo = '';
String coursename = '';
String duration = '';
String intake = '';
int grandtotal = 0;
String neetEligibility = '';
String ieltsEligibility = '';
bool passport = false;
bool ielts = false;
bool tenthCard = false;
bool twelfthCard = false;
bool visa = false;
String Firstyearfees = '';
String Secondyearfees = '';
String Thirdyearfees = '';
String Fourthyearfees = '';
String Fifthyearfees = '';
List<dynamic> Firstyearsubjects = [];
List<dynamic> Secondyearsubjects = [];
List<dynamic> Thirdyearsubjects = [];
List<dynamic> Fourthyearsubjects = [];
List<dynamic> Fifthyearsubjects = [];

class _CourseDetailsState extends State<CourseDetails>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // fetchCourseDetails();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: White,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: primaryColor,
            )),
        title: SizedBox(
          height: 250, // Set the width of the container
          width: 200, // Set the height of the container
          child:
              Image.asset(edvoyagelogo1), // Replace with the actual image path
        ),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 150.0,
                  decoration: BoxDecoration(
                      color: White,
                      shape: BoxShape.rectangle,
                      image: DecorationImage(
                          image: AssetImage("assets/Rectangle_1008.png"),
                          fit: BoxFit.cover)),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  heightFactor: 2.3,
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    width: 100,
                    height: 90.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: AssetImage("assets/logo_2.png"),
                          fit: BoxFit.cover),
                    ),
                  ),
                ),
              ],
            ),
            Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  //  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      universityname,
                      style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'Roboto',
                          letterSpacing: 2,
                          color: Colors.black,
                          fontWeight: FontWeight.w600),
                    ),
                    hGap(10),
                    Icon(Icons.edit)
                  ],
                ),
                vGap(5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on),
                    hGap(5),
                    Text(
                      universitylocation,
                      style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'Roboto',
                          letterSpacing: 2,
                          color: Colors.black,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                vGap(5),
              ],
            ),
            vGap(5),
            Container(
              color: White,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                ),
                child: TabBar(
                  unselectedLabelColor: Colors.grey,
                  labelColor: Cprimary,
                  controller: _tabController,
                  indicatorColor: Cprimary,
                  labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 18.0,
                            color: Colors.orange,
                          ) ??
                      TextStyle(fontSize: 18.0, color: Colors.orange),
                  unselectedLabelStyle:
                      Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 16.0,
                                color: Colors.grey[200],
                              ) ??
                          TextStyle(fontSize: 16.0, color: Colors.grey[200]),
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: const [
                    Tab(child: Text('Course')),
                    Tab(child: Text('Application')),
                    Tab(child: Text('Voyage')),
                  ],
                ),
                // UIHelper.verticalSpaceSmall(),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  coursesTab(
                    coursename: coursename,
                    duration: duration,
                    intake: intake,
                    grandtotal: grandtotal,
                    neetEligibility: neetEligibility,
                    ieltsEligibility: ieltsEligibility,
                    passport: passport,
                    ielts: ielts,
                    tenthCard: tenthCard,
                    twelfthCard: twelfthCard,
                    visa: visa,
                    Firstyearfees: Firstyearfees,
                    Secondyearfees: Secondyearfees,
                    Thirdyearfees: Thirdyearfees,
                    Fourthyearfees: Fourthyearfees,
                    Fifthyearfees: Fifthyearfees,
                    Firstyearsubjects: Firstyearsubjects,
                    Secondyearsubjects: Secondyearsubjects,
                    Thirdyearsubjects: Thirdyearsubjects,
                    Fourthyearsubjects: Fourthyearsubjects,
                    Fifthyearsubjects: Fifthyearsubjects,
                  ),
                  // CustomStepper(),
                  DevoyageTab(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void fetchCourseDetails(
      {required int courseid, required int universityid}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? mobile = prefs.getString('mobilenumber');

    AppLog.debug("Course ID: $courseid");
    AppLog.debug("University ID: $universityid");
    AppLog.debug("Username: $mobile");

    try {
      final response = await AuthenticatedHttp.get(
        Uri.parse(BaseUrl.courseById(courseid)),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final Map<String, dynamic> courseDetails;
        if (decoded is Map<String, dynamic> &&
            decoded.containsKey('success') &&
            decoded.containsKey('data')) {
          final envelope = ApiResponseHandler.parseResponse(
            response.body,
            (data) => data as Map<String, dynamic>,
          );
          if (!envelope.isSuccess || envelope.data == null) {
            throw Exception(envelope.message.isNotEmpty
                ? envelope.message
                : 'Failed to load course details');
          }
          courseDetails = envelope.data!;
        } else {
          courseDetails = Map<String, dynamic>.from(decoded as Map);
        }

        universityname = courseDetails['university_name']?.toString() ?? '';
        universitylocation = courseDetails['university_city']?.toString() ?? '';
        universitywebsite = courseDetails['university_website']?.toString() ?? '';
        universityProfileImage = courseDetails['image']?.toString() ?? '';
        universityLogo = courseDetails['image']?.toString() ?? '';
        coursename = courseDetails['name']?.toString() ?? '';
        duration = courseDetails['duration']?.toString() ?? '';
        intake = courseDetails['level']?.toString() ?? '';
        grandtotal = (courseDetails['tuition_fee'] as num?)?.toInt() ?? 0;
        neetEligibility = courseDetails['minimum_gpa']?.toString() ?? '';
        ieltsEligibility =
            courseDetails['language_requirements']?.toString() ?? '';
        Firstyearfees = courseDetails['tuition_fee']?.toString() ?? '';
        Secondyearfees = '';
        Thirdyearfees = '';
        Fourthyearfees = '';
        Fifthyearfees = '';
        Firstyearsubjects = courseDetails['subjects'] as List<dynamic>? ?? [];
        Secondyearsubjects = [];
        Thirdyearsubjects = [];
        Fourthyearsubjects = [];
        Fifthyearsubjects = [];

        final requirements = courseDetails['requirements'] as List<dynamic>? ?? [];
        passport = requirements.any((r) => r.toString().toLowerCase().contains('passport'));
        ielts = requirements.any((r) => r.toString().toLowerCase().contains('ielts'));
        tenthCard = requirements.any((r) => r.toString().contains('10'));
        twelfthCard = requirements.any((r) => r.toString().contains('12'));
        visa = requirements.any((r) => r.toString().toLowerCase().contains('visa'));

        // Print each variable
        AppLog.debug('University Name: $universityname');
        AppLog.debug('University Location: $universitylocation');
        AppLog.debug('University Website: $universitywebsite');
        AppLog.debug('University Profile Image: $universityProfileImage');
        AppLog.debug('University Logo: $universityLogo');
        AppLog.debug('Course Name: $coursename');
        AppLog.debug('Duration: $duration');
        AppLog.debug('Intake: $intake');
        AppLog.debug('Grand Total: $grandtotal');
        AppLog.debug('NEET Eligibility: $neetEligibility');
        AppLog.debug('IELTS Eligibility: $ieltsEligibility');
        AppLog.debug('Passport: $passport');
        AppLog.debug('IELTS: $ielts');
        AppLog.debug('Tenth Card: $tenthCard');
        AppLog.debug('Twelfth Card: $twelfthCard');
        AppLog.debug('Visa: $visa');

        // Set the state or do other operations as needed
        setState(() {
          // Assign the values to your global variables
        });

        AppLog.debug('Data fetched successfully');
      } else {
        AppLog.debug('Failed to load courses. Status code: ${response.statusCode}');
        throw Exception('Failed to load courses');
      }
    } catch (e, stackTrace) {
      AppLog.debug('Error fetching data: $e');
      AppLog.debug('StackTrace: $stackTrace');
    }
  }
}
