# SIPENGO - Quick Reference Guide

**Quick links and commands for SIPENGO development and deployment.**

---

## 🚀 Quick Start Commands

### Setup Development Environment
```bash
# Clone repository
git clone https://github.com/azcharia/sipengo.git
cd sipengo

# Create .env file
cp .env.example .env
# Edit .env with your Supabase credentials

# Install dependencies
flutter pub get

# Run app
flutter run
```

### Build for Release
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

---

## 📚 Documentation Quick Links

| Document | Purpose | Read Time |
|----------|---------|-----------|
| [README.md](README.md) | Project overview | 10 min |
| [SETUP.md](SETUP.md) | Development setup | 15 min |
| [ARCHITECTURE.md](ARCHITECTURE.md) | Code structure | 15 min |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Guidelines | 10 min |
| [PROJECT_ANALYSIS.md](PROJECT_ANALYSIS.md) | Analysis report | 20 min |
| [FINAL_REPORT.md](FINAL_REPORT.md) | Complete report | 15 min |

---

## 🔐 Security Checklist

### Before Committing
```bash
# Check for sensitive files
git ls-files | grep -E "\.env|credentials|secret|key"

# Verify .gitignore
cat .gitignore | grep "\.env"

# Run code analysis
dart analyze

# Format code
dart format lib/
```

### Environment Variables
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

---

## 🛠️ Development Commands

### Code Quality
```bash
# Analyze code
dart analyze

# Format code
dart format lib/

# Check for issues
flutter analyze

# Run tests
flutter test
```

### Dependencies
```bash
# Get dependencies
flutter pub get

# Upgrade dependencies
flutter pub upgrade

# Check outdated packages
flutter pub outdated

# Add new package
flutter pub add package_name
```

### Build & Run
```bash
# Run app
flutter run

# Run with verbose logging
flutter run -v

# Run on specific device
flutter run -d device_id

# Clean build
flutter clean
```

---

## 📱 Platform-Specific Commands

### Android
```bash
# Run on Android
flutter run -d android

# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release

# Check Android setup
flutter doctor -v
```

### iOS
```bash
# Run on iOS
flutter run -d ios

# Build iOS
flutter build ios --release

# Check iOS setup
flutter doctor -v
```

### Web
```bash
# Run on web
flutter run -d chrome

# Build web
flutter build web --release

# Serve web
flutter run -d web-server
```

### Windows
```bash
# Run on Windows
flutter run -d windows

# Build Windows
flutter build windows --release
```

### macOS
```bash
# Run on macOS
flutter run -d macos

# Build macOS
flutter build macos --release
```

### Linux
```bash
# Run on Linux
flutter run -d linux

# Build Linux
flutter build linux --release
```

---

## 🗄️ Database Commands

### Supabase Setup
```sql
-- Run in Supabase SQL Editor
-- Copy content from supabase_setup.sql
-- Paste and execute

-- For Google Maps integration
-- Copy content from supabase_migration_gmaps.sql
-- Paste and execute
```

### Database Queries
```sql
-- View all families
SELECT * FROM families;

-- View all residents
SELECT * FROM residents;

-- View family with members
SELECT f.*, r.* FROM families f
LEFT JOIN residents r ON f.id = r.family_id
WHERE f.id = 'family_id';
```

---

## 🔍 Troubleshooting Quick Fixes

### App Won't Start
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run -v

# Check logs
flutter run -v 2>&1 | grep -i error
```

### Supabase Connection Failed
```bash
# Verify .env file
cat .env

# Check credentials
echo $SUPABASE_URL
echo $SUPABASE_ANON_KEY

# Test connection
flutter run -v
```

### Image Upload Fails
```bash
# Check permissions
# Android: AndroidManifest.xml has CAMERA, READ_EXTERNAL_STORAGE, WRITE_EXTERNAL_STORAGE
# iOS: Info.plist has NSPhotoLibraryUsageDescription

# Check file size (< 10MB)
# Check internet connection
# Check Supabase storage bucket exists
```

### Search Not Working
```bash
# Verify data exists
# Check RLS policies
# Verify user is authenticated
# Check console for errors
```

---

## 📊 Project Structure Quick Reference

```
lib/
├── core/              # Configuration & constants
│   ├── config/        # Supabase config
│   ├── constants/     # Colors, strings, storage
│   └── theme/         # Material theme
├── data/              # Data layer
│   ├── models/        # Family, Resident models
│   ├── repositories/  # CRUD operations
│   └── services/      # Supabase, Storage, Export
├── domain/            # Business logic
│   └── enums/         # Gender, Relationship
└── presentation/      # UI layer
    ├── providers/     # State management
    └── screens/       # UI screens
```

---

## 🎯 Feature Quick Reference

### Authentication
- **File**: `lib/presentation/screens/auth/login_screen.dart`
- **Provider**: `lib/presentation/providers/auth_provider.dart`
- **Service**: `lib/data/services/supabase_service.dart`

### Family Management
- **Model**: `lib/data/models/family_model.dart`
- **Repository**: `lib/data/repositories/family_repository.dart`
- **Screens**: `lib/presentation/screens/family/`

### Resident Management
- **Model**: `lib/data/models/resident_model.dart`
- **Repository**: `lib/data/repositories/resident_repository.dart`
- **Screen**: `lib/presentation/screens/resident/resident_form_screen.dart`

### Export Functionality
- **Service**: `lib/data/services/export_service.dart`
- **Usage**: `lib/presentation/screens/home/home_screen.dart`

### Statistics
- **Provider**: `lib/presentation/providers/statistics_provider.dart`
- **Widget**: `lib/presentation/screens/home/widgets/statistics_dashboard.dart`

---

## 🔗 Important Links

### Official Documentation
- [Flutter](https://flutter.dev/docs)
- [Dart](https://dart.dev/guides)
- [Supabase](https://supabase.com/docs)
- [Riverpod](https://riverpod.dev)

### Project Repository
- [GitHub](https://github.com/azcharia/sipengo)

### Community
- [Flutter Community](https://flutter.dev/community)
- [Dart Community](https://dart.dev/community)
- [Supabase Community](https://supabase.com/community)

---

## 📝 Common Tasks

### Add New Feature
1. Create feature branch: `git checkout -b feature/feature-name`
2. Create model in `lib/data/models/`
3. Create repository in `lib/data/repositories/`
4. Create provider in `lib/presentation/providers/`
5. Create screen in `lib/presentation/screens/`
6. Test thoroughly
7. Create pull request

### Add New Screen
1. Create file in `lib/presentation/screens/`
2. Create provider if needed
3. Add navigation
4. Test on multiple devices
5. Update documentation

### Add New Dependency
1. Run: `flutter pub add package_name`
2. Update pubspec.yaml if needed
3. Run: `flutter pub get`
4. Test thoroughly
5. Commit changes

### Fix Bug
1. Create branch: `git checkout -b bugfix/bug-description`
2. Identify root cause
3. Implement fix
4. Test thoroughly
5. Create pull request

---

## 🚀 Deployment Checklist

### Before Release
- [ ] All tests pass
- [ ] Code reviewed
- [ ] Documentation updated
- [ ] Version bumped in pubspec.yaml
- [ ] Build tested on all platforms
- [ ] No console errors
- [ ] No sensitive data exposed

### Release Steps
1. Update version in `pubspec.yaml`
2. Create release branch
3. Build for all platforms
4. Test on real devices
5. Create GitHub release
6. Deploy to app stores

---

## 💡 Tips & Tricks

### Performance
- Use `const` constructors
- Implement `==` and `hashCode` for models
- Use `ListView.builder` for long lists
- Cache expensive computations
- Use `FutureProvider` for async operations

### Debugging
- Use `flutter run -v` for verbose logs
- Use `dart analyze` to find issues
- Use breakpoints in IDE
- Use `print()` for quick debugging
- Check console for errors

### Code Quality
- Follow Dart style guide
- Use meaningful names
- Add comments for complex logic
- Keep functions small
- Use type annotations

---

## 📞 Getting Help

### Documentation
1. Check README.md
2. Check SETUP.md
3. Check ARCHITECTURE.md
4. Check code comments

### Troubleshooting
1. Check FINAL_REPORT.md
2. Check GitHub issues
3. Search Flutter documentation
4. Ask in community forums

### Reporting Issues
1. Check existing issues
2. Provide clear description
3. Include error logs
4. Include steps to reproduce
5. Include device/platform info

---

## 🎓 Learning Resources

### Flutter
- [Flutter Documentation](https://flutter.dev/docs)
- [Flutter Cookbook](https://flutter.dev/docs/cookbook)
- [Flutter YouTube Channel](https://www.youtube.com/flutterdev)

### Dart
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Dart Effective Dart](https://dart.dev/guides/language/effective-dart)

### Supabase
- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Examples](https://github.com/supabase/supabase/tree/master/examples)

### State Management
- [Riverpod Documentation](https://riverpod.dev)
- [Riverpod Examples](https://github.com/rrousselGit/riverpod/tree/master/examples)

---

## 📋 Version History

| Version | Date | Status | Notes |
|---------|------|--------|-------|
| 1.0.0 | Feb 2026 | ✅ Released | Initial production release |
| 1.1.0 | TBD | 🔄 Planned | Advanced filtering, activity logging |
| 2.0.0 | TBD | 🔮 Future | Offline sync, notifications |

---

## 🎉 Quick Summary

**SIPENGO** is a production-ready Flutter census management application with:
- ✅ Complete feature set
- ✅ Secure implementation
- ✅ Comprehensive documentation
- ✅ Clean, maintainable code
- ✅ Cross-platform support

**Ready to use!** 🚀

---

**Last Updated**: February 2026  
**Version**: 1.0.0  
**Repository**: https://github.com/azcharia/sipengo
