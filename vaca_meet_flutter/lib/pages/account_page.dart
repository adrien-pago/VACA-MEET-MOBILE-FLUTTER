import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/profile_service.dart';
import '../theme/acount_theme.dart';
import '../services/session_utils.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedTheme = 'light';
  bool _loading = false;
  String? _errorMessage;
  String? _successMessage;
  Map<String, dynamic>? _userProfile;
  bool _editMode = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final service = ProfileService();
      final profile = await service.getFullProfile();
      setState(() {
        _userProfile = profile;
        _firstNameController.text = profile['firstName'] ?? '';
        _lastNameController.text = profile['lastName'] ?? '';
        _selectedTheme = profile['theme'] ?? 'light';
      });
    } catch (e) {
      await handleSessionExpired(context, e);
      setState(() {
        _errorMessage = 'Erreur lors du chargement du profil';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final service = ProfileService();
      await service.updateMobileProfile(
        _firstNameController.text,
        _lastNameController.text,
      );
      setState(() {
        _successMessage = 'Profil mis à jour avec succès';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la mise à jour du profil';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _updateTheme() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final service = ProfileService();
      await service.updateTheme(_selectedTheme);
      setState(() {
        _successMessage = 'Thème mis à jour avec succès';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la mise à jour du thème';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _updatePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final service = ProfileService();
      await service.updatePassword(
        _currentPasswordController.text,
        _newPasswordController.text,
      );
      setState(() {
        _successMessage = 'Mot de passe mis à jour avec succès';
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la mise à jour du mot de passe';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Map<String, dynamic>? get _profileData => _userProfile?['user'] ?? _userProfile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon compte'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Infos'),
            Tab(text: 'Thème'),
            Tab(text: 'Mot de passe'),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: AccountTheme.backgroundDecoration,
          ),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else
            TabBarView(
              controller: _tabController,
              children: [
                _buildProfileTab(),
                _buildThemeTab(),
                _buildPasswordTab(),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: AccountTheme.cardDecoration,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: !_editMode ? _buildProfileDisplay() : _buildProfileEdit(),
        ),
      ),
    );
  }

  Widget _buildProfileDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Informations du compte', style: AccountTheme.sectionTitleStyle, textAlign: TextAlign.center),
        const SizedBox(height: 24),
        _displayField(
          icon: Icons.email_outlined,
          label: 'Email',
          value: _profileData?['username'] ?? '',
        ),
        const SizedBox(height: 12),
        _displayField(
          icon: Icons.person_outline,
          label: 'Prénom',
          value: _profileData?['firstName'] ?? '',
        ),
        const SizedBox(height: 12),
        _displayField(
          icon: Icons.person_outline,
          label: 'Nom',
          value: _profileData?['lastName'] ?? '',
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => setState(() => _editMode = true),
            icon: const Icon(Icons.edit),
            label: const Text('Modifier'),
            style: AccountTheme.bigButtonStyle,
          ),
        ),
      ],
    );
  }

  Widget _displayField({required IconData icon, required String label, required String value}) {
    return Container(
      decoration: AccountTheme.displayFieldDecoration,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: AccountTheme.valueStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileEdit() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Modifier mes informations', style: AccountTheme.titleStyle, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          TextFormField(
            controller: _firstNameController,
            decoration: AccountTheme.inputDecoration(label: 'Prénom', icon: Icons.person_outline),
            validator: (value) => value == null || value.isEmpty ? 'Veuillez entrer votre prénom' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _lastNameController,
            decoration: AccountTheme.inputDecoration(label: 'Nom', icon: Icons.person_outline),
            validator: (value) => value == null || value.isEmpty ? 'Veuillez entrer votre nom' : null,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _loading ? null : () async {
                  await _updateProfile();
                  if (_errorMessage == null) {
                    await _loadUserProfile();
                    setState(() => _editMode = false);
                  }
                },
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text('Valider', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  elevation: 4,
                  shadowColor: Colors.green.withOpacity(0.2),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _loading ? null : () {
                  setState(() {
                    _editMode = false;
                    _firstNameController.text = _profileData?['firstName'] ?? '';
                    _lastNameController.text = _profileData?['lastName'] ?? '';
                  });
                },
                icon: const Icon(Icons.close, color: Colors.white),
                label: const Text('Annuler', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  elevation: 4,
                  shadowColor: Colors.red.withOpacity(0.2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RadioListTile<String>(
                title: const Text('Clair'),
                value: 'light',
                groupValue: _selectedTheme,
                onChanged: (value) {
                  setState(() {
                    _selectedTheme = value!;
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text('Sombre'),
                value: 'dark',
                groupValue: _selectedTheme,
                onChanged: (value) {
                  setState(() {
                    _selectedTheme = value!;
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loading ? null : _updateTheme,
                icon: const Icon(Icons.save),
                label: const Text('Enregistrer'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _passwordFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _currentPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Mot de passe actuel',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Veuillez entrer votre mot de passe actuel' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Nouveau mot de passe',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un nouveau mot de passe';
                    }
                    if (value.length < 6) {
                      return 'Le mot de passe doit contenir au moins 6 caractères';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirmer le mot de passe',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez confirmer le mot de passe';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Les mots de passe ne correspondent pas';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _loading ? null : _updatePassword,
                  icon: const Icon(Icons.save),
                  label: const Text('Enregistrer'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 