import 'package:flutter/material.dart';

// Dummy Adatmodell a projektekhez
class ProjectModel {
  final String id;
  final String title;
  final String client;
  String status; // 'Folyamatban', 'Kész', 'Karbantartás'
  final String description;

  ProjectModel(this.id, this.title, this.client, this.status, this.description);
}

class ProjectsKanbanView extends StatefulWidget {
  final bool isAdmin; // Kívülről kapja a jogosultságot
  const ProjectsKanbanView({super.key, required this.isAdmin});

  @override
  State<ProjectsKanbanView> createState() => _ProjectsKanbanViewState();
}

class _ProjectsKanbanViewState extends State<ProjectsKanbanView> {
  // Mock Adatok feltöltése
  final List<ProjectModel> _projects = [
    ProjectModel('1', 'Okoskert Építés', 'Kovács János', 'Folyamatban', 'Teljes tereprendezés és öntözőrendszer telepítés.'),
    ProjectModel('2', 'Terasz burkolás', 'Nagy Kft.', 'Folyamatban', 'Prémium WPC burkolat lerakása 40nm-en.'),
    ProjectModel('3', 'Térkövezés', 'Szabó Éva', 'Kész', 'Kocsibeálló térkövezése szürke betonnal.'),
    ProjectModel('4', 'Tavaszi metszés', 'Kiss Péter', 'Karbantartás', 'Éves karbantartási szerződés alapján.'),
    ProjectModel('5', 'Gyep ápolás', 'Tóth Család', 'Karbantartás', 'Gyepszellőztetés és tápanyagozás.'),
  ];

  // Drag & Drop logika: Státusz frissítése
  void _updateProjectStatus(String projectId, String newStatus) {
    setState(() {
      final project = _projects.firstWhere((p) => p.id == projectId);
      project.status = newStatus;
    });
  }

  void _showProjectDetails(ProjectModel project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: Text(project.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ügyfél: ${project.client}', style: const TextStyle(color: Color(0xFF00D084), fontSize: 16)),
              const SizedBox(height: 16),
              Text('Leírás:', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(project.description, style: const TextStyle(color: Colors.white, height: 1.5)),
              const SizedBox(height: 24),
              const Text('Akciók:', style: TextStyle(color: Colors.white)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ActionChip(label: const Text('Szerkesztés'), onPressed: () {}, backgroundColor: Colors.blue.withValues(alpha: 0.2)),
                  ActionChip(label: const Text('Hozzárendelés'), onPressed: () {}, backgroundColor: Colors.orange.withValues(alpha: 0.2)),
                  ActionChip(label: const Text('Törlés'), onPressed: () {}, backgroundColor: Colors.red.withValues(alpha: 0.2)),
                ],
              )
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Bezárás', style: TextStyle(color: Color(0xFF00D084)))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'CRM & Projektek (Kanban)',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              // VIZUÁLIS HIERARCHIA: Gomb állapota függ az isAdmin-tól
              Tooltip(
                message: widget.isAdmin ? 'Kattints új projekt létrehozásához' : 'Irodai alkalmazottként nincs jogosultságod!',
                child: ElevatedButton.icon(
                  onPressed: widget.isAdmin ? () {} : null,
                  icon: const Icon(Icons.add),
                  label: const Text('Új projekt'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D084),
                    foregroundColor: const Color(0xFF0D1117),
                    disabledBackgroundColor: Colors.grey.shade800,
                    disabledForegroundColor: Colors.grey.shade500,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildKanbanColumn('Folyamatban', const Color(0xFF3B82F6)),
                const SizedBox(width: 24),
                _buildKanbanColumn('Kész', const Color(0xFF10B981)),
                const SizedBox(width: 24),
                _buildKanbanColumn('Karbantartás', const Color(0xFFF59E0B)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKanbanColumn(String statusName, Color accentColor) {
    final columnProjects = _projects.where((p) => p.status == statusName).toList();

    return Expanded(
      child: DragTarget<String>(
        onAcceptWithDetails: (details) {
          _updateProjectStatus(details.data, statusName);
        },
        builder: (context, candidateData, rejectedData) {
          bool isHovered = candidateData.isNotEmpty;
          
          return Container(
            decoration: BoxDecoration(
              color: isHovered ? accentColor.withValues(alpha: 0.1) : const Color(0xFF0D1117),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isHovered ? accentColor : Colors.white12),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(statusName.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, color: accentColor, letterSpacing: 1.2)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                        child: Text('${columnProjects.length}', style: TextStyle(color: accentColor, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: columnProjects.length,
                    itemBuilder: (context, index) {
                      final project = columnProjects[index];
                      // Draggable elem a Drag&Drop-hoz
                      return Draggable<String>(
                        data: project.id,
                        feedback: Material(
                          color: Colors.transparent,
                          child: Opacity(
                            opacity: 0.8,
                            child: SizedBox(width: 300, child: _buildProjectCard(project, accentColor)),
                          ),
                        ),
                        childWhenDragging: Opacity(opacity: 0.3, child: _buildProjectCard(project, accentColor)),
                        child: _buildProjectCard(project, accentColor),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProjectCard(ProjectModel project, Color accent) {
    return Card(
      color: const Color(0xFF161B22),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.white12)),
      elevation: 4,
      child: InkWell(
        onTap: () => _showProjectDetails(project),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: accent, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(project.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16))),
                ],
              ),
              const SizedBox(height: 12),
              Text('Ügyfél: ${project.client}', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}