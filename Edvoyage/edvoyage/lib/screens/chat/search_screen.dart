import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import '../../models/user.dart';
import '../../utils/colors/colors.dart';
import '../../screens/notes/logo.dart';
import 'chat_screen.dart';

// API Configuration - Using edzkool chat API
String get _searchBaseUrl {
  return 'https://edzkool.publicvm.com/api';
}

String? _searchCurrentEmail;

void _setSearchCurrentEmail(String email) {
  _searchCurrentEmail = email;
}

Map<String, String> get _searchHeaders {
  final headers = {'Content-Type': 'application/x-www-form-urlencoded'};
  if (_searchCurrentEmail != null) {
    headers['X-User-Email'] = _searchCurrentEmail!;
  }
  return headers;
}

Future<List<User>> _searchUsers(String query) async {
  try {
    final response = await http.get(
      Uri.parse('$_searchBaseUrl/users/search?email=${Uri.encodeComponent(_searchCurrentEmail ?? '')}&q=${Uri.encodeComponent(query)}'),
      headers: _searchHeaders,
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) {
        final users = (data['users'] as List).map((u) => User.fromJson(u)).toList();
        return users;
      }
    }
    return [];
  } catch (e) {
    print('Error searching users: $e');
    return [];
  }
}

Future<List<User>> _getAllUsers() async {
  try {
    final response = await http.get(
      Uri.parse('$_searchBaseUrl/users?email=${Uri.encodeComponent(_searchCurrentEmail ?? '')}'),
      headers: _searchHeaders,
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final usersData = data['data'] as List;
        final users = usersData.map((u) {
          // Extract profile data if available
          final profile = u['profile'] as Map<String, dynamic>?;
          
          // Build full name from various sources
          String fullName = '';
          if (profile != null && profile['full_name'] != null && profile['full_name'].toString().isNotEmpty) {
            fullName = profile['full_name'];
          } else if (u['first_name'] != null && u['last_name'] != null) {
            fullName = '${u['first_name']} ${u['last_name']}'.trim();
          } else if (u['first_name'] != null) {
            fullName = u['first_name'];
          } else {
            fullName = u['username'] ?? u['email'] ?? '';
          }
          
          // Extract avatar from profile or use default
          String avatar = 'https://i.pravatar.cc/150?img=1';
          if (profile != null) {
            if (profile['profile_picture_url'] != null && profile['profile_picture_url'].toString().isNotEmpty) {
              avatar = profile['profile_picture_url'].toString().startsWith('http') 
                  ? profile['profile_picture_url']
                  : 'https://edzkool.publicvm.com${profile['profile_picture_url']}';
            } else if (profile['profile_picture'] != null && profile['profile_picture'].toString().isNotEmpty) {
              avatar = profile['profile_picture'].toString().startsWith('http')
                  ? profile['profile_picture']
                  : 'https://edzkool.publicvm.com${profile['profile_picture']}';
            }
          }
          
          // Extract location info for role display
          String location = '';
          if (profile != null) {
            final city = profile['city'] ?? '';
            final country = profile['country'] ?? '';
            if (city.isNotEmpty && country.isNotEmpty) {
              location = '$city, $country';
            } else if (city.isNotEmpty) {
              location = city;
            } else if (country.isNotEmpty) {
              location = country;
            }
          }
          
          return User(
            email: u['email'] ?? u['username'] ?? '',
            name: fullName,
            avatar: avatar,
            role: location,
          );
        }).toList();
        return users;
      }
    }
    return [];
  } catch (e) {
    print('Error getting users: $e');
    return [];
  }
}

class SearchScreen extends StatefulWidget {
  final String? userEmail;

  const SearchScreen({super.key, this.userEmail});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<User> _filteredUsers = [];
  List<User> _allUsers = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Set current email for API authentication
    if (widget.userEmail != null) {
      _setSearchCurrentEmail(widget.userEmail!);
    }
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final users = await _getAllUsers();
      setState(() {
        _allUsers = users;
        _filteredUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load users: $e';
      });
    }
  }

  void _onSearchChanged(String query) async {
    if (query.isEmpty) {
      setState(() => _filteredUsers = _allUsers);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final users = await _searchUsers(query);
      setState(() {
        _filteredUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Search failed: $e')),
      );
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _filteredUsers = _allUsers);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: _loadUsers,
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: primaryColor,
            )),
        title: SizedBox(
          height: 250, // Set the width of the container
          width: 200, // Set the height of the container
          child:
              Image.asset(edvoyagelogo1), // Replace with the actual image path
        ),
      ),
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
  
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredUsers.isEmpty
                      ? const Center(
                          child: Text(
                            "No users found",
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _filteredUsers.length,
                          itemBuilder: (context, index) {
                            return _UserTile(user: _filteredUsers[index], currentUserEmail: widget.userEmail);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// UserTile Widget
class _UserTile extends StatelessWidget {
  final User user;
  final String? currentUserEmail;

  const _UserTile({required this.user, this.currentUserEmail});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(user: user, currentUserEmail: currentUserEmail),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(user.avatar),
              backgroundColor: Colors.grey.shade300,
              onBackgroundImageError: (e, stackTrace) {
                // Fallback to default avatar on error
              },
              child: user.avatar.contains('pravatar') || user.avatar.isEmpty
                  ? Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name.isNotEmpty ? user.name : user.email,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (user.role.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      user.role,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFF0F8A7B),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
