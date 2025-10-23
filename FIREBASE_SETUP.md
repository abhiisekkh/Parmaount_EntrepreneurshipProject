# Firebase Backend Setup Guide

This guide will help you set up Firebase for your Paramount Classes Flutter application.

## Prerequisites

- Flutter SDK installed
- Firebase CLI installed (`npm install -g firebase-tools`)
- Google account with Firebase access

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter project name: `paramount-classes` (or your preferred name)
4. Enable Google Analytics (recommended)
5. Choose analytics account or create new one
6. Click "Create project"

## Step 2: Enable Firebase Services

### Authentication
1. In Firebase Console, go to "Authentication" → "Sign-in method"
2. Enable "Email/Password" provider
3. Optionally enable "Google" provider for Google Sign-In
4. Configure authorized domains

### Firestore Database
1. Go to "Firestore Database" → "Create database"
2. Choose "Start in test mode" (we'll add security rules later)
3. Select location (choose closest to your users)
4. Click "Done"

### Storage
1. Go to "Storage" → "Get started"
2. Choose "Start in test mode" (we'll add security rules later)
3. Select location (same as Firestore)
4. Click "Done"

### Analytics (Optional)
1. Go to "Analytics" → "Get started"
2. Follow setup wizard

## Step 3: Add Firebase to Your Flutter App

### Install FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

### Configure Firebase
```bash
flutterfire configure
```

This will:
- Detect your Firebase project
- Generate platform-specific configuration files
- Update `firebase_options.dart`

### Alternative Manual Configuration

If FlutterFire CLI doesn't work, manually download config files:

#### Android
1. Go to Project Settings → Your Apps → Android app
2. Download `google-services.json`
3. Place in `android/app/`

#### iOS
1. Go to Project Settings → Your Apps → iOS app
2. Download `GoogleService-Info.plist`
3. Place in `ios/Runner/`

#### Web
1. Go to Project Settings → Your Apps → Web app
2. Copy config object
3. Update `lib/firebase_options.dart`

## Step 4: Update Configuration Files

### Update firebase_options.dart
Replace placeholder values in `lib/firebase_options.dart` with your actual Firebase config:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'your-actual-web-api-key',
  appId: 'your-actual-web-app-id',
  messagingSenderId: 'your-actual-sender-id',
  projectId: 'your-actual-project-id',
  authDomain: 'your-project-id.firebaseapp.com',
  storageBucket: 'your-project-id.appspot.com',
  measurementId: 'your-actual-measurement-id',
);
```

### Update firebase_config.dart
Update `lib/config/firebase_config.dart` with your project details:

```dart
static const String projectId = 'your-actual-project-id';
static const String apiKey = 'your-actual-api-key';
static const String messagingSenderId = 'your-actual-sender-id';
```

## Step 5: Install Dependencies

Run the following command to install all Firebase dependencies:

```bash
flutter pub get
```

## Step 6: Initialize Firebase

Ensure Firebase is initialized in your `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
```

## Step 7: Set Up Security Rules

### Firestore Security Rules
Go to Firestore Database → Rules and replace with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow read: if request.auth != null && resource.data.role == 'admin';
    }
    
    // Students collection
    match /students/{studentId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (request.auth.token.role == 'teacher' || request.auth.token.role == 'admin');
    }
    
    // Faculty collection
    match /faculty/{facultyId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (request.auth.token.role == 'admin' || request.auth.uid == facultyId);
    }
    
    // Attendance collection
    match /attendance/{attendanceId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (request.auth.token.role == 'teacher' || request.auth.token.role == 'admin');
    }
    
    // Classes collection
    match /classes/{classId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (request.auth.token.role == 'teacher' || request.auth.token.role == 'admin');
    }
    
    // Subjects collection
    match /subjects/{subjectId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (request.auth.token.role == 'admin');
    }
  }
}
```

### Storage Security Rules
Go to Storage → Rules and replace with:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Profile images
    match /profile_images/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Documents
    match /documents/{userId}/{documentType}/{allPaths=**} {
      allow read: if request.auth != null && 
        (request.auth.uid == userId || request.auth.token.role == 'teacher' || request.auth.token.role == 'admin');
      allow write: if request.auth != null && 
        (request.auth.uid == userId || request.auth.token.role == 'admin');
    }
    
    // Attendance sheets
    match /attendance_sheets/{className}/{date}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (request.auth.token.role == 'teacher' || request.auth.token.role == 'admin');
    }
  }
}
```

## Step 8: Create Database Indexes

Firestore requires composite indexes for certain queries. Go to Firestore Database → Indexes and create:

1. **Students by Class and Section**
   - Collection: `students`
   - Fields: `className` (Ascending), `section` (Ascending), `isActive` (Ascending)

2. **Attendance by Student and Date**
   - Collection: `attendance`
   - Fields: `studentId` (Ascending), `date` (Descending)

3. **Attendance by Class and Date**
   - Collection: `attendance`
   - Fields: `className` (Ascending), `date` (Descending)

4. **Faculty by Department**
   - Collection: `faculty`
   - Fields: `department` (Ascending), `isActive` (Ascending)

## Step 9: Test Your Setup

### Test Authentication
```dart
try {
  await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: 'test@example.com',
    password: 'password123',
  );

## Step 10: Deploy Firestore Rules (CLI)

Once you've updated `firestore.rules` in the repo (the file at the project root), deploy it with the Firebase CLI:

1. Login to Firebase:

```bash
firebase login
```

2. Select or initialize your project in the current folder (only needed once):

```bash
firebase use --add
```

3. Deploy only Firestore rules:

```bash
firebase deploy --only firestore:rules
```

This will push the `firestore.rules` file from your local project to the selected Firebase project.

Important: The version of the rules in this repo is permissive and intended for development. Before deploying to production, remove the fallback `match /{document=**}` rule and enforce role checks and data validation.

  print('Authentication working!');
} catch (e) {
  print('Authentication error: $e');
}
```

### Test Firestore
```dart
try {
  await FirebaseFirestore.instance.collection('test').add({
    'message': 'Hello Firebase!',
    'timestamp': FieldValue.serverTimestamp(),
  });
  print('Firestore working!');
} catch (e) {
  print('Firestore error: $e');
}
```

### Test Storage
```dart
try {
  final ref = FirebaseStorage.instance.ref().child('test.txt');
  await ref.putString('Hello Firebase Storage!');
  print('Storage working!');
} catch (e) {
  print('Storage error: $e');
}
```

## Step 10: Environment Configuration

### Development vs Production
Update `lib/config/firebase_config.dart`:

```dart
static const String environment = 'development'; // Change to 'production' for live app

// Feature flags for different environments
static const bool enablePushNotifications = true;
static const bool enableAnalytics = true;
static const bool enableErrorReporting = true;
```

## Troubleshooting

### Common Issues

1. **"Firebase not initialized" error**
   - Ensure `Firebase.initializeApp()` is called before using Firebase services
   - Check that `firebase_options.dart` is properly configured

2. **"Permission denied" error**
   - Verify security rules are properly set
   - Check user authentication status
   - Ensure user has required role permissions

3. **"Network error"**
   - Check internet connection
   - Verify Firebase project is in correct region
   - Check if Firebase service is down

4. **"Invalid API key" error**
   - Verify API key in configuration files
   - Ensure API key matches the correct Firebase project
   - Check if API key has proper restrictions

### Debug Mode
Enable debug logging:

```dart
// In main.dart
if (kDebugMode) {
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
}
```

## Security Best Practices

1. **Never expose API keys in public repositories**
2. **Use environment variables for sensitive data**
3. **Implement proper user role-based access control**
4. **Regularly review and update security rules**
5. **Enable Firebase App Check for production apps**
6. **Monitor Firebase usage and set up billing alerts**

## Monitoring and Analytics

1. **Firebase Console**: Monitor app performance, crashes, and usage
2. **Firestore Usage**: Track database reads/writes and costs
3. **Storage Usage**: Monitor file uploads and storage costs
4. **Authentication**: Track user sign-ups and sign-ins
5. **Performance**: Monitor app performance metrics

## Cost Optimization

1. **Set up billing alerts** to avoid unexpected charges
2. **Use offline persistence** to reduce Firestore reads
3. **Implement proper indexing** to optimize queries
4. **Use batch operations** for multiple writes
5. **Monitor usage patterns** and optimize accordingly

## Next Steps

After setting up Firebase:

1. **Test all features** thoroughly
2. **Set up user management** system
3. **Implement data validation** and error handling
4. **Add offline support** using Firestore persistence
5. **Set up push notifications** for important updates
6. **Implement analytics** to track user behavior
7. **Set up monitoring** and alerting systems

## Support

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Community](https://firebase.google.com/community)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/firebase)

## License

This setup guide is part of the Paramount Classes project. Please ensure compliance with Firebase terms of service and your project's licensing requirements. 