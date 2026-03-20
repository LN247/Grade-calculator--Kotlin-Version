# THE GRADER 🎓
**Smart Grade Calculator for Teachers**

A Flutter/Dart Android app that lets teachers upload Excel mark sheets and automatically generate fully graded reports.

---

## 🚀 Quick Start (VS Code)

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.0.0  
- Android Studio (for the emulator) **or** a physical Android device  
- VS Code with the **Flutter** and **Dart** extensions installed

### Steps

```bash
# 1. Extract the zip, then open the folder in VS Code
cd the_grader

# 2. Install all dependencies
flutter pub get

# 3. Check your environment is healthy
flutter doctor

# 4. Run on a connected device or emulator
flutter run
```

> **VS Code shortcut:** Open the project folder → press **F5** (or Run > Start Debugging) → select your device.

### Build a release APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

---

## 📁 Project Structure

```
the_grader/
├── lib/
│   ├── main.dart                   ← Entry point + all Dart feature demos
│   ├── models/
│   │   └── student.dart            ← DATA CLASS with nullable fields
│   ├── utils/
│   │   ├── grade_calculator.dart   ← Higher-order functions + collection ops
│   │   └── excel_parser.dart       ← Excel read/write
│   ├── screens/
│   │   ├── home_screen.dart        ← Upload & landing screen
│   │   ├── result_screen.dart      ← Graded results with filter/sort
│   │   └── manual_entry_screen.dart← Manual score entry
│   └── widgets/
│       ├── student_grade_card.dart ← Per-student expandable card
│       └── stats_panel.dart        ← Class statistics dashboard
├── android/                        ← Android build files
├── test/
│   └── widget_test.dart            ← Unit tests
└── pubspec.yaml
```

---

## ✅ Dart Feature Checklist

| Feature | Location |
|---|---|
| **Data class** | `lib/models/student.dart` — `class Student` |
| **Nullable inputs** (`double?`) | `Student` fields: `mathScore`, `englishScore`, etc. |
| **Elvis operator** (`??`) | `computeAverage()`, `gradeDistribution()`, `parseScore()` |
| **Safe calls** (`?.`) | `_subjectRow()` in card widget, `subjectAverage()` in main |
| **Edge case handling** | Out-of-range scores clamped to null, empty rows skipped |
| **Member function 1** | `Student.computeAverage()` |
| **Member function 2** | `Student.computeGrade()` |
| **HOF on List\<Student\>** | `processStudents(students, predicate)` |
| **Custom HOF** | `applyTransform<T,R>(items, transform)` |
| **Lambda in main()** | Passed to `applyTransform(students, (s) => ...)` |
| **Collection ops** | `where`, `map`, `fold`, `sort`, `groupBy` all in `main()` |

---

## 📊 Excel Template Format

| Student ID | Student Name | Math (/100) | English (/100) | Science (/100) | Social Studies (/100) | Computer (/100) |
|---|---|---|---|---|---|---|
| S001 | Alice Johnson | 88 | 92 | 85 | 79 | 95 |
| S002 | Bob Smith | 72 | 68 | *(blank)* | 74 | 80 |

> Leave a cell **blank** for a missing score — it becomes `null` and is excluded from the average calculation.

---

## 🎨 Grading Scale

| Range | Letter | GPA | Remarks |
|---|---|---|---|
| 90–100 | A+ | 4.0 | PASS |
| 85–89 | A | 3.7 | PASS |
| 80–84 | A- | 3.3 | PASS |
| 75–79 | B+ | 3.0 | PASS |
| 70–74 | B | 2.7 | PASS |
| 65–69 | B- | 2.3 | PASS |
| 60–64 | C+ | 2.0 | PASS |
| 55–59 | C | 1.7 | MARGINAL |
| 50–54 | D | 1.0 | MARGINAL |
| 0–49 | F | 0.0 | FAIL |

---

## 🔧 Troubleshooting

**"No devices found"**  
→ Start an Android emulator via Android Studio (AVD Manager) or plug in a device with USB debugging enabled.

**"Flutter SDK not found"**  
→ Run `flutter doctor` and follow its instructions to fix your PATH.

**Gradle build errors**  
→ Make sure you have JDK 17+ installed. Run `flutter clean` then `flutter pub get` again.

**`file_picker` permission denied on device**  
→ The app will request storage permissions at runtime on Android 12 and below. Accept the prompt.
