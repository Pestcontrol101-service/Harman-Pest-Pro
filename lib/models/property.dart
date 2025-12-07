class Property {
  final String id;
  final String ownerName;
  final String address;
  final String phone;

  Property({required this.id, required this.ownerName, required this.address, this.phone = ''});

  factory Property.fromMap(String id, Map<String, dynamic> map) {
    return Property(
      id: id,
      ownerName: map['ownerName'] ?? '',
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerName': ownerName,
      'address': address,
      'phone': phone,
    };
  }
}
