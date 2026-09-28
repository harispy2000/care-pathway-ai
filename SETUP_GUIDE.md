# Care Pathway AI - Rebuild Source

This is a reconstructed source-code package based on the project we built in chat.
It is not a byte-for-byte copy of the old laptop project, but it contains the same main architecture:

- Flutter frontend
- ASP.NET Core Web API backend
- SQL Server database with EF Core
- Ollama AI integration
- Patient profile
- Analysis history
- Emergency contact section
- Optional Firebase notification service

---

## 1. Install requirements on the new laptop

Install:

- Visual Studio Code
- Flutter SDK
- Android Studio / Android SDK
- .NET SDK 10 or adjust backend target framework to your installed version
- SQL Server / SSMS if using local SQL
- Ollama if you want local AI model

Check:

```powershell
flutter doctor
 dotnet --version
```

---

## 2. Create the Flutter project

Go to the folder where you want the project:

```powershell
cd D:\Venkatesh\Development\Application\AR360
flutter create mobile_app
```

Then copy the provided `mobile_app/lib` folder and `mobile_app/pubspec.yaml` from this zip into your new Flutter project.

Run:

```powershell
cd mobile_app
flutter pub get
```

---

## 3. Configure Android permissions

Open:

```text
mobile_app/android/app/src/main/AndroidManifest.xml
```

Inside `<manifest>`, add:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

Inside `<application>`, add cleartext for local HTTP testing:

```xml
android:usesCleartextTraffic="true"
```

If using phone dialer with `url_launcher`, also add this near the top:

```xml
<queries>
    <intent>
        <action android:name="android.intent.action.VIEW" />
        <data android:scheme="tel" />
    </intent>
</queries>
```

---

## 4. Configure Gradle for flutter_local_notifications

Open:

```text
mobile_app/android/app/build.gradle.kts
```

Inside `android { compileOptions { ... } }`, add:

```kotlin
isCoreLibraryDesugaringEnabled = true
```

Make sure Java compatibility is 17:

```kotlin
compileOptions {
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
    isCoreLibraryDesugaringEnabled = true
}
```

Add this at the bottom, outside `android {}`:

```kotlin
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}
```

If Kotlin cache crashes, open:

```text
mobile_app/android/gradle.properties
```

Add:

```properties
kotlin.incremental=false
kotlin.compiler.execution.strategy=in-process
org.gradle.daemon=false
```

---

## 5. Configure API URL

Open:

```text
mobile_app/lib/config/api_config.dart
```

Change:

```dart
static const String baseUrl = "http://YOUR_API_IP_OR_DOMAIN:5193";
```

Example local laptop API:

```dart
static const String baseUrl = "http://192.168.1.6:5193";
```

Example hosted API under `/care`:

```dart
static const String baseUrl = "https://yourdomain.com/care";
```

---

## 6. Create backend project

Copy the provided folder:

```text
backend/CarePathwayApi
```

Open terminal:

```powershell
cd backend\CarePathwayApi
 dotnet restore
```

If your machine does not have .NET 10, either install .NET 10 SDK or edit `CarePathwayApi.csproj` and change:

```xml
<TargetFramework>net10.0</TargetFramework>
```

to your installed version, for example:

```xml
<TargetFramework>net9.0</TargetFramework>
```

Then update package versions if needed.

---

## 7. Configure database

Open:

```text
backend/CarePathwayApi/appsettings.json
```

LocalDB example:

```json
"DefaultConnection": "Server=(localdb)\\MSSQLLocalDB;Database=CarePathwayDb;Trusted_Connection=True;TrustServerCertificate=True;"
```

Remote SQL Server example:

```json
"DefaultConnection": "Server=YOUR_SERVER_IP,1433;Database=CarePathwayDb;User Id=YOUR_USER;Password=YOUR_PASSWORD;TrustServerCertificate=True;"
```

Run migrations:

```powershell
 dotnet tool install --global dotnet-ef
 dotnet ef migrations add InitialCreate
 dotnet ef database update
```

---

## 8. Run backend

```powershell
cd backend\CarePathwayApi
 dotnet run --urls "http://0.0.0.0:5193"
```

Test in browser:

```text
http://localhost:5193
```

You should see:

```text
Care Pathway API is running
```

On phone, use laptop Wi-Fi IP:

```text
http://YOUR_LAPTOP_IP:5193
```

---

## 9. Ollama setup

Install Ollama and run:

```powershell
ollama pull qwen2.5:3b
ollama run qwen2.5:3b
```

The backend will call:

```text
http://localhost:11434/api/chat
```

If Ollama is not running, the backend falls back to the rule-based safety service.

---

## 10. Firebase notifications

The source includes Firebase notification service, but it is disabled by default.

In `lib/main.dart`:

```dart
const bool enableFirebaseNotifications = false;
```

Keep it false until Firebase is configured.

To configure:

```powershell
firebase login
flutterfire configure --platforms=android
flutter pub get
```

Then replace placeholder `lib/firebase_options.dart` with the generated file.

Finally change:

```dart
const bool enableFirebaseNotifications = true;
```

Also make sure:

```text
android/app/google-services.json
```

exists.

---

## 11. Run Flutter app

```powershell
cd mobile_app
flutter pub get
flutter run
```

For Android phone:

```powershell
flutter devices
flutter run -d YOUR_DEVICE_ID
```

---

## Important note

This package was reconstructed from the code and architecture discussed in chat. It gives you a solid working rebuild, but it is not guaranteed to match every animation/style/detail from the old laptop project.
