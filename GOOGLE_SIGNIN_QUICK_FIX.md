# Google Sign-In Fix Guide

## Current Error
`ApiException: 10` means your SHA-1 certificate fingerprint is not properly configured in Firebase Console.

## Your SHA-1 Fingerprint
```
8B:88:5A:B9:B2:8B:D9:2A:C7:C3:C9:CB:A8:4C:9D:C4:D2:23:57:9F
```

## Step-by-Step Fix

### 1. Add SHA-1 to Firebase Console
1. Go to: https://console.firebase.google.com/project/paramountclasses-78104/settings/general/android:com.example.paramount
2. Scroll down to "SHA certificate fingerprints"
3. Click "Add fingerprint"
4. Paste: `8B:88:5A:B9:B2:8B:D9:2A:C7:C3:C9:CB:A8:4C:9D:C4:D2:23:57:9F`
5. Click "Save"

### 2. Enable Google Sign-In
1. Go to: https://console.firebase.google.com/project/paramountclasses-78104/authentication/providers
2. Click on "Google" provider
3. Click "Enable"
4. Add your support email (required)
5. Click "Save"

### 3. Download New google-services.json
1. Go back to: https://console.firebase.google.com/project/paramountclasses-78104/settings/general/android:com.example.paramount
2. Click "Download google-services.json"
3. Replace the file at: `android/app/google-services.json`

### 4. Clean and Rebuild
```bash
cd /Users/abhisekh/Desktop/Paramount--Android-App-for-Educational-Institude
flutter clean
flutter pub get
flutter run
```

## Alternative: Use Firebase CLI to Download
```bash
# Login if not already
firebase login

# Use your project
firebase use paramountclasses-78104

# Download the config (this will overwrite android/app/google-services.json)
firebase apps:sdkconfig android com.example.paramount > android/app/google-services.json
```

## Verification
After completing the above steps:
1. The google-services.json should have proper "oauth_client" entries
2. The certificate_hash should match your SHA-1 fingerprint
3. Google Sign-In should work without ApiException: 10

## If Still Not Working
If you continue to get ApiException: 10:
1. Double-check the SHA-1 fingerprint is exactly: `8B:88:5A:B9:B2:8B:D9:2A:C7:C3:C9:CB:A8:4C:9D:C4:D2:23:57:9F`
2. Ensure you're testing with debug build (not release)
3. Make sure the package name is exactly: `com.example.paramount`
4. Try uninstalling and reinstalling the app

## Manual google-services.json Template
If the automatic download doesn't work, here's what the oauth_client section should look like:
```json
"oauth_client": [
  {
    "client_id": "YOUR_ANDROID_CLIENT_ID.apps.googleusercontent.com",
    "client_type": 1,
    "android_info": {
      "package_name": "com.example.paramount",
      "certificate_hash": "8b885ab9b28bd92ac7c3c9cba84c9dc4d223579f"
    }
  },
  {
    "client_id": "YOUR_WEB_CLIENT_ID.apps.googleusercontent.com",
    "client_type": 3
  }
]
```

The client IDs will be automatically generated when you add the SHA-1 fingerprint and enable Google Sign-In.