import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/data_service.dart';
import '../models/guest.dart';
import '../models/floor.dart';
import '../models/room.dart';

class AddGuestScreen extends StatefulWidget {
  final Room? initialRoom;

  const AddGuestScreen({super.key, this.initialRoom});

  @override
  State<AddGuestScreen> createState() => _AddGuestScreenState();
}

class _AddGuestScreenState extends State<AddGuestScreen> {
  final _formKey = GlobalKey<FormState>();
  final DataService _dataService = DataService();

  // Form controllers
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _aadharController = TextEditingController();
  final _rentController = TextEditingController();

  // Form values
  String? _selectedGender;
  Floor? _selectedFloor;
  Room? _selectedRoom;
  final DateTime _joinDate = DateTime.now();

  List<Room> _availableRooms = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialRoom != null) {
      _prefillData();
    }
  }

  void _prefillData() {
    final floor = _dataService.getFloorById(widget.initialRoom!.floorId);
    if (floor != null) {
      _selectedFloor = floor;
      _availableRooms = _dataService.getAvailableRoomsByFloor(floor.id);

      // Find the room in available rooms that matches the initial room
      // We need to find the matching object reference or ID match from the available list
      try {
        _selectedRoom = _availableRooms.firstWhere(
          (r) => r.id == widget.initialRoom!.id,
        );
      } catch (e) {
        // If the room is not available (full), it won't be in the list, so we can't select it
        _selectedRoom = null;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _aadharController.dispose();
    _rentController.dispose();
    super.dispose();
  }

  void _onFloorChanged(Floor? floor) {
    setState(() {
      _selectedFloor = floor;
      _selectedRoom = null;
      _availableRooms = floor != null
          ? _dataService.getAvailableRoomsByFloor(floor.id)
          : [];
    });
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedGender == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select gender'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_selectedFloor == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select floor'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_selectedRoom == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select room'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Create new guest
      final newGuest = Guest(
        id: 'g${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text,
        gender: _selectedGender!,
        mobileNumber: _mobileController.text,
        joinDate: _joinDate,
        floorId: _selectedFloor!.id,
        roomId: _selectedRoom!.id,
        aadharNumber: _aadharController.text,
        rentAmount: double.parse(_rentController.text),
      );

      // Add guest to data service
      _dataService.addGuest(newGuest);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Guest ${newGuest.name} added successfully!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // Navigate back
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add New Guest',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Fill in the details to register a new guest',
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Name Field
              const Text(
                'Name *',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter full name',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Gender Field
              const Text(
                'Gender *',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: InputDecoration(
                  hintText: 'Select gender',
                  prefixIcon: const Icon(Icons.wc),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Mobile Number Field
              const Text(
                'Mobile Number *',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: InputDecoration(
                  hintText: 'Enter 10-digit mobile number',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter mobile number';
                  }
                  if (value.length != 10) {
                    return 'Mobile number must be 10 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Join Date Display (Auto-selected as today)
              const Text(
                'Join Date',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.grey),
                    const SizedBox(width: 12),
                    Text(
                      '${_joinDate.day}/${_joinDate.month}/${_joinDate.year} (Today)',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Floor Selection
              const Text(
                'Floor *',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<Floor>(
                value: _selectedFloor,
                decoration: InputDecoration(
                  hintText: 'Select floor',
                  prefixIcon: const Icon(Icons.layers),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _dataService.floors.map((floor) {
                  return DropdownMenuItem(
                    value: floor,
                    child: Text('Floor ${floor.floorNumber}'),
                  );
                }).toList(),
                onChanged: _onFloorChanged,
              ),
              const SizedBox(height: 20),

              // Room Selection
              const Text(
                'Room *',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<Room>(
                value: _selectedRoom,
                decoration: InputDecoration(
                  hintText: _selectedFloor == null
                      ? 'Select floor first'
                      : _availableRooms.isEmpty
                      ? 'No available rooms'
                      : 'Select room',
                  prefixIcon: const Icon(Icons.meeting_room),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _availableRooms.map((room) {
                  return DropdownMenuItem(
                    value: room,
                    child: Text(
                      'Room ${room.roomNumber} (${room.availableBeds} bed${room.availableBeds != 1 ? 's' : ''} available)',
                    ),
                  );
                }).toList(),
                onChanged: _selectedFloor == null
                    ? null
                    : (value) {
                        setState(() {
                          _selectedRoom = value;
                        });
                      },
              ),
              const SizedBox(height: 20),

              // Aadhar Number Field
              const Text(
                'Aadhar Number *',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _aadharController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(12),
                ],
                decoration: InputDecoration(
                  hintText: 'Enter 12-digit Aadhar number',
                  prefixIcon: const Icon(Icons.credit_card),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Aadhar number';
                  }
                  if (value.length != 12) {
                    return 'Aadhar number must be 12 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Rent Amount Field
              const Text(
                'Rent Amount *',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _rentController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: 'Enter monthly rent',
                  prefixIcon: const Icon(Icons.currency_rupee),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter rent amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
