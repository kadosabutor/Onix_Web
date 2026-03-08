import 'package:flutter/material.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  // Szimuláljuk, hogy hiba történt az adatok lekérésekor a specifikáció szerint
  final bool _hasError = true; 

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
          
          // 3 Fő metrika vagy Hibaüzenet
          if (_hasError)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.sync_problem, color: Colors.orange),
                  SizedBox(width: 12),
                  Text(
                    'Adatok szinkronizálása folyamatban...',
                    style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            )
          else
            Row(
              children: [
                _buildMetricCard('Folyamatban lévő projektek', '12', Icons.engineering, Colors.blueAccent),
                const SizedBox(width: 16),
                _buildMetricCard('Számlázásra váró projektek', '4', Icons.receipt_long, Colors.orange),
                const SizedBox(width: 16),
                _buildMetricCard('Aktív dolgozók ma', '8', Icons.people, Colors.green),
              ],
            ),
          
          const SizedBox(height: 32),

          // Sürgős teendők szekció
          const Text(
            'Sürgős Teendők (AI)',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListView(
                padding: const EdgeInsets.all(8.0),
                children: [
                  _buildUrgentTaskItem('Kovács János', 'AI e-mail piszkozat jóváhagyásra vár (Projekt elkészült)'),
                  const Divider(),
                  _buildUrgentTaskItem('Tóth Kft.', 'AI e-mail piszkozat jóváhagyásra vár (Anyagköltség egyeztetés)'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
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
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUrgentTaskItem(String customerName, String taskDesc) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: Colors.redAccent,
        child: Icon(Icons.warning_amber_rounded, color: Colors.white),
      ),
      title: Text(customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(taskDesc),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
    );
  }
}