import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:onix_web/data/services/get_user_team_id.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final DateTime _currentDate = DateTime.now();
  
  // A naptár matekja: napok száma és az első nap eltolása
  late int _daysInMonth;
  late int _firstDayOffset;

  @override
  void initState() {
    super.initState();
    _calculateMonth();
  }

  void _calculateMonth() {
    _daysInMonth = DateUtils.getDaysInMonth(_currentDate.year, _currentDate.month);
    final DateTime firstDay = DateTime(_currentDate.year, _currentDate.month, 1);
    // Hétfő = 1, Vasárnap = 7. Az eltolás (üres cellák a hónap elején):
    _firstDayOffset = firstDay.weekday - 1; 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // A hátteret a WebMainLayout biztosítja
      body: Padding(
        padding: const EdgeInsets.all(32.0), // Szigorú 8px grid
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SaaS FEJLÉC ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Beosztás & Naptár',
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -1.0,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_currentDate.year}. ${_getMonthName(_currentDate.month)} - Húzd a munkatársakat a megfelelő napra a tervezéshez.',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: Color(0xFF9CA3AF),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            // --- FŐ TARTALOM: Kétoszlopos elrendezés ---
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // BAL SÁV: Munkatársak listája (Draggable)
                  SizedBox(
                    width: 260,
                    child: _buildWorkersSidebar(),
                  ),
                  const SizedBox(width: 32), // Térköz a naptár és a sáv között
                  
                  // JOBB OLDAL: Havi Naptár Rács (DragTarget)
                  Expanded(
                    child: _buildCalendarGrid(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- BAL SÁV: MUNKATÁRSAK ---
  Widget _buildWorkersSidebar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0C10), // Mély háttér a sávnak
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Elérhető kollégák',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<String?>(
              future: UserService.getTeamId(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF)));
                
                // Munkatársak lekérdezése a Firebase-ből
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where('teamId', isEqualTo: snapshot.data)
                      // Ideális esetben: .where('role', isEqualTo: 'worker')
                      .snapshots(),
                  builder: (context, userSnapshot) {
                    if (!userSnapshot.hasData) return const SizedBox();
                    
                    final workers = userSnapshot.data!.docs;

                    if (workers.isEmpty) {
                      return const Center(
                        child: Text(
                          'Nincsenek kollégák',
                          style: TextStyle(color: Color(0xFF6B7280), fontFamily: 'Inter'),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: workers.length,
                      itemBuilder: (context, index) {
                        final worker = workers[index].data() as Map<String, dynamic>;
                        worker['id'] = workers[index].id; // ID mentése a drag-and-drop logikához
                        
                        final workerName = worker['name'] ?? 'Ismeretlen';

                        // DRAGGABLE: A felhasználó megfoghatja ezt a kártyát
                        return Draggable<Map<String, dynamic>>(
                          data: worker,
                          feedback: Material(
                            color: Colors.transparent,
                            child: _buildWorkerCard(workerName, isDragging: true),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.4,
                            child: _buildWorkerCard(workerName),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: _buildWorkerCard(workerName),
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

  Widget _buildWorkerCard(String name, {bool isDragging = false}) {
    return Container(
      width: 212, // Rögzített szélesség a sávon belül
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: isDragging ? const Color(0xFF1C202B).withOpacity(0.8) : const Color(0xFF161922),
        borderRadius: BorderRadius.circular(12),
        border: isDragging ? Border.all(color: const Color(0xFF00E5FF), width: 1) : null,
        boxShadow: isDragging
            ? [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 12, spreadRadius: 4)]
            : [],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: const Color(0xFF2DD4BF).withOpacity(0.2), // Finom Hue-shiftelt zöld
            child: const Icon(LucideIcons.user, size: 14, color: Color(0xFF2DD4BF)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(LucideIcons.gripVertical, size: 16, color: Color(0xFF4B5563)),
        ],
      ),
    );
  }

  // --- JOBB OLDAL: NAPTÁR RÁCS ---
  Widget _buildCalendarGrid() {
    return Column(
      children: [
        // A napok fejlécének rácsa (Hétfő, Kedd...)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            _DayHeader('HÉ'), _DayHeader('KE'), _DayHeader('SZE'),
            _DayHeader('CSÜ'), _DayHeader('PÉ'), _DayHeader('SZO'), _DayHeader('VA'),
          ],
        ),
        const SizedBox(height: 16),
        // Naptár háló (Grid)
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Kiszámoljuk egy cella méretét a térközök (gap) levonásával
              // 7 oszlop, tehát 6 térköz van köztük (6 * 12px)
              final cellWidth = (constraints.maxWidth - (6 * 12)) / 7;
              
              // Sorok száma a hónapban
              final totalCells = _daysInMonth + _firstDayOffset;
              final numRows = (totalCells / 7).ceil();
              // Cella magasság kiszámítása
              final cellHeight = (constraints.maxHeight - ((numRows - 1) * 12)) / numRows;

              return GridView.builder(
                physics: const NeverScrollableScrollPhysics(), // Nincs görgetés, pontosan kitölti a teret
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 12, // Térköz a rácsvonalak helyett (Lose the lines)
                  mainAxisSpacing: 12,
                  childAspectRatio: cellWidth / cellHeight, // Dinamikus arány
                ),
                itemCount: numRows * 7,
                itemBuilder: (context, index) {
                  if (index < _firstDayOffset || index >= (_daysInMonth + _firstDayOffset)) {
                    // Üres cellák a hónap előtt és után
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent, // Nincs vonal, nincs doboz
                        borderRadius: BorderRadius.circular(16),
                      ),
                    );
                  }

                  // Aktuális nap (1-től indul)
                  final dayNumber = index - _firstDayOffset + 1;
                  final dayDate = DateTime(_currentDate.year, _currentDate.month, dayNumber);
                  final isToday = dayDate.year == DateTime.now().year &&
                                  dayDate.month == DateTime.now().month &&
                                  dayDate.day == DateTime.now().day;

                  // DRAG TARGET: Ide lehet húzni a munkást
                  return DragTarget<Map<String, dynamic>>(
                    onWillAccept: (data) => true,
                    onAccept: (workerData) {
                      _showAssignTaskPopover(context, workerData, dayDate);
                    },
                    builder: (context, candidateData, rejectedData) {
                      final isHovered = candidateData.isNotEmpty; // Ha épp fölötte lebeg a kártya
                      
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        decoration: BoxDecoration(
                          color: isHovered 
                            ? const Color(0xFF00E5FF).withOpacity(0.1) // Lebegéskor felvillan
                            : const Color(0xFF161922), // Alap SaaS sötét felület
                          borderRadius: BorderRadius.circular(16),
                          border: isHovered 
                            ? Border.all(color: const Color(0xFF00E5FF), width: 1.5)
                            : (isToday ? Border.all(color: const Color(0xFF374151), width: 1) : null), // Mai nap finom kerettel
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Dátum szám
                            Text(
                              dayNumber.toString(),
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 16,
                                fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                                color: isToday ? const Color(0xFF00E5FF) : Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            
                            // Ide kerülnének a már beosztott feladatok chipek/pöttyök formájában
                            // Ehhez egy külön Firestore lekérdezés kellene (napi események StreamBuilder-e)
                            // Példa vizuális marker (Lose the lines - no text, just colored dot/chip)
                            if (dayNumber % 3 == 0) // Csak mockup vizualizáció
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF59E0B).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Terasz (2)', // Kognitív teher csökkentve: Rövid címke
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFF59E0B),
                                  ),
                                  overflow: TextOverflow.ellipsis,
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
    );
  }

  // --- FELUGRÓ ABLAK (Popover) ---
  // Amikor elengedik (Drop) a munkást a nap felett, feljön egy gyors ablak a részleteknek
  void _showAssignTaskPopover(BuildContext context, Map<String, dynamic> workerData, DateTime date) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF161922),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            'Feladat kiosztása',
            style: const TextStyle(
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
              Text(
                'Munkatárs: ${workerData['name']}',
                style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
              ),
              const SizedBox(height: 8),
              Text(
                'Dátum: ${date.year}. ${_getMonthName(date.month)} ${date.day}.',
                style: const TextStyle(color: Color(0xFF9CA3AF), fontFamily: 'Inter'),
              ),
              const SizedBox(height: 24),
              // Ide kerülhet a Projekt kiválasztó legördülő (Dropdown)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0C10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1C202B)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Válassz projektet...', style: TextStyle(color: Color(0xFF6B7280), fontFamily: 'Inter')),
                    Icon(LucideIcons.chevronDown, color: Color(0xFF6B7280), size: 16),
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
            ElevatedButton(
              onPressed: () {
                // ITT TÖRTÉNIK AZ ADATBÁZISBA ÍRÁS (Optimistic UI: Azonnal visszazárjuk az ablakot)
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${workerData['name']} beosztva!'),
                    backgroundColor: const Color(0xFF2DD4BF),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF), // Accent color
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
              child: const Text(
                'Mentés',
                style: TextStyle(color: Color(0xFF0A0C10), fontFamily: 'Inter', fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  // --- Segéd metódusok ---

  String _getMonthName(int month) {
    const months = ['Január', 'Február', 'Március', 'Április', 'Május', 'Június', 
                    'Július', 'Augusztus', 'Szeptember', 'Október', 'November', 'December'];
    return months[month - 1];
  }
}

class _DayHeader extends StatelessWidget {
  final String title;
  const _DayHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6B7280),
            letterSpacing: 1.0, // Fejléceknél jó a pozitív letter spacing
          ),
        ),
      ),
    );
  }
}