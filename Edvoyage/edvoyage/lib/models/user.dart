class User {
  final String email;
  final String name;
  final String avatar;
  final String role;

  const User({
    required this.email,
    required this.name,
    required this.avatar,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      avatar: json['avatar'] ?? 'https://i.pravatar.cc/150?img=1',
      role: json['role'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'avatar': avatar,
      'role': role,
    };
  }
}
