import 'package:edzkool/utils/authenticated_http.dart';
import 'dart:convert';
import 'package:edzkool/screens/notes/videonotes/video_player_platform.dart';
import 'package:flutter/material.dart';
import 'package:edzkool/utils/app_log.dart';
import 'package:http/http.dart' as http;
import 'package:edzkool/screens/notes/logo.dart';
import 'package:edzkool/screens/notes/topbar.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:edzkool/_env/notes_env.dart';

final bool isWeb = kIsWeb;
bool isAndroid = !kIsWeb && Platform.isAndroid;
bool isIOS = !kIsWeb && Platform.isIOS;

bool isWindows = !kIsWeb && Platform.isWindows;
bool isMacOS = !kIsWeb && Platform.isMacOS;
bool isLinux = !kIsWeb && Platform.isLinux;

// --- DATA MODEL for Video ---
class Video {
  final int id;
  final String title;
  final String videoUrl;
  final String logo;

  final bool isFree;
  final String subjectName;
  final String doctorName;

  Video({
    required this.id,
    required this.title,
    required this.videoUrl,
    required this.logo,
    required this.isFree,
    required this.subjectName,
    required this.doctorName,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    final doctor = json['doctor'];
    final doctorName = doctor is Map ? doctor['name']?.toString() ?? 'Unknown' : 'Unknown';
    
    return Video(
      id: json['id'] ?? 0,
      title: json['title']?.toString() ?? 'Untitled',
      videoUrl: json['video_url']?.toString() ?? '',
      logo: json['logo']?.toString() ?? '',
      isFree: json['is_free'] ?? false,
      subjectName: json['subject_name']?.toString() ?? 'Unknown',
      doctorName: doctorName,
    );
  }
}

// --- SCREEN THAT ACCEPTS SUBJECT NAME ---
class VideosBySubjectScreen extends StatefulWidget {
  final String categoryName;
  final String subjectName;

  const VideosBySubjectScreen({
    super.key,
    required this.categoryName,
    required this.subjectName,
  });

  @override
  State<VideosBySubjectScreen> createState() => _VideosBySubjectScreenState();
}

class _VideosBySubjectScreenState extends State<VideosBySubjectScreen> {
  bool _isLoading = true;
  String videoUrl = "";
  List<Video> _videos = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchVideosBySubject();
  }

  Future<void> _fetchVideosBySubject() async {
    try {
      AppLog.debug('DEBUG: categoryName = ${widget.categoryName}');
      AppLog.debug('DEBUG: subjectName = ${widget.subjectName}');
      
      final response = await AuthenticatedHttp.get(Uri.parse("${BaseUrl.notesApi}videos/"));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        final List<dynamic> data =
            decoded is List ? decoded : decoded['results'] ?? [];
        
        AppLog.debug('DEBUG: Total videos from API: ${data.length}');
        if (data.isNotEmpty) {
          AppLog.debug('DEBUG: First video category: ${data[0]['category']}');
          AppLog.debug('DEBUG: First video subject_name: ${data[0]['subject_name']}');
        }

        final filtered = data.where(
          (item) =>
              item['category'] != null &&
              item['category']['name'] == widget.categoryName &&
              item['subject_name'] == widget.subjectName,
        );
        
        AppLog.debug('DEBUG: Filtered videos count: ${filtered.length}');

        final videos = filtered.map((json) => Video.fromJson(json)).toList();

        if (videos.isEmpty) {
          setState(() {
            _errorMessage = 'NULL (cat: ${widget.categoryName}, sub: ${widget.subjectName})';
            _isLoading = false;
          });
          return;
        }

        setState(() {
          _videos = videos;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'NULL';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'NULL';
        _isLoading = false;
      });
    }
  }

  bool isYouTubeUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;

    return uri.host.contains("youtube.com") || uri.host.contains("youtu.be");
  }

  bool isGoogleDriveUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;

    return uri.host.contains("drive.google.com");
  }

  Widget _buildVideoCard(Video video) {
    const Color primaryColor = Color(0xFF144787);

    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final marginH = w * 0.04;
    final marginV = h * 0.012;
    final paddingH = w * 0.045;
    final paddingV = h * 0.018;
    final thumbSize = w * 0.24;
    final titleSize = w * 0.055;
    final doctorSize = w * 0.045;
    final badgeSize = w * 0.04;
    final lockIconSize = w * 0.06;
    final accentHeight = w * 0.04;

    return InkWell(
      onTap: () {
        AppLog.debug(video.videoUrl);

        final a = isYouTubeUrl(video.videoUrl);
        final b = isGoogleDriveUrl(video.videoUrl);
        final videoType = a
            ? "youtube"
            : b
                ? "gdrive"
                : "other";
        AppLog.debug(videoType);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              // return WebViewScreen(url: video.videoUrl);
              return VideoPlayer(url: video.videoUrl);
            },
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: marginH, vertical: marginV),
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: paddingH, vertical: paddingV),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      video.logo,
                      width: thumbSize,
                      height: thumbSize,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: thumbSize,
                          height: thumbSize,
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: w * 0.04),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          video.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: titleSize,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        SizedBox(height: h * 0.008),
                        Text(
                          video.doctorName,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: doctorSize,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: w * 0.02),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        video.isFree ? Icons.lock_open : Icons.lock,
                        size: lockIconSize,
                        color: video.isFree ? primaryColor : Colors.orange,
                      ),
                      SizedBox(height: h * 0.004),
                      Text(
                        video.isFree ? "FREE" : "PREMIUM",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: badgeSize,
                          fontWeight: FontWeight.bold,
                          color: video.isFree ? primaryColor : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              height: accentHeight,
              width: double.infinity,
              color: primaryColor,
            ),
          ],
        ),
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
        body: Column(
          children: [
            Topbar(firstText: 'Medical Videos', secondText: widget.subjectName),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(
                          child: Text(
                            'NULL',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: w * 0.045,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _videos.length,
                          itemBuilder: (context, index) {
                            return _buildVideoCard(_videos[index]);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
