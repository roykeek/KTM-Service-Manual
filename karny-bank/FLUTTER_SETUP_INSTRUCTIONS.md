# Karny Bank - File Organization & Setup Instructions

## 📂 Complete File List

### Core Files to Copy/Create

#### 1. **pubspec.yaml** (Root)
Location: `karny_bank/pubspec.yaml`
Copy the provided pubspec.yaml file.

#### 2. **Main Entry Point**
```
lib/main.dart
```
Initializes Riverpod and app configuration.

#### 3. **Constants & Theme**
```
lib/constants/theme.dart
```
All colors, spacing, fonts, and theme configuration.

#### 4. **Providers (State Management)**
```
lib/providers/database_provider.dart
```
All Riverpod providers for reactive state.

#### 5. **Backend Services** (Copy from previous backend files)
```
lib/services/
├── database_service.dart
├── database_models.dart
├── calculation_service.dart
├── automation_service.dart
└── transaction_service.dart
```

#### 6. **Screens**
```
lib/screens/
├── splash_screen.dart          (Initialization)
├── dashboard_screen.dart       (Main UI)
├── history_screen.dart         (Transaction history)
└── configuration_screen.dart   (Settings)
```

#### 7. **Widgets (UI Components)**
```
lib/widgets/
├── account_card.dart           (Account card component)
├── transaction_dialogs.dart    (Deposit/Withdrawal dialogs)
├── financial_tips_dialog.dart  (Financial tips popup)
└── calculator_widget.dart      (Calculator overlay)
```

---

## 🏗️ Directory Structure to Create

```
karny_bank/
├── lib/
│   ├── main.dart
│   ├── constants/
│   │   └── theme.dart
│   ├── providers/
│   │   └── database_provider.dart
│   ├── services/
│   │   ├── database_service.dart
│   │   ├── database_models.dart
│   │   ├── calculation_service.dart
│   │   ├── automation_service.dart
│   │   └── transaction_service.dart
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── dashboard_screen.dart
│   │   ├── history_screen.dart
│   │   └── configuration_screen.dart
│   └── widgets/
│       ├── account_card.dart
│       ├── transaction_dialogs.dart
│       ├── financial_tips_dialog.dart
│       └── calculator_widget.dart
├── pubspec.yaml
└── android/
    └── (default Flutter structure)
```

---

## ⚡ Step-by-Step Setup

### Step 1: Create Flutter Project
```bash
flutter create karny_bank
cd karny_bank
```

### Step 2: Create Directory Structure
```bash
mkdir -p lib/constants
mkdir -p lib/providers
mkdir -p lib/services
mkdir -p lib/screens
mkdir -p lib/widgets
```

### Step 3: Copy Files
1. Copy `pubspec.yaml` to project root
2. Copy all service files to `lib/services/`
3. Copy all screen files to `lib/screens/`
4. Copy all widget files to `lib/widgets/`
5. Copy constants to `lib/constants/`
6. Copy providers to `lib/providers/`
7. Copy `main.dart` to `lib/`

### Step 4: Update Imports
All files use relative imports. Verify paths match your structure:
- `import 'package:flutter/material.dart';`
- `import 'package:flutter_riverpod/flutter_riverpod.dart';`
- `import '../constants/theme.dart';`
- etc.

### Step 5: Get Dependencies
```bash
flutter pub get
```

### Step 6: Run the App
```bash
flutter run
```

---

## 📋 File Mapping

| Created File | Destination | Purpose |
|---|---|---|
| `pubspec.yaml` | `karny_bank/pubspec.yaml` | Dependencies |
| `main.dart` | `lib/main.dart` | Entry point |
| `constants_theme.dart` | `lib/constants/theme.dart` | Design tokens |
| `providers_database_provider.dart` | `lib/providers/database_provider.dart` | State providers |
| `screens_splash_screen.dart` | `lib/screens/splash_screen.dart` | Initialization |
| `screens_dashboard_screen.dart` | `lib/screens/dashboard_screen.dart` | Dashboard |
| `screens_history_screen.dart` | `lib/screens/history_screen.dart` | History |
| `screens_configuration_screen.dart` | `lib/screens/configuration_screen.dart` | Settings |
| `widgets_account_card.dart` | `lib/widgets/account_card.dart` | Card component |
| `widgets_transaction_dialogs.dart` | `lib/widgets/transaction_dialogs.dart` | Dialogs |
| `widgets_financial_tips_dialog.dart` | `lib/widgets/financial_tips_dialog.dart` | Tips popup |
| `widgets_calculator_widget.dart` | `lib/widgets/calculator_widget.dart` | Calculator |
| Backend files (5) | `lib/services/` | Database & logic |

---

## 🔧 Import Verification

After copying files, verify these imports work correctly:

### Main
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'constants/theme.dart';
import 'screens/splash_screen.dart';
```

### Dashboard Screen
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/theme.dart';
import '../providers/database_provider.dart';
import '../widgets/account_card.dart';
import '../widgets/transaction_dialogs.dart';
import '../widgets/calculator_widget.dart';
import 'history_screen.dart';
import 'configuration_screen.dart';
```

### Widgets
```dart
import '../constants/theme.dart';
import '../services/database_models.dart';
import '../services/calculation_service.dart';
import '../providers/database_provider.dart';
```

---

## 🎯 Verification Checklist

After setup, verify:

- [ ] `flutter pub get` completes successfully
- [ ] No import errors in IDE
- [ ] `flutter analyze` shows no errors
- [ ] `flutter run` launches app
- [ ] Splash screen appears
- [ ] Dashboard loads with account cards
- [ ] Database initializes
- [ ] Sample accounts created
- [ ] Buttons are clickable
- [ ] Dialogs appear and close
- [ ] Bottom navigation works
- [ ] No console errors

---

## 🐛 Common Issues

### Issue: "Cannot find package 'flutter_riverpod'"
**Solution**: Run `flutter pub get`

### Issue: "Import not found"
**Solution**: Check file paths and directory structure match exactly

### Issue: "Widget not found"
**Solution**: Verify file names match imports (case-sensitive)

### Issue: "Database already in use"
**Solution**: Restart app or clear app data

### Issue: "No provider found"
**Solution**: Ensure Riverpod ProviderScope wraps app

---

## 📝 File Naming Convention

All files created follow this convention:
- `screens_XXX_screen.dart` → destination: `lib/screens/xxx_screen.dart`
- `widgets_XXX_widget.dart` → destination: `lib/widgets/xxx_widget.dart`
- `providers_XXX_provider.dart` → destination: `lib/providers/xxx_provider.dart`
- `constants_XXX.dart` → destination: `lib/constants/xxx.dart`
- Backend service files → destination: `lib/services/` (already correct names)

Simply rename by removing the prefix when copying.

---

## 🚀 Ready to Start?

1. Create the Flutter project structure
2. Copy all files to their destinations
3. Update any import paths if needed
4. Run `flutter pub get`
5. Launch with `flutter run`
6. Test all features

Your complete Karny Bank app is ready to go! 🎉

