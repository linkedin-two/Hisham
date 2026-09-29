import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:edvoyage/screens/profile/profile_Tab/profile_about.dart';
import 'package:edvoyage/screens/profile/profile_Tab/profile_application.dart';
import 'package:edvoyage/screens/profile/profile_Tab/profile_favorites.dart';
import 'package:edvoyage/screens/profile/profile_Tab/profile_feed.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:edvoyage/utils/colors/colors.dart';
import 'package:edvoyage/_env/env.dart';
import 'package:edvoyage/providers/user_email_provider.dart';
import 'package:edvoyage/utils/session_manager.dart';

// --- Config / Endpoints ---
String get USER_BY_EMAIL_URL => '${BaseUrl.baseUrl}/users/users/by-email/';
String get PROFILE_UPLOAD_URL =>
    '${BaseUrl.baseUrl}/users/upload-profile-image/';

// --- Simple UserProfile model (trimmed) ---
class UserProfile {
  final int id;
  final String email;
  final String username;
  final String? profilePicture;

  UserProfile({
    required this.id,
    required this.email,
    required this.username,
    this.profilePicture,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? 0,
      email: json['user_email'] ?? json['email'] ?? '',
      username: json['user_username'] ?? json['username'] ?? '',
      profilePicture: json['profile_picture_url'] ??
          json['profile_picture'] ??
          (json['profile'] != null
              ? (json['profile']['profile_picture_url'] ??
                  json['profile']['profile_picture'])
              : null),
    );
  }

  String get avatarUrl {
    final pic = profilePicture;
    if (pic == null || pic.isEmpty) return '';

    // If absolute URL
    if (pic.startsWith('http://') || pic.startsWith('https://')) return pic;

    // If backend gives `/media/...`
    if (pic.startsWith('/')) return '${BaseUrl.baseUrlApi}$pic';

    // If backend gives `profiles/...`
    return '${BaseUrl.baseUrlApi}/media/$pic';
  }
}

// --- API helpers ---
Future<Map<String, dynamic>> apiFetchUserByEmail(String email) async {
  final uri = Uri.parse(
    '$USER_BY_EMAIL_URL?email=${Uri.encodeComponent(email)}',
  );
  print('Fetching user by email from: $uri');
  
  final token = await SessionManager.getStoredToken();
  final headers = {'Accept': 'application/json'};
  if (token != null && token.isNotEmpty) {
    headers['Authorization'] = 'Bearer $token';
  }
  
  final resp = await http.get(uri, headers: headers);
  // Print full raw response body for debugging as requested
  try {
    // ignore: avoid_print
    print('Full user fetch response body: ${resp.body}');
  } catch (_) {}
  if (resp.statusCode == 200) {
    final body = jsonDecode(resp.body);
    if (body is Map && body.containsKey('data')) {
      return Map<String, dynamic>.from(body['data']);
    }
    return Map<String, dynamic>.from(body);
  }
  throw http.ClientException('Failed to fetch user: ${resp.statusCode}');
}

// Check if a given image URL exists and appears to be an image
Future<bool> _imageExists(String url) async {
  if (url.isEmpty) return false;
  try {
    final uri = Uri.parse(url);
    final resp = await http.get(uri,
        headers: {'Accept': 'image/*'}).timeout(const Duration(seconds: 6));
    if (resp.statusCode == 200) {
      final ct = resp.headers['content-type'] ?? '';
      return ct.startsWith('image/');
    }
    return false;
  } catch (_) {
    return false;
  }
}

String? _lookupMime(String filename) {
  final n = filename.toLowerCase();
  if (n.endsWith('.png')) return 'image/png';
  if (n.endsWith('.jpg') || n.endsWith('.jpeg')) return 'image/jpeg';
  if (n.endsWith('.gif')) return 'image/gif';
  return null;
}

Future<http.StreamedResponse> apiUploadProfilePicture(
  String email,
  XFile image,
) async {
  final uri = Uri.parse(PROFILE_UPLOAD_URL);
  final request = http.MultipartRequest('POST', uri);
  
  final token = await SessionManager.getStoredToken();
  request.headers['Accept'] = 'application/json';
  if (token != null && token.isNotEmpty) {
    request.headers['Authorization'] = 'Bearer $token';
  }
  
  request.fields['email'] = email;

  if (kIsWeb) {
    final bytes = await image.readAsBytes();
    final mime = _lookupMime(image.name) ?? 'image/jpeg';
    final parts = mime.split('/');
    final mf = http.MultipartFile.fromBytes(
      'profile_picture',
      bytes,
      filename: image.name.isNotEmpty ? image.name : 'avatar.jpg',
      contentType: MediaType(parts[0], parts[1]),
    );
    request.files.add(mf);
  } else {
    final mime = _lookupMime(image.path) ?? 'image/jpeg';
    final parts = mime.split('/');
    final mf = await http.MultipartFile.fromPath(
      'profile_picture',
      image.path,
      filename: image.path.split(Platform.pathSeparator).last,
      contentType: MediaType(parts[0], parts[1]),
    );
    request.files.add(mf);
  }

  return await request.send();
}

// --- Widget ---
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with TickerProviderStateMixin {
  bool isLoading = true;
  bool isUploadingImage = false;
  UserProfile? profile;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadProfile();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      isLoading = true;
    });

    final email = ref.read(userEmailProvider);
    if (email == null || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No email provided'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final user = await apiFetchUserByEmail(email);
      final mapped = {
        'id': user['id'] ?? 0,
        'user_email': user['email'] ?? user['user_email'] ?? email,
        'user_username': user['username'] ?? user['user_username'] ?? '',
        'profile_picture_url': user['profile'] != null
            ? user['profile']['profile_picture_url']
            : (user['profile_picture_url']),
        'profile_picture': user['profile'] != null
            ? user['profile']['profile_picture']
            : (user['profile_picture']),
      };
      final up = UserProfile.fromJson(mapped);
      print(
        'Loaded user profile: ${up.username}, ${up.email}, ${up.avatarUrl}',
      );
      setState(() {
        profile = up;
        isLoading = false;
      });

      // After loading user data, verify the profile image URL (if any)
      final avatar = up.avatarUrl;
      if (avatar.isNotEmpty) {
        await _imageExists(avatar);
        // Silently skip showing any message for missing/empty profile image
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exception: $e'),
          backgroundColor: Colors.purple,
        ),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      setState(() {
        isUploadingImage = true;
      });

      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image == null) return;

      final email = ref.read(userEmailProvider);
      if (email == null || email.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No email found. Please login again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final response = await apiUploadProfilePicture(email, image);
      final body = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadProfile();
      } else {
        String message = 'Upload failed: ${response.statusCode}';
        try {
          final parsed = jsonDecode(body);
          if (parsed is Map && parsed['message'] != null) {
            message = parsed['message'];
          }
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exception: $e'),
          backgroundColor: Colors.purple,
        ),
      );
    } finally {
      setState(() {
        isUploadingImage = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        title: Text('Profile', style: TextStyle(color: Colors.black)),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    flex: 35,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final headerH = constraints.maxHeight;
                        final double avatarRadius = 56.0;
                        final double avatarDiameter = avatarRadius * 2;

                        return Container(
                          height: headerH,
                          width: double.infinity,
                          color: primaryColor,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: avatarDiameter,
                                  height: avatarDiameter,
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Positioned.fill(
                                        child: CircleAvatar(
                                          radius: avatarRadius,
                                          backgroundColor: Colors.grey[200],
                                          backgroundImage: (profile != null &&
                                                  (profile!.avatarUrl)
                                                      .isNotEmpty)
                                              ? NetworkImage(profile!.avatarUrl)
                                              : null,
                                          child: (profile == null ||
                                                  (profile!.profilePicture ??
                                                          '')
                                                      .isEmpty)
                                              ? Icon(
                                                  Icons.person,
                                                  size: avatarRadius,
                                                  color: Colors.grey,
                                                )
                                              : null,
                                        ),
                                      ),
                                      Positioned(
                                        right: -6,
                                        bottom: -6,
                                        child: Material(
                                          elevation: 2,
                                          shape: const CircleBorder(),
                                          color: Colors.transparent,
                                          child: Container(
                                            width: 42,
                                            height: 42,
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            padding: const EdgeInsets.all(4),
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                color: Colors.yellow,
                                                shape: BoxShape.circle,
                                              ),
                                              child: isUploadingImage
                                                  ? const Center(
                                                      child: SizedBox(
                                                        width: 18,
                                                        height: 18,
                                                        child:
                                                            CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                        ),
                                                      ),
                                                    )
                                                  : IconButton(
                                                      padding: EdgeInsets.zero,
                                                      icon: const Icon(
                                                        Icons
                                                            .camera_alt_outlined,
                                                        size: 18,
                                                        color: Colors.black,
                                                      ),
                                                      onPressed: _pickImage,
                                                    ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  profile?.username ?? 'User',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  profile?.email ?? '',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    flex: 65,
                    child: Column(
                      children: [
                        TabBar(
                          controller: _tabController,
                          labelColor: Colors.black,
                          tabs: const [
                            Tab(text: 'Feed'),
                            Tab(text: 'About'),
                            Tab(text: 'Favourites'),
                            Tab(text: 'Applications'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              ProfileFeed(),
                              ProfileAbout(),
                              ProfileFevourites(),
                              ProfileApplication(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
