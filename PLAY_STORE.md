# Google Play Store Publishing Guide

Step-by-step guide to prepare, sign, build, and publish **NutriScan Calorie Tracker** on the Google Play Store.

---

## Step 1: Branding & Launcher Icons

Ensure launcher icons are generated from `assets/logo/logo.png`.
Run this command to generate launcher icons:
```bash
flutter pub run flutter_launcher_icons
```
*Note: Configured in `pubspec.yaml` under `flutter_launcher_icons`.*

---

## Step 2: Configure App Metadata

### Verify App Name
Update the app name in `android/app/src/main/AndroidManifest.xml` if needed:
   ```xml
   <application
       android:label="NutriScan"
       ...
   ```

### Check Permissions
In `android/app/src/main/AndroidManifest.xml`, verify the internet permission is set:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```
*Note: The camera permission is not required when using standard image picking via image_picker since it uses the system camera app directly.*

---

## Step 3: Create a Keystore (Signing Key)

An upload key (keystore) is required to sign the application.

### Windows (PowerShell)
Run:
```powershell
keytool -genkey -v -keystore upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```
*Keep this keystore file extremely secure. Do not check it into Git.*

---

## Step 4: Configure Signing in Flutter

To automate signing, configure the project with your keystore credentials.

1. Create a file named `android/key.properties` (never commit this file to Git):
   ```properties
   storePassword=<your-keystore-password>
   keyPassword=<your-key-password>
   keyAlias=upload
   storeFile=upload-keystore.jks
   ```
2. Make sure `key.properties` is ignored in `.gitignore`:
   ```gitignore
   **/android/key.properties
   ```

---

## Step 5: Update Gradle Build Configuration

Update [android/app/build.gradle.kts](file:///C:/dev/flutter/calorie-tracker/android/app/build.gradle.kts) to read `key.properties` and apply signing.

Add the following import statements to the very top of `build.gradle.kts`, and add the loader block before the `android { ... }` section:

```kotlin
import java.util.Properties
import java.io.FileInputStream

// ... plugins block ...

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
```

Inside the `android { ... }` block, configure the signing configs and build types:

```kotlin
android {
    ...
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it as String) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}
```

---

## Step 6: Build the App Bundle

Google Play requires the **Android App Bundle (.aab)** format.

Run this command to build the signed release bundle:
```bash
flutter build appbundle --release
```

The output file will be generated at:
`build/app/outputs/bundle/release/app-release.aab`

---

## Step 7: Google Play Console Setup

1. **Create Developer Account**: Register at [Google Play Console](https://play.google.com/console).
2. **Create New App**: Click "Create app", fill in the default language, app name, and select "App" and "Free".
3. **Set Up Store Presence**:
   - Upload high-res icon (512x512 PNG).
   - Upload feature graphic (1024x500 PNG).
   - Upload screenshots (phone/tablet).
   - Fill in short and full descriptions.
4. **Publishing Tracks**:
   - **Internal Testing**: Share builds instantly with up to 100 testers.
   - **Closed/Open Testing**: Beta testing before release.
   - **Production**: Launch app to public.
5. **Upload App Bundle**:
   - Create a new release in your preferred track.
   - Drag and drop `app-release.aab`.
   - Complete standard questionnaires (content rating, target audience, privacy policy).
6. **Review and Rollout**: Click "Save", "Review release", and "Start rollout" to submit the app to Google's review team.
