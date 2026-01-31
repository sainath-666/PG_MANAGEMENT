import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/room.dart';
import '../models/guest.dart';
import 'add_guest_screen.dart';

class GuestsScreen extends StatelessWidget {
  final Room room;

  const GuestsScreen({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Room ${room.roomNumber} - Guests',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: room.guests.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No guests in this room',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${room.availableBeds} bed${room.availableBeds != 1 ? 's' : ''} available',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: room.guests.length,
              itemBuilder: (context, index) {
                final guest = room.guests[index];
                return _buildGuestCard(context, guest);
              },
            ),
      floatingActionButton: room.availableBeds > 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddGuestScreen(initialRoom: room),
                  ),
                );
              },
              label: const Text('Add Guest'),
              icon: const Icon(Icons.add),
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }

  Widget _buildGuestCard(BuildContext context, Guest guest) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: guest.gender == 'Male'
                      ? Colors.blue.shade100
                      : guest.gender == 'Female'
                      ? Colors.pink.shade100
                      : Colors.purple.shade100,
                  child: Icon(
                    guest.gender == 'Male'
                        ? Icons.person
                        : guest.gender == 'Female'
                        ? Icons.person
                        : Icons.person_outline,
                    size: 32,
                    color: guest.gender == 'Male'
                        ? Colors.blue.shade700
                        : guest.gender == 'Female'
                        ? Colors.pink.shade700
                        : Colors.purple.shade700,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        guest.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            guest.gender == 'Male'
                                ? Icons.male
                                : guest.gender == 'Female'
                                ? Icons.female
                                : Icons.transgender,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            guest.gender,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.phone,
              label: 'Mobile',
              value: guest.mobileNumber,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: 'Join Date',
              value: dateFormat.format(guest.joinDate),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.credit_card,
              label: 'Aadhar',
              value: guest.aadharNumber,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.currency_rupee,
              label: 'Rent',
              value: '${guest.rentAmount.toStringAsFixed(0)}/month',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blue.shade700),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
