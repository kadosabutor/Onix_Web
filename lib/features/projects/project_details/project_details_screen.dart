import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:onix_web/features/web_layout/communication_view.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final String projectId;

  const ProjectDetailsScreen({super.key, required this.projectId});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  // A GlobalKey a belső Scaffold-hoz, hogy tudjuk nyitni az EndDrawert
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // 4 fül a Progressive Disclosure elv alapján
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.transparent, // A hátteret a WebMainLayout adja
        
        // --- ÚJ FUNKCIÓ: Slide-over Kommunikációs Panel ---
        endDrawer: Drawer(
          width: 400, // Fix szélesség a kényelmes olvasáshoz
          elevation: 0,
          backgroundColor: const Color(0xFF12151C), // Hue-shifted felület
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.horizontal(left: Radius.circular(24)),
          ),
          child: CommunicationView(projectId: widget.projectId), // Átadjuk az ID-t a szűréshez
        ),
        
        body: Padding(
          padding: const EdgeInsets.all(32.0), // Szigorú 8px grid
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. SaaS FEJLÉC & KOMMUNIKÁCIÓ GOMB ---
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('projects').doc(widget.projectId).get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox(height: 60);
                  
                  final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
                  final projectName = data['projectName'] ?? 'Ismeretlen Projekt';
                  final projectAddress = data['projectAddress'] ?? 'Nincs cím megadva';

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                projectName,
                                style: const TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: -1.0,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Status Chip
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2DD4BF).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Folyamatban',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2DD4BF),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(LucideIcons.mapPin, size: 16, color: Color(0xFF9CA3AF)),
                              const SizedBox(width: 8),
                              Text(
                                projectAddress,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 15,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      // Slide-over megnyitó gomb
                      ElevatedButton.icon(
                        onPressed: () {
                          // Megnyitja a jobb oldali panelt anélkül, hogy elhagynánk az oldalt
                          _scaffoldKey.currentState?.openEndDrawer();
                        },
                        icon: const Icon(LucideIcons.messageSquare, size: 18, color: Colors.white),
                        label: const Text(
                          'Kommunikáció',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1C202B), // Másodlagos gomb stílus
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Color(0xFF2A2E39), width: 1),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),

              // --- 2. FÜLEK (Tabs) NAVIGÁCIÓJA ---
              Container(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFF1C202B), width: 2)), // Finom alapvonal
                ),
                child: TabBar(
                  isScrollable: true, // weben kényelmesebb
                  tabAlignment: TabAlignment.start,
                  indicatorColor: const Color(0xFF00E5FF),
                  indicatorWeight: 3,
                  labelColor: Colors.white,
                  unselectedLabelColor: const Color(0xFF6B7280),
                  labelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600),
                  unselectedLabelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w500),
                  dividerColor: Colors.transparent, // Lose the lines (natív vonal eltüntetése)
                  tabs: const [
                    Tab(text: 'Általános adatok'),
                    Tab(text: 'Munkaórák'),
                    Tab(text: 'Anyaghasználat'),
                    Tab(text: 'Galéria / Fotók'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- 3. FÜLEK TARTALMA (TabBarView) ---
              Expanded(
                child: TabBarView(
                  children: [
                    _buildGeneralTab(),
                    _buildWorklogsTab(),
                    _buildMaterialsTab(), // Az újonnan kért letisztult táblázat!
                    _buildGalleryTab(),
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
  // TAB 1: ÁLTALÁNOS ADATOK
  // ==========================================
  Widget _buildGeneralTab() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0C10), // Kicsit mélyebb háttér a tartalomnak
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          'Itt kapnak helyet a projekt alapadatai, a megrendelő elérhetőségei és a leírás.',
          style: TextStyle(color: Color(0xFF9CA3AF), fontFamily: 'Inter'),
        ),
      ),
    );
  }

  // ==========================================
  // TAB 2: MUNKAÓRÁK
  // ==========================================
  Widget _buildWorklogsTab() {
    return const Center(
      child: Text('Munkaórák modul helye', style: TextStyle(color: Color(0xFF6B7280), fontFamily: 'Inter')),
    );
  }

  // ==========================================
  // TAB 3: ANYAGHASZNÁLAT (A kért új táblázat)
  // ==========================================
  Widget _buildMaterialsTab() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0C10), // Mélyebb háttér (Hue shift) a lista területének
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // TÁBLÁZAT FEJLÉC (Lose the lines elv)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF1C202B), width: 1)),
            ),
            child: Row(
              children: const [
                Expanded(flex: 2, child: Text('DÁTUM', style: _tableHeaderStyle)),
                Expanded(flex: 3, child: Text('RÖGZÍTŐ SZEMÉLY', style: _tableHeaderStyle)),
                Expanded(flex: 3, child: Text('ANYAG MEGNEVEZÉSE', style: _tableHeaderStyle)),
                Expanded(flex: 2, child: Text('MENNYISÉG', style: _tableHeaderStyle)),
                Expanded(flex: 2, child: Text('EGYSÉG', style: _tableHeaderStyle)),
                SizedBox(width: 40), // Hely a szerkesztés ikonnak
              ],
            ),
          ),
          
          // TÁBLÁZAT TARTALMA (Mock adat a vizualizációhoz, élesben Firestore Stream)
          Expanded(
            child: ListView.builder(
              itemCount: 4, // Példa sorok
              itemBuilder: (context, index) {
                final isEven = index % 2 == 0;
                
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  decoration: BoxDecoration(
                    // Zebra-csíkozás a vonalak helyett!
                    color: isEven ? Colors.transparent : const Color(0xFF161922),
                  ),
                  child: Row(
                    children: [
                      // Dátum
                      Expanded(
                        flex: 2,
                        child: Text(
                          '2026.03.${10 + index}.',
                          style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Color(0xFF9CA3AF)),
                        ),
                      ),
                      // Rögzítő
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: const Color(0xFF00E5FF).withOpacity(0.2),
                              child: const Icon(LucideIcons.user, size: 14, color: Color(0xFF00E5FF)),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Kiss Karcsi',
                              style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      // Anyag neve
                      Expanded(
                        flex: 3,
                        child: Text(
                          index % 2 == 0 ? 'Szürke Térkő (Klasszik)' : 'Fenyő Mulcs',
                          style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.white),
                        ),
                      ),
                      // Mennyiség
                      Expanded(
                        flex: 2,
                        child: Text(
                          index % 2 == 0 ? '12.5' : '45.0',
                          style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF00E5FF)), // Accented adat
                        ),
                      ),
                      // Egység
                      Expanded(
                        flex: 2,
                        child: Text(
                          index % 2 == 0 ? 'Raklap' : 'Zsák',
                          style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Color(0xFF9CA3AF)),
                        ),
                      ),
                      // Szerkesztés gomb (Irodai jogosultsághoz)
                      SizedBox(
                        width: 40,
                        child: IconButton(
                          icon: const Icon(LucideIcons.edit3, size: 16, color: Color(0xFF4B5563)),
                          hoverColor: const Color(0xFF1C202B),
                          onPressed: () {
                            // Ide jön majd az adatmódosító Modal (pl. elütés javítása)
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 4: GALÉRIA
  // ==========================================
  Widget _buildGalleryTab() {
    return const Center(
      child: Text('Képgaléria rács helye', style: TextStyle(color: Color(0xFF6B7280), fontFamily: 'Inter')),
    );
  }

  static const TextStyle _tableHeaderStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: Color(0xFF6B7280),
  );
}