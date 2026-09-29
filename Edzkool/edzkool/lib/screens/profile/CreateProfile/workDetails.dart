import 'package:edzkool/utils/authenticated_http.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:edzkool/utils/app_log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edzkool/_env/env.dart';
import 'package:edzkool/utils/Toasty.dart';
import 'package:edzkool/utils/colors/colors.dart';
import 'package:edzkool/utils/responsive.dart';
import 'package:edzkool/providers/user_email_provider.dart';

class WorkDetails extends ConsumerStatefulWidget {
  const WorkDetails({super.key});

  @override
  ConsumerState<WorkDetails> createState() => _WorkDetailsState();
}

class _WorkDetailsState extends ConsumerState<WorkDetails> {
  Measurements? size;
  TextEditingController positionController = TextEditingController();
  String? startYearDropdownValue;
  String? endYearDropdownValue;
  bool pursuingCheckbox = false;
  List<int> years = [
    1990,
    1991,
    1992,
    1993,
    1994,
    1995,
    1996,
    1997,
    1998,
    2000,
    2001,
    2002,
    2003,
    2004,
    2005,
    2006,
    2007,
    2009,
    2010,
    2011,
    2012,
    2013,
    2014,
    2016,
    2017,
    2018,
    2019,
    2020,
    2021,
    2022,
    2023,
    2024,
    2025,
    2026,
    2027
  ];

  @override
  Widget build(BuildContext context) {
    size = Measurements(MediaQuery.of(context).size);
    Future<void> postData() async {
      const url = BaseUrl.profileWork;

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
            'position': positionController.text,
            'start_year': startYearDropdownValue != null
                ? int.parse(startYearDropdownValue!)
                : null,
            'end_year': endYearDropdownValue != null
                ? int.parse(endYearDropdownValue!)
                : null,
            'pursuing': pursuingCheckbox,
          }),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          String message = 'Work details saved successfully!';
          try {
            final decoded = jsonDecode(response.body);
            if (decoded is Map && decoded['message'] is String) {
              message = decoded['message'];
            }
          } catch (_) {}
          AppLog.debug('Work data sent successfully!');
          Toasty.showSuccess(message);
          if (context.mounted) {
            Navigator.pop(context);
          }
        } else {
          String message = 'Failed to save work details (${response.statusCode})';
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
              'Failed to send work data. Status code: ${response.statusCode}');
          AppLog.debug('Response body: ${response.body}');
          Toasty.showError(message);
        }
      } catch (e) {
        AppLog.debug('Error sending work data: $e');
        Toasty.showError('Error sending work data: $e');
      }
    }

    final labelTextStyle = Theme.of(context).textTheme.titleSmall!.copyWith(
        fontSize: 16.0,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w700,
        color: titlecolor);

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
                    // print the controller values full

                    AppLog.debug(positionController.text);
                    AppLog.debug(startYearDropdownValue ?? '');
                    AppLog.debug(endYearDropdownValue ?? '');
                    AppLog.debug('$pursuingCheckbox');
                    postData();
                  },
                  child: Text(
                    'Save',
                    textScaler: TextScaler.linear(1.25),
                    style: TextStyle(
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
                  color: White,
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
        backgroundColor: whiteColor,
        title: Text(
          "Work Details",
          style: labelTextStyle,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 18.0, left: 8, right: 8),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              vGap(10),
              TextField(
                keyboardType: TextInputType.text,
                controller: positionController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Work Position ',
                  hintText: 'Work Position ',
                ),
              ),
              vGap(20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
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
                            value: startYearDropdownValue,
                            onChanged: (String? newValue) {
                              setState(() {
                                startYearDropdownValue = newValue!;
                              });
                            },
                            items: years
                                .map<DropdownMenuItem<String>>((int value) {
                              return DropdownMenuItem<String>(
                                value: value.toString(),
                                child: Text(
                                  value.toString(),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text('Pursuing'),
                        value: pursuingCheckbox,
                        onChanged: (value) {
                          setState(() {
                            pursuingCheckbox = value ?? false;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: White,
                        ),
                        child: Center(
                          child: DropdownButton<String>(
                            underline: SizedBox(),
                            hint: Text("--End Year--"),
                            value: endYearDropdownValue,
                            onChanged: (String? newValue) {
                              setState(() {
                                endYearDropdownValue = newValue!;
                              });
                            },
                            items: years
                                .map<DropdownMenuItem<String>>((int value) {
                              return DropdownMenuItem<String>(
                                value: value.toString(),
                                child: Text(value.toString()),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(),
                    ),
                  )
                ],
              ),
              SizedBox(height: size?.hp(20)),
            ],
          ),
        ),
      ),
    );
  }
}
