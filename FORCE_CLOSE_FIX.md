# Force Close Fix - MainApplication

## Masalah
APK force close immediately setelah dibuka, meskipun Firebase dan MultiDex sudah dikonfigurasi.

## Root Cause
Flutter menggunakan `${applicationName}` placeholder di AndroidManifest.xml yang tidak otomatis handle MultiDex initialization.

## Solusi
Buat custom `MainApplication` class yang extends `FlutterApplication` dan initialize MultiDex secara manual.

## Files Modified

### 1. `MainApplication.kt` (NEW FILE)
**Location**: `android/app/src/main/kotlin/BPR/Absens/MainApplication.kt`

```kotlin
package BPR.Absens

import io.flutter.app.FlutterApplication
import androidx.multidex.MultiDex
import android.content.Context

class MainApplication : FlutterApplication() {
    override fun attachBaseContext(base: Context) {
        super.attachBaseContext(base)
        MultiDex.install(this)
    }
}
```

### 2. `AndroidManifest.xml`
**Location**: `android/app/src/main/AndroidManifest.xml`

**Before:**
```xml
<application
    android:name="${applicationName}"
    ...>
```

**After:**
```xml
<application
    android:name=".MainApplication"
    ...>
```

## Why This Works

1. **FlutterApplication**: Extends Flutter's base application class
2. **MultiDex.install()**: Manually installs MultiDex before app starts
3. **attachBaseContext**: Called before onCreate(), ensuring MultiDex is ready

## Complete Fix Checklist

- [x] Firebase plugins enabled in build.gradle.kts
- [x] Firebase BOM dependencies added
- [x] MultiDex enabled in defaultConfig
- [x] MultiDex library dependency added
- [x] MainApplication class created
- [x] AndroidManifest.xml updated to use MainApplication
- [x] google-services.json present and valid
- [x] Package name matches (BPR.Absens)

## Testing
```bash
# Build APK
flutter build apk --debug

# Install to device
adb install frontend\build\app\outputs\flutter-apk\app-debug.apk

# Or copy APK to device and install manually
```

## Expected Result
✅ App opens without crash
✅ Login screen appears
✅ Firebase connection established
✅ All features working

## If Still Crashes
Check logcat for specific error:
```bash
adb logcat *:E | findstr "BPR.Absens"
```

Common errors and solutions:
- **ClassNotFoundException**: Clean build (`flutter clean`)
- **DexArchiveMerger**: Increase heap size in gradle.properties
- **FirebaseApp not initialized**: Check google-services.json
