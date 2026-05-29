# 💰 Expense Tracker App — Flutter

A beautiful, dark-themed expense tracking app inspired by the screenshots provided. Built with Flutter + SQLite.

---

## 📁 Complete Folder Structure

```
expense_tracker/
│
├── pubspec.yaml                     ← All dependencies
├── android/
├── ios/
├── assets/
│   ├── images/
│   ├── icons/
│   └── animations/
│
└── lib/
    ├── main.dart                    ← App entry point
    │
    ├── core/
    │   ├── theme/
    │   │   └── app_theme.dart       ← Colors, fonts, dark theme
    │   ├── constants/
    │   │   └── app_constants.dart   ← Categories, payment methods
    │   └── utils/
    │       └── app_utils.dart       ← Currency, date formatting
    │
    ├── models/
    │   ├── expense_model.dart       ← Expense data model
    │   └── budget_model.dart        ← Budget + monthly budget models
    │
    ├── services/
    │   └── database_service.dart    ← SQLite CRUD operations
    │
    ├── providers/
    │   ├── expense_provider.dart    ← Expense state management
    │   └── budget_provider.dart     ← Budget state management
    │
    ├── routes/
    │   └── app_routes.dart          ← Named routes + transitions
    │
    ├── screens/
    │   ├── splash/
    │   │   └── splash_screen.dart
    │   ├── home/
    │   │   └── home_screen.dart     ← Bottom nav shell
    │   ├── dashboard/
    │   │   └── dashboard_screen.dart ← Main home (budget card, flow, recent)
    │   ├── add_expense/
    │   │   └── add_expense_screen.dart ← Numpad + categories + suggested amounts
    │   ├── analytics/
    │   │   └── analytics_screen.dart  ← Donut chart + category breakdown
    │   ├── budgets/
    │   │   └── budgets_screen.dart    ← Monthly budget + category limits
    │   ├── transactions/
    │   │   └── transactions_screen.dart ← Search + filter all transactions
    │   └── settings/
    │       └── settings_screen.dart
    │
    └── widgets/
        ├── expense_card.dart         ← Swipeable transaction row
        ├── budget_card.dart          ← Category budget progress card
        ├── chart_widget.dart         ← Donut + bar chart reusables
        └── custom_button.dart        ← Reusable button
```

---

## 🚀 Setup Instructions (Android Studio)

### Step 1 — Open the Project
1. Open **Android Studio**
2. Click **"Open"** → select the `expense_tracker` folder
3. Wait for Gradle sync to finish

### Step 2 — Get Flutter Packages
Open Terminal (bottom of Android Studio) and run:
```bash
flutter pub get
```

### Step 3 — Create Assets Folders
```bash
mkdir -p assets/images assets/icons assets/animations
```
Add a placeholder file in each (or the app won't build):
```bash
touch assets/images/.gitkeep assets/icons/.gitkeep assets/animations/.gitkeep
```

### Step 4 — Run the App
```bash
flutter run
```
Or press the ▶️ Run button in Android Studio.

---

## 📦 Key Dependencies

| Package | Purpose |
|---------|---------|
| `provider` | State management |
| `sqflite` | Local SQLite database |
| `fl_chart` | Donut + bar charts |
| `google_fonts` | DM Sans font |
| `intl` | Currency & date formatting |
| `uuid` | Unique IDs for expenses |
| `shared_preferences` | App settings |
| `animate_do` | Animations |

---

## 🎨 Design System

| Color | Usage |
|-------|-------|
| `#0F1117` | Background |
| `#1A1D27` | Surface / Bottom nav |
| `#4ADE80` | Primary green (budget, buttons) |
| `#FF6B6B` | Expense red |
| `#F59E0B` | Food category |
| `#60A5FA` | Transport category |
| `#A78BFA` | Shopping category |

---

## ✨ Features Implemented

- ✅ **Add Expense** — Numpad, categories, AI category suggestion, suggested amounts, payment method
- ✅ **Dashboard** — Budget overview, monthly flow (income/expenses), recent transactions
- ✅ **Analytics** — Donut chart, quick highlights (daily avg, saved, largest), category breakdown
- ✅ **Budgets** — Monthly limit, per-category budgets with progress bars
- ✅ **Transactions** — Search, filter (All/Income/Expense), swipe to delete
- ✅ **Settings** — Currency, notifications toggle, export
- ✅ **SQLite** — Full offline persistence
- ✅ **Dark Theme** — Matches screenshot design exactly
- ✅ **Month Navigation** — Browse past months

---

## 🔧 Common Issues

**`MissingPluginException` for sqflite:**
```bash
flutter clean && flutter pub get && flutter run
```

**`assets` not found error:**
Make sure `pubspec.yaml` indentation is exactly 2 spaces. YAML is whitespace-sensitive.

**Font not loading:**
Run `flutter pub get` after adding `google_fonts`.
