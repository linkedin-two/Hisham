import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../utils/colors/colors.dart';
import '../../_env/env.dart';
import '../notes/logo.dart';
import '../notes/topbar.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late Future<List<AppNotification>> _offersFuture;
  late Future<List<AppNotification>> _allFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _offersFuture = _fetchNotifications(
      '${BaseUrl.baseUrl}/notifications/notifications/offers/',
    );
    _allFuture = _fetchNotifications(
      '${BaseUrl.baseUrl}/notifications/notifications/',
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Poppins'),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomLogoAppBar(),
        body: Column(
          children: [
            Topbar(firstText: 'Notifications', secondText: ''),
            SizedBox(height: h * 0.01),
            _animatedTabBar(),
            SizedBox(height: h * 0.012),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _notificationsView(_offersFuture),
                  _notificationsView(_allFuture),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _animatedTabBar() {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final height = h * 0.06;
    final marginH = w * 0.06;
    final labelSize = w * 0.04;

    return Container(
      height: height,
      margin: EdgeInsets.symmetric(horizontal: marginH),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Cprimary,
          borderRadius: BorderRadius.circular(30),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.black87,
        labelStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: labelSize,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: labelSize,
        ),
        tabs: [
          const Tab(text: "Offers"),
          const Tab(text: "All"),
        ],
      ),
    );
  }

  Future<List<AppNotification>> _fetchNotifications(String url) async {
    final resp = await http.get(Uri.parse(url));
    if (resp.statusCode != 200) {
      throw Exception('Failed to load notifications (${resp.statusCode})');
    }

    final decoded = jsonDecode(resp.body);
    final results =
        (decoded is Map<String, dynamic> && decoded['results'] is List)
            ? decoded['results'] as List
            : <dynamic>[];

    return results
        .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Widget _notificationsView(Future<List<AppNotification>> future) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final listPaddingH = w * 0.04;
    final listPaddingV = h * 0.012;
    final cardMarginV = h * 0.012;
    final paddingH = w * 0.045;
    final paddingV = h * 0.018;
    final titleSize = w * 0.055;
    final subtitleSize = w * 0.045;
    final bodySize = w * 0.04;
    final dateSize = w * 0.035;
    final accentHeight = w * 0.04;

    return FutureBuilder<List<AppNotification>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: Cprimary),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(w * 0.06),
              child: Text(
                'Error loading notifications\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: bodySize,
                  color: Colors.red,
                ),
              ),
            ),
          );
        }

        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return _noNotificationView();
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(
            horizontal: listPaddingH,
            vertical: listPaddingV,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final n = items[index];
            return Padding(
              padding: EdgeInsets.only(bottom: cardMarginV),
              child: Card(
                elevation: 2,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: paddingH,
                        vertical: paddingV,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  n.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: titleSize,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              SizedBox(width: w * 0.02),
                              Text(
                                n.createdAtText,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: dateSize,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          if (n.subtitle.isNotEmpty) ...[
                            SizedBox(height: h * 0.006),
                            Text(
                              n.subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: subtitleSize,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                          if (n.description.isNotEmpty) ...[
                            SizedBox(height: h * 0.008),
                            Text(
                              n.description,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: bodySize,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
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
              ),
            );
          },
        );
      },
    );
  }

  Widget _noNotificationView() {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final imageHeight = h * 0.25;
    final titleSize = w * 0.055;
    final bodySize = w * 0.045;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(w * 0.06),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/no_notifications.png',
              height: imageHeight,
              fit: BoxFit.contain,
            ),
            SizedBox(height: h * 0.02),
            Text(
              "You're all caught up!",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: titleSize,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: h * 0.01),
            Text(
              "No new notifications at the moment.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: bodySize,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppNotification {
  final String title;
  final String subtitle;
  final String description;
  final bool isOffer;
  final DateTime? createdAt;

  AppNotification({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.isOffer,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final createdAtStr = json['created_at']?.toString() ?? '';
    DateTime? created;
    if (createdAtStr.isNotEmpty) {
      created = DateTime.tryParse(createdAtStr);
    }

    return AppNotification(
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      isOffer: json['is_offer'] == true,
      createdAt: created,
    );
  }

  String get createdAtText {
    if (createdAt == null) return '';
    final d = createdAt!.toLocal();
    final day = d.day;
    final suffix = _daySuffix(day);
    final monthName = DateFormat('MMMM').format(d);
    return '$day$suffix $monthName of ${d.year}';
  }

  String _daySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }
}
