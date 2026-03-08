import 'package:flutter/material.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Áttekintés',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          
          // 3 Fő metrika (Kártyák)
          Row(
            children: [
              _buildMetricCard(
                title: 'Folyamatban lévő projektek',
                value: '12',
                icon: Icons.engineering,
                color: Colors.blueAccent,
              ),
              const SizedBox(width: 16),
              _buildMetricCard(
                title: 'Számlázásra váró projektek',
                value: '4',
                icon: Icons.receipt_long,
                color: Colors.orange,
              ),
              const SizedBox(width: 16),
              _buildMetricCard(
                title: 'Aktív dolgozók ma',
                value: '8',
                icon: Icons.people,
                color: Colors.green,
              ),
            ],
          ),
          
          const SizedBox(height: 32),

          // Sürgős teendők szekció
          const Text(
            'Sürgős Teendők',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView(
                padding: const EdgeInsets.all(8.0),
                children: [
                  _buildUrgentTaskItem(
                    customerName: 'Kovács János',
                    taskDesc: 'AI e-mail piszkozat jóváhagyásra vár (Projekt elkészült)',
                    date: 'Ma, 10:30',
                  ),
                  const Divider(),
                  _buildUrgentTaskItem(
                    customerName: 'Tóth Kft.',
                    taskDesc: 'AI e-mail piszkozat jóváhagyásra vár (Anyagköltség egyeztetés)',
                    date: 'Ma, 09:15',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Segédfüggvény a metrika kártyákhoz
  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Segédfüggvény a teendőkhöz
  Widget _buildUrgentTaskItem({
    required String customerName,
    required String taskDesc,
    required String date,
  }) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: Colors.redAccent,
        child: Icon(Icons.warning_amber_rounded, color: Colors.white),
      ),
      title: Text(customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(taskDesc),
      trailing: Text(date, style: const TextStyle(color: Colors.grey)),
      onTap: () {
        // TODO: Megnyitni az AI e-mail szerkesztőt jóváhagyásra
      },
    );
  }
}
