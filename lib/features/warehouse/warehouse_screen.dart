import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:onix_web/data/services/get_user_team_id.dart';
import 'package:onix_web/features/warehouse/add_material_screen.dart';
import 'package:onix_web/features/warehouse/ui/material_details_bottom_sheet.dart';
import 'package:onix_web/features/warehouse/ui/material_list_tile.dart';

class WarehouseScreen extends StatefulWidget {
  const WarehouseScreen({super.key});

  @override
  State<WarehouseScreen> createState() => _WarehouseScreenState();
}

class _WarehouseScreenState extends State<WarehouseScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // A hátteret a WebMainLayout adja
      body: Padding(
        padding: const EdgeInsets.all(32.0), // Szigorú 8px-es szorzó (32px padding)
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SaaS FEJLÉC (Header) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Katalógus',
                      style: TextStyle(
                        fontFamily: 'Outfit', // Display betűtípus
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -1.0, // Matematikai tipográfia: negatív kerning a nagy címeken
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Alapanyagok és egységárak központi nyilvántartása a számlázáshoz.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: Color(0xFF9CA3AF),
                        height: 1.5, // 150% sor-magasság olvashatóságért
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddMaterialScreen()),
                    );
                  },
                  icon: const Icon(LucideIcons.plus, size: 18, color: Color(0xFF0A0C10)),
                  label: const Text(
                    'Új alapanyag',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0A0C10),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5FF), // Brand accent color
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    elevation: 0, // Nincs "olcsó" árnyék
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // --- TÁBLÁZAT (Data Table Area) ---
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0C10), // Mélyebb háttér (Hue shift) a lista területének
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    // Oszlop-fejlécek
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xFF1C202B), width: 1), // Egyetlen finom elválasztó
                        ),
                      ),
                      child: const Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text('ALAPANYAG MEGNEVEZÉSE', style: _tableHeaderStyle),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text('MÉRTÉKEGYSÉG', style: _tableHeaderStyle),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text('EGYSÉGÁR', style: _tableHeaderStyle),
                          ),
                          SizedBox(width: 16), // Helykihagyás a nyílnak
                        ],
                      ),
                    ),

                    // Lista
                    Expanded(
                      child: FutureBuilder<String?>(
                        future: UserService.getTeamId(),
                        builder: (context, teamIdSnapshot) {
                          if (teamIdSnapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF)));
                          }

                          final teamId = teamIdSnapshot.data;
                          if (teamId == null || teamId.isEmpty) {
                            return _buildErrorState('Hiba: nem található teamId');
                          }

                          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            stream: FirebaseFirestore.instance
                                .collection('materials')
                                .where('teamId', isEqualTo: teamId)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF)));
                              }

                              if (snapshot.hasError) {
                                return _buildErrorState('Hiba történt az alapanyagok betöltésekor.');
                              }

                              final materials = snapshot.data?.docs ?? [];

                              if (materials.isEmpty) {
                                return _buildEmptyState();
                              }

                              return ListView.builder(
                                itemCount: materials.length,
                                itemBuilder: (context, index) {
                                  final material = materials[index];
                                  final data = material.data();
                                  
                                  final name = data['name'] as String? ?? 'Névtelen alapanyag';
                                  final unit = data['unit'] as String? ?? '-';
                                  final price = data['price'] as num?;

                                  return MaterialListTile(
                                    name: name,
                                    unit: unit,
                                    price: price,
                                    isEvenRow: index % 2 == 0, // Zebra csíkozás logikája
                                    onTap: () {
                                      // Részletek megnyitása (Üres Map-et adunk át, mert leválasztottuk a projektekről)
                                      MaterialDetailsBottomSheet.show(
                                        context,
                                        material,
                                        {}, 
                                      );
                                    },
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Segéd komponensek ---

  static const TextStyle _tableHeaderStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: Color(0xFF6B7280),
  );

  Widget _buildErrorState(String message) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(color: Colors.redAccent, fontFamily: 'Inter'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.packageOpen, size: 64, color: Color(0xFF374151)),
          const SizedBox(height: 16),
          const Text(
            'A katalógus üres',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Töltsd fel a raktárt alapanyagokkal és azok áraival\na számlázás automatizálásához.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Color(0xFF9CA3AF),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}