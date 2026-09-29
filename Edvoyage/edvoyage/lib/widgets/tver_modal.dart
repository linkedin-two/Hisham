import 'package:flutter/material.dart';
import 'package:edvoyage/_env/env.dart';
import 'package:edvoyage/utils/colors/colors.dart';
import 'package:edvoyage/utils/responsive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:edvoyage/utils/session_manager.dart';

class DropDownDemo extends StatefulWidget {
  final int universityId;
  final String universityName;

  const DropDownDemo(
      {super.key, required this.universityId, required this.universityName});

  @override
  _DropDownDemoState createState() => _DropDownDemoState();
}

class _DropDownDemoState extends State<DropDownDemo> {
  String dropdownValue = 'January';
  String yearValue = '2024';
  String email = '';
  String selectedProgram = '';
  String selectedSemester = 'Fall';
  DateTime? selectedStartDate;
  List<Map<String, dynamic>> programs = [];
  bool isLoading = false;
  bool isLoadingPrograms = false;
  Measurements? size;

  // Form validation
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set default email for testing
    email = 'test@example.com';
    _emailController.text = 'test@example.com';

    // Add dummy programs for testing (only if API fails)
    programs = [
      {'id': 1, 'name': 'Computer Science'},
      {'id': 2, 'name': 'Business Administration'},
      {'id': 3, 'name': 'Engineering'},
      {'id': 4, 'name': 'Medicine'},
      {'id': 5, 'name': 'Arts and Humanities'},
      {'id': 6, 'name': 'Law'},
      {'id': 7, 'name': 'Psychology'},
      {'id': 8, 'name': 'Economics'},
    ];

    // Set default program
    selectedProgram = 'Computer Science';

    // Set default start date
    selectedStartDate = DateTime.now().add(Duration(days: 30));

    fetchPrograms();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> fetchPrograms() async {
    setState(() {
      isLoadingPrograms = true;
    });

    try {
      print(
          "🔍 DEBUG: Fetching programs for university ID: ${widget.universityId}");
      final response = await http.get(
        Uri.parse('${BaseUrl.universityList}${widget.universityId}/'),
        headers: {'Content-Type': 'application/json'},
      );

      print("🔍 DEBUG: Programs API response status: ${response.statusCode}");
      print("🔍 DEBUG: Programs API response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null && data['data']['programs'] != null) {
          final apiPrograms =
              List<Map<String, dynamic>>.from(data['data']['programs']);
          print("🔍 DEBUG: Found ${apiPrograms.length} programs from API");

          // Only update programs if API returned data
          if (apiPrograms.isNotEmpty) {
            setState(() {
              programs = apiPrograms;
              // Reset selected program to first available program
              selectedProgram = apiPrograms.first['name'] ?? 'Computer Science';
            });
            print(
                "🔍 DEBUG: Updated programs from API, selected: $selectedProgram");
          } else {
            print(
                "🔍 DEBUG: API returned empty programs, keeping dummy programs");
          }
        } else {
          print(
              "🔍 DEBUG: No programs found in response, keeping dummy programs");
        }
      } else {
        print(
            "🔍 DEBUG: Failed to fetch programs: ${response.statusCode}, keeping dummy programs");
      }
    } catch (e) {
      print("🔍 DEBUG: Error fetching programs: $e, keeping dummy programs");
    } finally {
      setState(() {
        isLoadingPrograms = false;
      });
    }
  }

  Future<void> submitApplication() async {
    print("🔍 DEBUG: Submit button pressed!");
    print("🔍 DEBUG: Form validation starting...");

    if (!_formKey.currentState!.validate()) {
      print("🔍 DEBUG: Form validation failed!");
      return;
    }
    print("🔍 DEBUG: Form validation passed!");

    if (selectedProgram.isEmpty) {
      print("🔍 DEBUG: No program selected!");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a program')),
      );
      return;
    }
    print("🔍 DEBUG: Program selected: $selectedProgram");

    if (selectedStartDate == null) {
      print("🔍 DEBUG: No start date selected!");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a start date')),
      );
      return;
    }
    print("🔍 DEBUG: Start date selected: $selectedStartDate");

    setState(() {
      isLoading = true;
    });
    print("🔍 DEBUG: Loading state set to true");

    try {
      print("🔍 DEBUG: Submitting application");
      print("🔍 DEBUG: University ID: ${widget.universityId}");
      print("🔍 DEBUG: Program: $selectedProgram");
      print("🔍 DEBUG: Email: $email");
      print("🔍 DEBUG: Intake Month: $dropdownValue");
      print("🔍 DEBUG: Intake Year: $yearValue");
      print("🔍 DEBUG: Semester: $selectedSemester");
      print("🔍 DEBUG: Start Date: $selectedStartDate");

      // Find the selected program ID
      final selectedProgramData = programs.firstWhere(
        (program) => program['name'] == selectedProgram,
        orElse: () =>
            {'id': 1, 'name': selectedProgram}, // Default to ID 1 for testing
      );
      print("🔍 DEBUG: Selected program data: $selectedProgramData");

      // Ensure we have a valid program ID
      final programId = selectedProgramData['id'] ?? 1;
      print("🔍 DEBUG: Using program ID: $programId");

      final applicationData = {
        'university': widget.universityId,
        'program': programId,
        'intended_start_date':
            selectedStartDate!.toIso8601String().split('T')[0],
        'intended_start_semester': '$selectedSemester $yearValue',
        'academic_year': yearValue,
        'personal_statement': 'Application submitted via mobile app',
        'priority': 'medium',
        'additional_info': {
          'intake_month': dropdownValue,
          'email': email,
          'submitted_via': 'mobile_app'
        }
      };

      print("🔍 DEBUG: Application data: $applicationData");

      final token = await SessionManager.getStoredToken() ?? '';
      
      final response = await http.post(
        Uri.parse(
            '${BaseUrl.baseUrlApi}/api/v1/applications/applications/simple-test/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(applicationData),
      );

      print(
          "🔍 DEBUG: Application submission response status: ${response.statusCode}");
      print("🔍 DEBUG: Application submission response body: ${response.body}");

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        print(
            "🔍 DEBUG: Application created successfully: ${responseData['data']?['application_number']}");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Application submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Reset form
        setState(() {
          dropdownValue = 'January';
          yearValue = '2024';
          email = '';
          selectedProgram = '';
          selectedSemester = 'Fall';
          selectedStartDate = null;
        });
        _emailController.clear();

        // Close modal
        Navigator.of(context).pop();
      } else {
        print(
            "🔍 DEBUG: Application submission failed: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit application. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("🔍 DEBUG: Error submitting application: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting application: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
      print("🔍 DEBUG: Loading state set to false");
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaSize = MediaQuery.sizeOf(context);
    final w = mediaSize.width;
    final h = mediaSize.height;

    final padAll = (w * 0.04).clamp(12.0, 18.0);
    final padH = (w * 0.04).clamp(12.0, 18.0);
    final padV = (h * 0.02).clamp(10.0, 18.0);
    final fieldH = (h * 0.06).clamp(48.0, 60.0);
    final fieldHLg = (h * 0.075).clamp(54.0, 72.0);
    final iconSz = (w * 0.05).clamp(18.0, 24.0);
    final fsSm = (w * 0.03).clamp(12.0, 14.0);
    final fsMd = (w * 0.035).clamp(13.0, 16.0);
    final fsLg = (w * 0.045).clamp(16.0, 20.0);
    final contentPadH = (w * 0.03).clamp(10.0, 14.0);
    final contentPadV = (h * 0.02).clamp(10.0, 16.0);

    size = Measurements(mediaSize);

    return Container(
      constraints: BoxConstraints(
        maxHeight: mediaSize.height * 0.9,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(padAll),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size?.hp(2)),
                Center(
                  child: Text(
                    "Apply to ${widget.universityName}",
                    style:
                        TextStyle(fontSize: fsLg, fontWeight: FontWeight.w600),
                  ),
                ),
                SizedBox(height: size?.hp(2)),

                // Program Selection
                Text(
                  "Select Program",
                  style: TextStyle(fontSize: fsLg, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 10),
                SizedBox(
                  height: fieldH,
                  child: isLoadingPrograms
                      ? Center(child: CircularProgressIndicator())
                      : DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: grey4),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: grey4),
                            ),
                            filled: true,
                            fillColor: grey4,
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: contentPadH),
                          ),
                          dropdownColor: grey4,
                          initialValue: selectedProgram.isEmpty ||
                                  !programs
                                      .any((p) => p['name'] == selectedProgram)
                              ? null
                              : selectedProgram,
                          hint: Text('Select a program'),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedProgram = newValue ?? '';
                            });
                          },
                          items: programs.isNotEmpty
                              ? programs
                                  .map<DropdownMenuItem<String>>((program) {
                                  return DropdownMenuItem<String>(
                                    value: program['name'],
                                    child: Text(
                                      program['name'] ?? 'Unknown Program',
                                      style: TextStyle(fontSize: fsMd),
                                    ),
                                  );
                                }).toList()
                              : [
                                  DropdownMenuItem<String>(
                                    value: 'Computer Science',
                                    child: Text('Computer Science',
                                        style: TextStyle(fontSize: fsMd)),
                                  ),
                                  DropdownMenuItem<String>(
                                    value: 'Business Administration',
                                    child: Text('Business Administration',
                                        style: TextStyle(fontSize: fsMd)),
                                  ),
                                  DropdownMenuItem<String>(
                                    value: 'Engineering',
                                    child: Text('Engineering',
                                        style: TextStyle(fontSize: fsMd)),
                                  ),
                                ],
                        ),
                ),
                SizedBox(height: size?.hp(2)),

                // Start Date Selection
                Text(
                  "Start Date",
                  style: TextStyle(fontSize: fsLg, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 10),
                SizedBox(
                  height: fieldHLg,
                  child: InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(Duration(days: 30)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 365 * 2)),
                      );
                      if (date != null) {
                        setState(() {
                          selectedStartDate = date;
                        });
                      }
                    },
                    child: Container(
                      height: fieldHLg,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(15),
                        color: grey4,
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: padH, vertical: padV),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today,
                              color: Colors.grey, size: iconSz),
                          SizedBox(width: contentPadH),
                          Text(
                            selectedStartDate != null
                                ? '${selectedStartDate!.day}/${selectedStartDate!.month}/${selectedStartDate!.year}'
                                : 'Select start date',
                            style: TextStyle(fontSize: fsMd),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size?.hp(2)),

                // Semester Selection
                Text(
                  "Semester",
                  style: TextStyle(fontSize: fsLg, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 10),
                SizedBox(
                  height: fieldH,
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: grey4),
                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: grey4),
                      ),
                      filled: true,
                      fillColor: grey4,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: contentPadH),
                    ),
                    dropdownColor: grey4,
                    initialValue: selectedSemester,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedSemester = newValue!;
                      });
                    },
                    items: <String>[
                      'Fall',
                      'Spring',
                      'Summer',
                      'Winter',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(fontSize: fsLg),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: size?.hp(2)),

                // Intake Month
                Text(
                  "Choose Intake Month",
                  style: TextStyle(fontSize: fsLg, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 10),
                SizedBox(
                  height: fieldH,
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: grey4),
                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: grey4),
                      ),
                      filled: true,
                      fillColor: grey4,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: contentPadH),
                    ),
                    dropdownColor: grey4,
                    initialValue: dropdownValue,
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownValue = newValue!;
                      });
                    },
                    items: <String>[
                      'January',
                      'February',
                      'March',
                      'May',
                      'June',
                      'July',
                      'August',
                      'September',
                      'October',
                      'November',
                      'December',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(fontSize: fsLg),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: size?.hp(2)),

                // Intake Year
                Text(
                  "Choose Intake year",
                  style: TextStyle(fontSize: fsLg, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 10),
                SizedBox(
                  height: fieldH,
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: grey4),
                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: grey4),
                      ),
                      filled: true,
                      fillColor: grey4,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: contentPadH),
                    ),
                    dropdownColor: grey4,
                    initialValue: yearValue,
                    onChanged: (String? newValue) {
                      setState(() {
                        yearValue = newValue!;
                      });
                    },
                    items: <String>[
                      '2023',
                      '2024',
                      '2025',
                      '2026',
                      '2027',
                      '2028',
                      '2029',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(fontSize: fsLg),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: size?.hp(2)),

                // Email Field
                Text(
                  "Your Email",
                  style: TextStyle(fontSize: fsLg, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 10),
                SizedBox(
                  height: fieldH,
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        email = value;
                      });
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                          vertical: contentPadV, horizontal: contentPadH),
                      fillColor: grey4,
                      labelText: 'Email address',
                      isDense: true,
                      filled: true,
                      hintText: "Enter your email",
                      hintStyle:
                          TextStyle(fontFamily: 'Roboto', color: textColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: grey4),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: grey4),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size?.hp(3)),

                // Test Button (for debugging)
                SizedBox(height: size?.hp(2)),

                // Submit Button
                Container(
                  height: size?.hp(7),
                  width: getWidth(context),
                  decoration: BoxDecoration(
                    color: secondaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: isLoading
                          ? null
                          : () {
                              print("🔍 DEBUG: Button tapped!");
                              submitApplication();
                            },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: contentPadV),
                        child: Center(
                          child: isLoading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        thirdColor),
                                  ),
                                )
                              : Text(
                                  "Submit Application",
                                  style: TextStyle(
                                    letterSpacing: 2,
                                    fontFamily: 'Roboto',
                                    fontSize: fsLg,
                                    color: thirdColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
