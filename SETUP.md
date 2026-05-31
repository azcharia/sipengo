# SIPEN-GO - Development Setup Guide

Complete guide for setting up SIPEN-GO development environment.

## Prerequisites

### Required Software
- **Flutter SDK**: 3.7.2 or higher
  - Download: https://flutter.dev/docs/get-started/install
  - Verify: `flutter --version`

- **Dart SDK**: 3.7.2 or higher (included with Flutter)
  - Verify: `dart --version`

- **Git**: Latest version
  - Download: https://git-scm.com/

- **Supabase Account**: Free tier available
  - Sign up: https://supabase.com

### Optional (for specific platforms)
- **Android Studio** (for Android development)
- **Xcode** (for iOS development on macOS)
- **Visual Studio Code** or **Android Studio** (IDE)

## Step 1: Clone Repository

```bash
git clone https://github.com/azcharia/sipen-go.git
cd sipen-go
```

## Step 2: Setup Supabase Project

### 2.1 Create Supabase Project
1. Go to [supabase.com](https://supabase.com)
2. Click "New Project"
3. Fill in project details:
   - Name: `sipen-go` (or your preference)
   - Database Password: Create strong password
   - Region: Choose closest to your location
4. Wait for project to initialize (2-3 minutes)

### 2.2 Get Supabase Credentials
1. Go to Project Settings → API
2. Copy:
   - **Project URL** (SUPABASE_URL)
   - **Anon Key** (SUPABASE_ANON_KEY)
3. Save these securely

### 2.3 Setup Database Schema
1. Go to SQL Editor in Supabase Dashboard
2. Create new query
3. Copy entire content from `supabase_setup.sql`
4. Paste into SQL Editor
5. Click "Run"
6. Wait for completion (should see "Success" message)

### 2.4 Setup Google Maps Integration (Optional)
1. Go to SQL Editor
2. Create new query
3. Copy entire content from `supabase_migration_gmaps.sql`
4. Paste into SQL Editor
5. Click "Run"

### 2.5 Create Admin User
1. Go to Authentication → Users
2. Click "Add user"
3. Enter email and password
4. Click "Create user"
5. Note: This is your login credentials for the app

## Step 3: Configure Environment Variables

### 3.1 Create .env File
Create `.env` file in project root:

```bash
# Linux/macOS
touch .env

# Windows (PowerShell)
New-Item -Path .env -ItemType File
```

### 3.2 Add Credentials
Edit `.env` and add:

```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

**Replace with your actual values from Step 2.2**

### 3.3 Verify .env is in .gitignore
Check `.gitignore` contains:
```
.env
.env.local
.env.*.local
```

**IMPORTANT**: Never commit `.env` file to Git!

## Step 4: Install Flutter Dependencies

```bash
# Get all dependencies
flutter pub get

# Upgrade dependencies (optional)
flutter pub upgrade

# Check for issues
flutter doctor
```

## Step 5: Generate App Icons

```bash
flutter pub run flutter_launcher_icons
```

This generates icons for all platforms using `assets/images/dashboard logo.png`.

## Step 6: Run the Application

### Android
```bash
# List available devices
flutter devices

# Run on Android device/emulator
flutter run -d android

# Or specify device ID
flutter run -d <device-id>
```

### iOS (macOS only)
```bash
flutter run -d ios
```

### Web
```bash
flutter run -d chrome
```

### Windows
```bash
flutter run -d windows
```

### macOS
```bash
flutter run -d macos
```

### Linux
```bash
flutter run -d linux
```

## Step 7: Verify Setup

### Check Authentication
1. App should show login screen
2. Enter email and password from Step 2.5
3. Should navigate to home screen
4. Should see empty family list

### Check Database Connection
1. On home screen, click "+" FAB
2. Try adding a family
3. Should save without errors
4. Family should appear in list

### Check Storage
1. When adding family, upload a photo
2. Photo should upload successfully
3. Photo should display in family detail

## Troubleshooting

### Flutter Doctor Issues
```bash
flutter doctor -v
```

Fix any issues reported by Flutter Doctor.

### Supabase Connection Failed
- Verify `.env` file has correct credentials
- Check internet connection
- Verify Supabase project is active
- Check firewall/proxy settings

### App Crashes on Startup
```bash
# Run with verbose logging
flutter run -v

# Check logs for errors
# Look for "Exception" or "Error" messages
```

### Image Upload Fails
- Check storage bucket exists in Supabase
- Verify file permissions
- Check file size (< 10MB)
- Ensure internet connection

### Database Queries Return Empty
- Verify SQL scripts ran successfully
- Check RLS policies in Supabase
- Verify user is authenticated
- Check data exists in tables

## Development Workflow

### Creating a Feature Branch
```bash
git checkout -b feature/feature-name
```

### Running Tests
```bash
flutter test
```

### Building for Release
```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

### Code Formatting
```bash
# Format all Dart files
dart format lib/

# Analyze code
dart analyze
```

## Project Structure Overview

```
lib/
├── core/              # Configuration, constants, theme
├── data/              # Models, repositories, services
├── domain/            # Business logic, enums
└── presentation/      # UI screens and state management
```

See `ARCHITECTURE.md` for detailed structure.

## Important Files

| File | Purpose |
|------|---------|
| `.env` | Environment variables (DO NOT COMMIT) |
| `pubspec.yaml` | Dependencies and configuration |
| `supabase_setup.sql` | Database schema |
| `supabase_migration_gmaps.sql` | Google Maps integration |
| `lib/core/config/supabase_config.dart` | Supabase configuration |
| `lib/main.dart` | App entry point |

## Security Checklist

- [ ] `.env` file created and in `.gitignore`
- [ ] Supabase credentials not hardcoded
- [ ] Admin user created in Supabase
- [ ] RLS policies enabled
- [ ] Storage bucket permissions set correctly
- [ ] No sensitive data in version control

## Next Steps

1. Read `README.md` for feature overview
2. Read `ARCHITECTURE.md` for code structure
3. Read `PROJECT_STRUCTURE.md` for detailed file organization
4. Start developing features!

## Getting Help

- **Flutter Docs**: https://flutter.dev/docs
- **Dart Docs**: https://dart.dev/guides
- **Supabase Docs**: https://supabase.com/docs
- **Riverpod Docs**: https://riverpod.dev
- **GitHub Issues**: Check existing issues first

## Common Commands

```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Run tests
flutter test

# Format code
dart format lib/

# Analyze code
dart analyze

# Run app
flutter run

# Build release
flutter build apk --release
```

---

**Last Updated**: February 2026  
**Version**: 1.0.0
