<h1 align="center">
  <br>
  <img src="assets/images/dashboard logo.png" alt="SIPENGO Logo" width="200"/>
  <br>
  SIPENGO
  <br>
</h1>

<h4 align="center">Sistem Informasi Penduduk Gombang</h4>

<p align="center">
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.7.2-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter"></a>
  <a href="https://dart.dev"><img src="https://img.shields.io/badge/Dart-3.7.2-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart"></a>
  <a href="https://supabase.com"><img src="https://img.shields.io/badge/Supabase-Backend-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white" alt="Supabase"></a>
  <a href="#license"><img src="https://img.shields.io/badge/License-Proprietary-red.svg?style=for-the-badge" alt="License"></a>
</p>

<p align="center">
  A comprehensive census and population management application for the village of Gombang. It enables village officials to digitally record, manage, and analyze family data with advanced features like family lineage tracking, photo documentation, and data export.
</p>

<p align="center">
  <a href="#-key-features">Features</a> •
  <a href="#-tech-stack">Tech Stack</a> •
  <a href="#-getting-started">Getting Started</a> •
  <a href="#-database-schema">Database</a> •
  <a href="#-roadmap">Roadmap</a>
</p>

---

## ✨ Key Features

SIPENGO was designed to modernize the administrative workflow of Gombang village, ensuring data accuracy and ease of access.

- 🔐 **Secure Authentication:** Email and password login exclusively for village officials, powered by Supabase Auth.
- 👨‍👩‍👧‍👦 **Family Management (Kartu Keluarga):** Complete CRUD capabilities for managing family records.
- 👤 **Resident Profiles:** Detailed individual resident management including NIK, birth dates, and demographics.
- 🌳 **Lineage Tracking:** Visual family tree mapping parent-child relationships intuitively.
- 📸 **House Photography:** Capture, upload, and securely store house photos integrated with cloud storage.
- 🗺️ **Google Maps Integration:** Pinpoint and retrieve family addresses via Google Maps URLs.
- 📊 **Real-time Analytics:** Dashboard tracking total families, residents, gender distribution, and verified photos.
- 📤 **Comprehensive Export:** Generate and share reports in **PDF** or **Excel (.xlsx)** formats instantly.

## 💻 Tech Stack

SIPENGO is built using a modern, scalable, and cross-platform stack:

| Category | Technology | Description |
| :--- | :--- | :--- |
| **Frontend** | [Flutter](https://flutter.dev) | Cross-platform UI toolkit (Dart 3.7.2+) |
| **State Management** | [Riverpod](https://riverpod.dev) | Reactive caching and data-binding framework |
| **Backend & Auth** | [Supabase](https://supabase.com) | Open-source Firebase alternative (PostgreSQL) |
| **File Storage** | Supabase Storage | Robust cloud storage for housing photo assets |
| **Architecture** | MVVM / Clean Arch | Separation of concerns for maintainability |

## 🚀 Getting Started

Follow these instructions to set up the project locally for development and testing.

### Prerequisites

Ensure you have the following installed on your local machine:
- **Flutter SDK** (v3.7.2 or higher)
- **Dart SDK** (v3.7.2 or higher)
- **Git**
- A **Supabase** account (Free tier is sufficient)

### Installation

1. **Clone the repository:**
   `ash
   git clone https://github.com/azcharia/sipengo.git
   cd sipengo
   `

2. **Configure the Database:**
   - Create a new project on [Supabase](https://supabase.com).
   - Navigate to the SQL Editor and execute the contents of supabase_setup.sql.
   - For Google Maps column migrations, execute supabase_migration_gmaps.sql.

3. **Set up Environment Variables:**
   Create a .env file in the root directory and add your Supabase credentials:
   `nv
   SUPABASE_URL=https://your-project-id.supabase.co
   SUPABASE_ANON_KEY=your-anon-key-here
   `

4. **Install Dependencies & Generate Icons:**
   `ash
   flutter pub get
   flutter pub run flutter_launcher_icons
   `

5. **Run the Application:**
   `ash
   flutter run
   `
   *(Supports Android, iOS, Web, Windows, macOS, and Linux)*

## 📱 Screenshots

> *(Note: Add your actual application screenshots in the ssets/images/ folder and link them here for publication)*

| Home Dashboard |  Family Detail | Family Tree |
| :---: | :---: | :---: |
| <img src="assets/images/placeholder_home.png" width="200" alt="Home Screen"/> | <img src="assets/images/placeholder_detail.png" width="200" alt="Detail Screen"/> | <img src="assets/images/placeholder_tree.png" width="200" alt="Tree Screen"/> |

## 🗄️ Database Schema Concept

SIPENGO relies on a robust relational database structure. Key tables include:

- **amilies**: Stores Family Card (KK) details, address, head of household, GPS locations, and house photo URLs.
- **
esidents**: Stores individual citizens linked to a family, NIK, date of birth, gender, and hierarchical relationships (parent-child).
- **storage.house-photos**: A Supabase storage bucket specifically configured for authenticated uploads of residential properties.

*Authentication and Row-Level Security (RLS) are strictly enforced to protect citizen privacy.*

## 📁 Source Code Structure

The project follows a modular **Clean Architecture** pattern to ensure scalability:

`	ext
lib/
├── core/         # Configurations, themes, constants, and utilities
├── data/         # Models, Repositories, and backend Services (Supabase)
├── domain/       # Business logic entities and enums (Gender, Relationship)
├── presentation/ # UI Layer: Screens, Widgets, and Riverpod State Providers
└── main.dart     # Application entry point
`
*(For a deeper dive, refer to [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) and [ARCHITECTURE.md](ARCHITECTURE.md))*

## 🤝 Contributing

This repository is primarily maintained for the Gombang village administration. However, standard collaboration practices apply:
1. Ensure you are on a new branch (eature/your-feature-name).
2. Adhere to the established Dart style guide and Clean Architecture patterns.
3. Test your changes locally before submitting a Pull Request.

## 📝 License

**Proprietary Software**  
All rights reserved to the Gombang Village Administration.  
Unauthorized copying, modification, or distribution of this software is strictly prohibited.

## 📬 Contact & Support

**Project Lead:** Azcharia  
**Repository:** [github.com/azcharia/sipengo](https://github.com/azcharia/sipengo)

If you encounter any issues, please refer to the Troubleshooting section in the [Wiki/Issues](https://github.com/azcharia/sipengo/issues) or consult the internal developer documentations provided in the repository.

---
<p align="center">Made with ❤️ for Desa Gombang</p>
