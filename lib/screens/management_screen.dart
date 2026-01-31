import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../models/floor.dart';
import 'rooms_screen.dart';

class ManagementScreen extends StatefulWidget {
  const ManagementScreen({super.key});

  @override
  State<ManagementScreen> createState() => _ManagementScreenState();
}

class _ManagementScreenState extends State<ManagementScreen> {
  final DataService _dataService = DataService();

  @override
  Widget build(BuildContext context) {
    final floors = _dataService.floors;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: floors.isEmpty
          ? const Center(child: Text('No floors available'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: floors.length,
              itemBuilder: (context, index) {
                final floor = floors[index];
                return _buildFloorCard(floor);
              },
            ),
    );
  }

  Widget _buildFloorCard(Floor floor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RoomsScreen(floor: floor)),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.layers,
                      color: Colors.blue.shade700,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Floor ${floor.floorNumber}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${floor.totalRooms} Rooms',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    icon: Icons.bed,
                    label: 'Total Beds',
                    value: floor.totalBeds.toString(),
                    color: Colors.orange,
                  ),
                  _buildStatItem(
                    icon: Icons.check_circle,
                    label: 'Available',
                    value: floor.availableBeds.toString(),
                    color: Colors.green,
                  ),
                  _buildStatItem(
                    icon: Icons.person,
                    label: 'Occupied',
                    value: floor.occupiedBeds.toString(),
                    color: Colors.red,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
