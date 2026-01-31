import 'room.dart';

class Floor {
  final String id;
  final int floorNumber;
  final List<Room> rooms;

  Floor({required this.id, required this.floorNumber, required this.rooms});

  int get totalRooms => rooms.length;
  int get availableRooms => rooms.where((r) => r.hasAvailability).length;
  int get totalBeds => rooms.fold(0, (sum, room) => sum + room.totalBeds);
  int get availableBeds =>
      rooms.fold(0, (sum, room) => sum + room.availableBeds);
  int get occupiedBeds => rooms.fold(0, (sum, room) => sum + room.occupiedBeds);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'floorNumber': floorNumber,
      'rooms': rooms.map((r) => r.toJson()).toList(),
    };
  }

  factory Floor.fromJson(Map<String, dynamic> json) {
    return Floor(
      id: json['id'],
      floorNumber: json['floorNumber'],
      rooms: (json['rooms'] as List).map((r) => Room.fromJson(r)).toList(),
    );
  }
}
