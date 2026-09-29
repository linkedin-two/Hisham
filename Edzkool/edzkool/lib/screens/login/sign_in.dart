import 'package:edzkool/utils/authenticated_http.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../_env/env.dart';
import '../../utils/avatar.dart';
import '../../utils/colors/colors.dart';
import '../../utils/responsive.dart';
import 'package:validators/validators.dart';
import '../../utils/session_manager.dart';
import 'package:edzkool/providers/user_email_provider.dart';
import '../../widgets/long_button.dart';
import 'loginwithgoogle.dart';
import 'ordivider.dart';
import 'otp.dart';
import '../home_screen/homeScreen.dart';
import '../../teacher_cms/widgets/layout/mobile_app_shell.dart';
import '../../teacher_cms/state/app_state.dart';

class SignIn extends ConsumerStatefulWidget {
  const SignIn({super.key});

  @override
  ConsumerState<SignIn> createState() => _SignInState();
}

class _SignInState extends ConsumerState<SignIn> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final formKey = GlobalKey<FormState>();

  // Student controllers
  final TextEditingController studentEmailController = TextEditingController();
  final TextEditingController studentPasswordController = TextEditingController();

  // Teacher controllers
  final TextEditingController teacherUsernameController = TextEditingController();
  final TextEditingController teacherPasswordController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;
  int _selectedTabIndex = 0; // 0 = Student, 1 = Teacher

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedTabIndex = _tabController.index;
          errorMessage = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    studentEmailController.dispose();
    studentPasswordController.dispose();
    teacherUsernameController.dispose();
    teacherPasswordController.dispose();
    super.dispose();
  }

  Future<void> loginStudent() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    final email = studentEmailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        isLoading = false;
        errorMessage = 'Student Email address is required.';
      });
      return;
    }
    if (!isEmail(email)) {
      setState(() {
        isLoading = false;
        errorMessage = 'Please enter a valid email address.';
      });
      return;
    }

    try {
      await SessionManager.storeUserEmail(email);
      await SessionManager.storeUserRole('student');
      ref.read(userEmailProvider.notifier).state = email;
      
      // Send OTP via API
      try {
        await AuthenticatedHttp.post(
          Uri.parse(BaseUrl.sendOtp),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email}),
        );
      } catch (_) {}

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 24),
              SizedBox(width: 10),
              Text(
                'OTP sent successfully!',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
          backgroundColor: ColorConst.greenColor,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          elevation: 6,
          duration: const Duration(seconds: 2),
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Otp(mobile: email),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget _buildStudentUI(Measurements size) {
    return Column(
      key: const ValueKey('student_ui'),
      children: [
        SizedBox(
          width: size.wp(85),
          child: TextFormField(
            controller: studentEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              icon: Icon(Icons.email_outlined, color: primaryColor, size: size.hp(3)),
              labelText: 'Student Email Address',
              hintText: 'student@example.com',
              labelStyle: TextStyle(color: grey2, fontWeight: FontWeight.w400),
            ),
          ),
        ),
        SizedBox(height: size.hp(1)),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: size.wp(10)),
            child: Text(
              'Enter your registered email to receive a 6-digit OTP',
              style: TextStyle(
                color: grey2,
                fontSize: size.hp(1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> loginTeacher() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final username = teacherUsernameController.text.trim();
    final password = teacherPasswordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        isLoading = false;
        errorMessage = 'Username/Email and Password are required.';
      });
      return;
    }

    // Default credential check: teacher / teacher
    if (username.toLowerCase() == 'teacher' && password == 'teacher') {
      await SessionManager.storeUserEmail(username);
      await SessionManager.storeUserRole('teacher');
      await SessionManager.setLoginState(true);

      if (!mounted) return;
      final teacherAppState = AppState();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MobileAppShell(state: teacherAppState)),
      );
    } else {
      try {
        final response = await AuthenticatedHttp.post(
          Uri.parse('${BaseUrl.baseUrlApi}/api/v1/teacher/login/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'username': username, 'password': password}),
        );
        if (response.statusCode == 200) {
          await SessionManager.storeUserEmail(username);
          await SessionManager.storeUserRole('teacher');
          await SessionManager.setLoginState(true);
          if (!mounted) return;
          final teacherAppState = AppState();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MobileAppShell(state: teacherAppState)),
          );
          return;
        }
      } catch (_) {}

      setState(() {
        isLoading = false;
        errorMessage = 'Invalid teacher credentials. Default is teacher / teacher';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Measurements size = Measurements(MediaQuery.of(context).size);

    return Scaffold(
      backgroundColor: thirdColor,
      body: SafeArea(
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.wp(5)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size.hp(1.5)),
                  Center(
                    child: Image.asset(
                      signup,
                      height: size.hp(28),
                      width: size.wp(75),
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: size.hp(1.5)),

                  // Sliding Navigation Tab Bar
                  Container(
                    height: size.hp(6.5),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: grey2,
                        labelStyle: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: size.hp(2),
                          fontWeight: FontWeight.bold,
                        ),
                        unselectedLabelStyle: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: size.hp(1.9),
                          fontWeight: FontWeight.w500,
                        ),
                        tabs: const [
                          Tab(
                            iconMargin: EdgeInsets.zero,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.school, size: 20),
                                SizedBox(width: 8),
                                Text('Student'),
                              ],
                            ),
                          ),
                          Tab(
                            iconMargin: EdgeInsets.zero,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.person_pin_rounded, size: 20),
                                SizedBox(width: 8),
                                Text('Teacher'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: size.hp(2.5)),

                  // Header Title based on active tab
                  Text(
                    _selectedTabIndex == 0 ? 'Student Login' : 'Teacher Portal Login',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      color: primaryColor,
                      fontSize: size.hp(2.8),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: size.hp(0.8)),
                  Container(
                    height: size.hp(0.4),
                    width: size.wp(8),
                    decoration: BoxDecoration(
                      color: secondaryColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  SizedBox(height: size.hp(2.5)),

                  // Animated Tab Content (Student UI vs Teacher UI)
                  _selectedTabIndex == 0 ? _buildStudentUI(size) : _buildTeacherUI(size),

                  SizedBox(height: size.hp(2.5)),
                  if (errorMessage != null)
                    Padding(
                      padding: EdgeInsets.only(bottom: size.hp(2)),
                      child: Text(
                        errorMessage!,
                        style: TextStyle(color: Colors.red, fontSize: size.hp(1.8)),
                      ),
                    ),
                  if (isLoading) const Center(child: CircularProgressIndicator()),

                  SizedBox(height: size.hp(2)),
                  Center(
                    child: LongButton(
                      action: isLoading
                          ? () {}
                          : (_selectedTabIndex == 0 ? loginStudent : loginTeacher),
                      text: _selectedTabIndex == 0 ? 'Send OTP' : 'Login as Teacher',
                    ),
                  ),

                  if (_selectedTabIndex == 0) ...[
                    SizedBox(height: size.hp(2)),
                    const OrDivider(),
                    SizedBox(height: size.hp(2)),
                    const GoogleAuthButton(),
                  ],
                  SizedBox(height: size.hp(3)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }



  Widget _buildTeacherUI(Measurements size) {
    return Column(
      key: const ValueKey('teacher_ui'),
      children: [
        SizedBox(
          width: size.wp(85),
          child: TextFormField(
            controller: teacherUsernameController,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              icon: Icon(Icons.account_circle_outlined, color: primaryColor, size: size.hp(3)),
              labelText: 'Teacher Username or Email',
              labelStyle: TextStyle(color: grey2, fontWeight: FontWeight.w400),
            ),
          ),
        ),
        SizedBox(height: size.hp(1.5)),
        SizedBox(
          width: size.wp(85),
          child: TextFormField(
            controller: teacherPasswordController,
            obscureText: true,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              icon: Icon(Icons.lock_outline, color: primaryColor, size: size.hp(3)),
              labelText: 'Password',
              labelStyle: TextStyle(color: grey2, fontWeight: FontWeight.w400),
            ),
          ),
        ),
        SizedBox(height: size.hp(1)),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: size.wp(10)),
            child: Text(
              'Demo credentials: teacher / teacher',
              style: TextStyle(
                color: Colors.teal,
                fontSize: size.hp(1.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

void showCustomSnackbar(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: const Row(
        children: [
          Icon(Icons.check_circle, color: Colors.white, size: 24),
          SizedBox(width: 10),
          Text(
            'OTP sent successfully!',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
      backgroundColor: ColorConst.greenColor,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      elevation: 6,
      duration: const Duration(seconds: 3),
    ),
  );
  Future.delayed(const Duration(seconds: 3), () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const Otp(mobile: ""),
      ),
    );
  });
}
