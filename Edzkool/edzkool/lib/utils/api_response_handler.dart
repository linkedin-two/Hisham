import 'dart:convert';

/// Standardized API Response Handler
/// 
/// This class handles the standardized backend API response format:
/// {
///   "success": true|false,
///   "message": "...",
///   "data": { ... } | [ ... ] | null,
///   "errors": { ... } | null,
///   "meta": { ... } | null
/// }
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final Map<String, dynamic>? errors;
  final Map<String, dynamic>? meta;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
    this.meta,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) dataParser,
  ) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? dataParser(json['data']) : null,
      errors: json['errors'] as Map<String, dynamic>?,
      meta: json['meta'] as Map<String, dynamic>?,
    );
  }

  /// Extract list data from paginated or direct list responses
  static List<dynamic> extractList(dynamic data) {
    if (data is Map && data.containsKey('results')) {
      return data['results'] as List<dynamic>;
    } else if (data is List) {
      return data;
    } else {
      return [];
    }
  }

  /// Check if response indicates success
  bool get isSuccess => success;

  /// Check if response has errors
  bool get hasErrors => errors != null && errors!.isNotEmpty;

  /// Get error message
  String get errorMessage {
    if (errors != null && errors!.isNotEmpty) {
      return errors!.values.first.toString();
    }
    return message;
  }
}

/// API Response Handler Utility
class ApiResponseHandler {
  /// Parse API response and handle standardized envelope format
  static ApiResponse<T> parseResponse<T>(
    String responseBody,
    T Function(dynamic) dataParser,
  ) {
    try {
      final json = jsonDecode(responseBody) as Map<String, dynamic>;
      return ApiResponse.fromJson(json, dataParser);
    } catch (e) {
      throw Exception('Failed to parse API response: $e');
    }
  }

  /// Extract data from API response for list endpoints
  static List<T> parseListResponse<T>(
    String responseBody,
    T Function(Map<String, dynamic>) itemParser,
  ) {
    final response = parseResponse(responseBody, (data) => data);
    
    if (!response.isSuccess) {
      throw Exception(response.errorMessage);
    }

    final list = ApiResponse.extractList(response.data);
    return list.map((item) => itemParser(item as Map<String, dynamic>)).toList();
  }

  /// Extract single item from API response
  static T parseSingleResponse<T>(
    String responseBody,
    T Function(Map<String, dynamic>) itemParser,
  ) {
    final response = parseResponse(responseBody, (data) => data);
    
    if (!response.isSuccess) {
      throw Exception(response.errorMessage);
    }

    if (response.data == null) {
      throw Exception('No data returned from API');
    }

    return itemParser(response.data as Map<String, dynamic>);
  }

  /// Handle error responses
  static Exception handleErrorResponse(String responseBody, int statusCode) {
    try {
      final json = jsonDecode(responseBody) as Map<String, dynamic>;
      final message = json['message'] ?? 'Unknown error';
      final errors = json['errors'];
      
      if (errors != null && errors is Map && errors.isNotEmpty) {
        final errorDetails = errors.values.join(', ');
        return Exception('API Error ($statusCode): $message - $errorDetails');
      }
      
      return Exception('API Error ($statusCode): $message');
    } catch (e) {
      return Exception('API Error ($statusCode): $responseBody');
    }
  }
}
