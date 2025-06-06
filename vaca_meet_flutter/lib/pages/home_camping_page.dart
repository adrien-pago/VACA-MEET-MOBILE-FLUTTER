import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'activity_camping_page.dart';
import 'account_page.dart';
import '../theme/home_theme.dart';
import '../theme/app_theme.dart';
import '../theme/home_camping_theme.dart';
import '../services/session_utils.dart';

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
      await handleSessionExpired(context, e);
      setState(() { _errorMessage = 'Erreur de connexion au serveur.'; });
    } finally {
      setState(() { _loading = false; });
    }
  }

  void _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Oui'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      Navigator.pushReplacementNamed(context, '/');
    }
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
        centerTitle: true,
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
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6DD5FA), Colors.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                child: Column(
                  children: [
                    Icon(Icons.account_circle, size: 80, color: Colors.white),
                    const SizedBox(height: 8),
                    Text(
                      _user != null ? (_user!['firstName'] ?? '') : '',
                      style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _user != null ? _user!['username'] ?? '' : '',
                      style: const TextStyle(color: Colors.black87, fontSize: 14),
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
            decoration: HomeCampingTheme.backgroundDecoration,
          ),
          if (_loading)
            const Center(child: CircularProgressIndicator()),
          if (!_loading)
            Column(
              children: [
                const SizedBox(height: 28),
                Text(
                  campingName.isNotEmpty ? 'Bienvenue au $campingName' : 'Bienvenue au camping',
                  style: HomeCampingTheme.welcomeTextStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final cardWidth = constraints.maxWidth;
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: cardWidth,
                                child: Container(
                                  decoration: HomeCampingTheme.cardDecoration,
                                  child: Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Animations du camping',
                                          style: HomeCampingTheme.sectionTitleStyle,
                                        ),
                                        const SizedBox(height: 8),
                                        TextButton.icon(
                                          onPressed: _goToActivity,
                                          icon: const Icon(Icons.calendar_today, color: Colors.black),
                                          label: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text('Voir les activités'),
                                              const SizedBox(width: 6),
                                              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
                                            ],
                                          ),
                                          style: HomeCampingTheme.activityButtonStyle,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: cardWidth,
                                child: Container(
                                  decoration: HomeCampingTheme.cardDecoration,
                                  child: Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Services disponibles',
                                          style: HomeCampingTheme.sectionTitleStyle,
                                        ),
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
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: cardWidth,
                                child: Container(
                                  decoration: HomeCampingTheme.cardDecoration,
                                  child: Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Activités des vacanciers',
                                          style: HomeCampingTheme.sectionTitleStyle,
                                        ),
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
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
} 