import 'package:flutter/material.dart';

class ProjectsKanbanView extends StatelessWidget {
  const ProjectsKanbanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ügyfelek & Projektek',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildKanbanColumn('Folyamatban', Colors.blue, [
                  _buildProjectCard('Okoskert Építés', 'Kovács János', 'Jelenleg'),
                ]),
                const SizedBox(width: 16),
                _buildKanbanColumn('Kész', Colors.green, [
                  _buildProjectCard('Térkövezés', 'Szabó Éva', 'Befejezve'),
                ]),
                const SizedBox(width: 16),
                _buildKanbanColumn('Karbantartás', Colors.orange, [
                  _buildProjectCard('Tavaszi metszés', 'Kiss Péter', 'Éves'),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKanbanColumn(String title, Color color, List<Widget> cards) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
                  Text('${cards.length}', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                ],
              ),
            ),
            Expanded(
              child: ListView(padding: const EdgeInsets.all(12), children: cards),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCard(String projectName, String customerName, String status) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        title: Text(projectName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Ügyfél: $customerName\nStátusz: $status'),
        isThreeLine: true,
        onTap: () {
          // TODO: Részletes adatlap megnyitása
        },
      ),
    );
  }
}