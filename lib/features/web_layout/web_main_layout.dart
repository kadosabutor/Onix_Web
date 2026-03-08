import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// --- EZEK AZ IMPORTOK KELLEMEK A PIROS ALÁHÚZÁS ELTÜNTETÉSÉHEZ ---
import 'dashboard_view.dart';
import 'projects_kanban_view.dart';
import 'finance_export_view.dart';
import 'communication_view.dart';
// ----------------------------------------------------------------

class WebMainLayout extends StatefulWidget {
  const WebMainLayout({super.key});

  @override
  State<WebMainLayout> createState() => _WebMainLayoutState();
}

class _WebMainLayoutState extends State<WebMainLayout> {
  int _selectedIndex = 0;

  // Az aloldalak listája a specifikáció alapján
  final List<Widget> _pages = [
    const DashboardView(),
    const ProjectsKanbanView(),
    const FinanceExportView(),
    const CommunicationView(),
    const Center(child: Text('Csapat nézet (Későbbi fejlesztés)', style: TextStyle(fontSize: 24))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Bal oldali menüsáv
          Container(
            width: 250,
            color: const Color(0xFF1E1E2C),
            child: Column(
              children: [
                // Logó
                Container(
                  padding: const EdgeInsets.all(24.0),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.business, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Onix',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Menüpontok
                _buildNavItem(Icons.dashboard, 'Vezérlőpult', 0),
                _buildNavItem(Icons.view_kanban, 'Ügyfelek & Projektek', 1),
                _buildNavItem(Icons.attach_money, 'Pénzügy / Számlázás', 2),
                _buildNavItem(Icons.chat, 'Kommunikáció', 3),
                _buildNavItem(Icons.group, 'Csapat', 4),

                const Spacer(),

                // Felhasználó (RBAC: Irodai alkalmazott) és Kijelentkezés
                const Divider(color: Colors.white24, height: 1),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: const Text(
                    'Irodai Alkalmazott',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white54),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Jobb oldali fő terület
          Expanded(
            child: Column(
              children: [
                // Felső keresősáv
                Container(
                  height: 64,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Keresés projektek vagy ügyfelek között...',
                            prefixIcon: const Icon(Icons.search, color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding: const EdgeInsets.symmetric(vertical: 0),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined, color: Colors.grey),
                            onPressed: () {},
                          ),
                          Positioned(
                            right: 12,
                            top: 12,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Dinamikus tartalom (A kiválasztott oldal)
                Expanded(
                  child: Container(
                    color: Colors.grey[100],
                    child: _pages[_selectedIndex],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // AI Asszisztens Gomb
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        tooltip: 'AI Asszisztens',
        child: const Icon(Icons.auto_awesome),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String title, int index) {
    final isActive = _selectedIndex == index;
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: isActive ? Colors.white : Colors.white54),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white54,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        tileColor: isActive ? Colors.white.withValues(alpha: 0.1) : null,
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}