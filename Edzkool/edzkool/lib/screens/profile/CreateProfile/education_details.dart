import 'package:flutter/material.dart';
import 'package:edzkool/utils/app_log.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edzkool/_env/env.dart';
import 'package:edzkool/utils/Toasty.dart';
import 'package:edzkool/utils/colors/colors.dart';
import 'package:edzkool/utils/responsive.dart';
import 'package:edzkool/utils/authenticated_http.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:edzkool/providers/user_email_provider.dart';

class EducationDetails extends ConsumerStatefulWidget {
  const EducationDetails({super.key});

  @override
  ConsumerState<EducationDetails> createState() => _EducationDetailsState();
}

class _EducationDetailsState extends ConsumerState<EducationDetails> {
  Measurements? size;
  String? dropdownValueStartYearHigher;
  String? dropdownValueEndYearHigher;
  TextEditingController gradeControllerHigher = TextEditingController();

  String? dropdownValueStartYearSecondary;
  String? dropdownValueEndYearSecondary;
  TextEditingController gradeControllerSecondary = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final bool _checkbox = false;
  List<String> years = List.generate(
      66, (index) => (1960 + index).toString()); // 1960 to 2025 as strings

  Future<void> sendDataToBackend() async {
    final url = BaseUrl.profileEducation;
    AppLog.debug('Attempting to connect to: $url');

    try {
      final email = ref.read(userEmailProvider);
      if (email == null || email.isEmpty) {
        Toasty.showtoast('Email not found. Please login again.');
        return;
      }
      // Validate required fields for Higher Education
      if (dropdownValueStartYearHigher == null ||
          dropdownValueStartYearHigher!.isEmpty) {
        Toasty.showtoast('Please select a start year for higher education');
        return;
      }

      if (dropdownValueEndYearHigher == null ||
          dropdownValueEndYearHigher!.isEmpty) {
        Toasty.showtoast('Please select an end year for higher education');
        return;
      }

      // Validate required fields for Secondary Education
      if (dropdownValueStartYearSecondary == null ||
          dropdownValueStartYearSecondary!.isEmpty) {
        Toasty.showtoast('Please select a start year for secondary education');
        return;
      }

      if (dropdownValueEndYearSecondary == null ||
          dropdownValueEndYearSecondary!.isEmpty) {
        Toasty.showtoast('Please select an end year for secondary education');
        return;
      }

      // Validate percentage format for Higher Education
      double? higherPercentageValue;
      if (gradeControllerHigher.text.isNotEmpty) {
        try {
          higherPercentageValue = double.parse(gradeControllerHigher.text);
          if (higherPercentageValue < 1 || higherPercentageValue > 100) {
            Toasty.showtoast(
                'Higher Education percentage must be between 1% and 100%');
            return;
          }
        } catch (e) {
          Toasty.showtoast(
              'Please enter a valid percentage for Higher Education (e.g., 85)');
          return;
        }
      }

      // Validate percentage format for Secondary Education
      double? secondaryPercentageValue;
      if (gradeControllerSecondary.text.isNotEmpty) {
        try {
          secondaryPercentageValue =
              double.parse(gradeControllerSecondary.text);
          if (secondaryPercentageValue < 1 || secondaryPercentageValue > 100) {
            Toasty.showtoast(
                'Secondary Education percentage must be between 1% and 100%');
            return;
          }
        } catch (e) {
          Toasty.showtoast(
              'Please enter a valid percentage for Secondary Education (e.g., 85)');
          return;
        }
      }

      // Prepare data for simple education API
      final educationData = {
        'email': email,
        'higher_start_year': int.parse(dropdownValueStartYearHigher!),
        'higher_end_year': int.parse(dropdownValueEndYearHigher!),
        'higher_percentage': higherPercentageValue,
        'lower_start_year': int.parse(dropdownValueStartYearSecondary!),
        'lower_end_year': int.parse(dropdownValueEndYearSecondary!),
        'lower_percentage': secondaryPercentageValue,
      };

      AppLog.debug('Education Request body: $educationData');

      final response = await AuthenticatedHttp.post(
        Uri.parse(url),
        body: jsonEncode(educationData),
      ).timeout(const Duration(seconds: 10));

      AppLog.debug('Response status: ${response.statusCode}');
      AppLog.debug('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        String message = 'Education saved successfully!';
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map && decoded['message'] is String) {
            message = decoded['message'];
          }
        } catch (_) {}
        AppLog.debug('Education data saved successfully!');
        Toasty.showSuccess(message);
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        String message =
            'Failed to save education data (${response.statusCode})';
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
        AppLog.debug('Failed to send data. Status: ${response.statusCode}');
        Toasty.showError(message);
      }
    } on SocketException catch (e) {
      AppLog.debug('Network error: $e');
      Toasty.showError(
          'Network error: Check your internet connection and server IP');
    } on TimeoutException catch (e) {
      AppLog.debug('Timeout error: $e');
      Toasty.showError('Request timeout: Server not responding');
    } catch (error) {
      AppLog.debug('Error sending data: $error');
      Toasty.showError('Error sending data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    size = Measurements(MediaQuery.of(context).size);

    final labelTextStyle = Theme.of(context).textTheme.titleSmall!.copyWith(
          fontSize: 16.0,
          fontWeight: FontWeight.w700,
          fontFamily: 'Roboto',
          color: titlecolor,
        );

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
        backgroundColor: whiteColor,
        title: Text(
          "Educational Details",
          style: labelTextStyle,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 18.0, left: 8, right: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              vGap(10),
              Text(
                "Higher Education",
                style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                    color: secondaryColor),
              ),
              vGap(10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    border: Border.all(color: Colors.black),
                    color: White,
                  ),
                  child: Center(
                    child: DropdownButton<String>(
                      underline: SizedBox(),
                      hint: Text("--Start Year--"),
                      value: dropdownValueStartYearHigher,
                      onChanged: (String? newValue) {
                        setState(() {
                          dropdownValueStartYearHigher = newValue!;
                        });
                      },
                      items:
                          years.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              vGap(20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    border: Border.all(color: Colors.black),
                    color: White,
                  ),
                  child: Center(
                    child: DropdownButton<String>(
                      underline: SizedBox(),
                      hint: Text("--End Year--"),
                      value: dropdownValueEndYearHigher,
                      onChanged: (String? newValue) {
                        setState(() {
                          dropdownValueEndYearHigher = newValue!;
                        });
                      },
                      items:
                          years.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: White,
                        ),
                        child: TextField(
                          controller: gradeControllerHigher,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^[0-9]{1,3}(\.\d{0,2})?$')),
                          ],
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Enter Grade(%)',
                            hintText: 'Enter Grade(%)',
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("(Visible only to user)")),
                  )
                ],
              ),
              Divider(
                thickness: 1,
              ),
              vGap(10),
              Text(
                "Secondary Education",
                style: TextStyle(
                    fontSize: 16.0,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                    color: secondaryColor),
              ),
              vGap(10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    border: Border.all(color: Colors.black),
                    color: White,
                  ),
                  child: Center(
                    child: DropdownButton<String>(
                      underline: SizedBox(),
                      hint: Text("--Start Year--"),
                      value: dropdownValueStartYearSecondary,
                      onChanged: (String? newValue) {
                        setState(() {
                          dropdownValueStartYearSecondary = newValue!;
                        });
                      },
                      items:
                          years.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              vGap(20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    border: Border.all(color: Colors.black),
                    color: White,
                  ),
                  child: Center(
                    child: DropdownButton<String>(
                      underline: SizedBox(),
                      hint: Text("--End Year--"),
                      value: dropdownValueEndYearSecondary,
                      onChanged: (String? newValue) {
                        setState(() {
                          dropdownValueEndYearSecondary = newValue!;
                        });
                      },
                      items:
                          years.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: White,
                        ),
                        child: TextField(
                          controller: gradeControllerSecondary,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^[0-9]{1,3}(\.\d{0,2})?$')),
                          ],
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Enter Grade(%)',
                            hintText: 'Enter Grade(%)',
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("(Visible only to user)")),
                  )
                ],
              ),
              SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    children: [
                      vGap(20),
                      Container(
                        width: size?.wp(87),
                        height: size?.hp(5),
                        decoration: BoxDecoration(
                            color: secondaryColor,
                            borderRadius: BorderRadius.circular(10)),
                        child: TextButton(
                          onPressed: () {
                            // Access the values using the controllers
                            AppLog.debug(
                                'Higher Education Start Year: $dropdownValueStartYearHigher');
                            AppLog.debug(
                                'Higher Education End Year: $dropdownValueEndYearHigher');
                            AppLog.debug(
                                'Higher Education Grade: ${gradeControllerHigher.text}');

                            AppLog.debug(
                                'Secondary Education Start Year: $dropdownValueStartYearSecondary');
                            AppLog.debug(
                                'Secondary Education End Year: $dropdownValueEndYearSecondary');
                            AppLog.debug(
                                'Secondary Education Grade: ${gradeControllerSecondary.text}');
                            sendDataToBackend();
                          },
                          child: Text(
                            'Submit',
                            textScaler: TextScaler.linear(1.25),
                            style: TextStyle(
                              color: thirdColor,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
