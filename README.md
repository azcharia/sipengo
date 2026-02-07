# SIPENGO - Sistem Informasi Penduduk Gombang

[![Flutter](https://img.shields.io/badge/Flutter-3.7.2-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.7.2-blue.svg)](https://dart.dev)
[![License](https://img.shields.io/badge/License-Proprietary-red.svg)](#license)

A comprehensive census and population management application for the village of Gombang, enabling village officials to digitally record, manage, and analyze family data with advanced features like family lineage tracking, photo documentation, and data export.

## 🎯 Features

### Core Features
- � **Secure Authentication** - Email/password login for village officials via Supabase Auth
- �👨‍👩‍👧‍👦 **Family Management** - Complete CRUD operations for family records (Kartu Keluarga)
- 👤 **Resident Management** - Add, edit, and manage family members with detailed information
- 🌳 **Family Lineage** - Visual family tree (Silsilah) showing parent-child relationships
- � **House Photography** - Capture and store house photos with cloud storage integration
- 🔍 **Advanced Search** - Search families by KK number, name, or address
- 📊 **Statistics Dashboard** - Real-time metrics (total families, residents, gender distribution, photo verification %)
- 📤 **Data Export** - Export all data to Excel (.xlsx) or PDF reports
- 🗺️ **Google Maps Integration** - Store and access Google Maps links for family locations

### Technical Features
- ✅ Clean Architecture with MVVM pattern
- ✅ Riverpod state management for robust, compile-safe reactive programming
- ✅ Row-Level Security (RLS) policies for data protection
- ✅ Responsive design for mobile and tablet
- ✅ Cross-platform support (Android, iOS, Web, Windows, macOS, Linux)
- ✅ Offline-ready architecture
- ✅ Professional UI with green theme (village/nature context)

## 🛠️ Tech Stack

| Component | Technology |
|-----------|-----------|
| **Frontend** | Flutter (Dart 3.7.2+) |
| **Backend** | Supabase (PostgreSQL, Auth, Storage) |
| **State Management** | Riverpod 2.6.1+ |
| **Database** | PostgreSQL (via Supabase) |
| **Authentication** | Supabase Auth (JWT) |
| **File Storage** | Supabase Storage |
| **Export** | PDF (pdf 3.11.1), Excel (excel 4.0.6) |
| **UI Components** | Flutter Material Design 3 |

## 📋 Prerequisites

- Flutter SDK 3.7.2 or higher
- Dart SDK 3.7.2 or higher
- Supabase account (free tier available)
- Git
- Android Studio / Xcode (for mobile development)

## 🚀 Quick Start

### 1. Clone Repository
```bash
git clone https://github.com/azcharia/sipengo.git
cd sipengo
```

### 2. Setup Supabase Project
1. Create a new project at [supabase.com](https://supabase.com)
2. Go to SQL Editor and run the setup script:
   ```bash
   # Copy content from supabase_setup.sql
   # Paste into Supabase SQL Editor and execute
   ```
3. For Google Maps integration, also run:
   ```bash
   # Copy content from supabase_migration_gmaps.sql
   # Paste into Supabase SQL Editor and execute
   ```

### 3. Configure Environment Variables
Create a `.env` file in the project root:
```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

**Get these values from:**
- Supabase Dashboard → Settings → API
- Copy the Project URL and Anon Key

### 4. Install Dependencies
```bash
flutter pub get
```

### 5. Generate App Icons
```bash
flutter pub run flutter_launcher_icons
```

### 6. Run the Application
```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Web
flutter run -d chrome

# Windows
flutter run -d windows
```

## 📁 Project Structure

```
lib/
├── core/                          # Core utilities & configuration
│   ├── config/
│   │   └── supabase_config.dart   # Supabase credentials (env-based)
│   ├── constants/
│   │   ├── app_colors.dart        # Color palette
│   │   ├── app_strings.dart       # UI text strings (Indonesian)
│   │   └── storage_constants.dart # Storage bucket names
│   └── theme/
│       └── app_theme.dart         # Material theme configuration
│
├── data/                          # Data layer
│   ├── models/
│   │   ├── family_model.dart      # Family data model
│   │   └── resident_model.dart    # Resident data model
│   ├── repositories/
│   │   ├── family_repository.dart # Family CRUD operations
│   │   └── resident_repository.dart # Resident CRUD operations
│   └── services/
│       ├── supabase_service.dart  # Supabase client initialization
│       ├── storage_service.dart   # Image upload/download
│       └── export_service.dart    # PDF/Excel export
│
├── domain/                        # Business logic & entities
│   └── enums/
│       ├── gender.dart            # Gender enum (Male/Female)
│       └── relationship.dart      # Relationship types
│
├── presentation/                  # UI layer
│   ├── providers/                 # Riverpod state management
│   │   ├── auth_provider.dart     # Authentication state
│   │   ├── family_provider.dart   # Family data state
│   │   ├── resident_provider.dart # Resident data state
│   │   └── statistics_provider.dart # Dashboard statistics
│   │
│   └── screens/
│       ├── auth/
│       │   └── login_screen.dart  # Login page
│       ├── splash/
│       │   └── splash_screen.dart # Splash screen with logo
│       ├── home/
│       │   ├── home_screen.dart   # Family list & dashboard
│       │   └── widgets/
│       │       └── statistics_dashboard.dart # Stats cards
│       └── family/
│           ├── family_detail_screen.dart # Family details
│           ├── family_form_screen.dart   # Add/edit family
│           └── widgets/
│               └── lineage_tree_view.dart # Family tree display
│
└── main.dart                      # App entry point
```

## 🗄️ Database Schema

### Tables

#### `families` (Kartu Keluarga)
```sql
- id (UUID, Primary Key)
- kk_number (String, Unique) - Family card number
- address (Text) - Family address
- head_of_household (String) - Head name
- house_photo_url (String, nullable) - Photo URL in storage
- gmaps_link (String, nullable) - Google Maps link
- latitude (Decimal, nullable) - GPS latitude
- longitude (Decimal, nullable) - GPS longitude
- created_at (Timestamp)
- updated_at (Timestamp)
- created_by (UUID, FK to auth.users)
```

#### `residents` (Penduduk)
```sql
- id (UUID, Primary Key)
- family_id (UUID, FK to families)
- nik (String, Unique) - National ID
- full_name (String)
- birth_date (Date)
- gender (Enum: male, female)
- relationship (Enum: head, wife, child, grandchild, parent, etc.)
- parent_id (UUID, FK to residents, nullable) - For lineage
- created_at (Timestamp)
- updated_at (Timestamp)
```

#### `storage.house-photos`
```
Bucket for storing house photos
- Public read access
- Authenticated write access
- Path: {family_id}/{timestamp}_{filename}
```

## 🔐 Security

### Authentication
- Supabase Auth with JWT tokens
- Email/password authentication
- Automatic session management
- Secure token refresh

### Authorization
- Row-Level Security (RLS) policies
- User-based data access control
- Authenticated-only operations
- Admin role verification

### Data Protection
- PostgreSQL constraints
- Foreign key relationships
- Unique constraints on sensitive fields
- Automatic timestamps for audit trail

## 📱 Usage Guide

### Login
1. Enter email and password
2. Click "Masuk" (Login)
3. Session persists across app restarts

### Add Family
1. Click "+" FAB on home screen
2. Fill in family details:
   - KK Number (unique)
   - Head of household name
   - Address
   - Google Maps link (optional)
3. Take/upload house photo
4. Click "Simpan" (Save)

### Add Family Member
1. Open family detail
2. Click "Tambah Anggota" (Add Member)
3. Fill in resident details:
   - NIK (National ID)
   - Full name
   - Birth date
   - Gender
   - Relationship to head
   - Parent (if applicable)
4. Click "Simpan" (Save)

### View Family Tree
1. Open family detail
2. Scroll to see all members
3. Members are organized by relationship
4. Color-coded badges show relationship type

### Export Data
1. Click menu icon (⋮) in home screen
2. Select "Unduh Excel" (Download Excel) or "Cetak Laporan" (Print Report)
3. File downloads to device
4. Share via WhatsApp, Email, Drive, etc.

### Search Families
1. Use search bar on home screen
2. Type KK number, family name, or address
3. Results update in real-time

## 🐛 Troubleshooting

### App Force Closes on Android 12+
**Solution:**
1. Ensure `AndroidManifest.xml` has required permissions
2. Check Supabase credentials in `.env` file
3. Verify logo files exist in `assets/images/`
4. Run: `flutter clean && flutter pub get && flutter run -v`

### Images Not Uploading
**Solution:**
1. Check internet connection
2. Verify Supabase Storage bucket exists
3. Check file permissions in `android/app/src/main/AndroidManifest.xml`
4. Ensure image file size < 10MB

### Search Not Working
**Solution:**
1. Verify Supabase connection
2. Check RLS policies allow SELECT
3. Ensure data exists in database
4. Check console for error messages

### Export Fails
**Solution:**
1. Ensure device has storage permission
2. Check available disk space
3. Verify data exists before exporting
4. Try exporting smaller datasets first

## 📚 Documentation

- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Detailed architecture and design patterns
- **[PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md)** - Complete file structure visualization
- **[supabase_setup.sql](supabase_setup.sql)** - Database schema SQL script
- **[supabase_migration_gmaps.sql](supabase_migration_gmaps.sql)** - Google Maps integration SQL

## 🔄 Development Workflow

### Adding a New Feature
1. Create feature branch: `git checkout -b feature/feature-name`
2. Implement feature following Clean Architecture
3. Test thoroughly on multiple devices
4. Create pull request with description
5. Merge after review

### Code Style
- Follow Dart style guide
- Use meaningful variable names
- Add comments for complex logic
- Keep functions small and focused
- Use type annotations

### Testing
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage
```

## 📦 Building for Release

### Android
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# Or build App Bundle for Play Store
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS
```bash
flutter build ios --release
# Follow Xcode instructions for signing and deployment
```

### Web
```bash
flutter build web --release
# Output: build/web/
```

## 🤝 Contributing

This is a private project for Gombang village administration. For contributions:
1. Contact project maintainer
2. Follow code style guidelines
3. Test thoroughly before submitting
4. Document changes clearly

## 📝 License

**Proprietary License** - All rights reserved to Gombang Village Administration

This software is proprietary and confidential. Unauthorized copying, modification, or distribution is prohibited.

## 👥 Team

- **Project Lead**: Azcharia
- **Repository**: [github.com/azcharia/sipengo](https://github.com/azcharia/sipengo)

## 📞 Support

For issues, questions, or feature requests:
1. Check existing documentation
2. Review troubleshooting section
3. Contact project maintainer
4. Check GitHub issues

## 🎓 Learning Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Guide](https://dart.dev/guides)
- [Supabase Documentation](https://supabase.com/docs)
- [Riverpod Documentation](https://riverpod.dev)
- [Clean Architecture in Flutter](https://resocoder.com/flutter-clean-architecture)

## 📊 Project Statistics

- **Total Files**: 26+
- **Lines of Code**: 2,500+
- **Supported Platforms**: 6 (Android, iOS, Web, Windows, macOS, Linux)
- **Database Tables**: 2 main + 1 storage bucket
- **API Endpoints**: 20+
- **UI Screens**: 6+

## 🚀 Roadmap

### v1.0 (Current)
- ✅ Core CRUD operations
- ✅ Family lineage tracking
- ✅ Photo documentation
- ✅ Data export (Excel/PDF)
- ✅ Statistics dashboard
- ✅ Google Maps integration

### v1.1 (Planned)
- 🔄 Advanced filtering and sorting
- 🔄 Activity logging
- 🔄 Batch operations
- 🔄 Data import from CSV

### v2.0 (Future)
- 🔮 Offline synchronization
- 🔮 Mobile app notifications
- 🔮 Advanced analytics
- 🔮 Multi-language support
- 🔮 Biometric authentication

---

**Last Updated**: February 2026  
**Version**: 1.0.0  
**Status**: Production Ready
