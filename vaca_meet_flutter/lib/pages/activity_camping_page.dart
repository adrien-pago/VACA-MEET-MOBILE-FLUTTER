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

  // Types d'activités et couleurs associées
  final Map<String, Color> activityColors = {
    'fitness': Color(0xFFFF5A4C),
    'meditation': Color(0xFF2ECC85),
    'yoga': Color(0xFF25D0B6),
    'water': Color(0xFF38BDF8),
    'sport': Color(0xFFFF9452),
    'kids': Color(0xFFFF32B1),
    'workshop': Color(0xFF6C5DD3),
    'leisure': Color(0xFF8E44EF),
    'culture': Color(0xFFFFCA45),
    'food': Color(0xFFF9B233),
  };

  // Semaine courante (lundi au dimanche)
  DateTime currentMonday = _getMonday(DateTime.now());

  static DateTime _getMonday(DateTime date) {
    return date.subtract(Duration(days: date.weekday == 7 ? 6 : date.weekday - 1));
  }

  bool _loading = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _activities = [];

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
      final data = await service.getCampingInfo(widget.campingId);
      if (data != null && data['activities'] is List) {
        setState(() {
          _activities = List<Map<String, dynamic>>.from(data['activities']);
        });
      } else {
        setState(() {
          _errorMessage = "Aucune activité trouvée.";
        });
      }
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
  }

  void _goToNextWeek() {
    setState(() {
      currentMonday = currentMonday.add(const Duration(days: 7));
    });
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
    // Pour l'instant, on ne filtre pas par date réelle, car l'API ne fournit pas de date précise
    return _activities;
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
                                          final activity = activities.firstWhere(
                                            (a) => _dayToIndex(a['day'] ?? '') == dayIdx && _timeToIndex(a['time'] ?? '') == timeIdx,
                                            orElse: () => {},
                                          );
                                          return Container(
                                            width: 100,
                                            height: 60,
                                            margin: const EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              color: activity.isNotEmpty && activityColors[activity['type']] != null
                                                  ? activityColors[activity['type']]!.withOpacity(0.85)
                                                  : Colors.grey[200],
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: activity.isNotEmpty
                                                ? Center(
                                                    child: Text(
                                                      activity['title'] ?? '',
                                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  )
                                                : null,
                                          );
                                        }),
                                      ],
                                    );
                                  }),
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