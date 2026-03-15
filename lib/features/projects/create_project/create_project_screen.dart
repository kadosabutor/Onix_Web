import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:onix_web/data/services/get_user_team_id.dart';

class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllerek
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _clientNameController = TextEditingController();
  final _clientPhoneController = TextEditingController();
  final _clientEmailController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _clientNameController.dispose();
    _clientPhoneController.dispose();
    _clientEmailController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final teamId = await UserService.getTeamId();
      if (teamId == null) throw Exception('Nem található aktív munkaterület (Team ID).');

      // Optimistic adatmentés Firestore-ba
      await FirebaseFirestore.instance.collection('projects').add({
        'teamId': teamId,
        'projectName': _nameController.text.trim(),
        'projectAddress': _addressController.text.trim(),
        'clientName': _clientNameController.text.trim(),
        'clientPhone': _clientPhoneController.text.trim(),
        'clientEmail': _clientEmailController.text.trim(),
        'description': _descriptionController.text.trim(),
        'status': 'waiting', // Alapértelmezett induló státusz
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Projekt sikeresen létrehozva!'),
            backgroundColor: Color(0xFF10B981), // Success zöld
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop(); // Vissza a projektlistához
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hiba történt: $e'),
            backgroundColor: const Color(0xFFEF4444), // Error piros
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // A hátteret a WebMainLayout adja
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
        child: Center(
          // KOGNITÍV TEHER CSÖKKENTÉSE: Max szélesség beállítása asztali nézetre!
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Vissza gomb és Fejléc ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(LucideIcons.arrowLeft, color: Color(0xFF9CA3AF)),
                        hoverColor: const Color(0xFF1C202B),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Új Projekt Létrehozása',
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
                              'Add meg a projekt és a megrendelő alapadatait. Később további részleteket is hozzáadhatsz.',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                color: Color(0xFF9CA3AF),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // --- 1. SZEKCIÓ: Projekt Alapadatok ---
                  _buildSectionHeader('1. Projekt Alapadatai', LucideIcons.folderEdit),
                  _buildFormCard(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Projekt Megnevezése *',
                            hintText: 'pl. Márai Sándor u. 9/A Terasz',
                            prefixIcon: Icon(LucideIcons.type),
                          ),
                          validator: (value) => value!.isEmpty ? 'Kötelező mező' : null,
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _addressController,
                          decoration: const InputDecoration(
                            labelText: 'Munkavégzés Pontos Címe *',
                            hintText: 'Irányítószám, Város, Utca, Házszám',
                            prefixIcon: Icon(LucideIcons.mapPin),
                          ),
                          validator: (value) => value!.isEmpty ? 'Kötelező mező' : null,
                        ),
                      ],
                    ),
                  ),

                  // --- 2. SZEKCIÓ: Ügyfél Adatok (Kétoszlopos Layout) ---
                  _buildSectionHeader('2. Ügyfél (Megrendelő) Adatai', LucideIcons.user),
                  _buildFormCard(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _clientNameController,
                          decoration: const InputDecoration(
                            labelText: 'Ügyfél Neve / Cégnév *',
                            hintText: 'pl. Kovács János vagy OKert Kft.',
                            prefixIcon: Icon(LucideIcons.userCheck),
                          ),
                          validator: (value) => value!.isEmpty ? 'Kötelező mező' : null,
                        ),
                        const SizedBox(height: 24),
                        // Asztali nézet: Egymás melletti mezők
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _clientPhoneController,
                                decoration: const InputDecoration(
                                  labelText: 'Telefonszám',
                                  hintText: '+36 30 123 4567',
                                  prefixIcon: Icon(LucideIcons.phone),
                                ),
                              ),
                            ),
                            const SizedBox(width: 24), // 24px grid gap
                            Expanded(
                              child: TextFormField(
                                controller: _clientEmailController,
                                decoration: const InputDecoration(
                                  labelText: 'E-mail Cím',
                                  hintText: 'pelda@email.com',
                                  prefixIcon: Icon(LucideIcons.mail),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // --- 3. SZEKCIÓ: Egyéb ---
                  _buildSectionHeader('3. Egyéb Információk', LucideIcons.alignLeft),
                  _buildFormCard(
                    child: TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Projekt Leírása / Jegyzetek',
                        hintText: 'Minden olyan információ, amit a terepen lévő kollégáknak tudnia kell...',
                        alignLabelWithHint: true,
                      ),
                    ),
                  ),

                  // --- Akció Gombok ---
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isLoading ? null : () => context.pop(),
                        child: const Text('Mégsem'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _submitForm,
                        icon: _isLoading 
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0A0C10)))
                            : const Icon(LucideIcons.save, size: 18),
                        label: Text(_isLoading ? 'Mentés folyamatban...' : 'Projekt Létrehozása'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 64), // Alsó kifutó
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Segéd Metódusok az Űrlap építéséhez ---

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, top: 24.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF00E5FF)),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF161922), // AppTheme OnixColors.surfaceHighlight
        borderRadius: BorderRadius.circular(24),
      ),
      child: child,
    );
  }
}