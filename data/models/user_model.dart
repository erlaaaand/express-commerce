class UserModel {
  final String id;
  final String username;
  final String email;
  final bool isActive;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.isActive = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'] ?? '',
      username: json['username'] ?? 'User',
      email: json['email'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'isActive': isActive,
    };
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      isActive: isActive ?? this.isActive,
    );
  }
}