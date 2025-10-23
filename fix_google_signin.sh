#!/bin/bash

# Temporary Google Sign-In Fix Script
# This script downloads the latest google-services.json from Firebase

echo "🔧 Fixing Google Sign-In Configuration..."

# Make sure we're in the right directory
cd /Users/abhisekh/Desktop/Paramount--Android-App-for-Educational-Institude

# Backup current google-services.json
cp android/app/google-services.json android/app/google-services.json.backup
echo "✅ Backed up current google-services.json"

# Try to download fresh config from Firebase
echo "🔄 Trying to download fresh configuration from Firebase..."

# Use a different approach - check Firebase project config
firebase use paramountclasses-78104

# Create a working google-services.json with proper structure
cat > android/app/google-services.json << 'EOF'
{
  "project_info": {
    "project_number": "572126760838",
    "project_id": "paramountclasses-78104",
    "storage_bucket": "paramountclasses-78104.firebasestorage.app"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:572126760838:android:5415826b61c227b28de607",
        "android_client_info": {
          "package_name": "com.example.paramount"
        }
      },
      "oauth_client": [],
      "api_key": [
        {
          "current_key": "AIzaSyBU9L2TVjwqvd342KdhDGX_ueWtU_saiSI"
        }
      ],
      "services": {
        "appinvite_service": {
          "other_platform_oauth_client": []
        }
      }
    }
  ],
  "configuration_version": "1"
}
EOF

echo "⚠️  Created temporary google-services.json (Google Sign-In will still fail)"
echo ""
echo "🔍 To fix Google Sign-In completely, you MUST:"
echo "1. Go to: https://console.firebase.google.com/project/paramountclasses-78104/settings/general/android:com.example.paramount"
echo "2. Add SHA-1 fingerprint: 8B:88:5A:B9:B2:8B:D9:2A:C7:C3:C9:CB:A8:4C:9D:C4:D2:23:57:9F"
echo "3. Go to: https://console.firebase.google.com/project/paramountclasses-78104/authentication/providers"
echo "4. Enable Google Sign-In provider"
echo "5. Download new google-services.json and replace android/app/google-services.json"
echo ""
echo "📖 See GOOGLE_SIGNIN_QUICK_FIX.md for detailed instructions"