class Guest {
  final String id;
  final String name;
  final String gender;
  final String mobileNumber;
  final DateTime joinDate;
  final String floorId;
  final String roomId;
  final String aadharNumber;
  final double rentAmount;

  Guest({
    required this.id,
    required this.name,
    required this.gender,
    required this.mobileNumber,
    required this.joinDate,
    required this.floorId,
    required this.roomId,
    required this.aadharNumber,
    required this.rentAmount,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'mobileNumber': mobileNumber,
      'joinDate': joinDate.toIso8601String(),
      'floorId': floorId,
      'roomId': roomId,
      'aadharNumber': aadharNumber,
      'rentAmount': rentAmount,
    };
  }

  factory Guest.fromJson(Map<String, dynamic> json) {
    return Guest(
      id: json['id'],
      name: json['name'],
      gender: json['gender'],
      mobileNumber: json['mobileNumber'],
      joinDate: DateTime.parse(json['joinDate']),
      floorId: json['floorId'],
      roomId: json['roomId'],
      aadharNumber: json['aadharNumber'],
      rentAmount: json['rentAmount'],
    );
  }
}
