import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:onix_web/data/services/get_user_team_id.dart';

class TeamView extends StatefulWidget {
  const TeamView({super.key});

  @override
  State<TeamView> createState() => _TeamViewState();
}

class _TeamViewState extends State<TeamView> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // 3 fül: Aktív, Kérelmek, Gépek
      child: Scaffold(
        backgroundColor: Colors.transparent, // A WebMainLayout adja a hátteret
        body: Padding(
          padding: const EdgeInsets.all(32.0), // Szigorú 8px grid (32px)
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
                        'Csapat & Erőforrások',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -1.0, // Negatív kerning nagy címeknél
                          height: 1.1,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Munkatársak, hozzáférések és munkagépek központi kezelése.',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          color: Color(0xFF9CA3AF),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Későbbi funkció: Felugró ablak meghívó küldéséhez
                    },
                    icon: const Icon(LucideIcons.userPlus, size: 18, color: Color(0xFF0A0C10)),
                    label: const Text(
                      'Új Munkatárs',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A0C10),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E5FF), // Brand accent
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // --- 2. FÜLEK (Tabs) ---
              Container(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFF1C202B), width: 2)),
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
                  tabs: [
                    const Tab(text: 'Aktív Munkatársak'),
                    Tab(
                      child: Row(
                        children: [
                          const Text('Csatlakozási Kérelmek'),
                          const SizedBox(width: 8),
                          // Premium Micro-UI: Notification Badge a kérelmeknek
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE53935).withOpacity(0.15), // Hue-shifted red
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Új', // Élesben ide egy szám jön a lekérdezésből
                              style: TextStyle(color: Color(0xFFEF4444), fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Tab(text: 'Munkagépek & Óradíjak'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- 3. FÜLEK TARTALMA ---
              Expanded(
                child: TabBarView(
                  children: [
                    _buildActiveColleaguesTab(),
                    _buildJoinRequestsTab(),
                    _buildMachinesTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1: AKTÍV MUNKATÁRSAK
  // ==========================================
  Widget _buildActiveColleaguesTab() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0C10), // Sötét konténer
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Fejléc
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF1C202B), width: 1)),
            ),
            child: Row(
              children: const [
                Expanded(flex: 3, child: Text('MUNKATÁRS NEVE', style: _tableHeaderStyle)),
                Expanded(flex: 2, child: Text('JOGOSULTSÁG', style: _tableHeaderStyle)),
                Expanded(flex: 2, child: Text('TELEFONSZÁM', style: _tableHeaderStyle)),
                SizedBox(width: 40),
              ],
            ),
          ),
          // Lista
          Expanded(
            child: FutureBuilder<String?>(
              future: UserService.getTeamId(),
              builder: (context, teamSnapshot) {
                if (!teamSnapshot.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF)));
                
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where('teamId', isEqualTo: teamSnapshot.data)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();
                    final users = snapshot.data!.docs;

                    if (users.isEmpty) return _buildEmptyState('Nincsenek munkatársak', LucideIcons.users);

                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final data = users[index].data() as Map<String, dynamic>;
                        final isEven = index % 2 == 0;
                        final role = data['role'] ?? 'worker';
                        
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                          decoration: BoxDecoration(
                            color: isEven ? Colors.transparent : const Color(0xFF161922), // Zebra-csíkozás
                          ),
                          child: Row(
                            children: [
                              // Név és Avatar
                              Expanded(
                                flex: 3,
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: const Color(0xFF2DD4BF).withOpacity(0.2),
                                      child: const Icon(LucideIcons.user, size: 16, color: Color(0xFF2DD4BF)),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      data['name'] ?? 'Névtelen',
                                      style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              // Szerepkör (Role chip)
                              Expanded(
                                flex: 2,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: role == 'admin' ? const Color(0xFF00E5FF).withOpacity(0.1) : const Color(0xFF1C202B),
                                      borderRadius: BorderRadius.circular(8),
                                      border: role == 'admin' ? Border.all(color: const Color(0xFF00E5FF).withOpacity(0.3)) : null,
                                    ),
                                    child: Text(
                                      role == 'admin' ? 'Irodavezető' : 'Munkatárs',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: role == 'admin' ? const Color(0xFF00E5FF) : const Color(0xFF9CA3AF),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Telefonszám
                              Expanded(
                                flex: 2,
                                child: Text(
                                  data['phoneNumber'] ?? '-',
                                  style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Color(0xFF9CA3AF)),
                                ),
                              ),
                              // Műveletek
                              SizedBox(
                                width: 40,
                                child: IconButton(
                                  icon: const Icon(LucideIcons.moreVertical, size: 18, color: Color(0xFF6B7280)),
                                  onPressed: () {},
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: CSATLAKOZÁSI KÉRELMEK
  // ==========================================
  Widget _buildJoinRequestsTab() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0C10),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF1C202B), width: 1)),
            ),
            child: Row(
              children: const [
                Expanded(flex: 3, child: Text('KÉRELMEZŐ NEVE', style: _tableHeaderStyle)),
                Expanded(flex: 2, child: Text('E-MAIL CÍM', style: _tableHeaderStyle)),
                Expanded(flex: 2, child: Text('MŰVELETEK', style: _tableHeaderStyle)),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<String?>(
              future: UserService.getTeamId(),
              builder: (context, teamSnapshot) {
                if (!teamSnapshot.hasData) return const Center(child: CircularProgressIndicator());
                
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('join_requests')
                      .where('teamId', isEqualTo: teamSnapshot.data)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();
                    final requests = snapshot.data!.docs;

                    if (requests.isEmpty) return _buildEmptyState('Nincsenek új kérelmek', LucideIcons.checkCircle);

                    return ListView.builder(
                      itemCount: requests.length,
                      itemBuilder: (context, index) {
                        final data = requests[index].data() as Map<String, dynamic>;
                        
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: Color(0xFF161922), width: 1)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  data['userName'] ?? 'Ismeretlen',
                                  style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  data['userEmail'] ?? '-',
                                  style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Color(0xFF9CA3AF)),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Row(
                                  children: [
                                    // Primary Action: Elfogadás
                                    ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF2DD4BF), // Zöldes elfogadás
                                        foregroundColor: const Color(0xFF0A0C10),
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      child: const Text('Elfogadás', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(width: 8),
                                    // Secondary Action: Elutasítás
                                    OutlinedButton(
                                      onPressed: () {},
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(0xFFEF4444), // Piros
                                        side: const BorderSide(color: Color(0xFF1C202B)),
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      child: const Text('Elutasítás', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 3: MUNKAGÉPEK (Zebra-csíkozott tábla)
  // ==========================================
  Widget _buildMachinesTab() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0C10),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF1C202B), width: 1)),
            ),
            child: Row(
              children: [
                const Expanded(flex: 3, child: Text('MUNKAGÉP MEGNEVEZÉSE', style: _tableHeaderStyle)),
                const Expanded(flex: 2, child: Text('TÍPUS', style: _tableHeaderStyle)),
                const Expanded(flex: 2, child: Text('ÓRADÍJ (HUF)', style: _tableHeaderStyle)),
                SizedBox(
                  width: 120,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {}, // Új gép hozzáadása
                      icon: const Icon(LucideIcons.plus, size: 14, color: Color(0xFF00E5FF)),
                      label: const Text('Új gép', style: TextStyle(color: Color(0xFF00E5FF), fontFamily: 'Inter')),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<String?>(
              future: UserService.getTeamId(),
              builder: (context, teamSnapshot) {
                if (!teamSnapshot.hasData) return const Center(child: CircularProgressIndicator());
                
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('machine_hours')
                      .where('teamId', isEqualTo: teamSnapshot.data)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();
                    final machines = snapshot.data!.docs;

                    if (machines.isEmpty) return _buildEmptyState('Nincsenek rögzített munkagépek', LucideIcons.tractor);

                    return ListView.builder(
                      itemCount: machines.length,
                      itemBuilder: (context, index) {
                        final data = machines[index].data() as Map<String, dynamic>;
                        final isEven = index % 2 == 0;
                        
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                          decoration: BoxDecoration(
                            color: isEven ? Colors.transparent : const Color(0xFF161922),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Row(
                                  children: [
                                    const Icon(LucideIcons.truck, size: 18, color: Color(0xFF9CA3AF)),
                                    const SizedBox(width: 12),
                                    Text(
                                      data['machineName'] ?? 'Ismeretlen gép',
                                      style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              const Expanded(
                                flex: 2,
                                child: Text(
                                  'Földmunkagép', // Mock adat, élesben jöhet adatbázisból
                                  style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: Color(0xFF9CA3AF)),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '${data['hourlyRate'] ?? 0} Ft / óra',
                                  style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF00E5FF)),
                                ),
                              ),
                              const SizedBox(
                                width: 120,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Icon(LucideIcons.chevronRight, size: 16, color: Color(0xFF4B5563)),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static const TextStyle _tableHeaderStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: Color(0xFF6B7280),
  );

  Widget _buildEmptyState(String text, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: const Color(0xFF374151)),
          const SizedBox(height: 16),
          Text(text, style: const TextStyle(fontFamily: 'Inter', fontSize: 16, color: Color(0xFF6B7280))),
        ],
      ),
    );
  }
}