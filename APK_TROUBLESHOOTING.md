# Troubleshooting APK Force Close

## Masalah yang Sudah Diperbaiki

### 1. Firebase Configuration Error
**Gejala**: App crash immediately after opening
**Penyebab**: Firebase plugins dan dependencies di-comment out di `build.gradle.kts`
**Solusi**: 
- ✅ Mengaktifkan `id("com.google.gms.google-services")`
- ✅ Mengaktifkan Firebase BOM dependencies
- ✅ File `google-services.json` sudah ada di folder yang benar

### 2. MultiDex Error
**Gejala**: App crash dengan error "method count exceeds 65K"
**Penyebab**: Firebase dan dependencies lain melebihi method count limit
**Solusi**:
- ✅ Menambahkan `multiDexEnabled = true` di defaultConfig
- ✅ Menambahkan dependency `androidx.multidex:multidex:2.0.1`

### 3. Java Version Incompatibility
**Gejala**: Build gagal dengan error "IllegalArgumentException: 25.0.1"
**Penyebab**: Kotlin compiler tidak support Java 25
**Solusi**:
- ✅ Install Java 17 LTS
- ✅ Gunakan script `BUILD_APK_JAVA17.bat` yang sudah set JAVA_HOME

## File yang Sudah Dimodifikasi

### `frontend/android/app/build.gradle.kts`
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // ✅ Diaktifkan
}

dependencies{
    implementation(platform("com.google.firebase:firebase-bom:34.1.0")) // ✅ Diaktifkan
    implementation("com.google.firebase:firebase-analytics") // ✅ Diaktifkan
    implementation("androidx.multidex:multidex:2.0.1") // ✅ Ditambahkan
}

android {
    defaultConfig {
        multiDexEnabled = true // ✅ Ditambahkan
    }
}
```

### `frontend/android/build.gradle.kts`
```kotlin
// Suppress Java warnings
gradle.projectsEvaluated {
    tasks.withType<JavaCompile> {
        options.compilerArgs.add("-Xlint:-options")
        options.compilerArgs.add("-Xlint:-deprecation")
    }
}
```

### `frontend/android/gradle.properties`
```properties
# Suppress warnings
org.gradle.warning.mode=none
android.suppressUnsupportedCompileSdk=34
```

## Cara Build APK yang Benar

### Option 1: Menggunakan Script (Recommended)
```cmd
BUILD_APK_JAVA17.bat
```

### Option 2: Manual dengan Flutter
```cmd
set "JAVA_HOME=C:\Program Files\Java\jdk-17"
set "PATH=%JAVA_HOME%\bin;%PATH%"
cd frontend
flutter clean
flutter pub get
flutter build apk --release
```

### Option 3: Debug APK (Untuk Testing Cepat)
```cmd
cd frontend
flutter build apk --debug
```

## Cara Test APK

### 1. Install ke Device
```cmd
adb install frontend\build\app\outputs\flutter-apk\bpr-absence.apk
```

### 2. Monitor Log Saat Install
```cmd
adb logcat *:E
```
Filter hanya error untuk lihat crash details.

### 3. Cek Specific Package Log
```cmd
adb logcat | findstr "BPR.Absens"
```

## Checklist Sebelum Build Production

- [ ] Firebase `google-services.json` ada dan valid
- [ ] Java 17 terinstall dan JAVA_HOME di-set dengan benar
- [ ] `multiDexEnabled = true` di build.gradle.kts
- [ ] Firebase plugins aktif (tidak di-comment)
- [ ] Test di device fisik atau emulator
- [ ] Tidak ada force close saat buka app
- [ ] Login berhasil
- [ ] Fitur utama berfungsi (attendance, letters, assignments)

## Error Messages & Solutions

### "Gradle build failed to produce an .apk file"
- Cek apakah file APK benar-benar tidak ada di `build\app\outputs\flutter-apk\`
- Kadang Flutter salah deteksi, APK sebenarnya sudah jadi
- Gunakan Gradle langsung: `gradlew assembleRelease`

### "java.lang.IllegalArgumentException: 25.0.1"
- Java version tidak kompatibel
- Gunakan Java 17: `BUILD_APK_JAVA17.bat`

### "FAILED_PRECONDITION: requires an index"
- Ini untuk Firestore query, bukan masalah APK
- Sudah diperbaiki dengan in-memory filtering

### Force Close Immediately After Launch
1. Cek logcat: `adb logcat *:E`
2. Pastikan Firebase configuration aktif
3. Pastikan MultiDex enabled
4. Test dengan debug APK dulu

## APK Output Locations

**Debug APK**:
```
frontend\build\app\outputs\flutter-apk\app-debug.apk
```

**Release APK**:
```
frontend\build\app\outputs\flutter-apk\app-release.apk
```
Rename menjadi `bpr-absence.apk` setelah build

## APK Size Comparison

- **Debug APK**: ~85 MB (dengan debug symbols)
- **Release APK**: ~55-60 MB (optimized)
- **Split APK**: 3 files @ ~30 MB each (per architecture)

## Next Steps

1. Build release APK dengan `BUILD_APK_JAVA17.bat`
2. Install dan test di device
3. Jika masih crash, ambil logcat dan analisa error
4. Upload ke Firebase App Distribution untuk testing
5. Collect feedback dari tester
6. Fix bugs yang ditemukan
7. Build production APK dengan proper signing key untuk Play Store
