import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/web_layout/web_main_layout.dart';
import '../features/web_layout/dashboard_view.dart';
import '../features/web_layout/projects_kanban_view.dart';
import '../features/web_layout/finance_export_view.dart';
import '../features/web_layout/communication_view.dart';
import '../features/web_layout/team_view.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/dashboard',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        // A menüsáv lesz a "Shell", vagyis a keret
        return WebMainLayout(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [GoRoute(path: '/dashboard', builder: (context, state) => const DashboardView())],
        ),
        StatefulShellBranch(
          // Később az isAdmin változót globális state-ből (pl. Providerből) érdemes ide betölteni
          routes: [GoRoute(path: '/kanban', builder: (context, state) => ProjectsKanbanView(isAdmin: true))],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/finance', builder: (context, state) => const FinanceExportView())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/communication', builder: (context, state) => const CommunicationView())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/team', builder: (context, state) => const TeamView())],
        ),
      ],
    ),
  ],
);