import 'package:flutter/material.dart';
import 'package:edzkool/utils/app_log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edzkool/_env/env.dart';
import 'package:edzkool/utils/Toasty.dart';
import 'package:edzkool/utils/colors/colors.dart';
import 'package:edzkool/utils/responsive.dart';
import 'package:edzkool/utils/authenticated_http.dart';
import 'package:edzkool/providers/user_email_provider.dart';
import 'dart:convert'; // Added for jsonEncode

class SocialLink extends ConsumerStatefulWidget {
  const SocialLink({super.key});

  @override
  ConsumerState<SocialLink> createState() => _SocialLinkState();
}

class _SocialLinkState extends ConsumerState<SocialLink> {
  Measurements? size;

  TextEditingController facebookController = TextEditingController();
  TextEditingController linkedInController = TextEditingController();

  Future<void> sendSocialLinks() async {
    final url = BaseUrl.profileSocial;

    try {
      final email = ref.read(userEmailProvider);
      if (email == null || email.isEmpty) {
        Toasty.showtoast('Email not found. Please login again.');
        return;
      }
      final response = await AuthenticatedHttp.post(
        Uri.parse(url),
        headers: {'X-User-Email': email},
        body: jsonEncode({
          'email': email,
          'facebook_link': facebookController.text,
          'linkedin_link': linkedInController.text,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        String message = 'Social links saved successfully!';
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map && decoded['message'] is String) {
            message = decoded['message'];
          }
        } catch (_) {}
        AppLog.debug('Social links sent successfully!');
        Toasty.showSuccess(message);
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        String message = 'Failed to save social links (${response.statusCode})';
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map) {
            if (decoded['message'] is String) {
              message = decoded['message'];
            }
            final errors = decoded['errors'];
            if (errors is Map && errors.isNotEmpty) {
              final firstKey = errors.keys.first;
              final val = errors[firstKey];
              if (val is List && val.isNotEmpty) {
                message = '${firstKey.toString()}: ${val.first}';
              } else if (val is String) {
                message = '${firstKey.toString()}: $val';
              }
            }
          }
        } catch (_) {}
        AppLog.debug(
            'Failed to send social links. Status code: ${response.statusCode}');
        AppLog.debug('Response body: ${response.body}');
        Toasty.showError(message);
      }
    } catch (e) {
      AppLog.debug('Error sending social links: $e');
      Toasty.showError('Error sending social links: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    size = Measurements(MediaQuery.of(context).size);

    final labelTextStyle = Theme.of(context).textTheme.titleSmall!.copyWith(
          fontSize: 16.0,
          fontWeight: FontWeight.w700,
          fontFamily: 'Roboto',
          // Assuming titlecolor is defined somewhere
          color: titlecolor,
        );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        height: size?.hp(15),
        margin: const EdgeInsets.all(10),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Column(
            children: [
              Container(
                width: size?.wp(87),
                height: size?.hp(5),
                decoration: BoxDecoration(
                  color: secondaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextButton(
                  onPressed: () {
                    sendSocialLinks(); // Call the function to send data
                  },
                  child: Text(
                    'Save',
                    textScaler: TextScaler.linear(1.25),
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      color: thirdColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              vGap(20),
              Container(
                width: size?.wp(87),
                height: size?.hp(5),
                decoration: BoxDecoration(
                  color: Colors.white, // Use Colors.white instead of White
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancel',
                    textScaler: TextScaler.linear(1.25),
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: cblack10,
      appBar: AppBar(
        elevation: 1,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white, // Use Colors.white instead of whiteColor
        title: Text(
          "Social Links",
          style: labelTextStyle,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 18.0, left: 8, right: 8),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Facebook",
                style: labelTextStyle,
              ),
              vGap(10),
              TextField(
                controller: facebookController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter Your Link',
                  hintText: 'Enter your link',
                ),
              ),
              vGap(20),
              Text(
                "LinkedIn",
                style: labelTextStyle,
              ),
              vGap(10),
              TextField(
                controller: linkedInController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter Your Link',
                  hintText: 'Enter your link',
                ),
              ),
              SizedBox(height: size?.hp(20)),
            ],
          ),
        ),
      ),
    );
  }
}
