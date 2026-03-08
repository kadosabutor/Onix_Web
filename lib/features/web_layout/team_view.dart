import 'package:flutter/material.dart';

class TeamView extends StatelessWidget {
  const TeamView({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock adatok a csapathoz
    final List<Map<String, dynamic>> teamMembers = [
      {'name': 'Zeck Krisztián', 'role': 'Tulajdonos (Admin)', 'status': 'Aktív', 'color': Colors.amber},
      {'name': 'Kovács József', 'role': 'Terepi Munkás', 'status': 'Terepen', 'color': const Color(0xFF00D084)},
      {'name': 'Nagy Anna', 'role': 'Irodai Alkalmazott', 'status': 'Irodában', 'color': Colors.blue},
      {'name': 'Szabó Péter', 'role': 'Terepi Munkás', 'status': 'Szabadságon', 'color': Colors.grey},
    ];

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Csapat & Dolgozók', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.person_add),
                label: const Text('Új munkatárs'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0A3622), foregroundColor: const Color(0xFF00D084)),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 3 oszlop a gridben
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: 2.5,
              ),
              itemCount: teamMembers.length,
              itemBuilder: (context, index) {
                final member = teamMembers[index];
                return Card(
                  color: const Color(0xFF0D1117),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Colors.white12)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: const Color(0xFF161B22),
                          child: Text(member['name'].substring(0, 1), style: const TextStyle(color: Colors.white, fontSize: 24)),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(member['name'], style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(member['role'], style: const TextStyle(color: Colors.white54, fontSize: 14)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: member['color'].withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                          child: Text(member['status'], style: TextStyle(color: member['color'], fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}