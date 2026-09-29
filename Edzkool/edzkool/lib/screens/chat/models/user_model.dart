class UserSimple {
  final String email;
  final String name;

  UserSimple({
    required this.email,
    this.name = '',
  });

  factory UserSimple.fromJson(Map<String, dynamic> json) {
    return UserSimple(
      email: json['email'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
    };
  }
}
