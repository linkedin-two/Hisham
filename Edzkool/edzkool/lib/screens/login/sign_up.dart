import 'package:edzkool/utils/authenticated_http.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../_env/env.dart';
import '../../utils/avatar.dart';
import '../../utils/colors/colors.dart';
import '../../utils/responsive.dart';
import '../../utils/Toasty.dart';
import '../../widgets/long_button.dart';
import 'otp.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController _email = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;

  void setLoading(bool loading) {
    if (mounted) {
      setState(() {
        isLoading = loading;
      });
    }
  }

  @override
  void initState() {
    super.initState();
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
                  SizedBox(height: size.hp(2)),
                  Center(
                    child: Image.asset(
                      signup,
                      height: size.hp(35),
                      width: size.wp(75),
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: size.hp(2)),
                  Text(
                    'Sign up',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      color: primaryColor,
                      fontSize: size.hp(3),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: size.hp(1)),
                  Container(
                    height: size.hp(0.4),
                    width: size.wp(6),
                    decoration: BoxDecoration(
                      color: Colors.teal,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  SizedBox(height: size.hp(3)),
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: _email,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter Email Address';
                      }
                      // Basic email validation
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      icon: Icon(
                        Icons.email,
                        color: primaryColor,
                        size: size.hp(3),
                      ),
                      labelText: 'Email Address',
                      labelStyle: TextStyle(
                        color: grey2,
                        fontWeight: FontWeight.w400,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: primaryColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                    ),
                  ),
                  SizedBox(height: size.hp(1)),
                  // Remember Me checkbox
                  SizedBox(height: size.hp(1)),
                  // Container(
                  //   height: size.hp(2),
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       Wrap(
                  //         children: [
                  //           TextButton(
                  //             onPressed: () {},
                  //             child: Text('By signing up, you agree to our ',
                  //                 style: TextStyle(
                  //                   color: grey2,
                  //                   fontSize: size.hp(1.7),
                  //                 )),
                  //           ),
                  //           TextButton(
                  //             onPressed: () => Get.to(() => terms_condition()),
                  //             child: Text('Terms & Conditions',
                  //                 style: TextStyle(
                  //                     color: primaryColor,
                  //                     fontSize: size.hp(1.7))),
                  //           ),
                  //         ],
                  //       ),
                  //       Wrap(
                  //         children: [
                  //           TextButton(
                  //             onPressed: () {},
                  //             child: Text('and ',
                  //                 style: TextStyle(
                  //                     color: grey2, fontSize: size.hp(1.7))),
                  //           ),
                  //           TextButton(
                  //             onPressed: () => Get.to(() => privacy()),
                  //             child: Text('Privacy Policy',
                  //                 style: TextStyle(
                  //                     color: primaryColor,
                  //                     fontSize: size.hp(1.7))),
                  //           ),
                  //         ],
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  Text(
                    "By Signing Up you agree to our terms and Conditions and Privacy Policy",
                    style: TextStyle(fontSize: size.hp(2.2)),
                  ),
                  SizedBox(height: size.hp(6)),
                  Center(
                    child: LongButton(
                      action: isLoading
                          ? () {}
                          : () => sendOtp(context, _email.text.trim()),
                      text: isLoading ? 'Sending OTP...' : 'Send OTP to Email',
                    ),
                  ),
                  SizedBox(height: size.hp(2)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> sendOtp(BuildContext context, String email) async {
  if (email.isEmpty) {
    Toasty.showtoast('Please enter your email address');
    return;
  }

  // Validate email format
  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
    Toasty.showtoast('Please enter a valid email address');
    return;
  }

  // Show loading state
  if (context.mounted) {
    final state = context.findAncestorStateOfType<_SignUpState>();
    state?.setLoading(true);
  }

  try {
    final response = await AuthenticatedHttp.post(
      Uri.parse('${BaseUrl.baseUrl}/users/otp/create/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'otp_type': 'email',
        'contact': email,
        'device_id': '1',
        'device_type': 'mobile',
      }),
    );

    if (context.mounted) {
      final state = context.findAncestorStateOfType<_SignUpState>();
      state?.setLoading(false);
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);

      if (data['success']) {
        Toasty.showtoast('OTP sent successfully to your email');

        // Navigate to OTP screen
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Otp(mobile: email)),
          );
        }
      } else {
        Toasty.showtoast(data['message'] ?? 'Failed to send OTP');
      }
    } else if (response.statusCode == 429) {
      // Device blocked
      final data = jsonDecode(response.body);
      Toasty.showtoast(data['message'] ?? 'Device blocked for 5 minutes');
    } else {
      Toasty.showtoast('Failed to send OTP');
    }
  } catch (e, stackTrace) {
    if (context.mounted) {
      final state = context.findAncestorStateOfType<_SignUpState>();
      state?.setLoading(false);
    }

    Toasty.showtoast("${e.toString()}\n$stackTrace");
  }
}
