# Google Sign-In Fix Instructions

## Issue
Your app is showing `ApiException: 10` because the SHA-1 fingerprint is not properly configured in Firebase.

## Your Debug SHA-1 Fingerprint
```
8B:88:5A:B9:B2:8B:D9:2A:C7:C3:C9:CB:A8:4C:9D:C4:D2:23:57:9F
```

## Step-by-Step Fix

### 1. Add SHA-1 to Firebase Console
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `paramountclasses-78104`
3. Go to **Project Settings** (gear icon) → **Your apps**
4. Click on your Android app (`com.example.paramount`)
5. Scroll down to **SHA certificate fingerprints**
6. Click **Add fingerprint**
7. Paste this SHA-1: `8B:88:5A:B9:B2:8B:D9:2A:C7:C3:C9:CB:A8:4C:9D:C4:D2:23:57:9F`
8. Click **Save**

### 2. Enable Google Sign-In
1. In Firebase Console, go to **Authentication** → **Sign-in method**
2. Click on **Google**
3. Click **Enable**
4. Set your project support email
5. Click **Save**

### 3. Download New google-services.json
1. Go back to **Project Settings** → **Your apps**
2. Click **Download google-services.json**
3. Replace the file in `android/app/google-services.json`

### 4. Alternative: Quick Test
If you want to test immediately, I can help you create a temporary OAuth client ID.

## Verification
After completing these steps:
1. Clean and rebuild your app: `flutter clean && flutter pub get`
2. Run the app: `flutter run`
3. Test Google Sign-In

## Important Notes
- The SHA-1 fingerprint must match exactly
- Make sure you're using the debug keystore for development
- For production, you'll need to add the release SHA-1 as well