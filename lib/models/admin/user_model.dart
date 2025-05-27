enum UserRole {
  admin,
  restaurantOwner,
  customer,
}

class UserModel {
  final String id;
  final String email;
  final String name;
  final String? phoneNumber;
  final UserRole role;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.phoneNumber,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'role': role.toString().split('.').last,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'],
      role: UserRole.values.firstWhere(
        (role) => role.toString().split('.').last == map['role'],
        orElse: () => UserRole.customer,
      ),
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phoneNumber,
    UserRole? role,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
    );
  }
} 