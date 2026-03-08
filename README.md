<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/SQLite-07405E?style=for-the-badge&logo=sqlite&logoColor=white" alt="SQLite" />
  <img src="https://img.shields.io/badge/Firebase-039BE5?style=for-the-badge&logo=Firebase&logoColor=white" alt="Firebase" />
  <img src="https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white" alt="Docker" />
  <img src="https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white" alt="GitHub Actions" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-004D40?style=for-the-badge&logo=android&logoColor=white" alt="Platform" />
  <img src="https://img.shields.io/badge/License-All%20Rights%20Reserved-E11D48?style=for-the-badge&logo=security&logoColor=white" alt="License" />
</p>

# 🧩 Employee Connect

> **Advanced Employee & Family Management System**

Employee Connect is a **Flutter-based mobile application** designed to **modernize and simplify the management of employee demographics, social aid programs, and employment records**.

The system focuses on **Clean Architecture and Domain-Driven Design (DDD)** and aims to **provide administrative officers with a secure, offline-first tool to generate professional PDF reports and track socio-economic data with precision**.

---

# ✨ Key Features

| Feature | Description |
|---|---|
| Family Demographics | Comprehensive tracking of households, relationships, and demographic data. |
| Social Aid Management | Integrated eligibility tracking for Samurdhi, Aswasuma, and local aid programs. |
| Employment Analytics | Granular reporting for government, private sector, and self-employed statistics. |
| Intelligent PDF Engine | One-click professional PDF report generation for all administrative categories. |
| Secure Licensing | 256-bit encrypted license activation system to protect sensitive village data. |
| Cross-Platform Ready | Dockerized web deployment and responsive UI for mobile, web, and desktop. |

---

# 🎬 Project Demonstration

The following resources demonstrate the system's behavior:

- � [Product Demonstration Video](#-product-video)
- �📸 [Screenshots of key features](#-screenshots)
- ⚙️ [System architecture overview](docs/architecture.md)
- 🧠 [Engineering lessons](#-engineering-lessons)
- 🔧 [Design decisions](#-key-design-decisions)
- 🗺️ [Roadmap](#-roadmap)
- 🚀 [Future improvements](#-future-improvements)
- 📝 [License](#-license)
- 📩 [Contact](#-contact)

If deeper technical access is required, it can be provided upon request.

---

# 📹 Product Video

> **[DEMONSTRATION PENDING]**

*A comprehensive video or GIF of the system's walkthrough demonstrating the Clean Architecture, reporting engine, and core workflows is available upon request for technical review.*

---

# 📸 Screenshots

| Family Data Entry | Data List View | Aid Categories |
|---------------|---------------|---------------|
| ![](Screenshots/Family%20Data%20Entry.jpg) | ![](Screenshots/Family%20Data%20List.jpg) | ![](Screenshots/Family%20Aid%20Types.jpg) |

| Aid Details (Samurdhi) | Employment Analytics | Statistics Overview |
|---------------|---------------|---------------|
| ![](Screenshots/Family%20Aid%20details%20(Samurdi).jpg) | ![](Screenshots/Job%20Types.jpg) | ![](Screenshots/old.jpg) |

| User Profile View | Data Update Screen | PDF Export Engine |
|---------------|---------------|---------------|
| ![](Screenshots/Profile%20for%20an%20User.jpg) | ![](Screenshots/Updating%20screen%20for%20an%20User.jpg) | ![](Screenshots/PDF%20Downloading%20Screen%20for%20a%20Filtered%20Category.jpg) |

| Security Activation | Database Export | Database Import |
|---------------|---------------|---------------|
| ![](Screenshots/Security%20License%20Activation.jpeg) | ![](Screenshots/Data%20Exporting.jpg) | ![](Screenshots/Data%20Importing.jpg) |

---

# ⚙️ Architecture Overview

Employee Connect is implemented using a **Clean Architecture with Domain-Driven Design (DDD) principles**.

### Frontend
- Flutter (Framework)
- Material UI
- Responsive Max-Width Container

### Backend & Storage
- SQLite (Local Database)
- Firebase Firestore (Cloud Synchronization)
- Firebase Core

### Communication & Services
- Service Locator (Get_it)
- PDF Generation Engine
- Printing & File Sharing Services

### Local Persistence & Security
- Shared Preferences
- Flutter Secure Storage
- AES/RSA Encryption (License Verification)

---

# 🧠 Engineering Lessons

During development of Employee Connect the focus areas included:

- **Architectural Integrity**: Implementing strict layer boundaries to ensure the domain remains independent of technical implementations like SQLite or Firebase.
- **Data Persistence Patterns**: Managing SQLite schemas and migrations effectively for complex relational data in an offline-first mobile environment.
- **Decoupled PDF Rendering**: Building a flexible PDF generation engine that consumes domain entities without being tied to the presentation layer.
- **Security Best Practices**: Implementing encrypted license verification and secure credential storage for administrative data protection.
- **Cross-Platform Consistency**: Engineering a responsive 'Max-Width' container strategy that preserves mobile UX patterns on large screen web deployments.

---

# 🔧 Key Design Decisions

1. **Separation of Concerns (Clean Architecture)**

   Decided to split the app into core, data, domain, and presentation layers to maximize testability and allow future transitions (e.g., from SQLite to another DB) without touching business logic.

2. **Offline-First Approach**

   Chose SQLite with selective Firebase synchronization to ensure village officers can work in remote areas with limited connectivity while maintaining data durability.

3. **Service Locator Pattern**

   Used `get_it` for dependency injection to manage complexity and facilitate mocking during unit testing of domain repositories and external services.

4. **Material UI with Constrained Width**

   Implemented a 'Max-Width' builder for the web to prevent UI stretching on desktop browsers, maintaining the professional density and readability of the application.

5. **Encrypted Licensing Module**

   Developed a custom license validation service using `shared_preferences` and encryption to secure the application against unauthorized access and protect sensitive records.

---

# 🗺️ Roadmap

The following phases outline the development and implementation milestones for Employee Connect:

- ✅ **Phase 1: Core Foundation** — Implementation of Clean Architecture, Dependency Injection (`get_it`), and base Domain entities. **(COMPLETED)**
- ✅ **Phase 2: Data Persistence** — Integration of SQLite with `sqflite`, repository implementations, and secure local storage with `flutter_secure_storage`. **(COMPLETED)**
- ✅ **Phase 3: Family Management** — Development of complex CRUD forms, profile management, and relational household data mapping. **(COMPLETED)**
- ✅ **Phase 4: Advanced Reporting & PDF** — Implementation of the analytics engine for Aid/Employment data and custom PDF generation logic. **(COMPLETED)**
- 🟡 **Phase 5: DevOps** — Dockerization for web deployment, GitHub Actions CI integration, and Firebase synchronization. **(IN PROGRESS)**
- ✅ **Phase 6: Security & Licensing** — Development of the 256-bit encrypted license activation system and administrative guards. **(COMPLETED)**

---

# 🚀 Future Improvements

Planned enhancements to build upon the current stable release:

- 🏗️ **Biometric Authentication** — Integration of Fingerprint/FaceID for secure local access.
- 🏗️ **Analytics Dashboard** — Interactive charts and data visualization for demographic trends.
- 🏗️ **Localization** — Full support for multi-language (Sinhala, Tamil) administrative workflows.
- 🏗️ **Data Migration Tools** — Advanced CSV/Excel importing tools for legacy system transitions.
- 🏗️ **Automated Cloud Backup** — Scheduled background snapshots for disaster recovery.Geospatial mapping of households within the village division using GIS data.
- Multi-user role-based access control (RBAC) for different administrative levels.
- Real-time notification system for aid disbursement and government updates.
- Progressive Web App (PWA) optimization for high-performance low-bandwidth environments.

---

## 📄 Documentations

Additional documentation is available in the `docs/` folder:

| File | Description |
|---|---|
| ["Architecture Guide"](docs/architecture.md) | Deep dive into Clean Architecture and Data Flow. |
| ["Feature Breakdown"](docs/features.md) | Detailed view of reporting and aid management logic. |

---

# 📝 License

This repository is published for **portfolio and educational review purposes**.

The source code may not be accessed, copied, modified, distributed, or used without explicit permission from the author.

© 2024 Viraj Tharindu — All Rights Reserved.

---

# 📩 Contact

If you are reviewing this project as part of a hiring process or are interested in the technical approach behind it, feel free to reach out.

I would be happy to discuss the architecture, design decisions, or provide a private walkthrough of the project.

**Opportunities for collaboration or professional roles are always welcome.**

📧 Email: virajtharindu1997@gmail.com  
💼 LinkedIn: [https://www.linkedin.com/in/viraj-tharindu/](https://www.linkedin.com/in/viraj-tharindu/)  
🌐 Portfolio: [Visit my portfolio](https://virajtharindu.github.io/Portfolio-Website/)  
🐙 GitHub: [https://github.com/VirajTharindu](https://github.com/VirajTharindu)  

---

<p align="center">
  <em>Built with ❤️ for efficient Employee administration!</em>
</p>
