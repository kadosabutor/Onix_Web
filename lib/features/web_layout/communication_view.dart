import 'package:flutter/material.dart';

class CommunicationView extends StatelessWidget {
  const CommunicationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kommunikációs Központ',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bal oldal: Belső Push Értesítések
                Expanded(
                  flex: 1,
                  child: _buildInternalPushSection(context),
                ),
                const SizedBox(width: 24),
                // Jobb oldal: AI E-mail Piszkozatok (Human-in-the-loop)
                Expanded(
                  flex: 2,
                  child: _buildAIEmailSection(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInternalPushSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.send_to_mobile, color: Colors.blueAccent),
                SizedBox(width: 8),
                Text('Belső Értesítés (Push)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Címzett (Pl. Mindenki a terepen)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Értesítés szövege',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: APNS / FCM push küldése
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
                child: const Text('Küldés a mobilokra'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIEmailSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.purpleAccent),
                SizedBox(width: 8),
                Text('AI E-mail Piszkozatok Jóváhagyása', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            const Text('A rendszer által generált ügyféllavelek. Kötelező ellenőrizni küldés előtt!', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildEmailDraftCard(
                    context,
                    'Kovács János',
                    'Projekt elkészült - Átadás egyeztetése',
                    'Tisztelt Kovács János!\n\nÖrömmel értesítjük, hogy az "Okoskert Építés" projekt a mai nappal befejeződött. Kérjük, jelezzen vissza, mikor lenne alkalmas a hivatalos átadás-átvétel!\n\nÜdvözlettel,\nOnix Csapat',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailDraftCard(BuildContext context, String client, String subject, String draftBody) {
    return Card(
      color: Colors.grey.shade50,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ügyfél: $client', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Tárgy: $subject', style: const TextStyle(fontStyle: FontStyle.italic)),
            const SizedBox(height: 12),
            TextField(
              maxLines: 6,
              controller: TextEditingController(text: draftBody),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {},
                  child: const Text('Elvetés', style: TextStyle(color: Colors.red)),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: E-mail küldése API-n keresztül
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Jóváhagyás és Küldés'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}