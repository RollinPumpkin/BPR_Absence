# iOS Deployment with GitHub Actions

## Overview
This repository includes a comprehensive GitHub Actions workflow for automated iOS deployment with security testing and jailbreak analysis capabilities.

## Prerequisites

### 1. iOS Development Setup
- Apple Developer Account (Team Admin access required)
- iOS Distribution Certificate
- App Store Connect API Key
- Provisioning Profile

### 2. Required GitHub Secrets

Add the following secrets to your GitHub repository:

#### iOS Code Signing
```
IOS_CERTIFICATE_BASE64          # Base64 encoded .p12 certificate
IOS_CERTIFICATE_PASSWORD        # Password for the .p12 certificate
IOS_PROVISIONING_PROFILE_BASE64 # Base64 encoded provisioning profile
IOS_DEVELOPMENT_TEAM            # Your Apple Developer Team ID
IOS_CODE_SIGN_IDENTITY          # Certificate name (e.g., "Apple Distribution: Company Name")
IOS_PROVISIONING_PROFILE_SPECIFIER # Provisioning profile name
KEYCHAIN_PASSWORD               # Temporary keychain password
```

#### App Store Connect API
```
APP_STORE_CONNECT_API_KEY_ID    # API Key ID from App Store Connect
APP_STORE_CONNECT_API_ISSUER_ID # Issuer ID from App Store Connect
APP_STORE_CONNECT_API_KEY       # Base64 encoded .p8 API key file
```

## Setup Instructions

### 1. Generate iOS Certificate and Provisioning Profile

```bash
# Export certificate as .p12
# In Keychain Access: Export certificate -> Personal Information Exchange (.p12)

# Convert to base64
base64 -i certificate.p12 -o certificate_base64.txt

# Convert provisioning profile to base64
base64 -i profile.mobileprovision -o profile_base64.txt
```

### 2. Create App Store Connect API Key

1. Go to App Store Connect → Users and Access → Keys
2. Generate a new API key with App Manager role
3. Download the .p8 file
4. Convert to base64: `base64 -i AuthKey_XXXXXXXXXX.p8`

### 3. Configure Repository Secrets

Go to GitHub Repository → Settings → Secrets and Variables → Actions

Add all the required secrets listed above.

### 4. Update Configuration Files

#### Update `frontend/ios/exportOptions.plist`:
```xml
<key>teamID</key>
<string>YOUR_ACTUAL_TEAM_ID</string>

<key>provisioningProfiles</key>
<dict>
    <key>com.your.bundle.id</key>
    <string>Your Provisioning Profile Name</string>
</dict>
```

#### Update `frontend/ios/Runner.xcodeproj/project.pbxproj`:
- Set your bundle identifier
- Configure team ID
- Set provisioning profile

## Workflow Features

### 🧪 Comprehensive Testing
- **Backend Testing**: Complete API endpoint validation
- **Frontend Testing**: Flutter unit and integration tests
- **Coverage Reports**: Automated code coverage analysis

### 🏗️ iOS Build Pipeline
- **Automated Code Signing**: Secure certificate and profile management
- **Archive & Export**: Complete IPA generation
- **Build Artifacts**: Persistent storage for debugging

### 🔒 Security Analysis
- **Jailbreak Detection Testing**: Comprehensive security validation
- **Static Analysis**: Binary and configuration security checks
- **Runtime Protection**: Anti-tampering mechanism verification
- **Security Reports**: Detailed compliance documentation

### 🚀 Deployment Options
- **TestFlight Integration**: Automatic beta distribution
- **Environment Support**: Staging and production deployments
- **Manual Triggers**: On-demand deployment control

## Workflow Triggers

### Automatic Triggers
```yaml
# Push to main or develop branches
push:
  branches: [ main, develop ]

# Pull requests to main
pull_request:
  branches: [ main ]
```

### Manual Triggers
```yaml
# Manual workflow dispatch with options
workflow_dispatch:
  inputs:
    deploy_environment:
      description: 'Deployment Environment'
      required: true
      default: 'staging'
      type: choice
      options:
      - staging
      - production
    enable_jailbreak_testing:
      description: 'Enable Jailbreak Testing'
      required: true
      default: true
      type: boolean
```

## Security Testing Features

### Jailbreak Detection Analysis
- **Static String Analysis**: Detection of jailbreak-related strings
- **File System Checks**: Common jailbreak file presence validation
- **URL Scheme Detection**: Cydia and jailbreak app scheme checks
- **Binary Analysis**: Security feature verification

### Security Recommendations
- ✅ Implement jailbreak detection with graceful handling
- ✅ Use certificate pinning for all API communications
- ✅ Store sensitive data in iOS Keychain
- ✅ Implement runtime integrity checks
- ✅ Add anti-debugging mechanisms
- ✅ Consider code obfuscation for critical business logic

## Deployment Process

### 1. Automatic Deployment (Main Branch)
```bash
git push origin main
# Triggers full pipeline: Test → Build → Security Analysis → Deploy
```

### 2. Manual Deployment
1. Go to GitHub Actions
2. Select "iOS Deployment with Jailbreak Testing"
3. Click "Run workflow"
4. Choose environment and options
5. Monitor deployment progress

### 3. TestFlight Distribution
- Automatic upload to TestFlight after successful build
- Beta testers receive notifications
- Internal testing available immediately
- External testing requires App Store Connect approval

## Monitoring and Troubleshooting

### Build Artifacts
- **iOS Build Artifacts**: IPA files and Xcode archives
- **Test Results**: Comprehensive test reports
- **Security Analysis**: Detailed security compliance reports
- **Coverage Reports**: Code coverage metrics

### Common Issues

#### Code Signing Errors
```bash
# Verify certificate and provisioning profile match
# Check team ID consistency
# Ensure provisioning profile contains correct devices
```

#### TestFlight Upload Failures
```bash
# Verify App Store Connect API credentials
# Check bundle ID matches App Store Connect record
# Ensure version/build numbers are incremented
```

#### Security Analysis Warnings
```bash
# Review security recommendations
# Implement suggested security measures
# Update security configurations
```

## Best Practices

### Security
1. **Never commit certificates or keys** to version control
2. **Rotate API keys** regularly
3. **Use environment-specific** configurations
4. **Monitor security reports** for compliance

### Deployment
1. **Test thoroughly** before production deployment
2. **Use staging environment** for validation
3. **Increment version numbers** appropriately
4. **Monitor deployment status** and logs

### Maintenance
1. **Update dependencies** regularly
2. **Review security recommendations** quarterly
3. **Archive build artifacts** appropriately
4. **Maintain deployment documentation**

## Support

For issues with the deployment pipeline:

1. **Check workflow logs** in GitHub Actions
2. **Review security analysis reports**
3. **Verify all secrets are properly configured**
4. **Ensure iOS development prerequisites are met**

## Security Compliance

This deployment pipeline includes:
- ✅ **OWASP Mobile Security** compliance checks
- ✅ **Apple App Store** security requirements
- ✅ **Jailbreak detection** validation
- ✅ **Runtime protection** verification
- ✅ **Binary security** analysis

---

**Last Updated**: October 2025  
**Compatibility**: iOS 12.0+, Xcode 15.4+, Flutter 3.24.0+