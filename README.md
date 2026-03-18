# 🎤 TalkNotes: Enterprise AI Voice-to-Text Integration

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![Flutter](https://img.shields.io/badge/Flutter-Cross--Platform-02569B?logo=flutter)
![Node.js](https://img.shields.io/badge/Node.js-Backend-339933?logo=node.js)
![MongoDB](https://img.shields.io/badge/MongoDB-Database-47A248?logo=mongodb)
![License](https://img.shields.io/badge/license-ISC-green.svg)

**TalkNotes** is a scalable, AI-powered cross-platform application that transforms unstructured audio recordings into intelligent, professionally formatted text. Built with a Flutter frontend and a robust Node.js backend, TalkNotes leverages advanced AI technologies—including Google Cloud Speech-to-Text and Google Gemini AI—to automate the transcription and summarization processes for meeting notes, journal entries, and corporate documentation.

---

## 🏗️ System Architecture

TalkNotes follows a decoupled client-server architecture to ensure high scalability and seamless cross-platform delivery:

*   **Client Interface (Frontend):** A cross-platform mobile application built with **Flutter**, delivering a native-like experience for iOS and Android users. Handles local audio recording, file selection, and API communication.
*   **RESTful API Server (Backend):** A **Node.js/Express.js** server implementing a secure Model-View-Controller (MVC) pattern. 
*   **AI Processing Pipeline:** Integrates **Google Cloud Speech API** for high-accuracy transcription and **Google Gemini AI** for Natural Language Processing (NLP) to contextualize and format the text.
*   **Data & Asset Storage:** Utilizes **MongoDB** for highly available NoSQL data persistence and **Cloudinary** for scalable, secure media asset storage.

---

## ✨ Enterprise Capabilities

*   🎙️ **High-Fidelity Audio Ingestion:** Support for seamless cross-platform audio recording and multi-format file uploads.
*   🔤 **Automated Speech-to-Text Pipeline:** Real-time and asynchronous transcription using enterprise-grade Google Cloud Speech-to-Text.
*   🤖 **Generative AI Formatting:** Context-aware transformation of raw transcripts into structured formats (e.g., Executive Summaries, Meeting Minutes, Action Items) via Gemini AI.
*   🔐 **Secure Authentication & RBAC:** Role-Based Access Control distinguishing standard Users and System Administrators, secured via JWT and Bcrypt encryption.
*   ☁️ **Scalable Cloud Storage:** Offloaded media handling via Cloudinary to ensure rapid API response times and reduced server load.
*   📊 **Comprehensive Admin Console:** Centralized management of user lifecycles, platform analytics, and dynamic "Note Style" templating.

---

## 🛠️ Technology Stack

### Frontend (Mobile App)
*   **Framework:** Flutter / Dart
*   **Platform Targets:** iOS, Android

### Backend (API Services)
*   **Runtime:** Node.js
*   **Framework:** Express.js
*   **Architecture:** RESTful API, MVC Pattern
*   **Security:** JSON Web Tokens (JWT), CORS, bcrypt

### Data & Cloud Integration
*   **Database:** MongoDB, Mongoose ODM
*   **AI / ML:** Google Gemini AI, Google Cloud Speech API
*   **File Storage:** Cloudinary
*   **Logging & Diagnostics:** Morgan

---

## 🚀 Getting Started

### Prerequisites

Ensure the following tools are installed in your development environment:
*   [Node.js](https://nodejs.org/) (v16.x or higher recommended)
*   [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.0 or higher)
*   [MongoDB](https://www.mongodb.com/) (Local instance or Atlas Cluster)
*   Google Cloud Console Account (Speech API enabled, Service Account JSON key)
*   Google Gemini AI API Key
*   Cloudinary Account Credentials

### 1. Backend Setup (`/TalknoteBackend`)

1. **Navigate to the backend directory:**
   ```bash
   cd TalknoteBackend
   ```
2. **Install dependencies:**
   ```bash
   npm install
   ```
3. **Configure Environment Variables:**
   Create a `.env` file based on `.env.example`:
   ```bash
   cp .env.example .env
   ```
   *See the [Environment Configuration](#-environment-configuration) section for required values.*
4. **Launch the API Server:**
   ```bash
   # Development mode with hot-reload
   npm run dev

   # Production mode
   npm start
   ```

### 2. Frontend Setup (`/flutter_app`)

1. **Navigate to the frontend directory:**
   ```bash
   cd flutter_app
   ```
2. **Fetch Flutter packages:**
   ```bash
   flutter pub get
   ```
3. **Configure API Endpoints:**
   Ensure the frontend environment configuration points to your local or deployed TalkNotes Backend URL.
4. **Run the Application:**
   ```bash
   flutter run
   ```

---

## 🔐 Environment Configuration (Backend)

The backend requires the following variables defined in your `.env` file:

| Variable | Description | Required |
|----------|-------------|:--------:|
| `PORT` | API Server port (default: 3000) | No |
| `MONGODB_URL_STG` | MongoDB connection string | **Yes** |
| `DB_NAME` | Target Database name | **Yes** |
| `TOKEN_SECRET_KEY` | Secret key for JWT signature generation | **Yes** |
| `GEMINI_API_KEY` | Google Gemini AI API key | **Yes** |
| `GOOGLE_APPLICATION_CREDENTIALS`| Absolute path to Google Cloud service account JSON | **Yes** |
| `CLOUDINARY_CLOUD_NAME` | Cloudinary instance identifier | **Yes** |
| `CLOUDINARY_API_KEY` | Cloudinary API Key | **Yes** |
| `CLOUDINARY_API_SECRET` | Cloudinary API Secret | **Yes** |
| `FRONTEND_BASE_URL` | Permitted origins for CORS | **Yes** |

---

## 📡 API Reference Overview

The REST API utilizes standard HTTP methods and JSON responses. Base URL paths are prefixed with `/api`.

**Standard Response Format:**
```json
{
  "status": 1,
  "message": "Operation successful",
  "data": { ... }
}
```

### Key Endpoints

*   **Authentication:** `POST /api/user/registerUser`, `POST /api/user/loginUser`
*   **Audio Processing:** 
    *   `POST /api/user/saveAudioNote` (Metadata persistence)
    *   `POST /api/user/processAudioNote` (Multipart upload, AI Transcription & Formatting)
*   **Note Management:** `GET /api/user/getNotes`, `POST /api/user/createNote`, `PUT /api/user/updateNote/:noteId`
*   **Admin Panel:** `POST /api/admin/adminLogin`, `GET /api/admin/noteStyles`, `POST /api/admin/userDeactivate/:userId`

---

## 📁 Repository Structure

```text
Talknotes/
├── TalknoteBackend/          # Node.js REST API
│   ├── src/
│   │   ├── configs/          # Third-party client integrations
│   │   ├── controllers/      # Route logic & payload handling
│   │   ├── middlewares/      # Auth & Multipart upload interceptors
│   │   ├── models/           # Mongoose Data Schemas
│   │   ├── routes/           # API Routing definitions
│   │   ├── services/         # Core business logic (AI pipelines)
│   │   └── index.js          # API entry point
│   ├── package.json
│   └── README.md
│
└── flutter_app/              # Flutter Cross-Platform Client
    ├── lib/                  # Dart application code
    ├── ios/                  # iOS specific configurations
    ├── android/              # Android specific configurations
    ├── pubspec.yaml
    └── README.md
```

---

## 🤝 Contributing

We welcome contributions to enhance TalkNotes. To contribute:

1. Fork the repository.
2. Create a standardized feature branch (`git checkout -b feature/MYSYSTEM-123-Description`).
3. Commit your changes with descriptive messages.
4. Push to your branch (`git push origin feature/MYSYSTEM-123-Description`).
5. Open a Pull Request for code review.

## 📄 License

This enterprise software is distributed under the **ISC License**. See the `LICENSE` file for more information.

## 📧 Support & Contact

*   **Architecture & Development:** Jinish K.
*   **GitHub:** [@Jinish2170](https://github.com/Jinish2170)
*   **Issue Tracking:** Please utilize the GitHub Issues tab to report bugs or request feature enhancements.
