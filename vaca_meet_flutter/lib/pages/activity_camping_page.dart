import 'package:flutter/material.dart';
import 'activity_camping_service.dart';

class ActivityCampingPage extends StatefulWidget {
  final int campingId;
  const ActivityCampingPage({super.key, required this.campingId});

  @override
  State<ActivityCampingPage> createState() => _ActivityCampingPageState();
}

class _ActivityCampingPageState extends State<ActivityCampingPage> {
  // Jours de la semaine
  final List<String> daysOfWeek = [
    'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'
  ];

  // Plages horaires
  final List<String> timeSlots = [
    '8h - 9h',
    '9h - 10h',
    '10h - 11h',
    '11h - 12h',
    '12h - 13h',
    '13h - 14h',
    '14h - 15h',
    '15h - 16h',
    '16h - 17h',
    '17h - 18h',
    '18h - 19h',
    'Soirée',
  ];

  // Semaine courante (lundi au dimanche)
  DateTime currentMonday = _getMonday(DateTime.now());

  static DateTime _getMonday(DateTime date) {
    return date.subtract(Duration(days: date.weekday == 7 ? 6 : date.weekday - 1));
  }

  bool _loading = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _activities = [];
  Map<int, Map<String, dynamic>> _categories = {};

  @override
  void initState() {
    super.initState();
    _fetchActivities();
  }

  Future<void> _fetchActivities() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final service = ActivityCampingService();
      final weekStart = currentMonday;
      final weekEnd = currentMonday.add(const Duration(days: 6));
      final activities = await service.getActivities(widget.campingId, weekStart: weekStart, weekEnd: weekEnd);
      // Extraire les catégories uniques
      final Map<int, Map<String, dynamic>> categories = {};
      for (final act in activities) {
        if (act['type'] is Map && act['type']['id'] != null) {
          categories[act['type']['id']] = act['type'];
        }
      }
      setState(() {
        _activities = activities;
        _categories = categories;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement des activités.';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _goToPreviousWeek() {
    setState(() {
      currentMonday = currentMonday.subtract(const Duration(days: 7));
    });
    _fetchActivities();
  }

  void _goToNextWeek() {
    setState(() {
      currentMonday = currentMonday.add(const Duration(days: 7));
    });
    _fetchActivities();
  }

  String _weekDisplay() {
    final sunday = currentMonday.add(const Duration(days: 6));
    String format(DateTime d) => "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";
    return "${format(currentMonday)} - ${format(sunday)}";
  }

  // Mappe le nom du jour en index (0 = Lundi, ...)
  int _dayToIndex(String day) {
    return daysOfWeek.indexWhere((d) => d.toLowerCase() == day.toLowerCase());
  }

  // Mappe le créneau horaire en index
  int _timeToIndex(String time) {
    return timeSlots.indexWhere((t) => t.toLowerCase() == time.toLowerCase());
  }

  // Filtre les activités pour la semaine courante
  List<Map<String, dynamic>> getActivitiesForCurrentWeek() {
    return _activities;
  }

  Color? _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    try {
      String hexColor = hex.replaceAll('#', '');
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }
      return Color(int.parse(hexColor, radix: 16));
    } catch (_) {
      return null;
    }
  }

  // Nouvelle fonction pour déterminer les index de créneaux couverts par une activité
  List<int> _getTimeSlotIndexes(String start, String end) {
    final slots = <int>[];
    final startParts = start.split(":");
    final endParts = end.split(":");
    int startHour = int.parse(startParts[0]);
    int startMin = int.parse(startParts[1]);
    int endHour = int.parse(endParts[0]);
    int endMin = int.parse(endParts[1]);
    // Si l'activité commence à 20h ou après, on la met dans 'Soirée'
    if (startHour >= 20) {
      return [timeSlots.length - 1];
    }
    // On parcourt tous les créneaux sauf 'Soirée'
    for (int i = 0; i < timeSlots.length - 1; i++) {
      final slotStart = 8 + i;
      final slotEnd = slotStart + 1;
      // Si l'activité chevauche ce créneau
      final slotStartTime = DateTime(0, 1, 1, slotStart, 0);
      final slotEndTime = DateTime(0, 1, 1, slotEnd, 0);
      final actStart = DateTime(0, 1, 1, startHour, startMin);
      final actEnd = DateTime(0, 1, 1, endHour, endMin);
      if (actEnd.isAfter(slotStartTime) && actStart.isBefore(slotEndTime)) {
        slots.add(i);
      }
    }
    return slots;
  }

  @override
  Widget build(BuildContext context) {
    final activities = getActivitiesForCurrentWeek();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planning des activités'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6DD5FA), Color(0xFF2980B9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(
                    child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                  )
                : Column(
                    children: [
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: _goToPreviousWeek,
                          ),
                          Text(
                            _weekDisplay(),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: _goToNextWeek,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                children: [
                                  // En-tête des jours
                                  Row(
                                    children: [
                                      Container(
                                        width: 80,
                                        alignment: Alignment.center,
                                        child: const Text('Horaire', style: TextStyle(fontWeight: FontWeight.bold)),
                                      ),
                                      ...List.generate(daysOfWeek.length, (dayIdx) {
                                        final day = daysOfWeek[dayIdx];
                                        final today = DateTime.now();
                                        final currentDay = currentMonday.add(Duration(days: dayIdx));
                                        final isToday = today.day == currentDay.day && today.month == currentDay.month && today.year == currentDay.year;
                                        return Container(
                                          width: 100,
                                          alignment: Alignment.center,
                                          decoration: isToday
                                              ? BoxDecoration(
                                                  borderRadius: BorderRadius.circular(8),
                                                  color: Colors.blue.withOpacity(0.15),
                                                )
                                              : null,
                                          child: Text(
                                            day,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: isToday ? Colors.blue[900] : Colors.black87,
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                  // Planning
                                  ...List.generate(timeSlots.length, (timeIdx) {
                                    return Row(
                                      children: [
                                        Container(
                                          width: 80,
                                          height: 60,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: timeSlots[timeIdx] == 'Soirée' ? Colors.blue[50] : Colors.white,
                                          ),
                                          child: Text(timeSlots[timeIdx], style: const TextStyle(fontSize: 13)),
                                        ),
                                        ...List.generate(daysOfWeek.length, (dayIdx) {
                                          // Chercher une activité pour ce créneau
                                          final activitiesInSlot = activities.where((a) {
                                            if (a['day'] == null || a['start_time'] == null || a['end_time'] == null) return false;
                                            return _dayToIndex(a['day']) == dayIdx && _getTimeSlotIndexes(a['start_time'], a['end_time']).contains(timeIdx);
                                          }).toList();
                                          return Container(
                                            width: 100,
                                            height: 60,
                                            margin: const EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              color: activitiesInSlot.isNotEmpty ? Colors.blue : Colors.grey[200],
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: activitiesInSlot.isNotEmpty
                                                ? ListView(
                                                    physics: const NeverScrollableScrollPhysics(),
                                                    children: activitiesInSlot.map((activity) {
                                                      final cat = activity['type'] is Map ? activity['type'] : null;
                                                      final color = cat != null ? _parseColor(cat['color']) : Colors.grey[400];
                                                      return Container(
                                                        margin: const EdgeInsets.symmetric(vertical: 2),
                                                        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: color,
                                                          borderRadius: BorderRadius.circular(6),
                                                          border: Border.all(color: color ?? Colors.grey, width: 2),
                                                        ),
                                                        child: Text(
                                                          activity['title'] ?? '',
                                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                                          textAlign: TextAlign.center,
                                                        ),
                                                      );
                                                    }).toList(),
                                                  )
                                                : null,
                                          );
                                        }),
                                      ],
                                    );
                                  }),
                                  // Légende des catégories
                                  if (_categories.isNotEmpty) ...[
                                    const SizedBox(height: 24),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: _categories.values.map((cat) {
                                        final color = _parseColor(cat['color']);
                                        return Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 8),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 18,
                                                height: 18,
                                                decoration: BoxDecoration(
                                                  color: color ?? Colors.grey,
                                                  borderRadius: BorderRadius.circular(6),
                                                  border: Border.all(color: Colors.black12),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(cat['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w500)),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
} 