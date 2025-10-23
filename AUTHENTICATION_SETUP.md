# Personal Sign-In Methods Setup Guide

This guide will help you configure Google Sign-In, Apple Sign-In, and Facebook Sign-In for your Paramount Institute app.

## 🔧 Prerequisites

Before setting up social sign-in methods, ensure you have:
- ✅ Firebase project configured
- ✅ Flutter project with Firebase integration
- ✅ Required dependencies installed (already done in pubspec.yaml)

## 📱 Platform Configuration

### Google Sign-In Setup

#### Android Configuration

1. **Get Google Services JSON**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Select your project → Project Settings → General tab
   - Download `google-services.json` (already in your project)

2. **Configure OAuth Client**
   - In Firebase Console, go to Authentication → Sign-in method
   - Enable Google sign-in provider
   - Note the Web client ID (you'll need this)

3. **Update Android Files**
   
   **android/app/build.gradle** - Add at the bottom:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

   **android/build.gradle** - Add in dependencies:
   ```gradle
   classpath 'com.google.gms:google-services:4.3.15'
   ```

#### iOS Configuration

1. **Download GoogleService-Info.plist**
   - From Firebase Console → Project Settings → iOS app
   - Download `GoogleService-Info.plist`
   - Add to `ios/Runner/` folder in Xcode

2. **Configure URL Schemes**
   
   **ios/Runner/Info.plist** - Add:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
       <dict>
           <key>CFBundleURLName</key>
           <string>REVERSED_CLIENT_ID</string>
           <key>CFBundleURLSchemes</key>
           <array>
               <string>YOUR_REVERSED_CLIENT_ID_FROM_PLIST</string>
           </array>
       </dict>
   </array>
   ```

### Apple Sign-In Setup

#### Requirements
- Apple Developer Account ($99/year)
- iOS 13.0+ / macOS 10.15+

#### Configuration Steps

1. **Enable Apple Sign-In in Developer Console**
   - Go to [Apple Developer Console](https://developer.apple.com/)
   - Certificates, Identifiers & Profiles → Identifiers
   - Select your app → Sign In with Apple → Enable

2. **Firebase Configuration**
   - Firebase Console → Authentication → Sign-in method
   - Enable Apple sign-in provider
   - Add your Apple Team ID and Key ID

3. **iOS Configuration**
   
   **ios/Runner/Runner.entitlements**:
   ```xml
   <key>com.apple.developer.applesignin</key>
   <array>
       <string>Default</string>
   </array>
   ```

### Facebook Sign-In Setup

1. **Create Facebook App**
   - Go to [Facebook Developers](https://developers.facebook.com/)
   - Create New App → Consumer
   - Add Facebook Login product

2. **Configure Firebase**
   - Firebase Console → Authentication → Sign-in method
   - Enable Facebook provider
   - Add App ID and App Secret from Facebook

3. **Android Configuration**
   
   **android/app/src/main/res/values/strings.xml**:
   ```xml
   <string name="facebook_app_id">YOUR_FACEBOOK_APP_ID</string>
   <string name="fb_login_protocol_scheme">fbYOUR_FACEBOOK_APP_ID</string>
   ```

   **android/app/src/main/AndroidManifest.xml**:
   ```xml
   <uses-permission android:name="android.permission.INTERNET"/>
   
   <application>
       <meta-data android:name="com.facebook.sdk.ApplicationId" 
                  android:value="@string/facebook_app_id"/>
       
       <activity android:name="com.facebook.FacebookActivity"
                 android:configChanges="keyboard|keyboardHidden|screenLayout|screenSize|orientation"
                 android:label="@string/app_name" />
       
       <activity android:name="com.facebook.CustomTabActivity"
                 android:exported="true">
           <intent-filter>
               <action android:name="android.intent.action.VIEW" />
               <category android:name="android.intent.category.DEFAULT" />
               <category android:name="android.intent.category.BROWSABLE" />
               <data android:scheme="@string/fb_login_protocol_scheme" />
           </intent-filter>
       </activity>
   </application>
   ```

4. **iOS Configuration**
   
   **ios/Runner/Info.plist**:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
       <dict>
           <key>CFBundleURLName</key>
           <string>FacebookAuth</string>
           <key>CFBundleURLSchemes</key>
           <array>
               <string>fbYOUR_FACEBOOK_APP_ID</string>
           </array>
       </dict>
   </array>
   
   <key>FacebookAppID</key>
   <string>YOUR_FACEBOOK_APP_ID</string>
   <key>FacebookDisplayName</key>
   <string>Paramount Institute</string>
   
   <key>LSApplicationQueriesSchemes</key>
   <array>
       <string>fbapi</string>
       <string>fb-messenger-share-api</string>
       <string>fbauth2</string>
       <string>fbshareextension</string>
   </array>
   ```

## 🧪 Testing Your Implementation

### Demo Credentials
Your app includes demo credentials for testing:

- **Student**: `student@paramount.edu` / `student123`
- **Teacher**: `teacher@paramount.edu` / `teacher123`
- **Admin**: `admin@paramount.edu` / `admin123`

### Social Sign-In Testing

1. **Google Sign-In**
   - Use any valid Google account
   - First-time users will be prompted to complete profile setup

2. **Apple Sign-In**
   - Available only on iOS devices
   - Use any Apple ID for testing

3. **Facebook Sign-In**
   - Use any Facebook account
   - Test with both new and existing users

## 🔐 Security Best Practices

1. **Environment Variables**
   ```dart
   // Consider using flutter_dotenv for sensitive keys
   String get googleClientId => const String.fromEnvironment('GOOGLE_CLIENT_ID');
   ```

2. **Firebase Security Rules**
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
     }
   }
   ```

3. **User Data Validation**
   - Always validate user input
   - Sanitize data before storing in Firebase
   - Implement proper error handling

## 📝 Features Implemented

### ✅ Authentication Methods
- [x] Email/Password Authentication
- [x] Google Sign-In
- [x] Apple Sign-In (iOS only)
- [x] Facebook Sign-In
- [x] Demo Credentials for Testing

### ✅ User Management
- [x] User Registration with Role Selection
- [x] Profile Setup for New Users
- [x] Automatic Role-based Navigation
- [x] User Session Management

### ✅ UI/UX Features
- [x] Modern Material 3 Design
- [x] Beautiful Animations with AnimateDo
- [x] Responsive Social Sign-In Buttons
- [x] Form Validation and Error Handling
- [x] Loading States and Feedback

## 🚀 Next Steps

1. **Test Social Sign-In**
   - Configure at least Google Sign-In for full testing
   - Test user registration flow
   - Verify role-based navigation

2. **Customize UI**
   - Update colors to match your brand
   - Add custom logos and icons
   - Implement dark mode support

3. **Enhanced Security**
   - Implement password strength requirements
   - Add two-factor authentication
   - Set up email verification

4. **User Experience**
   - Add forgot password functionality
   - Implement account linking
   - Add profile picture upload

## 📞 Support

If you encounter any issues:
1. Check Firebase Console for authentication logs
2. Verify all configuration files are in place
3. Test with demo credentials first
4. Check platform-specific requirements

Your personal sign-in system is now ready! 🎉

The system provides a comprehensive authentication experience with multiple sign-in options, beautiful UI, and proper user management. Users can choose their preferred authentication method and get automatically routed to the appropriate dashboard based on their role.