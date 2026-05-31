# SIPEN-GO - Architecture & Implementation Plan

## 1. Project Overview
**SIPEN-GO (Sistem Informasi Penduduk Gombang)** is a census and population management application for village officials to record and manage family data digitally.

## 2. Tech Stack
- **Frontend**: Flutter (Dart)
- **Backend**: Supabase (PostgreSQL, Auth, Storage)
- **State Management**: Riverpod (more robust, modern, and compile-safe)
- **Architecture**: Clean Architecture with MVVM pattern

## 3. Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   └── storage_constants.dart
│   ├── theme/
│   │   └── app_theme.dart
│   ├── utils/
│   │   ├── validators.dart
│   │   └── date_formatter.dart
│   └── config/
│       └── supabase_config.dart
├── data/
│   ├── models/
│   │   ├── family_model.dart
│   │   ├── resident_model.dart
│   │   └── user_model.dart
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   ├── family_repository.dart
│   │   └── resident_repository.dart
│   └── services/
│       ├── supabase_service.dart
│       └── storage_service.dart
├── domain/
│   ├── entities/
│   │   ├── family.dart
│   │   └── resident.dart
│   └── enums/
│       ├── gender.dart
│       └── relationship.dart
├── presentation/
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── family_provider.dart
│   │   └── resident_provider.dart
│   ├── screens/
│   │   ├── auth/
│   │   │   └── login_screen.dart
│   │   ├── home/
│   │   │   └── home_screen.dart
│   │   ├── family/
│   │   │   ├── family_list_screen.dart
│   │   │   ├── family_detail_screen.dart
│   │   │   ├── family_form_screen.dart
│   │   │   └── widgets/
│   │   │       ├── family_card.dart
│   │   │       ├── house_photo_picker.dart
│   │   │       └── lineage_tree_view.dart
│   │   └── resident/
│   │       ├── resident_form_screen.dart
│   │       └── widgets/
│   │           └── resident_card.dart
│   └── widgets/
│       ├── custom_button.dart
│       ├── custom_text_field.dart
│       └── loading_indicator.dart
└── main.dart

## 4. Database Schema (Supabase SQL)

See `supabase_setup.sql` for complete setup script.

## 5. Key Features Implementation

### Authentication
- Supabase Auth with email/password
- Role-based access (village officials only)
- Persistent session management

### Family Management
- CRUD operations for families
- House photo upload to Supabase Storage
- Search and filter capabilities
- GPS coordinates (optional)

### Resident Management
- CRUD operations for residents
- Parent-child relationship tracking
- Lineage tree visualization
- NIK validation

### UI/UX
- Green color scheme (nature/village theme)
- Clean, intuitive interface
- Responsive design
- Confirmation dialogs for destructive actions

## 6. Implementation Phases

### Phase 1: Setup & Core (Current)
- Project dependencies
- Supabase configuration
- Core utilities and constants
- Theme setup

### Phase 2: Data Layer
- Models and entities
- Repository pattern
- Supabase service integration

### Phase 3: State Management
- Riverpod providers
- State classes
- Error handling

### Phase 4: UI Implementation
- Authentication screens
- Family CRUD screens
- Resident CRUD screens
- Lineage visualization

### Phase 5: Testing & Refinement
- Integration testing
- UI/UX improvements
- Performance optimization
