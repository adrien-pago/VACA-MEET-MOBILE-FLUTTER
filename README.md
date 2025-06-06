# Vaca Meet Mobile

Application mobile moderne développée avec Flutter pour les utilisateurs du camping.

## 📱 Présentation du Projet

Vaca Meet est une application mobile permettant aux utilisateurs de se connecter et d'avoir connaissance de toutes les activités et plus du camping. Elle utilise une architecture moderne avec Flutter pour le frontend et une API RESTful Symfony pour le backend.

## 🏗️ Architecture Technique

Le projet est divisé en deux parties principales:

### Frontend (vaca-meet-mobile-flutter)

Application mobile native développée avec Flutter, offrant une expérience utilisateur moderne et fluide.

### Backend (vaca-meet-api)

API RESTful développée avec Symfony 6.4, gérant l'authentification JWT, la persistance des données et la logique métier.

## 🗂️ Structure du Projet

```
VACA-MEET-MOBILE-FLUTTER/
├── lib/                   # Code source Flutter
│   ├── config/           # Configuration de l'application
│   ├── models/           # Modèles de données
│   ├── pages/            # Pages de l'application
│   ├── services/         # Services (API, authentification)
│   ├── widgets/          # Widgets réutilisables
│   └── main.dart         # Point d'entrée de l'application
├── assets/               # Ressources statiques
└── test/                # Tests unitaires et d'intégration
```

## 📲 Frontend (Flutter)

### Technologies utilisées

- **Flutter**: Framework UI pour le développement cross-platform
- **Dart**: Langage de programmation
- **Provider**: Gestion d'état
- **Shared Preferences**: Stockage local
- **HTTP**: Client HTTP pour les appels API

### Structure du Frontend

```
lib/
├── config/              # Configuration
│   └── config.dart      # Configuration globale
├── models/             # Modèles de données
│   └── user_profile.dart # Modèle utilisateur
├── pages/              # Pages de l'application
│   ├── home_page.dart  # Page d'accueil
│   ├── login_page.dart # Authentification
│   ├── register_page.dart # Création de compte
│   └── account_page.dart # Gestion du compte
├── services/           # Services
│   ├── auth_service.dart # Service d'authentification
│   └── profile_service.dart # Service de profil
├── widgets/            # Widgets réutilisables
│   └── glass_card.dart # Carte avec effet glassmorphism
└── main.dart           # Point d'entrée
```

### Fonctionnalités Frontend

- **Design System**: Interface utilisateur moderne et cohérente
- **Animations fluides**: Transitions et effets visuels
- **Mode sombre**: Support automatique du thème clair/sombre
- **Responsive Design**: S'adapte à toutes les tailles d'écran
- **Sécurité**: Authentification JWT avec stockage sécurisé
- **Glassmorphism**: Effets visuels modernes

## 🖥️ Backend (vaca-meet-api)

### Technologies utilisées

- **Symfony 6.4**: Framework PHP moderne
- **Doctrine ORM**: Mapping objet-relationnel
- **Lexik JWT**: Authentification par token JWT
- **API Platform**: Simplification du développement d'API REST

### Points d'API

#### Authentification

- **POST /api/register**: Inscription d'un nouvel utilisateur
  - Corps de la requête: `{ username, password, firstName, lastName }`
  - Réponse: `{ user, message }`

- **POST /api/login**: Authentification
  - Corps de la requête: `{ username, password }`
  - Réponse: `{ token, user }`

#### Utilisateur

- **GET /api/mobile/user**: Récupération du profil utilisateur
  - Entête: `Authorization: Bearer {token}`
  - Réponse: `{ id, username, firstName, lastName, email }`

## 🚀 Démarrage Rapide

### Frontend (Flutter)

```bash
# Installation des dépendances
flutter pub get

# Démarrage en développement
flutter run
flutter run -d chrome 

# Build pour Android
flutter build apk

# Build pour iOS
flutter build ios
```

### Configuration requise

- Flutter SDK (dernière version stable)
- Android Studio / Xcode
- Un émulateur ou un appareil physique

## 📝 Documentation

La documentation détaillée de l'application se trouve dans le dossier `docs/`, incluant:

- Guide d'installation
- Architecture de l'application
- Guide de contribution
- Procédures de déploiement

## 🔒 Sécurité

- Authentification JWT
- Validation des données côté serveur
- Stockage sécurisé des tokens
- Chiffrement des données sensibles

## 👥 Contribuer

1. Fork le projet
2. Créez votre branche de fonctionnalité (`git checkout -b feature/amazing-feature`)
3. Commit vos changements (`git commit -m 'Add some amazing feature'`)
4. Push vers la branche (`git push origin feature/amazing-feature`)
5. Ouvrez une Pull Request

## 📄 Licence

Ce projet est sous licence.
