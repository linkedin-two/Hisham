import 'package:edzkool/utils/authenticated_http.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';
import '../../_env/env.dart';
import '../../utils/Toasty.dart';
import '../../utils/avatar.dart';
import '../../utils/colors/colors.dart';
import '../../utils/responsive.dart';
import 'package:edzkool/providers/user_email_provider.dart';
import '../../widgets/back_arrow_button.dart';
import '../../widgets/long_button.dart';
import '../home_screen/homeScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:edzkool/utils/session_manager.dart';
import '../../utils/app_log.dart';

class Otp extends ConsumerStatefulWidget {
  final String mobile;
  const Otp({super.key, required this.mobile});

  @override
  ConsumerState<Otp> createState() => _OtpState();
}

class _OtpState extends ConsumerState<Otp> {
  OtpFieldController otpController = OtpFieldController();
  String otps = "";
  int attempts = 0;
  bool isBlocked = false;
  DateTime? blockedUntil;
  Timer? blockTimer;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    blockTimer?.cancel();
    super.dispose();
  }

  void showBlockedMessage() {
    if (blockedUntil != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StreamBuilder(
            stream: Stream.periodic(const Duration(seconds: 1)),
            builder: (context, snapshot) {
              Duration remaining = blockedUntil != null ? blockedUntil!.difference(DateTime.now()) : Duration.zero;
              if (remaining.isNegative) remaining = Duration.zero;
              
              String message = 'You have been blocked for 5 minutes due to multiple failed attempts.\n\nRemaining time: ${remaining.inMinutes}:${(remaining.inSeconds % 60).toString().padLeft(2, '0')}';

              return AlertDialog(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                title: Row(
                  children: [
                    Icon(Icons.block, color: Colors.white, size: 24),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Account Temporarily Blocked',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer,
                      color: Colors.white,
                      size: 48,
                    ),
                    SizedBox(height: 16),
                    Text(
                      message,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                actions: [
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'OK',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    }
  }

  Future<void> verifyOtp() async {
    if (isBlocked) {
      showBlockedMessage();
      return;
    }

    if (otps.length != 6) {
      Toasty.showtoast('Please enter 6-digit OTP');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      String deviceId = '1';


      // if (otps == '000000') {
      //   print('🔍 DEBUG: Using backup OTP code for testing');
      //   print('🔍 DEBUG: Mobile number: ${widget.mobile}');

      //   // Check if user exists first
      //   await _checkAndCreateUser(widget.mobile, '000000');
      //   return;
      // }

      final response = await AuthenticatedHttp.post(
        Uri.parse('${BaseUrl.baseUrl}/users/otp/verify/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'otp_code': otps,
          'contact': widget.mobile,
          'device_id': deviceId,
          'device_type': 'mobile',
        }),
      );

      final data = jsonDecode(response.body);
      AppLog.debug('OTP verification response: ${response.statusCode}');

      if (response.statusCode == 200 && data['success']) {
        if (data['data'] != null && data['data']['access'] != null) {
          await SessionManager.storeToken(data['data']['access']);
          final refresh = data['data']['refresh'];
          if (refresh is String && refresh.isNotEmpty) {
            await SessionManager.storeRefreshToken(refresh);
          }
        }

        ref.read(userEmailProvider.notifier).state = widget.mobile;
        await SessionManager.setLoginState(true);
        await SessionManager.storeUserEmail(widget.mobile);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        }
        Toasty.showtoast('OTP verified successfully!');
      } else {
        // Wrong OTP
        attempts++;
        if (attempts >= 3) {
          await handleMaxAttempts();
        } else {
          Toasty.showtoast(data['message'] ?? 'Invalid OTP');
        }
      }
    } catch (e) {
      AppLog.error('OTP verification error', e);
      Toasty.showtoast('Network error. Please try again.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Store user session and navigate to home

  Future<void> handleMaxAttempts() async {
    DateTime blockUntil = DateTime.now().add(Duration(minutes: 5));
    Future<void> storeBlockTime(DateTime blockUntil) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('blockUntil', blockUntil.toIso8601String());
    }

    Future<DateTime?> getBlockTime() async {
      final prefs = await SharedPreferences.getInstance();
      final blockUntilString = prefs.getString('blockUntil');
      if (blockUntilString != null) {
        return DateTime.parse(blockUntilString);
      }
      return null;
    }

    Future<void> clearBlockTime() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('blockUntil');
    }

    storeBlockTime(blockUntil);

    setState(() {
      isBlocked = true;
      blockedUntil = blockUntil;
    });
    Future<void> startBlockTimer() async {
      DateTime? blockUntil = await getBlockTime();
      if (blockUntil != null) {
        Duration remaining = blockUntil.difference(DateTime.now());
        if (remaining.isNegative) {
          await clearBlockTime();
          setState(() {
            isBlocked = false;
            blockedUntil = null;
          });
        } else {
          blockTimer?.cancel();
          blockTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
            Duration currentRemaining = blockUntil.difference(DateTime.now());
            if (currentRemaining.isNegative) {
              timer.cancel();
              await clearBlockTime();
              setState(() {
                isBlocked = false;
                blockedUntil = null;
              });
            } else {
              setState(() {});
            }
          });
        }
      }
    }

    startBlockTimer();
    showBlockedMessage();
  }

  @override
  Widget build(BuildContext context) {
    Measurements size = Measurements(MediaQuery.of(context).size);
    return Scaffold(
      backgroundColor: thirdColor,
      body: SingleChildScrollView(
        child: Container(
          color: thirdColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: size.hp(5)),
              const Row(
                children: [
                  BackArrow(),
                ],
              ),
              SizedBox(
                height: size.hp(30),
                width: size.wp(60),
                child: Image.asset(
                  otp,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: size.hp(1)),
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Enter OTP',
                    textScaler: TextScaler.linear(2.2),
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.hp(3)),
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "A 6 digit code has been sent to\nyour email address:\n${widget.mobile}",
                        textAlign: TextAlign.left,
                        textScaler: const TextScaler.linear(1.4),
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          color: Color.fromARGB(255, 67, 56, 56),
                          fontWeight: FontWeight.w800,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: size.hp(3)),

              // Blocked status indicator
              if (isBlocked && blockedUntil != null) ...[
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 30),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.block, color: Colors.red, size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Account Temporarily Blocked',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Remaining time: ${blockedUntil!.difference(DateTime.now()).inMinutes}:${(blockedUntil!.difference(DateTime.now()).inSeconds % 60).toString().padLeft(2, '0')}',
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.hp(2)),
              ],

              // OTP Input Field
              if (!isBlocked) ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.wp(5)),
                  child: OTPTextField(
                    controller: otpController,
                    length: 6,
                    width: size.wp(90),
                    textFieldAlignment: MainAxisAlignment.spaceEvenly,
                    fieldWidth: size.wp(12),
                    fieldStyle: FieldStyle.box,
                    outlineBorderRadius: 10,
                    style: TextStyle(fontSize: size.wp(5)),
                    onChanged: (value) {
                      otps = value;
                    },
                  ),
                ),
                SizedBox(height: size.hp(2)),

                // Backup OTP indicator for testing
                // Container(
                //   margin: EdgeInsets.symmetric(horizontal: 30),
                //   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                //   decoration: BoxDecoration(
                //     color: Colors.blue.withValues(alpha: 0.1),
                //     borderRadius: BorderRadius.circular(8),
                //     border:
                //         Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                //   ),
                //   child: Row(
                //     children: [
                //       Icon(Icons.info_outline, color: Colors.blue, size: 16),
                //       SizedBox(width: 8),
                //       Expanded(
                //         child: Text(
                //           'For testing: Use backup code "000000"',
                //           style: TextStyle(
                //             color: Colors.blue.shade700,
                //             fontSize: 12,
                //             fontWeight: FontWeight.w500,
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                // SizedBox(height: size.hp(2)),

                // Attempts remaining indicator
                if (attempts > 0) ...[
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 30),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      '${3 - attempts} attempts remaining',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: size.hp(2)),
                ],

                // Verify Button
                LongButton(
                  action: isLoading ? () {} : () => verifyOtp(),
                  text: isLoading ? 'Verifying...' : 'Verify',
                ),
              ],

              SizedBox(height: size.hp(2)),
            ],
          ),
        ),
      ),
    );
  }
}
