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
                Expanded(flex: 1, child: _buildInternalPushSection()),
                const SizedBox(width: 24),
                Expanded(flex: 2, child: _buildAIEmailSection()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInternalPushSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Belső Értesítés (Push)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(labelText: 'Címzett (Pl. Terepesek)', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            const TextField(maxLines: 4, decoration: InputDecoration(labelText: 'Üzenet', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
                child: const Text('Küldés a mobilokra'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIEmailSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AI E-mail Piszkozatok Jóváhagyása', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Kötelező ellenőrizni küldés előtt!', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildEmailDraftCard(
                    'Kovács János',
                    'Projekt elkészült',
                    'Tisztelt Kovács János!\n\nAz "Okoskert Építés" befejeződött. Kérjük, jelezzen vissza az átadással kapcsolatban.\n\nÜdvözlettel,\nOnix Csapat',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailDraftCard(String client, String subject, String draftBody) {
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
              maxLines: 5,
              controller: TextEditingController(text: draftBody),
              decoration: const InputDecoration(border: OutlineInputBorder(), filled: true, fillColor: Colors.white),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () {}, child: const Text('Elvetés', style: TextStyle(color: Colors.red))),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.check),
                  label: const Text('Jóváhagyás és Küldés'), // Pontosítva a specifikáció szerint
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