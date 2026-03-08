import 'package:flutter/material.dart';

class FinanceExportView extends StatelessWidget {
  const FinanceExportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pénzügy és Számlázás',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Riport generálása és letöltése folyamatban...'), backgroundColor: Colors.green),
                  );
                },
                icon: const Icon(Icons.download),
                label: const Text('Riport Generálása'), // Javítva a specifikáció szerint
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Kész (Számlázásra váró) projektek listája', style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 16),
          
          Expanded(
            child: Card(
              elevation: 2,
              child: ListView(
                children: [
                  _buildFinanceRow('Térkövezés és füvesítés', 'Szabó Éva', '245 000 Ft', '120 000 Ft'),
                  const Divider(height: 1),
                  _buildFinanceRow('Okosöntöző kiépítése', 'Kovács Kft.', '180 000 Ft', '90 000 Ft'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceRow(String project, String client, String materialCost, String laborCost) {
    return ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: const CircleAvatar(backgroundColor: Colors.greenAccent, child: Icon(Icons.check, color: Colors.white)),
      title: Text(project, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('Ügyfél: $client'),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('Anyagköltség: $materialCost', style: const TextStyle(color: Colors.redAccent)),
          Text('Munkadíj: $laborCost', style: const TextStyle(color: Colors.blueAccent)),
        ],
      ),
    );
  }
}