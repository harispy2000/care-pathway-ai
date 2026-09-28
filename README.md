# Care Pathway AI 🩺

A **mobile application** (Flutter) with an AI-assisted healthcare decision-support backend that analyzes user-provided symptoms and generates personalized care-pathway guidance using **Google Gemini**.

> **Disclaimer:** Care Pathway AI provides AI-assisted guidance for informational purposes only. It is not a medical diagnosis or a replacement for a qualified healthcare professional. Users should seek professional medical help for severe, worsening, or emergency symptoms.

---

## 🚀 Overview

Care Pathway AI is a **mobile app** that helps users understand what steps they can consider taking based on the symptoms they provide.

Instead of functioning as a simple chatbot, the application processes the user's symptoms through a structured backend pipeline and generates a care pathway containing:

* Risk and emergency assessment
* Possible symptom/condition concerns
* Safety recommendations
* Personalized care steps
* Relevant matched factors
* Follow-up reminders
* Analysis history

The application is designed with safety in mind and explicitly identifies situations where urgent medical attention may be required.

---

## ✨ Features

### 🤖 AI-Powered Symptom Analysis

Users can enter their symptoms and receive AI-generated care-pathway guidance powered by **Google Gemini**.

The AI analyzes the supplied information and generates structured results that are displayed directly in the application's existing UI.

### 🚨 Emergency & Risk Assessment

The application evaluates the reported symptoms and provides an emergency/risk indication.

Potentially serious symptoms are accompanied by safety guidance recommending urgent professional medical attention.

### 🧭 Personalized Care Pathway

The AI generates structured care steps based on the user's input rather than returning a generic conversational response.

Example pathway:

1. Immediate care/safety recommendation
2. Recommended monitoring or self-care
3. Follow-up recommendation

### 📋 Matched Factors

The application displays relevant factors identified during the analysis, helping users understand what aspects of their input contributed to the generated pathway.

### 🔔 Follow-Up Reminders

Users can set reminders to revisit their care pathway or monitor their symptoms.

### 📚 Analysis History

Previous analyses can be stored and reviewed so users can track their interactions with the application.

### 🔐 Authentication

The application supports user authentication and user-specific data handling.

### 🛡️ Safety-First Design

AI output is accompanied by safety disclaimers and emergency guidance.

The system also maintains safe fallback behavior when the AI service cannot be reached.

---

## 🏗️ System Architecture

```text
┌──────────────────────┐
│     Flutter App      │
│                      │
│  • Symptom Input     │
│  • Analysis UI       │
│  • History           │
│  • Reminders         │
└──────────┬───────────┘
           │
           │ HTTPS / REST API
           ▼
┌──────────────────────┐
│   ASP.NET Core API   │
│                      │
│ • Authentication     │
│ • Business Logic     │
│ • Care Pathway API   │
│ • Response Handling  │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────────┐
│ GeminiCarePathwayService │
│                          │
│ Structured AI Requests   │
│ + Response Validation    │
└──────────┬───────────────┘
           │
           │ Gemini API
           ▼
┌──────────────────────┐
│    Google Gemini     │
│                      │
│ AI Symptom Analysis  │
│ Structured Response  │
└──────────────────────┘
```

---

## 🛠️ Technology Stack

| Technology              | Purpose                           |
| ----------------------- | --------------------------------- |
| **Flutter**             | Cross-platform mobile application |
| **Dart**                | Flutter application development   |
| **ASP.NET Core / .NET** | Backend REST API                  |
| **C#**                  | Backend implementation            |
| **Google Gemini API**   | AI-powered symptom analysis       |
| **MongoDB**             | Data storage and analysis history |
| **REST API**            | Frontend-backend communication    |
| **JSON**                | Structured API and AI responses   |

---

## 🧠 AI Architecture

The application uses a provider-based AI service architecture.

```text
ICarePathwayService
        │
        ▼
GeminiCarePathwayService
        │
        ▼
Google Gemini API
```

This separates the AI provider from the rest of the application and allows the backend to manage communication with the AI model.

The Gemini API key is kept **server-side** and is never placed inside the Flutter application.

### Structured AI Output

Gemini generates structured information corresponding to the application's care-pathway response model, including:

```text
Risk Score
Emergency Level
Possible Condition / Concern
Safety Advice
Care Steps
Matched Factors
```

The backend validates and processes the response before sending it to the Flutter application.

---

## 🔒 Security

Sensitive credentials are not stored in the Flutter application.

The Gemini API key is configured on the backend using environment variables / server-side secrets.

```text
Flutter
   │
   │ No Gemini API key
   ▼
.NET Backend
   │
   │ Secure server-side API key
   ▼
Google Gemini
```

This prevents users from extracting the Gemini API key from the mobile application.

---

## 🔄 Request Flow

When a user submits symptoms:

```text
1. User enters symptoms
          ↓
2. Flutter sends request
          ↓
3. ASP.NET Core receives request
          ↓
4. GeminiCarePathwayService processes request
          ↓
5. Gemini analyzes the symptoms
          ↓
6. Structured response returned
          ↓
7. Backend validates response
          ↓
8. Flutter displays care pathway
```

---

## 🛡️ Safety & Fallback Handling

The application does not rely exclusively on the availability of the AI provider.

If the Gemini service becomes unavailable, the backend can use its safety/fallback handling rather than leaving the request completely unresolved.

The application also maintains emergency safety messaging and advises users to seek professional medical assistance when symptoms are severe, worsening, or potentially life-threatening.

---

## 📱 Application Screens

### Authentication

* Login
* Registration
* User authentication

### Symptom Analysis

* Symptom input
* AI analysis
* Risk assessment

### Analysis Result

* Emergency/risk level
* Possible condition/concern
* Safety advice
* Care steps
* Matched factors
* Follow-up reminder

### History

* Previous analyses
* User-specific records

---

## ⚙️ Local Setup

### Prerequisites

Install:

* Flutter SDK
* .NET SDK
* MongoDB or configured MongoDB connection
* Google Gemini API credentials

Ollama is **not required** for the current implementation.

### Backend

Navigate to the backend:

```bash
cd backend/CarePathwayApi
```

Configure the Gemini API key using a secure environment variable or .NET user secrets.

Example:

```bash
dotnet user-secrets set "AI:Gemini:ApiKey" "YOUR_GEMINI_API_KEY"
```

Then run:

```bash
dotnet run
```

### Flutter

Navigate to the Flutter project:

```bash
cd frontend
```

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

---

## 🌐 Deployment Architecture

The application is designed so that users do not need to install a local AI model.

```text
User Device
     │
     │ HTTPS
     ▼
Hosted .NET API
     │
     │ Gemini API
     ▼
Google Gemini
```

The Gemini credentials remain on the backend server.

This allows the application to be deployed without requiring users to install Ollama or download a local language model.

---

## 📌 Future Improvements

* More advanced symptom history analysis
* Improved personalized care pathways
* Medication and appointment reminders
* Voice-based symptom input
* Multilingual support
* Additional healthcare information sources
* Improved explainability of AI-generated recommendations
* Production cloud deployment

---

## ⚠️ Medical Disclaimer

Care Pathway AI is an AI-assisted healthcare decision-support application.

It does **not** provide a medical diagnosis and should not replace consultation with a qualified healthcare professional.

If symptoms are severe, rapidly worsening, or potentially life-threatening, users should seek urgent medical assistance.

---

## 👨‍💻 Project

**Care Pathway AI**

Built using Flutter, ASP.NET Core, MongoDB and Google Gemini.
