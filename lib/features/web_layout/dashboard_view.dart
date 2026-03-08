import 'package:flutter/material.dart';
import '../../app/app_theme.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  final bool _hasError = true; 

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Áttekintés',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 24),
          
          if (_hasError)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: OnixColors.errorRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: OnixColors.errorRed.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.sync_problem, color: OnixColors.errorRed),
                  SizedBox(width: 12),
                  Text(
                    'Adatok szinkronizálása folyamatban...',
                    style: TextStyle(color: OnixColors.errorRed, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            )
          else
            Row(
              children: [
                _buildMetricCard('Folyamatban lévő projektek száma', '12', Icons.engineering, Colors.blueAccent),
                const SizedBox(width: 16),
                _buildMetricCard('Számlázásra váró projektek száma', '4', Icons.receipt_long, Colors.orange),
                const SizedBox(width: 16),
                _buildMetricCard('Aktív dolgozók a mai napon', '8', Icons.people, OnixColors.cyberMint),
              ],
            ),
          
          const SizedBox(height: 32),

          Text(
            'Sürgős Teendők',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              elevation: 0,
              color: OnixColors.darkSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.white12),
              ),
              child: ListView(
                padding: const EdgeInsets.all(8.0),
                children: [
                  _buildUrgentTaskItem('Kovács János', 'AI e-mail piszkozat jóváhagyásra vár (Projekt elkészült)'),
                  const Divider(color: Colors.white12),
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
        elevation: 0,
        color: OnixColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.white12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 14, color: OnixColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: OnixColors.pureWhite)),
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
        backgroundColor: OnixColors.errorRed,
        child: Icon(Icons.warning_amber_rounded, color: OnixColors.pureWhite),
      ),
      title: Text(customerName, style: const TextStyle(fontWeight: FontWeight.bold, color: OnixColors.pureWhite)),
      subtitle: Text(taskDesc, style: const TextStyle(color: OnixColors.textSecondary)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: OnixColors.textSecondary),
    );
  }
}