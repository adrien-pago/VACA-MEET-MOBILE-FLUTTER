import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _loading = false;
  String? _errorMessage;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final url = Uri.parse('https://mobile.vaca-meet.fr/api/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', data['token']);
        }
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Erreur de connexion
        final data = jsonDecode(response.body);
        setState(() {
          _errorMessage = data['message'] ?? 'Identifiants incorrects. Veuillez réessayer.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de connexion au serveur.';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _goToRegister() {
    Navigator.pushNamed(context, '/register');
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Effet de fond (optionnel)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6DD5FA), Color(0xFF2980B9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo
                        Icon(Icons.account_circle, size: 80, color: Theme.of(context).primaryColor),
                        const SizedBox(height: 8),
                        // Titre
                        Text(
                          'Vaca Meet',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            foreground: Paint()
                              ..shader = const LinearGradient(
                                colors: [Color(0xFF6DD5FA), Color(0xFF2980B9)],
                              ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Sous-titre
                        const Text(
                          'Connexion',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 16),
                        // Email
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.mail_outline),
                          ),
                          validator: (value) =>
                              value == null || value.isEmpty ? 'Veuillez entrer votre email' : null,
                        ),
                        const SizedBox(height: 16),
                        // Mot de passe
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Mot de passe',
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                          validator: (value) =>
                              value == null || value.isEmpty ? 'Veuillez entrer votre mot de passe' : null,
                        ),
                        const SizedBox(height: 24),
                        // Bouton connexion
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.arrow_forward),
                            label: _loading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Se connecter'),
                            onPressed: _loading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Lien vers inscription
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Pas encore de compte ?"),
                            TextButton(
                              onPressed: _goToRegister,
                              child: const Text("S'inscrire"),
                            ),
                          ],
                        ),
                        // Affichage des erreurs
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 