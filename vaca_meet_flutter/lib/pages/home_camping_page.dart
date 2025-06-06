import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'activity_camping_page.dart';
import 'account_page.dart';

class HomeCampingPage extends StatefulWidget {
  final int campingId;
  const HomeCampingPage({super.key, required this.campingId});

  @override
  State<HomeCampingPage> createState() => _HomeCampingPageState();
}

class _HomeCampingPageState extends State<HomeCampingPage> {
  bool _loading = false;
  String? _errorMessage;
  Map<String, dynamic>? _user;
  Map<String, dynamic>? _campingInfo;
  String? _toastMessage;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _fetchData() async {
    setState(() { _loading = true; });
    try {
      final token = await _getToken();
      // Profil utilisateur
      final userResp = await http.get(
        Uri.parse('https://mobile.vaca-meet.fr/api/mobile/user'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (userResp.statusCode == 200) {
        _user = jsonDecode(userResp.body);
      }
      // Infos camping
      final campingResp = await http.get(
        Uri.parse('https://mobile.vaca-meet.fr/api/mobile/camping/info/${widget.campingId}'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (campingResp.statusCode == 200) {
        _campingInfo = jsonDecode(campingResp.body);
      } else {
        setState(() { _errorMessage = "Impossible de charger les infos du camping."; });
      }
    } catch (e) {
      setState(() { _errorMessage = 'Erreur de connexion au serveur.'; });
    } finally {
      setState(() { _loading = false; });
    }
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.pushReplacementNamed(context, '/');
  }

  void _goToHome() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _goToAccount() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AccountPage()),
    );
  }

  void _goToActivity() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActivityCampingPage(campingId: widget.campingId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final campingName = _campingInfo?['camping']?['name'] ?? '';
    final services = _campingInfo?['services'] ?? [];
    final activities = _campingInfo?['activities'] ?? [];
    return Scaffold(
      appBar: AppBar(
        title: Text(campingName.isNotEmpty ? campingName : 'Camping'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: 'Menu',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                color: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                child: Column(
                  children: [
                    Icon(Icons.account_circle, size: 64, color: Colors.white),
                    const SizedBox(height: 8),
                    Text(
                      _user != null ? '${_user!['firstName'] ?? ''} ${_user!['lastName'] ?? ''}' : '',
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _user != null ? _user!['username'] ?? '' : '',
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Accueil Vaca Meet'),
                onTap: () {
                  Navigator.pop(context);
                  _goToHome();
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Infos Camping'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Infos Camping à venir !')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Compte'),
                onTap: () {
                  Navigator.pop(context);
                  _goToAccount();
                },
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _logout();
                },
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6DD5FA), Color(0xFF2980B9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          if (_loading)
            const Center(child: CircularProgressIndicator()),
          if (!_loading)
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      campingName.isNotEmpty ? 'Bienvenue au $campingName' : 'Bienvenue au camping',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        foreground: Paint()
                          ..shader = LinearGradient(
                            colors: [Color(0xFF6DD5FA), Color(0xFF2980B9)],
                          ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Animations du camping', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                TextButton.icon(
                                  onPressed: _goToActivity,
                                  icon: const Icon(Icons.calendar_today),
                                  label: const Text('Voir les activités'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Services disponibles', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            if (services.isNotEmpty)
                              ...services.map<Widget>((service) => ListTile(
                                    leading: const Icon(Icons.room_service),
                                    title: Text(service['name'] ?? ''),
                                    subtitle: Text(service['description'] ?? ''),
                                    trailing: Text(service['hours'] ?? ''),
                                  ))
                            else
                              const Text('Aucun service disponible pour le moment.'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Activités des vacanciers', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            if (activities.isNotEmpty)
                              ...activities.map<Widget>((activity) => ListTile(
                                    leading: const Icon(Icons.people),
                                    title: Text(activity['title'] ?? ''),
                                    subtitle: Text(activity['description'] ?? ''),
                                    trailing: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(activity['day'] ?? ''),
                                        Text(activity['time'] ?? ''),
                                        Text(activity['location'] ?? ''),
                                      ],
                                    ),
                                  ))
                            else
                              const Text('Aucune activité organisée pour le moment.'),
                          ],
                        ),
                      ),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withAlpha((0.1 * 255).toInt()),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (_toastMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withAlpha((0.1 * 255).toInt()),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline, color: Colors.green),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _toastMessage!,
                                style: const TextStyle(color: Colors.green),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
} 