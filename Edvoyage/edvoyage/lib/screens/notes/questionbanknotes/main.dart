import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:edvoyage/_env/notes_env.dart';
import 'package:edvoyage/screens/notes/logo.dart';
import 'package:edvoyage/screens/notes/topbar.dart';
import 'package:edvoyage/utils/api_response_handler.dart';

class QBankScreen extends StatefulWidget {
  const QBankScreen({super.key});

  @override
  _QBankScreenState createState() => _QBankScreenState();
}

class _QBankScreenState extends State<QBankScreen> {
  late Future<List<Map<String, dynamic>>> modulesFuture;
  final int _selectedIndex = 3; // Notes tab is active

  @override
  void initState() {
    super.initState();
    modulesFuture = fetchQBankModules();
  }

  /// Fetch all Q-Bank questions and group by module
  Future<List<Map<String, dynamic>>> fetchQBankModules() async {
    try {
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/notes/notesqbank/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final envelope = ApiResponseHandler.parseResponse(
          response.body,
          (data) => data,
        );
        if (!envelope.isSuccess) {
          return [];
        }

        final List<dynamic> modulesData =
            ApiResponse.extractList(envelope.data);

        // Map modules into a List<Map<String, dynamic>>
        return modulesData.map<Map<String, dynamic>>((module) {
          return {
            'module_id': module['module_id'],
            'module_title': module['module_title'],
            'module_description': module['module_description'],
            'questions_count': module['questions_count'],
          };
        }).toList();
      } else {
        print('❌ API Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error fetching Q-Bank modules: $e');
      return [];
    }
  }

  /// Builds individual module cards
  Widget _buildModuleCard(Map<String, dynamic> module) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final marginH = w * 0.04;
    final marginV = h * 0.012;
    final paddingH = w * 0.045;
    final paddingTop = h * 0.018;
    final paddingBottom = h * 0.02;
    final titleSize = w * 0.055;
    final bodySize = w * 0.045;
    final accentHeight = w * 0.04;

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      margin: EdgeInsets.symmetric(horizontal: marginH, vertical: marginV),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              paddingH,
              paddingTop,
              paddingH,
              paddingBottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  module['module_title'] ?? 'Unknown Module',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: h * 0.008),
                Text(
                  module['module_description'] ?? '',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: bodySize,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: h * 0.012),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${module['questions_count']} Questions',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: bodySize,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Poppins'),
      ),
      child: Scaffold(
        appBar: CustomLogoAppBar(),
        body: SafeArea(
          child: Column(
            children: [
              Topbar(firstText: 'Q-Bank', secondText: 'Modules'),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: modulesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Failed to load Q-Bank modules',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: w * 0.045,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                      );
                    }

                    final modules = snapshot.data ?? [];
                    if (modules.isEmpty) {
                      return Center(
                        child: Text(
                          'No Q-Bank modules found',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: w * 0.045,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: modules.length,
                      itemBuilder: (context, index) {
                        return _buildModuleCard(modules[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
