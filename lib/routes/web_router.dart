import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Webes Layout és Aloldalak importálása
import 'package:onix_web/features/web_layout/web_main_layout.dart';
import 'package:onix_web/features/web_layout/dashboard_view.dart';
import 'package:onix_web/features/web_layout/projects_kanban_view.dart';
import 'package:onix_web/features/web_layout/finance_export_view.dart';
import 'package:onix_web/features/web_layout/communication_view.dart';
import 'package:onix_web/features/web_layout/team_view.dart';

// Globális kulcs a navigátornak
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/dashboard', // Ide érkezik a felhasználó belépés után
  routes: [
    // Állapotmegőrző Shell Route - Ez felel a bal oldali fix menüsávért!
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return WebMainLayout(navigationShell: navigationShell);
      },
      branches: [
        // 0. Menüpont: Vezérlőpult
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardView(),
            ),
          ],
        ),
        // 1. Menüpont: CRM & Projektek
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/crm',
              builder: (context, state) => const ProjectsKanbanView(),
            ),
          ],
        ),
        // 2. Menüpont: Pénzügy / Export
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/finance',
              builder: (context, state) => const FinanceExportView(),
            ),
          ],
        ),
        // 3. Menüpont: Kommunikáció
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/communication',
              builder: (context, state) => const CommunicationView(),
            ),
          ],
        ),
        // 4. Menüpont: Csapat (Itt lesz a Drag&Drop Naptár)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/team',
              builder: (context, state) => const TeamView(),
            ),
          ],
        ),
      ],
    ),
  ],
);