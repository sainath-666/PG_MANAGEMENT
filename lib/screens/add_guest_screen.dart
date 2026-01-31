import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/data_service.dart';
import '../models/guest.dart';
import '../models/floor.dart';
import '../models/room.dart';

class AddGuestScreen extends StatefulWidget {
  final Room? initialRoom;
  final Guest? guestToEdit;

  const AddGuestScreen({super.key, this.initialRoom, this.guestToEdit});

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
  DateTime _joinDate = DateTime.now();
  bool _isPaid = false;
  DateTime? _paidDate;

  List<Room> _availableRooms = [];
  bool get _isEditMode => widget.guestToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _prefillEditData();
    } else if (widget.initialRoom != null) {
      _prefillData();
    }
  }

  void _prefillEditData() {
    final guest = widget.guestToEdit!;
    _nameController.text = guest.name;
    _mobileController.text = guest.mobileNumber;
    _aadharController.text = guest.aadharNumber;
    _rentController.text = guest.rentAmount.toString();
    _selectedGender = guest.gender;
    _joinDate = guest.joinDate;
    _isPaid = guest.isPaid;
    _paidDate = guest.paidDate;

    final floor = _dataService.getFloorById(guest.floorId);
    if (floor != null) {
      _selectedFloor = floor;
      _availableRooms = _dataService.getAvailableRoomsByFloor(floor.id);

      // Find the current room even if it's full
      final currentRoom = _dataService.getRoomById(guest.roomId);
      if (currentRoom != null && !_availableRooms.contains(currentRoom)) {
        _availableRooms.add(currentRoom);
      }
      _selectedRoom = _availableRooms.firstWhere(
        (r) => r.id == guest.roomId,
        orElse: () => _availableRooms.first,
      );
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

  Future<void> _selectJoinDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _joinDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.teal.shade600,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _joinDate) {
      setState(() {
        _joinDate = picked;
      });
    }
  }

  Future<void> _selectPaidDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _paidDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.teal.shade600,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _paidDate = picked;
      });
    }
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

      if (_isEditMode) {
        // Update existing guest
        final updatedGuest = Guest(
          id: widget.guestToEdit!.id,
          name: _nameController.text,
          gender: _selectedGender!,
          mobileNumber: _mobileController.text,
          joinDate: _joinDate,
          floorId: _selectedFloor!.id,
          roomId: _selectedRoom!.id,
          aadharNumber: _aadharController.text,
          rentAmount: double.parse(_rentController.text),
          isPaid: _isPaid,
          paidDate: _isPaid ? _paidDate : null,
        );

        // Update guest in data service
        _dataService.updateGuest(updatedGuest);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${updatedGuest.name} updated successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Go back
        Navigator.pop(context);
      } else {
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
          isPaid: _isPaid,
          paidDate: _isPaid ? _paidDate : null,
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

        // Clear form
        _nameController.clear();
        _mobileController.clear();
        _aadharController.clear();
        _rentController.clear();
        setState(() {
          _selectedGender = null;
          _selectedFloor = null;
          _selectedRoom = null;
          _availableRooms = [];
          _isPaid = false;
          _paidDate = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          // Modern Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade600, Colors.teal.shade800],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.3),
                            Colors.white.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _isEditMode
                            ? Icons.edit_rounded
                            : Icons.person_add_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isEditMode ? 'Edit Guest' : 'Add New Guest',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isEditMode
                                ? 'Update guest information'
                                : 'Register guest information',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Scrollable Form Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Personal Information Section
                    _buildSectionHeader(
                      'Personal Information',
                      Icons.person_rounded,
                    ),
                    const SizedBox(height: 16),
                    _buildModernTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      hint: 'Enter guest full name',
                      icon: Icons.person_outline_rounded,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildGenderSelector(),
                    const SizedBox(height: 16),
                    _buildModernTextField(
                      controller: _mobileController,
                      label: 'Mobile Number',
                      hint: 'Enter 10-digit number',
                      icon: Icons.phone_rounded,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
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
                    const SizedBox(height: 24),

                    // Room Assignment Section
                    _buildSectionHeader(
                      'Room Assignment',
                      Icons.meeting_room_rounded,
                    ),
                    const SizedBox(height: 16),
                    _buildJoinDateCard(),
                    const SizedBox(height: 16),
                    _buildModernDropdown<Floor>(
                      value: _selectedFloor,
                      label: 'Select Floor',
                      hint: 'Choose floor',
                      icon: Icons.layers_rounded,
                      items: _dataService.floors,
                      itemBuilder: (floor) => 'Floor ${floor.floorNumber}',
                      onChanged: _onFloorChanged,
                    ),
                    const SizedBox(height: 16),
                    _buildModernDropdown<Room>(
                      value: _selectedRoom,
                      label: 'Select Room',
                      hint: _selectedFloor == null
                          ? 'Select floor first'
                          : _availableRooms.isEmpty
                          ? 'No available rooms'
                          : 'Choose room',
                      icon: Icons.meeting_room_outlined,
                      items: _availableRooms,
                      itemBuilder: (room) =>
                          'Room ${room.roomNumber} (${room.availableBeds} bed${room.availableBeds != 1 ? 's' : ''} available)',
                      onChanged: _selectedFloor == null
                          ? null
                          : (value) {
                              setState(() {
                                _selectedRoom = value;
                              });
                            },
                    ),
                    const SizedBox(height: 24),

                    // Additional Information Section
                    _buildSectionHeader(
                      'Additional Information',
                      Icons.description_rounded,
                    ),
                    const SizedBox(height: 16),
                    _buildModernTextField(
                      controller: _aadharController,
                      label: 'Aadhar Number',
                      hint: 'Enter 12-digit Aadhar',
                      icon: Icons.credit_card_rounded,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(12),
                      ],
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
                    const SizedBox(height: 16),
                    _buildModernTextField(
                      controller: _rentController,
                      label: 'Monthly Rent',
                      hint: 'Enter rent amount',
                      icon: Icons.currency_rupee_rounded,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter rent amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Payment Status Section
                    _buildSectionHeader(
                      'Payment Status',
                      Icons.payment_rounded,
                    ),
                    const SizedBox(height: 16),
                    _buildPaymentStatusToggle(),
                    if (_isPaid) ...[
                      const SizedBox(height: 16),
                      _buildPaidDateCard(),
                    ],
                    const SizedBox(height: 32),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _nameController.clear();
                              _mobileController.clear();
                              _aadharController.clear();
                              _rentController.clear();
                              setState(() {
                                _selectedGender = null;
                                _selectedFloor = null;
                                _selectedRoom = null;
                                _availableRooms = [];
                                _isPaid = false;
                                _paidDate = null;
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(
                                color: Colors.grey.shade400,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Clear',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _isEditMode
                                      ? Icons.save_rounded
                                      : Icons.check_circle_rounded,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _isEditMode ? 'Update Guest' : 'Add Guest',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.teal.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.teal.shade700, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: Icon(icon, color: Colors.teal.shade600),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildGenderOption('Male', Icons.male_rounded)),
            const SizedBox(width: 12),
            Expanded(child: _buildGenderOption('Female', Icons.female_rounded)),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGenderOption('Other', Icons.transgender_rounded),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption(String gender, IconData icon) {
    final isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = gender;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal.shade600 : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? Colors.teal.shade600 : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.teal.shade200,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade600,
              size: 28,
            ),
            const SizedBox(height: 6),
            Text(
              gender,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinDateCard() {
    final isToday =
        _joinDate.year == DateTime.now().year &&
        _joinDate.month == DateTime.now().month &&
        _joinDate.day == DateTime.now().day;

    return GestureDetector(
      onTap: () => _selectJoinDate(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade50, Colors.teal.shade100],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.teal.shade200, width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.teal.shade600,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.calendar_today_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Join Date',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.teal.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_joinDate.day}/${_joinDate.month}/${_joinDate.year}${isToday ? ' (Today)' : ''}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade900,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.edit_calendar_rounded,
              color: Colors.teal.shade600,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernDropdown<T>({
    required T? value,
    required String label,
    required String hint,
    required IconData icon,
    required List<T> items,
    required String Function(T) itemBuilder,
    required void Function(T?)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<T>(
            value: value,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: Icon(icon, color: Colors.teal.shade600),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            items: items.map((item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Text(
                  itemBuilder(item),
                  style: const TextStyle(fontSize: 15),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentStatusToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            setState(() {
              _isPaid = !_isPaid;
              if (!_isPaid) {
                _paidDate = null;
              } else if (_paidDate == null) {
                _paidDate = DateTime.now();
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _isPaid ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _isPaid ? Icons.check_circle_rounded : Icons.cancel_rounded,
                    color: _isPaid
                        ? Colors.green.shade600
                        : Colors.red.shade600,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Status',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _isPaid ? 'Payed' : 'Unpayed',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _isPaid
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isPaid,
                  onChanged: (value) {
                    setState(() {
                      _isPaid = value;
                      if (!_isPaid) {
                        _paidDate = null;
                      } else if (_paidDate == null) {
                        _paidDate = DateTime.now();
                      }
                    });
                  },
                  activeColor: Colors.green.shade600,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaidDateCard() {
    return GestureDetector(
      onTap: () => _selectPaidDate(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade50, Colors.green.shade100],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.green.shade200, width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.shade600,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.event_available_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Date',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _paidDate != null
                        ? '${_paidDate!.day}/${_paidDate!.month}/${_paidDate!.year}'
                        : 'Select payment date',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade900,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.edit_calendar_rounded,
              color: Colors.green.shade600,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
