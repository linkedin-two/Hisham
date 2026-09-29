import 'package:flutter/material.dart';
import 'package:edzkool/utils/app_log.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:edzkool/_env/env.dart';
import 'package:edzkool/utils/api_response_handler.dart';
import 'package:edzkool/utils/avatar.dart';
import 'package:edzkool/screens/University_tabs/FeedTab.dart';
import 'package:edzkool/screens/University_tabs/GalleryTab.dart';
import 'package:edzkool/models/university.dart';
import 'package:edzkool/screens/University_tabs/aboutTab.dart';
import 'package:edzkool/screens/University_tabs/courses_screenTab.dart';
import 'package:edzkool/utils/BottomNavigation/controller.dart';
import 'package:edzkool/utils/colors/colors.dart';
import 'package:edzkool/utils/responsive.dart';
import 'package:edzkool/utils/authenticated_http.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';

BottomNavigationController controller = Get.put(BottomNavigationController());

class UniversitHomeScreen extends StatefulWidget {
  final University university;
  const UniversitHomeScreen({super.key, required this.university});

  @override
  State<UniversitHomeScreen> createState() => _UniversitHomeScreenState();
}

class _UniversitHomeScreenState extends State<UniversitHomeScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  late University university;
  late Future<bool> userIsFollowing = Future.value(false);

  // Bookmark state management
  bool isBookmarked = false;
  bool isLoadingBookmark = false;

  Future<void> _checkIfBookmarked() async {
    final response = await AuthenticatedHttp.get(
      Uri.parse(BaseUrl.favouriteUniversities),
    );

    if (response.statusCode == 200) {
      try {
        final envelope = ApiResponseHandler.parseResponse(
          response.body,
          (data) => data,
        );
        if (!envelope.isSuccess) {
          return;
        }

        final List<dynamic> bookmarks = ApiResponse.extractList(envelope.data);

        setState(() {
          isBookmarked = bookmarks.any(
            (bookmark) => bookmark['university']['id'] == university.id,
          );
        });
      } catch (e) {
        AppLog.debug('Error parsing bookmark response: $e');
      }
    } else {
      AppLog.debug('Failed to load bookmarks');
    }
  }

  @override
  void initState() {
    super.initState();
    university = widget.university;
    _tabController = TabController(length: 4, vsync: this);

    AppLog.debug("Checking if user follows university");
    AppLog.debug("Checking if user follows university");
    AppLog.debug("Checking if user follows university");
    AppLog.debug('userIsFollowing pending');
    _checkIfBookmarked();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController!.dispose();
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> toggleBookmark() async {
    // Step 1: Optimistically toggle UI
    final previousState = isBookmarked;
    setState(() {
      isBookmarked = !isBookmarked;
      isLoadingBookmark = true;
    });

    try {
      // Step 2: Send request to backend
      final response = await AuthenticatedHttp.post(
        Uri.parse(BaseUrl.addFavouriteUniversity),
        body: jsonEncode({
          'user_id': 1, // replace with real user_id
          'university_id': university.id,
        }),
      );

      // Step 3: Parse response and update state based on backend
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        // Backend returns 'data' when added, no 'data' when removed
        final bool isNowBookmarked = responseData['data'] != null;
        setState(() {
          isBookmarked = isNowBookmarked; // Ensure state matches backend
        });
      } else {
        // Revert UI if backend fails
        setState(() {
          isBookmarked = previousState;
        });
        AppLog.debug('❌ Failed to toggle bookmark: ${response.statusCode}');
      }
    } catch (e) {
      // Revert UI if request errors out
      setState(() {
        isBookmarked = previousState;
      });
      AppLog.debug('❌ Error toggling bookmark: $e');
    } finally {
      setState(() {
        isLoadingBookmark = false;
      });
    }
  }

  double xOffset = 0;
  double yOffset = 0;
  double scaleFactor = 1;
  @override
  Widget build(BuildContext context) {
    AppLog.debug("🔍 DEBUG: University logo is: ${university.logo}");
    AppLog.debug("🔍 DEBUG: University logoUrl is: ${university.logoUrl}");
    AppLog.debug("🔍 DEBUG: University banner_image is: ${university.banner_image}");
    AppLog.debug("🔍 DEBUG: University name is: ${university.name}");
    AppLog.debug("🔍 DEBUG: University ID is: ${university.id}");
    AppLog.debug("🔍 DEBUG: University city is: ${university.city}");
    AppLog.debug("🔍 DEBUG: University country is: ${university.country}");

    final size = MediaQuery.sizeOf(context);
    final w = size.width;
    final h = size.height;

    final appBarLogoH = (h * 0.12).clamp(56.0, 120.0);
    final appBarLogoW = (w * 0.5).clamp(160.0, 240.0);
    final bannerH = (h * 0.18).clamp(120.0, 180.0);
    final uniLogoSize = (w * 0.23).clamp(72.0, 110.0);
    final smallIcon = (w * 0.03).clamp(10.0, 16.0);
    final waIcon = (w * 0.065).clamp(22.0, 30.0);

    // Debug image URLs
    final logoUrl = university.logo ?? university.logoUrl ?? '';
    final bannerUrl = university.banner_image ?? '';

    // Convert relative URLs to absolute URLs if needed
    final absoluteLogoUrl = logoUrl.startsWith('http')
        ? logoUrl
        : '${BaseUrl.baseUrlApi}$logoUrl';
    final absoluteBannerUrl = bannerUrl.startsWith('http')
        ? bannerUrl
        : '${BaseUrl.baseUrlApi}$bannerUrl';

    AppLog.debug("🔍 DEBUG: Final logo URL: $absoluteLogoUrl");
    AppLog.debug("🔍 DEBUG: Final banner URL: $absoluteBannerUrl");
    final labelTextStyle = Theme.of(
      context,
    ).textTheme.titleSmall!.copyWith(fontFamily: 'Roboto', fontSize: 8.0);

    return Scaffold(
      backgroundColor: White,
      appBar: AppBar(
        backgroundColor: White,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, color: Cprimary),
        ),
        title: SizedBox(
          height: appBarLogoH, // Set the width of the container
          width: appBarLogoW, // Set the height of the container
          child: Image.asset(
            edvoyagelogo1,
          ), // Replace with the actual image path
        ),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                // University Banner Image
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: bannerH,
                  decoration: BoxDecoration(
                    color: color3,
                    shape: BoxShape.rectangle,
                  ),
                  child:
                      university.banner_image != null &&
                          university.banner_image!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            absoluteBannerUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                decoration: BoxDecoration(
                                  color: color3,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                        : null,
                                    color: Cprimary,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              AppLog.debug(
                                "🔍 DEBUG: Error loading university banner: $error",
                              );
                              AppLog.debug(
                                "🔍 DEBUG: Banner URL that failed: $absoluteBannerUrl",
                              );
                              return Container(
                                decoration: BoxDecoration(
                                  color: color3,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.school,
                                    color: Cprimary,
                                    size: 48,
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: color3,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.school,
                              color: Cprimary,
                              size: 48,
                            ),
                          ),
                        ),
                ),
                // University Logo
                Align(
                  alignment: Alignment.bottomCenter,
                  heightFactor: 2.3,
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    width: uniLogoSize,
                    height: uniLogoSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: White,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child:
                          (university.logo != null &&
                                  university.logo!.isNotEmpty) ||
                              (university.logoUrl != null &&
                                  university.logoUrl!.isNotEmpty)
                          ? Image.network(
                              absoluteLogoUrl,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: Cprimary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          value:
                                              loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                              : null,
                                          color: White,
                                        ),
                                      ),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) {
                                AppLog.debug(
                                  "🔍 DEBUG: Error loading university logo: $error",
                                );
                                AppLog.debug(
                                  "🔍 DEBUG: Logo URL that failed: $absoluteLogoUrl",
                                );
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Cprimary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.school,
                                    color: White,
                                    size: 40,
                                  ),
                                );
                              },
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: Cprimary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.school, color: White, size: 40),
                            ),
                    ),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(university.name),
                    hGap(5),
                    GestureDetector(
                      onTap: () async {
                        final websiteUrl =
                            university.website?.isNotEmpty == true
                            ? university.website!
                            : 'https://www.google.com';
                        final uri = Uri.parse(websiteUrl);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Could not open website'),
                            ),
                          );
                        }
                      },
                      child: Image.asset(
                        "assets/external-link-alt.png",
                        width: smallIcon,
                        height: smallIcon,
                      ),
                    ),
                  ],
                ),
                vGap(5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on),
                    hGap(5),
                    Text(
                      '${university.state} , ${university.country}',
                    ),
                  ],
                ),
                vGap(5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    isLoadingBookmark
                        ? ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                Colors.grey,
                              ),
                              shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  side: BorderSide(color: grey2),
                                ),
                              ),
                            ),
                            onPressed: null, // Disable when loading
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      White,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Loading...',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    color: White,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : isBookmarked
                        ? ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                secondaryColor,
                              ),
                              shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  side: BorderSide(color: grey2),
                                ),
                              ),
                            ),
                            onPressed: toggleBookmark,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'UnFollow',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    color: White,
                                  ),
                                ),
                                SizedBox(width: 5),
                              ],
                            ),
                          )
                        : ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(Ctext2),
                              shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  side: BorderSide(color: grey2),
                                ),
                              ),
                            ),
                            onPressed: toggleBookmark,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Follow',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    color: fourthColor,
                                  ),
                                ),
                                SizedBox(width: 5),
                              ],
                            ),
                          ),
                    hGap(25),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Ctext2),
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            side: BorderSide(color: grey2),
                          ),
                        ),
                      ),
                      onPressed: () {
                        final phone = (university.phone != null && university.phone!.isNotEmpty) 
                            ? university.phone! 
                            : '+917012085349';
                        _openWhatsAppChat(phoneE164: phone);
                      },
                      child: SvgPicture.asset(
                        'assets/svg/WhatsApp.svg',
                        width: waIcon,
                        height: waIcon,
                        fit: BoxFit.contain,
                        semanticsLabel: 'WhatsApp',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            vGap(5),
            Container(
              color: White,
              child: TabBar(
                unselectedLabelColor: Colors.grey,
                labelColor: Cprimary,
                controller: _tabController,
                indicatorColor: Cprimary,
                labelStyle:
                    Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(fontSize: 15.0) ??
                    TextStyle(fontSize: 15.0),
                unselectedLabelStyle:
                    Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(fontSize: 14.0) ??
                    TextStyle(fontSize: 14.0),
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(child: Text('About')),
                  Tab(child: Text('Feed')),
                  Tab(child: Text('Course')),
                  Tab(child: Text('Gallery')),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  AboutTab(university: university),
                  FeedTab(universityId: university.id),
                  CoursesScreenTab(universityId: university.id),
                  GalleryTab(universityId: university.id),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openWhatsAppChat({required String phoneE164}) async {
    final normalizedPhone = phoneE164.replaceAll(RegExp(r'[^0-9]'), '');

    final businessUri = Uri.parse(
      'whatsapp-business://send?phone=$normalizedPhone',
    );
    final whatsappUri = Uri.parse('whatsapp://send?phone=$normalizedPhone');
    final webUri = Uri.parse('https://wa.me/$normalizedPhone');

    if (await canLaunchUrl(businessUri)) {
      await launchUrl(businessUri, mode: LaunchMode.externalApplication);
      return;
    }

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      return;
    }

    if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('WhatsApp is not available on this device.'),
      ),
    );
  }


}

Future<bool> _requestStoragePermission() async {
  var status = await Permission.storage.request();
  if (status.isGranted) {
    // Permission is granted
    return true;
  } else {
    // Permission is denied
    // Handle the denial
    return false;
  }
}
