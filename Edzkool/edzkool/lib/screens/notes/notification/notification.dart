import 'package:flutter/material.dart';
import 'package:edzkool/utils/colors/colors.dart';
import 'package:edzkool/screens/notes/logo.dart';
import 'package:edzkool/screens/notes/topbar.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
                children: [_noNotificationView(), _noNotificationView()],
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
