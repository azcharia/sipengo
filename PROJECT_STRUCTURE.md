# 📂 SIPEN-GO Project Structure

Understanding the architecture and directory layout is crucial for navigating the **SIPEN-GO** codebase. This document breaks down the folder structure, data flow, and feature map.

## 🌳 Complete File Tree

SIPEN-GO follows a modular **Clean Architecture** pattern combined with **Feature-first** organization within the presentation layer.

`	ext
sipen-go/
├── 📄 README.md                          # Main project overview & setup
├── 📄 ARCHITECTURE.md                    # Technical architecture & design decisions
├── 📄 CONTRIBUTING.md                    # Guidelines for contributing and PRs
├── 📄 PROJECT_STRUCTURE.md               # This file
├── 📄 SETUP.md                           # Detailed local development guide
├── 📄 supabase_setup.sql                 # Initial database schema setup
├── 📄 supabase_migration_gmaps.sql       # Database migration for Maps integration
├── 📄 pubspec.yaml                       # Flutter dependencies & assets
├── 📄 .env                               # Environment variables (NOT tracked by Git)
├── 📄 .gitignore                         # Git ignore rules
│
└── lib/
    ├── 📄 main.dart                      # Application entry point
    │
    ├── 📁 core/                          # Core utilities & global configurations
    │   ├── 📁 config/
    │   │   └── 📄 supabase_config.dart   # Environment variable bindings for Supabase
    │   ├── 📁 constants/
    │   │   ├── 📄 app_colors.dart        # Global color palette
    │   │   ├── 📄 app_strings.dart       # Static string resources (Indonesian)
    │   │   └── 📄 storage_constants.dart # Supabase Storage bucket names
    │   └── 📁 theme/
    │       └── 📄 app_theme.dart         # Material Design 3 theme configuration
    │
    ├── 📁 data/                          # Data Layer (API, Network, Local Storage)
    │   ├── 📁 models/                    # Data Transfer Objects (DTOs) with JSON serialization
    │   │   ├── 📄 family_model.dart      
    │   │   └── 📄 resident_model.dart    
    │   ├── 📁 repositories/              # Implementations for data fetching & CRUD
    │   │   ├── 📄 family_repository.dart 
    │   │   └── 📄 resident_repository.dart
    │   └── 📁 services/                  # Low-level service connectors
    │       ├── 📄 supabase_service.dart  # Supabase client initializer
    │       ├── 📄 storage_service.dart   # Cloud storage upload/download handler
    │       └── 📄 export_service.dart    # PDF and Excel report generator
    │
    ├── 📁 domain/                        # Domain Layer (Abstract business logic)
    │   └── 📁 enums/                     # Strongly-typed enumerations
    │       ├── 📄 gender.dart            
    │       └── 📄 relationship.dart      
    │
    └── 📁 presentation/                  # Presentation Layer (UI & State)
        ├── 📁 providers/                 # Riverpod State Management
        │   ├── 📄 auth_provider.dart     # Authentication and session state
        │   ├── 📄 family_provider.dart   # Family data caching and mutations
        │   ├── 📄 resident_provider.dart # Resident data caching
        │   └── 📄 statistics_provider.dart # Dashboard metrics state
        │
        └── 📁 screens/                   # Feature-based UI routing
            ├── 📁 auth/
            │   └── 📄 login_screen.dart  
            ├── 📁 splash/
            │   └── 📄 splash_screen.dart 
            ├── 📁 home/
            │   ├── 📄 home_screen.dart   
            │   └── 📁 widgets/           # Home-specific components
            │       └── 📄 statistics_dashboard.dart
            └── 📁 family/
                ├── 📄 family_detail_screen.dart
                ├── 📄 family_form_screen.dart
                └── 📁 widgets/           # Family-specific sub-components
                    └── 📄 lineage_tree_view.dart
`

---

## 🔄 Data Flow Architecture (MVVM & Clean Architecture)

SIPEN-GO uses **Riverpod** to bridge the UI (Presentation) with the data access layer seamlessly.

`mermaid
graph TD
    UI[User Interface / Screens] -->|Listens & Triggers| PROV[State Management / Riverpod Providers]
    PROV -->|Calls| REPO[Repositories]
    REPO -->|Fetches/Mutates via| SERV[Services / Supabase Client]
    SERV -->|HTTP/WebSockets| DB[(Supabase PostgreSQL & Storage)]
    
    DB -->|Returns JSON| SERV
    SERV -->|Returns Data Objects| REPO
    REPO -->|Parses via Models| PROV
    PROV -->|Updates State| UI
`

---

## 🎯 Feature Map

A quick lookup of where features live in the application logic:

- **🔐 Authentication**: lib/presentation/providers/auth_provider.dart
- **👨‍👩‍👧‍👦 Family Management (CRUD)**: lib/data/repositories/family_repository.dart
- **👤 Resident Management**: lib/data/repositories/resident_repository.dart
- **🌳 Lineage Tree Display**: UI handled in lib/presentation/screens/family/widgets/lineage_tree_view.dart by grouping parent-child data.
- **📸 House Photography**: Upload via storage_service.dart, state tracked in forms.
- **📊 Statistics Dashboard**: Aggregated globally via statistics_provider.dart.
- **📤 Data Export (PDF/Excel)**: Handled by lib/data/services/export_service.dart.
