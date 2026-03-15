import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:onix_web/data/services/get_user_team_id.dart';
import 'package:onix_web/features/projects/ui/ProjectTile.dart';

class ProjectsCollectorScreen extends StatefulWidget {
  const ProjectsCollectorScreen({super.key});

  @override
  State<ProjectsCollectorScreen> createState() => _ProjectsCollectorScreenState();
}

class _ProjectsCollectorScreenState extends State<ProjectsCollectorScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // 3 fül a projekt állapotoknak
      child: Scaffold(
        backgroundColor: Colors.transparent, // A hátteret a WebMainLayout biztosítja
        body: Padding(
          padding: const EdgeInsets.all(32.0), // 32px biztonsági sáv
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. SaaS FEJLÉC (Header) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Projektek',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -1.0,
                          height: 1.1,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'A cég összes aktív és lezárt munkájának áttekintése.',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          color: Color(0xFF9CA3AF),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                  // Elsődleges CTA Gomb
                  ElevatedButton.icon(
                    onPressed: () => context.go('/projects/create'), // Útválasztás a létrehozáshoz
                    icon: const Icon(LucideIcons.plus, size: 18, color: Color(0xFF0A0C10)),
                    label: const Text(
                      'Új Projekt',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A0C10),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E5FF), // Brand accent color
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // --- 2. FÜLEK (Tabs - Progressive Disclosure) ---
              Container(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFF1C202B), width: 2)), // Finom alapvonal
                ),
                child: TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicatorColor: const Color(0xFF00E5FF),
                  indicatorWeight: 3,
                  labelColor: Colors.white,
                  unselectedLabelColor: const Color(0xFF6B7280),
                  labelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600),
                  unselectedLabelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w500),
                  dividerColor: Colors.transparent, // Lose the lines
                  tabs: const [
                    Tab(text: 'Folyamatban'),
                    Tab(text: 'Várakozik'),
                    Tab(text: 'Befejezett (Kész)'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- 3. TARTALOM (TabBarView beépített lekérdezésekkel) ---
              Expanded(
                child: FutureBuilder<String?>(
                  future: UserService.getTeamId(),
                  builder: (context, teamSnapshot) {
                    if (!teamSnapshot.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF)));
                    final teamId = teamSnapshot.data;

                    return TabBarView(
                      children: [
                        _buildProjectList(teamId, 'in_progress'), // Folyamatban
                        _buildProjectList(teamId, 'waiting'),     // Várakozik
                        _buildProjectList(teamId, 'completed'),   // Kész
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Projekt Lista Építő (Újrahasznosítható a fülekhez) ---
  Widget _buildProjectList(String? teamId, String filterStatus) {
    if (teamId == null) return const SizedBox();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('projects')
          .where('teamId', isEqualTo: teamId)
          // Ha már van 'status' mező az adatbázisban, élesítsük be ezt:
          // .where('status', isEqualTo: filterStatus)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF)));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState();
        }

        final projects = snapshot.data!.docs;

        // Ideiglenes kliens-oldali szűrés, ha a Firestore index/query még nincs beállítva
        // Éles környezetben ezt a .where() oldja meg a lekérdezésben!
        final filteredProjects = projects.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final status = data['status'] ?? 'in_progress';
          return status == filterStatus;
        }).toList();

        if (filteredProjects.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 32),
          physics: const BouncingScrollPhysics(),
          itemCount: filteredProjects.length,
          itemBuilder: (context, index) {
            final doc = filteredProjects[index];
            final data = doc.data() as Map<String, dynamic>;

            return ProjectTile(
              title: data['projectName'] ?? 'Névtelen Projekt',
              address: data['projectAddress'] ?? 'Nincs cím megadva',
              status: filterStatus,
              onTap: () {
                // A projekt részleteire navigál az adott ID-val
                // Példa: context.go('/projects/${doc.id}');
                // Most egy egyszerű navigációt hívunk:
                context.go('/projects/details', extra: doc.id); 
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.folderOpen, size: 64, color: Color(0xFF374151)),
          const SizedBox(height: 16),
          const Text(
            'Nincsenek projektek ebben a kategóriában',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Kattints az "Új Projekt" gombra a kezdéshez.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}