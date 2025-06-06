import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_camping_page.dart';
import 'account_page.dart';
import '../theme/home_theme.dart';
import '../theme/app_theme.dart';
import '../theme/login_theme.dart';
import '../services/session_utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _loading = false;
  String? _errorMessage;
  String? _toastMessage;
  Map<String, dynamic>? _user;
  List<dynamic> _destinations = [];
  int? _selectedDestinationId;
  String _vacationPassword = '';
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _fetchDestinations();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _fetchUserProfile() async {
    setState(() { _loading = true; });
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('https://mobile.vaca-meet.fr/api/mobile/user'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          _user = jsonDecode(response.body);
        });
        print('HOME PROFILE DATA: ' + _user.toString());
        print('HOME PROFILE PICTURE: ' + (_user?['profilePicture']?.toString() ?? 'null'));
      } else {
        setState(() {
          _errorMessage = 'Impossible de charger le profil utilisateur.';
        });
      }
    } catch (e) {
      await handleSessionExpired(context, e);
      setState(() {
        _errorMessage = 'Erreur de connexion au serveur.';
      });
    } finally {
      setState(() { _loading = false; });
    }
  }

  Future<void> _fetchDestinations() async {
    setState(() { _loading = true; });
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('https://mobile.vaca-meet.fr/api/mobile/destinations'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _destinations = data['destinations'] ?? [];
        });
      } else {
        setState(() {
          _errorMessage = 'Impossible de charger les destinations.';
        });
      }
    } catch (e) {
      await handleSessionExpired(context, e);
      setState(() {
        _errorMessage = 'Erreur de connexion au serveur.';
      });
    } finally {
      setState(() { _loading = false; });
    }
  }

  Future<void> _verifyVacationPassword() async {
    if (_selectedDestinationId == null) {
      setState(() { _passwordError = 'Veuillez sélectionner une destination'; });
      return;
    }
    if (_vacationPassword.trim().isEmpty) {
      setState(() { _passwordError = 'Veuillez entrer le mot de passe'; });
      return;
    }
    setState(() { _loading = true; _passwordError = null; });
    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse('https://mobile.vaca-meet.fr/api/mobile/verify-password'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'destinationId': _selectedDestinationId,
          'password': _vacationPassword,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['valid'] == true) {
        setState(() { _toastMessage = null; });
        if (mounted && _selectedDestinationId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomeCampingPage(campingId: _selectedDestinationId!),
            ),
          );
        }
      } else {
        setState(() { _passwordError = data['message'] ?? 'Mot de passe incorrect'; });
      }
    } catch (e) {
      setState(() { _passwordError = 'Erreur de connexion au serveur.'; });
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

  void _goToAccount() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AccountPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vaca Meet'),
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
                    _user != null && _user!['profilePicture'] != null && (_user!['profilePicture'] as String).isNotEmpty
                        ? CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.white,
                            backgroundImage: NetworkImage('https://mobile.vaca-meet.fr' + _user!['profilePicture']),
                          )
                        : Icon(Icons.account_circle, size: 80, color: Colors.white),
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
              const Spacer(),
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
            decoration: HomeTheme.backgroundDecoration,
          ),
          if (_loading)
            const Center(child: CircularProgressIndicator()),
          if (!_loading)
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                const SizedBox(height: 36),
                Center(
                  child: Column(
                    children: [
                      _user != null && _user!['profilePicture'] != null && (_user!['profilePicture'] as String).isNotEmpty
                          ? CircleAvatar(
                              radius: 48,
                              backgroundColor: Colors.white,
                              backgroundImage: NetworkImage('https://mobile.vaca-meet.fr' + _user!['profilePicture']),
                            )
                          : CircleAvatar(
                              radius: 48,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.account_circle, size: 80, color: Theme.of(context).primaryColor),
                            ),
                      const SizedBox(height: 12),
                      Text(
                        _user != null
                            ? 'Bienvenue, ${_user!['firstName'] ?? ''} !'
                            : 'Bienvenue sur Vaca Meet !',
                        style: HomeTheme.welcomeTextStyle,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Container(
                        decoration: AppTheme.cardDecoration,
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Choisissez votre destination', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<int>(
                                value: _selectedDestinationId,
                                items: _destinations.asMap().entries.map<DropdownMenuItem<int>>((entry) {
                                  final idx = entry.key;
                                  final dest = entry.value;
                                  final isLast = idx == _destinations.length - 1;
                                  return DropdownMenuItem<int>(
                                    value: dest['id'],
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          dest['username'] ?? 'Destination',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        if (!isLast)
                                          const Divider(
                                            height: 12,
                                            thickness: 1,
                                            color: Color(0xFFE0E0E0),
                                          ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedDestinationId = value;
                                    _passwordError = null;
                                  });
                                },
                                decoration: AppTheme.textFieldDecoration(
                                  label: 'Destination',
                                  icon: Icons.location_on_outlined,
                                ),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                                selectedItemBuilder: (context) {
                                  return _destinations.map<Widget>((dest) {
                                    return Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        dest['username'] ?? 'Destination',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AuthTheme.primaryColor,
                                        ),
                                      ),
                                    );
                                  }).toList();
                                },
                                dropdownColor: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                obscureText: true,
                                decoration: AppTheme.textFieldDecoration(
                                  label: 'Mot de passe',
                                  icon: Icons.lock_outline,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _vacationPassword = value;
                                    _passwordError = null;
                                  });
                                },
                              ),
                              if (_passwordError != null) ...[
                                const SizedBox(height: 8),
                                Text(_passwordError!, style: const TextStyle(color: Colors.red)),
                              ],
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.arrow_forward),
                                  label: const Text("Let's Go"),
                                  onPressed: _loading ? null : _verifyVacationPassword,
                                  style: AppTheme.primaryButtonStyle,
                                ),
                              ),
                              if (_errorMessage != null) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
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
                                    color: Colors.green.withOpacity(0.1),
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