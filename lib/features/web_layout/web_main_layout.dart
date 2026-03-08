import 'package:flutter/material.dart';

// Importáljuk a többi nézetet
import 'dashboard_view.dart';
import 'projects_kanban_view.dart';
import 'finance_export_view.dart';
import 'communication_view.dart';
import 'team_view.dart'; // EZT AZ ÚJ FÁJLT MAJD LÉTREHOZZUK

// --- ARCULATI SZÍNEK (Design System) ---
class OnixColors {
  static const Color obsidianBlack = Color(0xFF0D1117);
  static const Color deepEmerald = Color(0xFF0A3622);
  static const Color cyberMint = Color(0xFF00D084);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color darkSurface = Color(0xFF161B22); // Picit világosabb fekete kártyáknak
  static const Color textSecondary = Colors.white70;
}

class WebMainLayout extends StatefulWidget {
  const WebMainLayout({super.key});

  @override
  State<WebMainLayout> createState() => _WebMainLayoutState();
}

class _WebMainLayoutState extends State<WebMainLayout> {
  int _selectedIndex = 0;
  bool _isAdmin = false; // SZEREPKÖR VÁLTÓ ÁLLAPOTA (Irodai vs Tulajdonos)

  // A kereső mező vezérlője
  final TextEditingController _searchController = TextEditingController();

  void _showNotificationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: OnixColors.darkSurface,
        title: const Text('Értesítések', style: TextStyle(color: OnixColors.pureWhite)),
        content: const Text('Jelenleg nincs új értesítésed.', style: TextStyle(color: OnixColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bezárás', style: TextStyle(color: OnixColors.cyberMint)),
          )
        ],
      ),
    );
  }

  void _showAIAssistantDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: OnixColors.deepEmerald,
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: OnixColors.cyberMint),
            SizedBox(width: 8),
            Text('Onix AI Asszisztens', style: TextStyle(color: OnixColors.pureWhite)),
          ],
        ),
        content: const Text(
          'Miben segíthetek ma? (Pl. "Listázd az eheti lejárt projekteket", "Írj egy levelet Kovács Jánosnak")',
          style: TextStyle(color: OnixColors.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bezárás', style: TextStyle(color: OnixColors.cyberMint)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Aloldalak inicializálása, átadva az isAdmin paramétert a Kanban-nak
    final List<Widget> pages = [
      const DashboardView(),
      ProjectsKanbanView(isAdmin: _isAdmin),
      const FinanceExportView(),
      const CommunicationView(),
      const TeamView(),
    ];

    return Scaffold(
      backgroundColor: OnixColors.obsidianBlack, // 60% sötét háttér dominancia
      body: Row(
        children: [
          // BAL OLDALI MENÜSÁV (Deep Emerald a organikus mélységért)
          Container(
            width: 260,
            color: OnixColors.deepEmerald,
            child: Column(
              children: [
                // Logó és Márkajelzés (Negatív tér és modern letisztultság)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: OnixColors.cyberMint, // 10% kiemelő szín
                          borderRadius: BorderRadius.circular(12), // Biomorfikus finom ívek
                        ),
                        child: const Icon(Icons.spa, color: OnixColors.obsidianBlack, size: 24), // Ide jön majd az új logó
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'ONIX',
                        style: TextStyle(
                          color: OnixColors.pureWhite,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.0, // Megnövelt betűköz a prémium hatásért
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Menüpontok
                _buildNavItem(Icons.dashboard_rounded, 'Vezérlőpult', 0),
                _buildNavItem(Icons.view_kanban_rounded, 'CRM & Projektek', 1),
                _buildNavItem(Icons.account_balance_wallet_rounded, 'Pénzügy / Export', 2),
                _buildNavItem(Icons.forum_rounded, 'Kommunikáció', 3),
                _buildNavItem(Icons.groups_rounded, 'Csapat', 4),

                const Spacer(),

                // Szerepkör Váltó (Csak teszteléshez)
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: OnixColors.obsidianBlack.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Szerepkör (Teszt)', style: TextStyle(color: OnixColors.textSecondary, fontSize: 10)),
                          Text('Jogosultság váltás', style: TextStyle(color: OnixColors.pureWhite, fontSize: 12)),
                        ],
                      ),
                      Switch(
                        value: _isAdmin,
                        activeColor: OnixColors.cyberMint,
                        onChanged: (val) {
                          setState(() {
                            _isAdmin = val;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Szerepkör váltva: ${_isAdmin ? "Tulajdonos (Admin)" : "Irodai alkalmazott"}'),
                              backgroundColor: OnixColors.cyberMint,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Felhasználó profil része
                const Divider(color: Colors.white12, height: 1),
                ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const CircleAvatar(
                    backgroundColor: OnixColors.obsidianBlack,
                    child: Icon(Icons.person_outline, color: OnixColors.cyberMint),
                  ),
                  title: Text(
                    _isAdmin ? 'Tulajdonos' : 'Irodai Alkalmazott',
                    style: const TextStyle(color: OnixColors.pureWhite, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.logout, color: OnixColors.textSecondary),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),

          // JOBB OLDALI FŐ TERÜLET
          Expanded(
            child: Column(
              children: [
                // Felső sáv (Kereső és Értesítések)
                Container(
                  height: 80,
                  color: OnixColors.obsidianBlack,
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Row(
                    children: [
                      // Kereső szimuláció
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: OnixColors.darkSurface,
                            borderRadius: BorderRadius.circular(24), // Organikus forma
                            border: Border.all(color: Colors.white12),
                          ),
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(color: OnixColors.pureWhite),
                            decoration: InputDecoration(
                              hintText: 'Keresés ügyfelek, projektek vagy fájlok között...',
                              hintStyle: const TextStyle(color: OnixColors.textSecondary),
                              prefixIcon: const Icon(Icons.search, color: OnixColors.textSecondary),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.send, color: OnixColors.cyberMint, size: 20),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Keresés: ${_searchController.text} (Hamarosan...)'), backgroundColor: OnixColors.deepEmerald),
                                  );
                                },
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 32),
                      // Értesítés ikon
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_none_rounded, color: OnixColors.pureWhite, size: 28),
                            onPressed: _showNotificationDialog,
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(color: OnixColors.cyberMint, shape: BoxShape.circle),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Dinamikus tartalom
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: OnixColors.darkSurface,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(32)), // Finom átmenet
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: pages[_selectedIndex],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // AI Asszisztens Gomb (Kibernetikus Menta kiemelés)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAIAssistantDialog,
        backgroundColor: OnixColors.cyberMint,
        foregroundColor: OnixColors.obsidianBlack,
        icon: const Icon(Icons.auto_awesome),
        label: const Text('AI Asszisztens', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String title, int index) {
    final isActive = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            setState(() {
              _selectedIndex = index;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            decoration: BoxDecoration(
              color: isActive ? OnixColors.obsidianBlack.withValues(alpha: 0.4) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isActive ? Border.all(color: OnixColors.cyberMint.withValues(alpha: 0.3)) : null,
            ),
            child: Row(
              children: [
                Icon(icon, color: isActive ? OnixColors.cyberMint : OnixColors.textSecondary, size: 22),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    color: isActive ? OnixColors.pureWhite : OnixColors.textSecondary,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}