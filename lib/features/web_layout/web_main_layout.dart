import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dashboard_view.dart'; // Importáljuk az új nézetet

class WebMainLayout extends StatefulWidget {
  const WebMainLayout({super.key});

  @override
  State<WebMainLayout> createState() => _WebMainLayoutState();
}

class _WebMainLayoutState extends State<WebMainLayout> {
  // Ez a változó tárolja, melyik menüpont van kiválasztva
  int _selectedIndex = 0;

  // Ide soroljuk fel a képernyőket, amik a középső részre kerülnek
  final List<Widget> _pages = [
    const DashboardView(),
    const Center(child: Text('Ügyfelek & Projektek (Kanban tábla jön ide)', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Pénzügy / Számlázás (Export jön ide)', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Kommunikáció (Push / AI e-mail jön ide)', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Csapat nézet', style: TextStyle(fontSize: 24))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Bal oldali menüsáv
          Container(
            width: 250,
            color: const Color(0xFF1E1E2C), // Sötét téma
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
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Navigációs elemek
                _buildNavItem(Icons.dashboard, 'Vezérlőpult', 0),
                _buildNavItem(Icons.people, 'Ügyfelek & Projektek', 1),
                _buildNavItem(Icons.attach_money, 'Pénzügy / Számlázás', 2),
                _buildNavItem(Icons.chat, 'Kommunikáció', 3),
                _buildNavItem(Icons.group, 'Csapat', 4),

                const Spacer(),

                // Felhasználó & Kijelentkezés
                const Divider(color: Colors.white24, height: 1),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: const Text(
                    'Irodai Alkalmazott', // Később ezt dinamikusan kérjük le (ACL)
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

          // Fő tartalmi terület
          Expanded(
            child: Column(
              children: [
                // Felső sáv (Kereső és Értesítések)
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
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Dinamikus tartalom (A kiválasztott menüpont alapján)
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
      // AI Asszisztens lebegő gombja
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: AI asszisztens chatablak megnyitása
        },
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        tooltip: 'AI Asszisztens',
        child: const Icon(Icons.auto_awesome),
      ),
    );
  }

  // Módosított menüépítő függvény
  Widget _buildNavItem(IconData icon, String title, int index) {
    final isActive = _selectedIndex == index;

    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? Colors.white : Colors.white54,
        ),
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
