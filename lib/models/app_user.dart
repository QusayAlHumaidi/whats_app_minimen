class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.password,
  });

  final String id;
  final String name;
  final String phone;
  final String password;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      password: json['password'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'password': password,
    };
  }
}
