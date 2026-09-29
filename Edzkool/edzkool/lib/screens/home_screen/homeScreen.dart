import 'package:edzkool/services/home_api_service.dart';
import 'package:edzkool/utils/authenticated_http.dart';
import 'package:flutter/material.dart';
import 'package:edzkool/utils/app_log.dart';
import 'package:flutter/services.dart';
import 'package:edzkool/_env/env.dart';
import 'package:edzkool/screens/home_screen/homescreenreplaceable/homeScreen_happysplash.dart';
import 'package:edzkool/utils/responsive.dart';
import 'package:edzkool/widgets/botttom_nav.dart';
import 'package:edzkool/utils/avatar.dart';
import 'package:edzkool/utils/colors/colors.dart';
import 'package:edzkool/widgets/long_button.dart';
import 'package:edzkool/screens/exploreUniversity_screen/exploreUniversitiesScreen.dart';
import 'package:edzkool/screens/notification/notification.dart';
import 'MCQQuestionWidget.dart';
import 'sad_splash.dart';
import 'exhausted _splash.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edzkool/utils/token_auth_service.dart';
import 'package:edzkool/screens/login/sign_up.dart';
import 'package:edzkool/providers/user_email_provider.dart';
import 'package:edzkool/utils/api_response_handler.dart';

class HomeData {
  final Map<String, dynamic> questionOfTheDayData;
  final List<dynamic> allNotificationsData;
  final List<dynamic> offerNotificationsData;

  HomeData({
    required this.questionOfTheDayData,
    required this.allNotificationsData,
    required this.offerNotificationsData,
  });
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Measurements? size;
  HomeData? homeData;
  int universityLength = 0;
  bool isLoadingUniversityCount = false;
  int coursesLength = 0;
  bool isLoadingCoursesCount = false;

  @override
  void initState() {
    super.initState();
    // Call fetchData when the widget is first created
    fetchData();
    getLengthOfAllUniversities();
    getLengthOfAllCourses();
  }

  // Method to refresh university count (can be called on pull-to-refresh or error)
  Future<void> refreshUniversityCount() async {
    await getLengthOfAllUniversities();
  }

  // Method to refresh courses count (can be called on pull-to-refresh or error)
  Future<void> refreshCoursesCount() async {
    await getLengthOfAllCourses();
  }

  Future<void> getLengthOfAllUniversities() async {
    setState(() {
      isLoadingUniversityCount = true;
    });

    try {
      var response = await AuthenticatedHttp.get(Uri.parse(BaseUrl.universityStats));
      if (response.statusCode == 200) {
        final envelope = ApiResponseHandler.parseResponse(
          response.body,
          (data) => data as Map<String, dynamic>,
        );
        AppLog.debug("The Response Data is: ${envelope.data}");

        if (envelope.isSuccess && envelope.data != null) {
          int totalUniversities = envelope.data!['total_universities'] ?? 0;
          AppLog.debug('Total Universities Count: $totalUniversities');

          setState(() {
            universityLength = totalUniversities;
            isLoadingUniversityCount = false;
          });
        } else {
          AppLog.debug('Invalid response format or success is false');
          setState(() {
            universityLength = 0;
            isLoadingUniversityCount = false;
          });
        }
      } else {
        AppLog.debug('Failed to load data: ${response.statusCode}');
        setState(() {
          universityLength = 0;
          isLoadingUniversityCount = false;
        });
      }
    } catch (e) {
      AppLog.debug('Error fetching university count: $e');
      setState(() {
        universityLength = 0;
        isLoadingUniversityCount = false;
      });
    }
  }

  Future<void> getLengthOfAllCourses() async {
    setState(() {
      isLoadingCoursesCount = true;
    });

    try {
      var response = await AuthenticatedHttp.get(Uri.parse(BaseUrl.coursesStats));
      if (response.statusCode == 200) {
        final envelope = ApiResponseHandler.parseResponse(
          response.body,
          (data) => data as Map<String, dynamic>,
        );
        AppLog.debug("The Courses Response Data is: ${envelope.data}");

        if (envelope.isSuccess && envelope.data != null) {
          int totalCourses = envelope.data!['total_courses'] ?? 0;
          AppLog.debug('Total Courses Count: $totalCourses');

          setState(() {
            coursesLength = totalCourses;
            isLoadingCoursesCount = false;
          });
        } else {
          AppLog.debug('Invalid courses response format or success is false');
          setState(() {
            coursesLength = 0;
            isLoadingCoursesCount = false;
          });
        }
      } else {
        AppLog.debug('Failed to load courses data: ${response.statusCode}');
        setState(() {
          coursesLength = 0;
          isLoadingCoursesCount = false;
        });
      }
    } catch (e) {
      AppLog.debug('Error fetching courses count: $e');
      setState(() {
        coursesLength = 0;
        isLoadingCoursesCount = false;
      });
    }
  }

  Future<void> fetchData() async {
    try {
      final responseData = await HomeApiService.fetchDashboard();
      if (responseData == null) {
        AppLog.debug('Failed to load home dashboard data');
        return;
      }

      final questionOfTheDayData =
          Map<String, dynamic>.from(responseData['question_of_the_day'] as Map? ?? {});
      final allNotificationsData =
          List<dynamic>.from(responseData['all_notifications'] as List? ?? []);
      final offerNotificationsData =
          List<dynamic>.from(responseData['offer_notifications'] as List? ?? []);

      setState(() {
        homeData = HomeData(
          questionOfTheDayData: questionOfTheDayData,
          allNotificationsData: allNotificationsData,
          offerNotificationsData: offerNotificationsData,
        );
      });
    } catch (e) {
      AppLog.debug('Error: $e');
    }
  }

  Future<void> _performLogout() async {
    ref.read(userEmailProvider.notifier).state = null;
    await TokenAuthService.logoutAndClear();

    // Navigate to the SignUp screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignUp()),
    );
  }

  @override
  Widget build(BuildContext context) {
    size = Measurements(MediaQuery.of(context).size);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          SystemNavigator.pop(); // exit the app
        }
      },
      child: Scaffold(
          bottomNavigationBar: BottomButton(onTap: () {}, selectedIndex: 2),
          backgroundColor: Colors.grey.shade200,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.2,
            automaticallyImplyLeading: false,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(
                Icons.logout,
                color: primaryColor,
              ),
              onPressed: () async {
                // Show confirmation dialog
                bool? shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Logout'),
                      content: Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text('Logout'),
                        ),
                      ],
                    );
                  },
                );

                if (shouldLogout == true) {
                  // Perform logout
                  await _performLogout();
                }
              },
            ),
            title: SizedBox(
              height: 200, // Set the height of the container
              child: Image.asset(
                  edvoyagelogo1), // Replace with the actual image path
            ),
            actions: [
              IconButton(
                  icon: Icon(
                    Icons.notifications,
                    color: primaryColor,
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NotificationScreen()));
                  })
            ],
          ),
          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(children: [
                  Center(
                    child: Container(
                      padding: EdgeInsets.only(top: 5),
                      height: size?.hp(30),
                      width: size?.wp(95),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: const Color.fromRGBO(20, 71, 135, 1),
                          border: Border.all(color: thirdColor, width: 1.5)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            'How are you feeling today?',
                            style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold),
                          ),
                          Stack(children: [
                            Container(
                              margin: EdgeInsets.only(top: 5),
                              height: size?.hp(15),
                              width: size?.wp(95),
                              child: Image.asset(
                                'assets/curving.png',
                                fit: BoxFit.fill,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 20),
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    height: size?.hp(10),
                                    width: size?.wp(17.5),
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                                pageBuilder: (_, __, ___) =>
                                                    ExhuastedSplash()));
                                      },
                                      child: Image.asset(
                                          'assets/exhaustedB.png',
                                          fit: BoxFit.fill),
                                    ),
                                  ),
                                  Container(
                                    height: size?.hp(11),
                                    width: size?.wp(25),
                                    decoration: BoxDecoration(
                                      color: thirdColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: SizedBox(
                                      height: size?.hp(10),
                                      width: size?.wp(22),
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              PageRouteBuilder(
                                                  pageBuilder: (_, __, ___) =>
                                                      HomeScreenhappysplash()));
                                        },
                                        child: Image.asset(
                                          'assets/happy.png',
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: size?.hp(10),
                                    width: size?.wp(17.5),
                                    child: TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              PageRouteBuilder(
                                                  pageBuilder: (_, __, ___) =>
                                                      SadSplash()));
                                        },
                                        child: Image.asset('assets/sadB.png',
                                            fit: BoxFit.fill)),
                                  )
                                ],
                              ),
                            )
                          ]),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 2),
                                height: 10,
                                width: 2,
                                decoration: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: BorderRadius.circular(.25)),
                              ),
                              Container(
                                height: 15,
                                width: 3,
                                decoration: BoxDecoration(
                                    color: secondaryColor,
                                    borderRadius: BorderRadius.circular(.25)),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 2),
                                height: 10,
                                width: 2,
                                decoration: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: BorderRadius.circular(.25)),
                              )
                            ],
                          ),
                          Text(
                            'Happy',
                            style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  ),
                  // Center(
                  //   child: Container(
                  //     margin: EdgeInsets.symmetric(vertical: 10),
                  //     height: size?.hp(30),
                  //     width: size?.wp(95),
                  //     decoration: BoxDecoration(
                  //         color: thirdColor,
                  //         borderRadius: BorderRadius.circular(10),
                  //         boxShadow: [
                  //           BoxShadow(
                  //               offset: Offset(1, 1),
                  //               blurRadius: 2,
                  //               color: grey2,
                  //               spreadRadius: 2)
                  //         ]),
                  //     child: Column(
                  //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //       children: [
                  //         Text(
                  //           'Explore Courses & Universities',
                  //           textScaler: TextScaler.linear(1.6),
                  //           style: TextStyle(
                  //             color: primaryColor,
                  //             fontWeight: FontWeight.w800,
                  //           ),
                  //         ),
                  //         Row(
                  //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //           children: [
                  //             Container(
                  //               height: size?.hp(14),
                  //               width: size?.wp(42),
                  //               decoration: BoxDecoration(
                  //                   color: thirdColor,
                  //                   borderRadius: BorderRadius.circular(10),
                  //                   boxShadow: [
                  //                     BoxShadow(
                  //                         offset: Offset(0, 0),
                  //                         spreadRadius: 1,
                  //                         color: grey2)
                  //                   ]),
                  //               child: Column(
                  //                 mainAxisAlignment: MainAxisAlignment.center,
                  //                 children: [
                  //                   SizedBox(
                  //                     height: size?.hp(4.5),
                  //                     width: size?.wp(9.6),
                  //                     child: Image.asset(
                  //                       universityimage,
                  //                     ),
                  //                   ),
                  //                   isLoadingUniversityCount
                  //                       ? SizedBox(
                  //                           height: 20,
                  //                           width: 20,
                  //                           child: CircularProgressIndicator(
                  //                             strokeWidth: 2,
                  //                             valueColor:
                  //                                 AlwaysStoppedAnimation<Color>(
                  //                                     primaryColor),
                  //                           ),
                  //                         )
                  //                       : Text(
                  //                           universityLength > 0
                  //                               ? universityLength.toString()
                  //                               : '--',
                  //                           textScaler: TextScaler.linear(1.5),
                  //                           style: TextStyle(
                  //                             fontWeight: FontWeight.w900,
                  //                             color: universityLength > 0
                  //                                 ? null
                  //                                 : Colors.grey,
                  //                           ),
                  //                         ),
                  //                   Text(
                  //                     'Universiteis',
                  //                     style: TextStyle(
                  //                       fontWeight: FontWeight.w800,
                  //                     ),
                  //                   )
                  //                 ],
                  //               ),
                  //             ),
                  //             Container(
                  //               height: size?.hp(14),
                  //               width: size?.wp(42),
                  //               decoration: BoxDecoration(
                  //                   color: thirdColor,
                  //                   borderRadius: BorderRadius.circular(10),
                  //                   boxShadow: [
                  //                     BoxShadow(
                  //                         offset: Offset(0, 0),
                  //                         spreadRadius: 1,
                  //                         color: grey2)
                  //                   ]),
                  //               child: Column(
                  //                 mainAxisAlignment: MainAxisAlignment.center,
                  //                 children: [
                  //                   SizedBox(
                  //                     height: size?.hp(4.5),
                  //                     width: size?.wp(9.6),
                  //                     child: Image.asset(
                  //                       coursesimage,
                  //                     ),
                  //                   ),
                  //                   isLoadingCoursesCount
                  //                       ? SizedBox(
                  //                           height: 20,
                  //                           width: 20,
                  //                           child: CircularProgressIndicator(
                  //                             strokeWidth: 2,
                  //                             valueColor:
                  //                                 AlwaysStoppedAnimation<Color>(
                  //                                     primaryColor),
                  //                           ),
                  //                         )
                  //                       : Text(
                  //                           coursesLength > 0
                  //                               ? coursesLength.toString()
                  //                               : '--',
                  //                           textScaler: TextScaler.linear(1.5),
                  //                           style: TextStyle(
                  //                             fontWeight: FontWeight.w900,
                  //                             color: coursesLength > 0
                  //                                 ? null
                  //                                 : Colors.grey,
                  //                           ),
                  //                         ),
                  //                   Text(
                  //                     'Courses',
                  //                     style: TextStyle(
                  //                       fontWeight: FontWeight.w800,
                  //                     ),
                  //                   )
                  //                 ],
                  //               ),
                  //             )
                  //           ],
                  //         ),
                  //         LongButton(
                  //             action: () {
                  //               Navigator.push(
                  //                   context,
                  //                   MaterialPageRoute(
                  //                       builder: (context) =>
                  //                           ExploreUniversitiesScreen()));
                  //             },
                  //             text: 'Explore Now'),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  MCQQuestionWidget(),
                ])),
          )),
    );
  }
}
