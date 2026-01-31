import '../models/floor.dart';
import '../models/room.dart';
import '../models/guest.dart';

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  final List<Floor> _floors = [];

  List<Floor> get floors => _floors;

  int get totalFloors => _floors.length;
  int get totalRooms => _floors.fold(0, (sum, floor) => sum + floor.totalRooms);
  int get totalBeds => _floors.fold(0, (sum, floor) => sum + floor.totalBeds);
  int get availableRooms =>
      _floors.fold(0, (sum, floor) => sum + floor.availableRooms);
  int get availableBeds =>
      _floors.fold(0, (sum, floor) => sum + floor.availableBeds);
  int get occupiedBeds =>
      _floors.fold(0, (sum, floor) => sum + floor.occupiedBeds);

  // Payment status getters
  int get totalGuests {
    int count = 0;
    for (var floor in _floors) {
      for (var room in floor.rooms) {
        count += room.guests.length;
      }
    }
    return count;
  }

  int get paidGuests {
    int count = 0;
    for (var floor in _floors) {
      for (var room in floor.rooms) {
        count += room.guests.where((guest) => guest.isPaid).length;
      }
    }
    return count;
  }

  int get unpaidGuests {
    int count = 0;
    for (var floor in _floors) {
      for (var room in floor.rooms) {
        count += room.guests.where((guest) => !guest.isPaid).length;
      }
    }
    return count;
  }

  void initializeMockData() {
    _floors.clear();

    // Floor 1
    _floors.add(
      Floor(
        id: 'f1',
        floorNumber: 1,
        rooms: [
          Room(
            id: 'r101',
            roomNumber: '101',
            floorId: 'f1',
            totalBeds: 3,
            guests: [
              Guest(
                id: 'g1',
                name: 'Rajesh Kumar',
                gender: 'Male',
                mobileNumber: '9876543210',
                joinDate: DateTime(2025, 10, 15),
                floorId: 'f1',
                roomId: 'r101',
                aadharNumber: '1234 5678 9012',
                rentAmount: 5000,
                isPaid: true,
                paidDate: DateTime(2026, 1, 25),
              ),
              Guest(
                id: 'g2',
                name: 'Amit Sharma',
                gender: 'Male',
                mobileNumber: '9876543211',
                joinDate: DateTime(2025, 11, 1),
                floorId: 'f1',
                roomId: 'r101',
                aadharNumber: '1234 5678 9013',
                rentAmount: 5000,
                isPaid: false,
              ),
            ],
          ),
          Room(
            id: 'r102',
            roomNumber: '102',
            floorId: 'f1',
            totalBeds: 4,
            guests: [
              Guest(
                id: 'g3',
                name: 'Priya Singh',
                gender: 'Female',
                mobileNumber: '9876543212',
                joinDate: DateTime(2025, 12, 10),
                floorId: 'f1',
                roomId: 'r102',
                aadharNumber: '1234 5678 9014',
                rentAmount: 5500,
                isPaid: true,
                paidDate: DateTime(2026, 1, 28),
              ),
            ],
          ),
          Room(
            id: 'r103',
            roomNumber: '103',
            floorId: 'f1',
            totalBeds: 3,
            guests: [
              Guest(
                id: 'g4',
                name: 'Suresh Reddy',
                gender: 'Male',
                mobileNumber: '9876543213',
                joinDate: DateTime(2026, 1, 5),
                floorId: 'f1',
                roomId: 'r103',
                aadharNumber: '1234 5678 9015',
                rentAmount: 4800,
                isPaid: false,
              ),
              Guest(
                id: 'g5',
                name: 'Vikram Patel',
                gender: 'Male',
                mobileNumber: '9876543214',
                joinDate: DateTime(2026, 1, 15),
                floorId: 'f1',
                roomId: 'r103',
                aadharNumber: '1234 5678 9016',
                rentAmount: 4800,
                isPaid: true,
                paidDate: DateTime(2026, 1, 30),
              ),
            ],
          ),
          Room(
            id: 'r104',
            roomNumber: '104',
            floorId: 'f1',
            totalBeds: 2,
            guests: [],
          ),
        ],
      ),
    );

    // Floor 2
    _floors.add(
      Floor(
        id: 'f2',
        floorNumber: 2,
        rooms: [
          Room(
            id: 'r201',
            roomNumber: '201',
            floorId: 'f2',
            totalBeds: 3,
            guests: [
              Guest(
                id: 'g6',
                name: 'Anjali Mehta',
                gender: 'Female',
                mobileNumber: '9876543215',
                joinDate: DateTime(2025, 11, 20),
                floorId: 'f2',
                roomId: 'r201',
                aadharNumber: '1234 5678 9017',
                rentAmount: 5200,
                isPaid: true,
                paidDate: DateTime(2026, 1, 20),
              ),
              Guest(
                id: 'g7',
                name: 'Sneha Gupta',
                gender: 'Female',
                mobileNumber: '9876543216',
                joinDate: DateTime(2025, 12, 5),
                floorId: 'f2',
                roomId: 'r201',
                aadharNumber: '1234 5678 9018',
                rentAmount: 5200,
                isPaid: false,
              ),
              Guest(
                id: 'g8',
                name: 'Kavita Rao',
                gender: 'Female',
                mobileNumber: '9876543217',
                joinDate: DateTime(2026, 1, 10),
                floorId: 'f2',
                roomId: 'r201',
                aadharNumber: '1234 5678 9019',
                rentAmount: 5200,
                isPaid: true,
                paidDate: DateTime(2026, 1, 27),
              ),
            ],
          ),
          Room(
            id: 'r202',
            roomNumber: '202',
            floorId: 'f2',
            totalBeds: 4,
            guests: [
              Guest(
                id: 'g9',
                name: 'Rahul Verma',
                gender: 'Male',
                mobileNumber: '9876543218',
                joinDate: DateTime(2025, 10, 25),
                floorId: 'f2',
                roomId: 'r202',
                aadharNumber: '1234 5678 9020',
                rentAmount: 5500,
                isPaid: true,
                paidDate: DateTime(2026, 1, 22),
              ),
              Guest(
                id: 'g10',
                name: 'Anil Kumar',
                gender: 'Male',
                mobileNumber: '9876543219',
                joinDate: DateTime(2025, 11, 15),
                floorId: 'f2',
                roomId: 'r202',
                aadharNumber: '1234 5678 9021',
                rentAmount: 5500,
                isPaid: false,
              ),
            ],
          ),
          Room(
            id: 'r203',
            roomNumber: '203',
            floorId: 'f2',
            totalBeds: 3,
            guests: [
              Guest(
                id: 'g11',
                name: 'Deepak Joshi',
                gender: 'Male',
                mobileNumber: '9876543220',
                joinDate: DateTime(2026, 1, 1),
                floorId: 'f2',
                roomId: 'r203',
                aadharNumber: '1234 5678 9022',
                rentAmount: 4900,
                isPaid: false,
              ),
            ],
          ),
          Room(
            id: 'r204',
            roomNumber: '204',
            floorId: 'f2',
            totalBeds: 2,
            guests: [],
          ),
        ],
      ),
    );

    // Floor 3
    _floors.add(
      Floor(
        id: 'f3',
        floorNumber: 3,
        rooms: [
          Room(
            id: 'r301',
            roomNumber: '301',
            floorId: 'f3',
            totalBeds: 4,
            guests: [
              Guest(
                id: 'g12',
                name: 'Manish Desai',
                gender: 'Male',
                mobileNumber: '9876543221',
                joinDate: DateTime(2025, 12, 1),
                floorId: 'f3',
                roomId: 'r301',
                aadharNumber: '1234 5678 9023',
                rentAmount: 5300,
                isPaid: true,
                paidDate: DateTime(2026, 1, 15),
              ),
              Guest(
                id: 'g13',
                name: 'Sanjay Nair',
                gender: 'Male',
                mobileNumber: '9876543222',
                joinDate: DateTime(2025, 12, 15),
                floorId: 'f3',
                roomId: 'r301',
                aadharNumber: '1234 5678 9024',
                rentAmount: 5300,
                isPaid: true,
                paidDate: DateTime(2026, 1, 18),
              ),
            ],
          ),
          Room(
            id: 'r302',
            roomNumber: '302',
            floorId: 'f3',
            totalBeds: 3,
            guests: [
              Guest(
                id: 'g14',
                name: 'Pooja Iyer',
                gender: 'Female',
                mobileNumber: '9876543223',
                joinDate: DateTime(2026, 1, 8),
                floorId: 'f3',
                roomId: 'r302',
                aadharNumber: '1234 5678 9025',
                rentAmount: 5100,
                isPaid: false,
              ),
            ],
          ),
          Room(
            id: 'r303',
            roomNumber: '303',
            floorId: 'f3',
            totalBeds: 3,
            guests: [],
          ),
          Room(
            id: 'r304',
            roomNumber: '304',
            floorId: 'f3',
            totalBeds: 2,
            guests: [],
          ),
        ],
      ),
    );
  }

  void addGuest(Guest guest) {
    for (var floor in _floors) {
      for (var room in floor.rooms) {
        if (room.id == guest.roomId) {
          room.guests.add(guest);
          return;
        }
      }
    }
  }

  Floor? getFloorById(String floorId) {
    try {
      return _floors.firstWhere((floor) => floor.id == floorId);
    } catch (e) {
      return null;
    }
  }

  Room? getRoomById(String roomId) {
    for (var floor in _floors) {
      for (var room in floor.rooms) {
        if (room.id == roomId) {
          return room;
        }
      }
    }
    return null;
  }

  List<Room> getAvailableRoomsByFloor(String floorId) {
    final floor = getFloorById(floorId);
    if (floor == null) return [];
    return floor.rooms.where((room) => room.hasAvailability).toList();
  }
}
