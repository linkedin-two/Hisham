import 'package:edzkool/_env/env.dart';

class University {
  final int id;
  final String name;
  final String city;
  final String country;
  final String state;
  final String? logoUrl;
  final int? estd;
  final double? rating;
  final String? location;
  final String? logo;
  final String? banner_image;
  final String? establishedYear;
  final bool? bookmark;
  final bool? is_FMGE_affiliated;
  final bool? is_USML_affiliated;
  final bool? is_PLAB_affiliated;
  final String? website;
  final String? about;
  final int? ranking;
  final int? founded_year;
  final int? undergraduate_programs;
  final String? phone;

  University({
    required this.id,
    required this.name,
    required this.city,
    required this.country,
    required this.state,
    this.logoUrl,
    this.estd,
    this.rating,
    this.location,
    this.logo,
    this.banner_image,
    this.establishedYear,
    this.bookmark,
    this.is_FMGE_affiliated,
    this.is_USML_affiliated,
    this.is_PLAB_affiliated,
    this.website,
    this.about,
    this.ranking,
    this.founded_year,
    this.undergraduate_programs,
    this.phone,
  });

  // Helper function to convert relative media paths to full URLs
  static String? toFullUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    
    // If the backend returns an absolute URL pointing to our VPS or localhost, 
    // extract just the relative media path to force it to use BaseUrl.mediaUrl.
    // This prevents "Mixed Content" HTTP vs HTTPS errors.
    if (path.contains('media/')) {
      path = path.substring(path.indexOf('media/') + 6);
    } else if (path.startsWith('http')) {
      // External URLs are returned as is
      return path;
    }
    
    // Remove leading slash if present
    var cleanPath = path.startsWith('/') ? path.substring(1) : path;
    // If path already starts with 'media/', remove it to avoid double media/
    if (cleanPath.startsWith('media/')) {
      cleanPath = cleanPath.substring(6); // Remove 'media/' prefix
    }
    return '${BaseUrl.mediaUrl}$cleanPath';
  }

  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      city: json['city'] ?? json['location'] ?? '',
      country: json['country'] ?? '',
      state: json['state'] ?? '',
      logoUrl: toFullUrl(json['logo_url'] ?? json['logo']),
      estd: json['estd'],
      rating: (json['rating'] ?? 0).toDouble(),
      location: json['location'],
      logo: toFullUrl(json['logo'] ?? json['logo_url']),
      banner_image: toFullUrl(json['banner_image'] ?? json['banner_image_url']),
      establishedYear: json['established_year'],
      bookmark: json['bookmark'],
      is_FMGE_affiliated: json['is_FMGE_affiliated'],
      is_USML_affiliated: json['is_USML_affiliated'],
      is_PLAB_affiliated: json['is_PLAB_affiliated'],
      website: json['website'],
      about: json['about'],
      ranking: json['ranking'],
      founded_year: json['founded_year'],
      undergraduate_programs: json['undergraduate_programs'],
      phone: json['phone'],
    );
  }
}
