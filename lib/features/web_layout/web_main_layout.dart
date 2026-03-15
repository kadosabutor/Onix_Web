import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';

// Assuming this path exists based on our new structure. 
// We mount it here so it's accessible globally via the slide-over.
import 'package:onix_web/features/web_layout/communication_view.dart';

class WebMainLayout extends StatefulWidget {
  final Widget child;

  const WebMainLayout({Key? key, required this.child}) : super(key: key);

  @override
  State<WebMainLayout> createState() => _WebMainLayoutState();
}

class _WebMainLayoutState extends State<WebMainLayout> {
  
  // Maps the current route to the active sidebar visual state
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/calendar')) return 1;
    if (location.startsWith('/projects')) return 2;
    if (location.startsWith('/team')) return 3;
    if (location.startsWith('/warehouse')) return 4;
    if (location.startsWith('/settings')) return 5;
    return 0; // Default fallback
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/calendar');
        break;
      case 2:
        context.go('/projects');
        break;
      case 3:
        context.go('/team');
        break;
      case 4:
        context.go('/warehouse');
        break;
      case 5:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      // HUE SHIFTING: Deep background color pushed towards blue/purple instead of flat black
      backgroundColor: const Color(0xFF0A0C10), 
      
      // NEW FEATURE: Communication Slide-Over Panel
      // Mounted at the root so any nested view (like ProjectDetails) can call Scaffold.of(context).openEndDrawer()
      endDrawer: const Drawer(
        width: 400, // Fixed width to prevent horizontal reading strain
        elevation: 0,
        backgroundColor: Color(0xFF12151C), // Elevated, hue-shifted surface
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(left: Radius.circular(24)),
        ),
        child: CommunicationView(), 
      ),
      
      body: Row(
        children: [
          // LOSE THE LINES: No vertical dividers. Separation is achieved purely by background color contrast.
          Container(
            width: 256, // Strict mathematical grid (32 * 8 = 256)
            color: const Color(0xFF0A0C10), 
            padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand Header
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    'ONIX',
                    style: TextStyle(
                      fontFamily: 'Outfit', // Or your selected display font
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1.0, // Mathematical Typography: Negative kerning for Display headers
                      height: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Unified Navigation Menu
                _buildNavItem(context, 'Dashboard', LucideIcons.layoutDashboard, 0, selectedIndex),
                _buildNavItem(context, 'Calendar', LucideIcons.calendarDays, 1, selectedIndex),
                _buildNavItem(context, 'Projects', LucideIcons.folderKanban, 2, selectedIndex),
                _buildNavItem(context, 'Team & Resources', LucideIcons.users, 3, selectedIndex),
                _buildNavItem(context, 'Warehouse', LucideIcons.packageSearch, 4, selectedIndex),
                
                const Spacer(),
                
                _buildNavItem(context, 'Settings', LucideIcons.settings, 5, selectedIndex),
              ],
            ),
          ),
          
          // Main Content Canvas
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 16.0, bottom: 16.0, right: 16.0),
              decoration: BoxDecoration(
                color: const Color(0xFF12151C), // Contrast surface to create hierarchy without borders
                borderRadius: BorderRadius.circular(24), // iOS-style organic corner starting point
              ),
              clipBehavior: Clip.antiAlias,
              // The child is injected by GoRouter's ShellRoute
              child: widget.child, 
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String title, IconData icon, int index, int selectedIndex) {
    final isSelected = index == selectedIndex;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0), // 8px Spacing Grid
      child: InkWell(
        onTap: () => _onItemTapped(index, context),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          // Premium Interaction: Custom easing duration for a smoother, less linear feel
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutQuart,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            // Avoid generic opacities for active states. Use a dedicated, slightly lifted solid color.
            color: isSelected ? const Color(0xFF1C202B) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon, // Enforcing Lucide Icons globally
                size: 20, 
                color: isSelected ? const Color(0xFF00E5FF) : const Color(0xFF9CA3AF), // Brand accent vs muted secondary
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF9CA3AF),
                  height: 1.5, // 150% Line height for UI elements
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}