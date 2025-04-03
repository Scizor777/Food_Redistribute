class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String type;
  final Map<String, dynamic>? supplierDetails;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.type,
    this.supplierDetails,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['_id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      type: map['type'] ?? '',
      supplierDetails: map['supplierDetails'],
    );
  }
}