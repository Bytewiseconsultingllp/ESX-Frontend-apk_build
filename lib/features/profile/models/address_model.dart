class Address {
  final String name;
  final String email;
  final String phoneNumber;
  final String alternateNumber;
  final String lane;
  final String city;
  final String state;
  final String country;
  final int pincode;

  Address({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.alternateNumber,
    required this.lane,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      alternateNumber: json['alternateNumber'],
      lane: json['lane'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      pincode: json['pincode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'alternateNumber': alternateNumber,
      'lane': lane,
      'city': city,
      'state': state,
      'country': country,
      'pincode': pincode,
    };
  }
}
