import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:okoskert_internal/core/utils/services/machine_work_hours_service.dart';
import 'package:okoskert_internal/data/services/get_user_team_id.dart';
import 'package:slide_to_act/slide_to_act.dart';

class AddWorkHoursBottomSheet extends StatefulWidget {
  final String machineId;
  const AddWorkHoursBottomSheet({super.key, required this.machineId});

  @override
  State<AddWorkHoursBottomSheet> createState() =>
      _AddWorkHoursBottomSheetState();
}

class _AddWorkHoursBottomSheetState extends State<AddWorkHoursBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _newHoursController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  late TextEditingController _dateController;
  num _currentWorkHours = 0;
  bool _isLoadingCurrentHours = true;
  bool _isProjectEnabled = false;
  String? _selectedProjectId;
  List<Map<String, String>> _projects = [];

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(text: _formatDate(_selectedDate));
    _loadCurrentWorkHours();
    _loadProjects();
  }

  @override
  void dispose() {
    _newHoursController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentWorkHours() async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('machines')
              .doc(widget.machineId)
              .get();

      if (doc.exists) {
        final data = doc.data();
        _currentWorkHours = data?['hours'] as num? ?? 0;
      }
      if (mounted) {
        setState(() {
          _isLoadingCurrentHours = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoadingCurrentHours = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hiba történt az adatok betöltésekor: $error'),
          ),
        );
      }
    }
  }

  Future<void> _loadProjects() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('projects')
              .where('teamId', isEqualTo: await UserService.getTeamId())
              .get();

      if (mounted) {
        setState(() {
          _projects =
              snapshot.docs.map((doc) {
                final data = doc.data();
                return {
                  'id': doc.id,
                  'name': data['projectName'] as String? ?? 'Névtelen projekt',
                };
              }).toList();
          // Rendezés név szerint
          _projects.sort((a, b) => a['name']!.compareTo(b['name']!));
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hiba történt a projektek betöltésekor: $error'),
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}. ${date.month.toString().padLeft(2, '0')}. ${date.day.toString().padLeft(2, '0')}.';
  }

  String _formatHours(num value) {
    final asDouble = value.toDouble();
    return asDouble % 1 == 0
        ? asDouble.toInt().toString()
        : asDouble.toStringAsFixed(1);
  }

  double? _parseHours(String raw) {
    return double.tryParse(raw.trim().replaceAll(',', '.'));
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedDate = DateTime(picked.year, picked.month, picked.day);
        _dateController.text = _formatDate(_selectedDate);
      });
    }
  }

  Future<void> _saveWorkHours() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final newHours = _parseHours(_newHoursController.text) ?? 0.0;

      await MachineWorkHoursService.saveWorkHours(
        machineId: widget.machineId,
        newHours: newHours,
        date: _selectedDate,
        previousHours: _currentWorkHours,
        projectEnabled: _isProjectEnabled,
        assignedProjectId: _selectedProjectId,
      );

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Óraállás sikeresen mentve')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hiba történt a mentéskor: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Text(
                  'Óraállás hozzáadása',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Dátum választó
            TextFormField(
              controller: _dateController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Dátum',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: _selectDate,
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _newHoursController,
              builder: (context, value, _) {
                final parsedNewHours = _parseHours(value.text);
                final diff =
                    parsedNewHours != null
                        ? parsedNewHours - _currentWorkHours
                        : null;
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _HoursValue(
                          label: 'Jelenlegi',
                          value:
                              _isLoadingCurrentHours
                                  ? 'Betöltés...'
                                  : '${_formatHours(_currentWorkHours)} óra',
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(Icons.arrow_forward_rounded),
                      ),
                      Expanded(
                        child: _HoursValue(
                          label: 'Következő',
                          value:
                              parsedNewHours == null
                                  ? 'Add meg az új óraállást'
                                  : '${_formatHours(parsedNewHours)} óra',
                          helper:
                              diff == null
                                  ? null
                                  : '+${_formatHours(diff)} óra változás',
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _newHoursController,
              decoration: const InputDecoration(
                labelText: 'Új óraállás',
                hintText: 'Pl. 1245.5',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Kérjük, adja meg az új óraállást';
                }
                final parsedValue = _parseHours(value);
                if (parsedValue == null) {
                  return 'Kérjük, érvényes számot adjon meg';
                }
                if (parsedValue <= _currentWorkHours) {
                  return 'Az új óraállás nem lehet kisebb, mint a jelenlegi óraállás';
                }
                if ((parsedValue - _currentWorkHours).abs() > 10) {
                  return 'Az új óraállás nem lehet nagyobb, mint 10 óra';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Projekt switch
            ListTile(
              leading: Switch(
                value: _isProjectEnabled,
                onChanged: (value) {
                  setState(() {
                    _isProjectEnabled = value;
                    if (!value) {
                      _selectedProjectId = null;
                    }
                  });
                },
              ),
              title: const Text('Projekt'),
            ),
            // Projekt dropdown (csak ha a switch be van kapcsolva)
            if (_isProjectEnabled) ...[
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedProjectId,
                decoration: const InputDecoration(
                  labelText: 'Projekt kiválasztása',
                  border: OutlineInputBorder(),
                ),
                items:
                    _projects.map((project) {
                      return DropdownMenuItem<String>(
                        value: project['id'],
                        child: Text(project['name']!),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProjectId = value;
                  });
                },
                validator: (value) {
                  if (_isProjectEnabled && value == null) {
                    return 'Kérjük, válasszon ki egy projektet';
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: SlideAction(
                sliderRotate: false,
                outerColor: Theme.of(context).colorScheme.primary,
                onSubmit: _saveWorkHours,
                child: Text(
                  'Mentés',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _HoursValue extends StatelessWidget {
  final String label;
  final String value;
  final String? helper;

  const _HoursValue({required this.label, required this.value, this.helper});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
        if (helper != null) ...[
          const SizedBox(height: 2),
          Text(
            helper!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ],
    );
  }
}
