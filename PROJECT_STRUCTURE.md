# SIPENGO - Project Structure Visualization

## 📂 Complete File Tree

```
sipengo/
│
├── 📄 README.md                          # Project overview
├── 📄 ARCHITECTURE.md                    # Architecture documentation
├── 📄 IMPLEMENTATION_GUIDE.md            # Step-by-step guide
├── 📄 PROJECT_SUMMARY.md                 # Complete feature summary
├── 📄 QUICK_START.md                     # 5-minute setup guide
├── 📄 PROJECT_STRUCTURE.md               # This file
├── 📄 supabase_setup.sql                 # Database schema
├── 📄 pubspec.yaml                       # Dependencies
├── 📄 .env.example                       # Environment template
├── 📄 .gitignore                         # Git ignore rules
│
└── lib/
    │
    ├── 📄 main.dart                      # App entry point
    │
    ├── 📁 core/                          # Core utilities
    │   ├── 📁 config/
    │   │   └── 📄 supabase_config.dart   # Supabase credentials
    │   ├── 📁 constants/
    │   │   ├── 📄 app_colors.dart        # Color palette
    │   │   ├── 📄 app_strings.dart       # Text strings (ID)
    │   │   └── 📄 storage_constants.dart # Storage config
    │   └── 📁 theme/
    │       └── 📄 app_theme.dart         # Material theme
    │
    ├── 📁 data/                          # Data layer
    │   ├── 📁 models/
    │   │   ├── 📄 family_model.dart      # Family data model
    │   │   └── 📄 resident_model.dart    # Resident data model
    │   ├── 📁 repositories/
    │   │   ├── 📄 family_repository.dart # Family CRUD
    │   │   └── 📄 resident_repository.dart # Resident CRUD
    │   └── 📁 services/
    │       ├── 📄 supabase_service.dart  # Supabase client
    │       └── 📄 storage_service.dart   # Image upload
    │
    ├── 📁 domain/                        # Business logic
    │   └── 📁 enums/
    │       ├── 📄 gender.dart            # Gender enum
    │       └── 📄 relationship.dart      # Relationship enum
    │
    └── 📁 presentation/                  # UI layer
        ├── 📁 providers/                 # State management
        │   ├── 📄 auth_provider.dart     # Auth state
        │   ├── 📄 family_provider.dart   # Family state
        │   └── 📄 resident_provider.dart # Resident state
        │
        └── 📁 screens/
            ├── 📁 auth/
            │   └── 📄 login_screen.dart  # Login page
            ├── 📁 home/
            │   └── 📄 home_screen.dart   # Family list
            └── 📁 family/
                ├── 📄 family_detail_screen.dart # Family detail
                └── 📁 widgets/
                    └── 📄 lineage_tree_view.dart # Members list
```

---

## 🔄 Data Flow Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         USER INTERFACE                       │
│  (Screens: Login, Home, Family Detail, Lineage Tree)        │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                    STATE MANAGEMENT                          │
│         (Riverpod Providers: Auth, Family, Resident)        │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                      REPOSITORIES                            │
│     (Business Logic: CRUD, Search, Validation)              │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                        SERVICES                              │
│    (Supabase Client, Storage Service, Auth Service)         │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                    SUPABASE BACKEND                          │
│         (PostgreSQL, Auth, Storage, RLS Policies)           │
└─────────────────────────────────────────────────────────────┘
```

---

## 🗄️ Database Schema

```
┌─────────────────────────────────────────────────────────────┐
│                         auth.users                           │
│  (Managed by Supabase Auth)                                 │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │ created_by (FK)
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                         families                             │
├─────────────────────────────────────────────────────────────┤
│  • id (UUID, PK)                                            │
│  • kk_number (String, Unique)                               │
│  • address (Text)                                           │
│  • head_of_household (String)                               │
│  • house_photo_url (String, nullable)                       │
│  • latitude / longitude (Decimal, nullable)                 │
│  • created_at / updated_at (Timestamp)                      │
│  • created_by (UUID, FK → auth.users)                       │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │ family_id (FK)
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                        residents                             │
├─────────────────────────────────────────────────────────────┤
│  • id (UUID, PK)                                            │
│  • family_id (UUID, FK → families)                          │
│  • nik (String, Unique)                                     │
│  • full_name (String)                                       │
│  • birth_date (Date)                                        │
│  • gender (Enum: male, female)                              │
│  • relationship (Enum: head, wife, child, etc.)             │
│  • parent_id (UUID, FK → residents, nullable) ◄─┐           │
│  • created_at / updated_at (Timestamp)           │           │
└──────────────────────────────────────────────────┘           │
                         │                                     │
                         └─────────────────────────────────────┘
                              (Self-referencing for lineage)

┌─────────────────────────────────────────────────────────────┐
│                   storage.house-photos                       │
│  (Supabase Storage Bucket)                                  │
│  • Public read access                                       │
│  • Authenticated write access                               │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎯 Feature Map

```
SIPENGO
│
├── 🔐 Authentication
│   ├── Login (Email/Password)
│   ├── Session Management
│   └── Logout
│
├── 👨‍👩‍👧‍👦 Family Management
│   ├── View All Families
│   ├── Search Families (KK, Name, Address)
│   ├── View Family Details
│   │   ├── House Photo Display
│   │   ├── Family Information
│   │   └── Member List (Lineage)
│   ├── Create Family (TODO)
│   ├── Edit Family (TODO)
│   └── Delete Family ✓
│
├── 👤 Resident Management
│   ├── View Family Members
│   ├── Lineage Tree Display
│   │   ├── Hierarchical Sorting
│   │   ├── Relationship Badges
│   │   ├── Age Calculation
│   │   └── Gender Icons
│   ├── Create Resident (TODO)
│   ├── Edit Resident (TODO)
│   └── Delete Resident (TODO)
│
└── 📸 House Photography
    ├── Upload to Storage ✓
    ├── Display in Detail ✓
    ├── Update Photo ✓
    └── Delete Photo ✓
```

---

## 🔄 Screen Navigation Flow

```
┌─────────────────┐
│  Login Screen   │
│  (Not Auth)     │
└────────┬────────┘
         │ Login Success
         ▼
┌─────────────────┐
│  Home Screen    │
│  (Family List)  │
└────────┬────────┘
         │ Tap Family
         ▼
┌─────────────────────────┐
│  Family Detail Screen   │
│  • House Photo          │
│  • Family Info          │
│  • Lineage Tree         │
└────────┬────────────────┘
         │ Add Resident (TODO)
         ▼
┌─────────────────────────┐
│  Resident Form Screen   │
│  (To Be Implemented)    │
└─────────────────────────┘
```

---

## 🎨 Component Hierarchy

```
MyApp (ProviderScope)
│
├── MaterialApp
│   ├── Theme (AppTheme.lightTheme)
│   │
│   └── Home Widget (Auth Check)
│       │
│       ├── LoginScreen (if not authenticated)
│       │   ├── Email TextField
│       │   ├── Password TextField
│       │   └── Login Button
│       │
│       └── HomeScreen (if authenticated)
│           ├── AppBar (with Logout)
│           ├── Search TextField
│           ├── Family List
│           │   └── Family Cards
│           │       └── → FamilyDetailScreen
│           │           ├── House Photo
│           │           ├── Family Info Card
│           │           └── LineageTreeView
│           │               └── Resident Cards
│           └── FAB (Add Family)
```

---

## 📦 State Management Flow

```
UI Component
    │
    │ ref.watch(provider)
    ▼
Provider (FutureProvider / StateNotifierProvider)
    │
    │ calls
    ▼
Repository
    │
    │ uses
    ▼
Service (Supabase / Storage)
    │
    │ communicates with
    ▼
Supabase Backend
```

**Example: Loading Families**
```
HomeScreen
    │ ref.watch(familiesProvider)
    ▼
FamilyProvider (FutureProvider)
    │ calls getAllFamilies()
    ▼
FamilyRepository
    │ uses SupabaseService.families
    ▼
SupabaseService
    │ client.from('families').select()
    ▼
Supabase Database
```

---

## 🔐 Security Layers

```
┌─────────────────────────────────────────────────────────────┐
│  Layer 1: Flutter App (Client-Side Validation)             │
│  • Form validation                                          │
│  • Input sanitization                                       │
│  • Type safety                                              │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│  Layer 2: Supabase Auth (Authentication)                    │
│  • JWT tokens                                               │
│  • Session management                                       │
│  • User verification                                        │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│  Layer 3: Row Level Security (Authorization)                │
│  • Authenticated-only access                                │
│  • User-based permissions                                   │
│  • Automatic policy enforcement                             │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│  Layer 4: PostgreSQL (Data Integrity)                       │
│  • Foreign key constraints                                  │
│  • Unique constraints                                       │
│  • Type validation                                          │
└─────────────────────────────────────────────────────────────┘
```

---

## 📊 Data Models Relationship

```
FamilyModel
├── id: String
├── kkNumber: String
├── address: String
├── headOfHousehold: String
├── housePhotoUrl: String?
├── latitude: double?
├── longitude: double?
├── createdAt: DateTime
└── updatedAt: DateTime
    │
    │ has many
    ▼
ResidentModel
├── id: String
├── familyId: String ──────┐ (FK to Family)
├── nik: String            │
├── fullName: String       │
├── birthDate: DateTime    │
├── gender: Gender         │
├── relationship: Relationship
├── parentId: String? ─────┘ (Self-referencing FK)
├── createdAt: DateTime
└── updatedAt: DateTime
```

---

## 🎯 Implementation Status

### ✅ Completed (Phase 1)
- [x] Database schema
- [x] Authentication system
- [x] Data models
- [x] Repositories
- [x] State management
- [x] Login screen
- [x] Home screen
- [x] Family detail screen
- [x] Lineage tree view
- [x] Image upload service
- [x] Search functionality
- [x] Delete operations

### 🚧 To Be Implemented (Phase 2)
- [ ] Family form screen
- [ ] Resident form screen
- [ ] Edit operations UI
- [ ] Image picker integration
- [ ] Form validation UI
- [ ] Error handling UI

### 🔮 Future Enhancements (Phase 3)
- [ ] Statistics dashboard
- [ ] Export to PDF/Excel
- [ ] Map view
- [ ] Advanced filters
- [ ] Offline support
- [ ] Push notifications

---

## 📝 File Size Overview

```
Total Files Created: 26
Total Lines of Code: ~2,500+

Breakdown:
├── Documentation: 5 files (~1,500 lines)
├── Core: 4 files (~200 lines)
├── Data Layer: 6 files (~600 lines)
├── Domain: 2 files (~50 lines)
├── Presentation: 8 files (~1,000 lines)
└── Configuration: 1 file (~150 lines)
```

---

## 🎓 Code Organization Principles

### Clean Architecture
```
Presentation → Domain → Data
     ↓           ↓        ↓
   UI Logic   Business  External
              Rules     Services
```

### SOLID Principles
- **S**ingle Responsibility: Each class has one job
- **O**pen/Closed: Open for extension, closed for modification
- **L**iskov Substitution: Subtypes are substitutable
- **I**nterface Segregation: Small, focused interfaces
- **D**ependency Inversion: Depend on abstractions

### Design Patterns Used
- **Repository Pattern**: Data access abstraction
- **Provider Pattern**: State management (Riverpod)
- **Factory Pattern**: Model creation from JSON
- **Singleton Pattern**: Supabase client instance

---

This structure provides a solid foundation for a scalable, maintainable application! 🚀
