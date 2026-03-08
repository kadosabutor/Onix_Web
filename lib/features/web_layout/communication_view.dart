import 'package:flutter/material.dart';

class CommunicationView extends StatefulWidget {
  const CommunicationView({super.key});

  @override
  State<CommunicationView> createState() => _CommunicationViewState();
}

class _CommunicationViewState extends State<CommunicationView> {
  // Toggle állapota: true = Belső Push, false = Külső AI Email
  bool _isInternalView = true;
  String _selectedTarget = 'Minden munkatárs'; // Címzett választó állapota

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Kommunikációs Központ', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 24),
          
          // Kettősség és Kontraszt elve: Letisztult Toggle Button
          Center(
            child: Container(
              decoration: BoxDecoration(color: const Color(0xFF0D1117), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
              child: ToggleButtons(
                isSelected: [_isInternalView, !_isInternalView],
                onPressed: (index) {
                  setState(() { _isInternalView = index == 0; });
                },
                borderRadius: BorderRadius.circular(12),
                selectedColor: const Color(0xFF0D1117),
                fillColor: const Color(0xFF00D084),
                color: Colors.white54,
                textStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0),
                constraints: const BoxConstraints(minHeight: 48, minWidth: 150),
                children: const [
                  Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('BELSŐ (PUSH)')),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('KÜLSŐ (AI EMAIL)')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          Expanded(
            child: _isInternalView ? _buildInternalPushSection() : _buildAIEmailSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildInternalPushSection() {
    return Center(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: const Color(0xFF0D1117), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Azonnali Értesítés Küldése', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 24),
            
            const Text('Címzett kiválasztása:', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            // CÍMZETT VÁLASZTÓ DROPDOWN
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white24)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedTarget,
                  dropdownColor: const Color(0xFF161B22),
                  isExpanded: true,
                  style: const TextStyle(color: Colors.white),
                  items: <String>['Minden munkatárs', 'Csak terepi munkások', 'Kovács József (Sofőr)', 'Szabó Péter (Kertész)']
                      .map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
                  onChanged: (String? newValue) {
                    setState(() { _selectedTarget = newValue!; });
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            const TextField(
              maxLines: 4,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Üzenet szövege',
                labelStyle: TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Color(0xFF161B22),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF00D084))),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.send),
                label: const Text('Értesítés Kézbesítése', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0A3622), foregroundColor: const Color(0xFF00D084)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIEmailSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Jóváhagyásra váró AI piszkozatok', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            children: [
              _buildEmailDraftCard('Kovács János', 'Projekt elkészült', 'Tisztelt Kovács János!\n\nAz "Okoskert Építés" befejeződött. Kérjük, jelezzen vissza.\n\nÜdvözlettel,\nOnix AI'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmailDraftCard(String client, String subject, String draftBody) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFF0D1117), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ügyfél: $client', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00D084), fontSize: 18)),
              const Chip(label: Text('AI Generált', style: TextStyle(color: Colors.black, fontSize: 10)), backgroundColor: Colors.amber),
            ],
          ),
          const SizedBox(height: 8),
          Text('Tárgy: $subject', style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.white70)),
          const SizedBox(height: 16),
          TextField(
            maxLines: 5,
            controller: TextEditingController(text: draftBody),
            style: const TextStyle(color: Colors.white, height: 1.5),
            decoration: const InputDecoration(border: OutlineInputBorder(), filled: true, fillColor: Color(0xFF161B22)),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: () {}, child: const Text('Elvetés', style: TextStyle(color: Colors.redAccent))),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.check),
                label: const Text('Jóváhagyás és Küldés'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D084), foregroundColor: Colors.black),
              ),
            ],
          )
        ],
      ),
    );
  }
}