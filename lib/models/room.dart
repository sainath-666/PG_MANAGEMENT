import 'guest.dart';

class Room {
  final String id;
  final String roomNumber;
  final String floorId;
  final int totalBeds;
  final List<Guest> guests;

  Room({
    required this.id,
    required this.roomNumber,
    required this.floorId,
    required this.totalBeds,
    required this.guests,
  });

  int get occupiedBeds => guests.length;
  int get availableBeds => totalBeds - occupiedBeds;
  bool get hasAvailability => availableBeds > 0;
  int get paidGuests => guests.where((guest) => guest.isPaid).length;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomNumber': roomNumber,
      'floorId': floorId,
      'totalBeds': totalBeds,
      'guests': guests.map((g) => g.toJson()).toList(),
    };
  }

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      roomNumber: json['roomNumber'],
      floorId: json['floorId'],
      totalBeds: json['totalBeds'],
      guests: (json['guests'] as List).map((g) => Guest.fromJson(g)).toList(),
    );
  }
}
