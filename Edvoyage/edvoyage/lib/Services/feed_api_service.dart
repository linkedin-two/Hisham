// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:edvoyage/_env/env.dart';
import 'package:edvoyage/utils/api_response_handler.dart';

/// ⚠️ Keep baseUrl as your local server for emulator/dev:
const String baseUrl = "${BaseUrl.baseUrl}/feed";

//
// MODELS (keep here so api_service is self-contained)
//

class UserModel {
  final int id;
  final String username;
  final String fullName;

  UserModel({required this.id, required this.username, required this.fullName});

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        username: json['username'] ?? '',
        fullName: json['full_name'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        if (fullName.isNotEmpty) 'full_name': fullName,
      };
}

class CategoryModel {
  final int id;
  final String name;

  CategoryModel({required this.id, required this.name});

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      CategoryModel(id: json['id'], name: json['name']);

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class CommentModel {
  final int id;
  final int post;
  final UserModel user;
  final String content;
  final String createdAt;

  CommentModel({
    required this.id,
    required this.post,
    required this.user,
    required this.content,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
        id: json['id'],
        post: json['post'],
        user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
        content: json['content'] ?? '',
        createdAt: json['created_at'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'post': post,
        'user': user.toJson(),
        'content': content,
        'created_at': createdAt,
      };
}

class PostModel {
  final int id;
  final UserModel user;
  final CategoryModel? category;
  final String content;
  final String createdAt;
  final bool isLikedByUser;
  final int likesCount;
  final int commentsCount;
  final List<CommentModel> comments;

  PostModel({
    required this.id,
    required this.user,
    this.category,
    required this.content,
    required this.createdAt,
    required this.isLikedByUser,
    required this.likesCount,
    required this.commentsCount,
    required this.comments,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final commentsJson = (json['comments'] as List<dynamic>?) ?? [];
    return PostModel(
      id: json['id'],
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      content: json['content'] ?? '',
      createdAt: json['created_at'] ?? '',
      isLikedByUser: json['is_liked_by_user'] ?? false,
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? commentsJson.length,
      comments: commentsJson
          .map((c) => CommentModel.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }

  PostModel copyWith({
    bool? isLikedByUser,
    int? likesCount,
    int? commentsCount,
    List<CommentModel>? comments,
  }) {
    return PostModel(
      id: id,
      user: user,
      category: category,
      content: content,
      createdAt: createdAt,
      isLikedByUser: isLikedByUser ?? this.isLikedByUser,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      comments: comments ?? List<CommentModel>.from(this.comments),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user': user.toJson(),
        'category': category?.toJson(),
        'content': content,
        'created_at': createdAt,
        'is_liked_by_user': isLikedByUser,
        'likes_count': likesCount,
        'comments_count': commentsCount,
        'comments': comments.map((c) => c.toJson()).toList(),
      };
}

//
// API Service
//
class ApiService {
  final http.Client client;

  ApiService({http.Client? client}) : client = client ?? http.Client();

  /// Fetch posts, optionally filtered by categoryId.
  Future<List<PostModel>> getPosts({int? categoryId, String? email}) async {
    late String url;

    if (categoryId == null) {
      url = "$baseUrl/posts/all/";
    } else {
      url = "$baseUrl/posts/$categoryId/";
    }

    if (email != null && email.isNotEmpty) {
      final sep = url.contains('?') ? '&' : '?';
      url = '$url${sep}email=${Uri.encodeComponent(email)}';
    }

    final resp = await client.get(Uri.parse(url));
    if (resp.statusCode != 200) {
      throw Exception("Failed to load posts (status: ${resp.statusCode})");
    }

    // Use standardized response handler
    return ApiResponseHandler.parseListResponse(
      resp.body,
      (json) => PostModel.fromJson(json),
    );
  }

  Future<List<CategoryModel>> getCategories() async {
    final resp = await client.get(Uri.parse("$baseUrl/categories/"));
    if (resp.statusCode != 200) {
      throw Exception('Failed to load categories (status: ${resp.statusCode})');
    }

    // Use standardized response handler
    return ApiResponseHandler.parseListResponse(
      resp.body,
      (json) => CategoryModel.fromJson(json),
    );
  }

  /// Toggle like. Expects standardized response with status in data field
  Future<String> toggleLike({required int postId, String? email}) async {
    final body = <String, dynamic>{};
    if (email != null && email.isNotEmpty) {
      body['email'] = email;
    }

    final resp = await client.post(
      Uri.parse("$baseUrl/posts/toggle-like/$postId/"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (resp.statusCode != 200 && resp.statusCode != 201) {
      throw Exception('Toggle like failed (status: ${resp.statusCode})');
    }

    // Parse standardized response and extract status from data
    final response = ApiResponseHandler.parseResponse(
      resp.body,
      (data) => data as Map<String, dynamic>,
    );

    if (!response.isSuccess) {
      throw Exception(response.errorMessage);
    }

    return response.data?['status'] as String? ?? 'error';
  }

  Future<CommentModel> createComment({
    required int postId,
    required String content,
    String? email,
  }) async {
    final resp = await client.post(
      Uri.parse("$baseUrl/posts/comments/$postId/"),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'content': content,
        if (email != null && email.isNotEmpty) 'email': email,
      }),
    );

    if (resp.statusCode != 201 && resp.statusCode != 200) {
      throw Exception('Failed to create comment (status: ${resp.statusCode})');
    }

    // Use standardized response handler for single item
    return ApiResponseHandler.parseSingleResponse(
      resp.body,
      (json) => CommentModel.fromJson(json),
    );
  }

  Future<PostModel> createPost({
    required int categoryId,
    required String content,
    String? token,
    String? email,
  }) async {
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final body = <String, dynamic>{'content': content};
    if (email != null && email.isNotEmpty) {
      body['email'] = email;
    }

    final resp = await client.post(
      Uri.parse("$baseUrl/posts/$categoryId/"),
      headers: headers,
      body: jsonEncode(body),
    );
    if (resp.statusCode != 201 && resp.statusCode != 200) {
      throw Exception('Failed to create post (status: ${resp.statusCode})');
    }

    // Use standardized response handler for single item
    return ApiResponseHandler.parseSingleResponse(
      resp.body,
      (json) => PostModel.fromJson(json),
    );
  }

  /// Optional: implement if backend supports sharing
  Future<bool> sharePost(String postId, String platform) async {
    final resp = await client.post(
      Uri.parse("$baseUrl/posts/$postId/share/"),
      body: jsonEncode({'platform': platform}),
      headers: {'Content-Type': 'application/json'},
    );
    return resp.statusCode == 200 || resp.statusCode == 201;
  }
}
