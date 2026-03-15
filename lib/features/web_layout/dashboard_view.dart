import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:onix_web/data/services/get_user_team_id.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Hátteret a WebMainLayout adja
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0), // Szigorú 8px grid
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. SaaS FEJLÉC ÉS GYORSLINKEK (Quick Actions) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vezérlőpult',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -1.0,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Üdv újra! Itt a mai napod gyors áttekintése.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        color: const Color(0xFF9CA3AF),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
                
                // Gyorslinkek (Wrap a reszponzivitásért kisebb ablakokon)
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _QuickActionButton(
                      label: 'Új Projekt',
                      icon: LucideIcons.folderPlus,
                      isPrimary: true,
                      onTap: () => context.go('/projects'), // Ideális esetben a Create routra visz
                    ),
                    _QuickActionButton(
                      label: 'Új Ügyfél',
                      icon: LucideIcons.userPlus,
                      onTap: () {}, // To be implemented
                    ),
                    _QuickActionButton(
                      label: 'Számla Export',
                      icon: LucideIcons.fileSpreadsheet,
                      onTap: () => _showExportModal(context), // Új funkció: Modal az exportra!
                    ),
                    _QuickActionButton(
                      label: 'Push Értesítés',
                      icon: LucideIcons.bellRing,
                      onTap: () {}, // To be implemented
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 48), // Szeparáló térköz

            // --- 2. FOLYAMATBAN LÉVŐ PROJEKTEK (Horizontális Csempék) ---
            const Text(
              'Aktív Projektek',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 180, // Fix magasság a horizontális listának
              child: FutureBuilder<String?>(
                future: UserService.getTeamId(),
                builder: (context, teamSnapshot) {
                  if (!teamSnapshot.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF)));
                  
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('projects')
                        .where('teamId', isEqualTo: teamSnapshot.data)
                        // .where('status', isEqualTo: 'in_progress') // Élesben csak az aktívakat kérjük le
                        .limit(10)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox();
                      
                      final projects = snapshot.data!.docs;
                      if (projects.isEmpty) {
                        return _buildEmptyState('Nincsenek aktív projektek', LucideIcons.folderOpen);
                      }

                      return ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(), // Prémium görgetési érzet
                        itemCount: projects.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 24), // Térköz a kártyák közt
                        itemBuilder: (context, index) {
                          final data = projects[index].data() as Map<String, dynamic>;
                          return _ProjectTileCard(
                            id: projects[index].id,
                            title: data['projectName'] ?? 'Névtelen projekt',
                            address: data['projectAddress'] ?? 'Nincs megadva cím',
                            progress: 0.65, // Mock adat, élesben a feladatokból számolva
                            onTap: () => context.go('/projects'), // Ideális esetben: /projects/${projects[index].id}
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 48),

            // --- 3. MAI NAPI TEENDŐK WIDGET ---
            const Text(
              'Mai Napi Teendők & Beosztás',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 24),
            
            // Letisztult napi lista (Lose the lines elv alapján)
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0A0C10), // Kicsit sötétebb háttérsziget
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _TodayTaskRow(
                    time: '08:00 - 16:00',
                    task: 'Teraszburkolás alapozása',
                    project: 'Márai Sándor u. 9/A',
                    assignees: ['Kiss Karcsi', 'Nagy János'],
                    isCompleted: false,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Divider(color: Color(0xFF1C202B), height: 1), // Finom vonal
                  ),
                  _TodayTaskRow(
                    time: '09:00 - 12:00',
                    task: 'Anyagbeszerzés (Térkő)',
                    project: 'Raktár -> Márai S. u.',
                    assignees: ['Kovács Béla'],
                    isCompleted: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- SZÁMLA EXPORT MODAL (Felugró ablak a külön oldal helyett) ---
  void _showExportModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF161922),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text(
            'Számlázási Adatok Exportálása',
            style: TextStyle(
              fontFamily: 'Outfit',
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Válaszd ki a hónapot, amelyiknek az anyag- és munkaóra költségeit exportálni szeretnéd (CSV/Excel).',
                style: TextStyle(color: Color(0xFF9CA3AF), fontFamily: 'Inter', height: 1.5),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0C10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1C202B)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('2026 Február', style: TextStyle(color: Colors.white, fontFamily: 'Inter', fontWeight: FontWeight.w500)),
                    Icon(LucideIcons.calendar, color: Color(0xFF9CA3AF), size: 18),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Mégsem', style: TextStyle(color: Color(0xFF9CA3AF), fontFamily: 'Inter')),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Exportálás elindítva...'),
                    backgroundColor: Color(0xFF2DD4BF),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(LucideIcons.download, size: 18, color: Color(0xFF0A0C10)),
              label: const Text('Letöltés', style: TextStyle(color: Color(0xFF0A0C10), fontFamily: 'Inter', fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(String text, IconData icon) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: const Color(0xFF161922),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF1C202B), width: 1), // Itt megengedett egy finom border az üresség jelzésére
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: const Color(0xFF374151)),
            const SizedBox(height: 16),
            Text(text, style: const TextStyle(color: Color(0xFF6B7280), fontFamily: 'Inter')),
          ],
        ),
      ),
    );
  }
}

// --- SEGÉDKOMPONENSEK ---

class _QuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFF00E5FF).withOpacity(0.1) : const Color(0xFF161922),
          borderRadius: BorderRadius.circular(16),
          border: isPrimary ? Border.all(color: const Color(0xFF00E5FF).withOpacity(0.3), width: 1) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: isPrimary ? const Color(0xFF00E5FF) : Colors.white),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isPrimary ? const Color(0xFF00E5FF) : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectTileCard extends StatelessWidget {
  final String id;
  final String title;
  final String address;
  final double progress;
  final VoidCallback onTap;

  const _ProjectTileCard({
    required this.id,
    required this.title,
    required this.address,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 320, // Rögzített szélesség a csempének
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF161922), // Sötét felület
          borderRadius: BorderRadius.circular(24), // Organikus sugár
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header ikonnnal
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0C10),
                    borderRadius: BorderRadius.circular(12), // Corner inside a corner (24 - 12 padding kb)
                  ),
                  child: const Icon(LucideIcons.hardHat, size: 20, color: Color(0xFF2DD4BF)), // Menta akcentus szín
                ),
                const Spacer(),
                const Icon(LucideIcons.moreHorizontal, size: 20, color: Color(0xFF6B7280)),
              ],
            ),
            const Spacer(),
            // Szöveges tartalom
            Text(
              title,
              style: const TextStyle(fontFamily: 'Outfit', fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              address,
              style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Color(0xFF9CA3AF)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            // Folyamatjelző (Progress Bar)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Haladás', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Color(0xFF9CA3AF))),
                Text('${(progress * 100).toInt()}%', style: const TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFF0A0C10),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2DD4BF)),
              borderRadius: BorderRadius.circular(4),
              minHeight: 6,
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayTaskRow extends StatelessWidget {
  final String time;
  final String task;
  final String project;
  final List<String> assignees;
  final bool isCompleted;

  const _TodayTaskRow({
    required this.time,
    required this.task,
    required this.project,
    required this.assignees,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Időpont
        SizedBox(
          width: 120,
          child: Text(
            time,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isCompleted ? const Color(0xFF4B5563) : const Color(0xFF9CA3AF),
              decoration: isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
        // Státusz ikon
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Icon(
            isCompleted ? LucideIcons.checkCircle2 : LucideIcons.circle,
            size: 20,
            color: isCompleted ? const Color(0xFF2DD4BF) : const Color(0xFF4B5563),
          ),
        ),
        // Feladat részletek
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isCompleted ? const Color(0xFF6B7280) : Colors.white,
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                project,
                style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Color(0xFF9CA3AF)),
              ),
            ],
          ),
        ),
        // Résztvevők chipek
        Row(
          children: assignees.map((name) => Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1C202B),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                name.split(' ').first, // Csak a keresztnév
                style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Color(0xFFD1D5DB)),
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }
}