import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/app_theme.dart';

class WebMainLayout extends StatefulWidget {
  // A GoRouter adja át ezt a Shell-t, ez tartalmazza az aktuális oldalt
  final StatefulNavigationShell navigationShell;

  const WebMainLayout({super.key, required this.navigationShell});

  @override
  State<WebMainLayout> createState() => _WebMainLayoutState();
}

class _WebMainLayoutState extends State<WebMainLayout> {
  bool _isAdmin = false;
  final TextEditingController _searchController = TextEditingController();

  void _goBranch(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

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
          'Miben segíthetek ma? (Pl. "Listázd az eheti lejárt projekteket")',
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
    // Képernyőszélesség vizsgálata a reszponzivitáshoz
    final isDesktop = MediaQuery.of(context).size.width >= 1000;

    return Scaffold(
      backgroundColor: OnixColors.obsidianBlack,
      body: Row(
        children: [
          // RESZPONZÍV BAL OLDALI MENÜSÁV
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: isDesktop ? 260 : 80,
            color: OnixColors.deepEmerald,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24.0 : 8.0, vertical: 32.0),
                  child: Row(
                    mainAxisAlignment: isDesktop ? MainAxisAlignment.start : MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: OnixColors.cyberMint,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.spa, color: OnixColors.obsidianBlack, size: 24),
                      ),
                      if (isDesktop) const SizedBox(width: 16),
                      if (isDesktop)
                        const Text(
                          'ONIX',
                          style: TextStyle(
                            color: OnixColors.pureWhite,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.0,
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Menüpontok
                _buildNavItem(Icons.dashboard_rounded, 'Vezérlőpult', 0, isDesktop),
                _buildNavItem(Icons.view_kanban_rounded, 'CRM & Projektek', 1, isDesktop),
                _buildNavItem(Icons.account_balance_wallet_rounded, 'Pénzügy / Export', 2, isDesktop),
                _buildNavItem(Icons.forum_rounded, 'Kommunikáció', 3, isDesktop),
                _buildNavItem(Icons.groups_rounded, 'Csapat', 4, isDesktop),

                const Spacer(),

                // Profil és Szerepkör rész
                const Divider(color: Colors.white12, height: 1),
                if (isDesktop) ...[
                  Container(
                    margin: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Admin nézet', style: TextStyle(color: OnixColors.textSecondary, fontSize: 12)),
                        Switch(
                          value: _isAdmin,
                          activeColor: OnixColors.cyberMint,
                          onChanged: (val) {
                            setState(() => _isAdmin = val);
                          },
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: const CircleAvatar(
                      backgroundColor: OnixColors.obsidianBlack,
                      child: Icon(Icons.person_outline, color: OnixColors.cyberMint),
                    ),
                    title: Text(
                      _isAdmin ? 'Tulajdonos' : 'Irodai Alkalmazott',
                      style: const TextStyle(color: OnixColors.pureWhite, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    trailing: const Icon(Icons.logout, color: OnixColors.textSecondary, size: 20),
                  ),
                ] else ...[
                   const Padding(
                     padding: EdgeInsets.symmetric(vertical: 24.0),
                     child: CircleAvatar(
                        backgroundColor: OnixColors.obsidianBlack,
                        child: Icon(Icons.person_outline, color: OnixColors.cyberMint),
                      ),
                   )
                ]
              ],
            ),
          ),

          // JOBB OLDALI FŐ TERÜLET
          Expanded(
            child: Column(
              children: [
                // Felső sáv
                Container(
                  height: 80,
                  color: OnixColors.obsidianBlack,
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: OnixColors.darkSurface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(color: OnixColors.pureWhite),
                            decoration: InputDecoration(
                              hintText: isDesktop ? 'Keresés ügyfelek, projektek vagy fájlok között...' : 'Keresés...',
                              hintStyle: const TextStyle(color: OnixColors.textSecondary),
                              prefixIcon: const Icon(Icons.search, color: OnixColors.textSecondary),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 32),
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
                              decoration: const BoxDecoration(color: OnixColors.errorRed, shape: BoxShape.circle),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Dinamikus tartalom betöltése a GoRouter-ből
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: OnixColors.darkSurface,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(32)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: widget.navigationShell, // Itt renderelődik ki az aktuális aloldal!
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: isDesktop 
      ? FloatingActionButton.extended(
          onPressed: _showAIAssistantDialog,
          backgroundColor: OnixColors.cyberMint,
          foregroundColor: OnixColors.obsidianBlack,
          icon: const Icon(Icons.auto_awesome),
          label: const Text('AI Asszisztens', style: TextStyle(fontWeight: FontWeight.bold)),
        )
      : FloatingActionButton(
          onPressed: _showAIAssistantDialog,
          backgroundColor: OnixColors.cyberMint,
          foregroundColor: OnixColors.obsidianBlack,
          child: const Icon(Icons.auto_awesome),
        ),
    );
  }

  Widget _buildNavItem(IconData icon, String title, int index, bool isDesktop) {
    final isActive = widget.navigationShell.currentIndex == index;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 16.0 : 8.0, vertical: 4.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _goBranch(index),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 16.0 : 0, vertical: 16.0),
            decoration: BoxDecoration(
              color: isActive ? OnixColors.obsidianBlack.withOpacity(0.4) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isActive ? Border.all(color: OnixColors.cyberMint.withOpacity(0.3)) : null,
            ),
            child: isDesktop 
                ? Row(
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
                  )
                : Center(
                    child: Icon(icon, color: isActive ? OnixColors.cyberMint : OnixColors.textSecondary, size: 24),
                  ),
          ),
        ),
      ),
    );
  }
}