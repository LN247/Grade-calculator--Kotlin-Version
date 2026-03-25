# 🎓 Student Grade Calculator — Android App

An Android application that lets users upload an Excel (.xlsx) spreadsheet of student data, automatically calculates letter grades, and displays results in a clean, colour-coded list.

---

## ✨ Features

| Feature | Detail |
|---|---|
| **File Picker** | System file-picker filtered to `.xlsx` files — no storage permission needed |
| **Excel Parsing** | Reads any `.xlsx` with `StudentID`, `StudentName`, and subject columns |
| **Grade Calculation** | Computes per-student average and assigns letter grade A–F |
| **Colour-coded badges** | Green A → Blue B → Amber C → Orange D → Red F |
| **Background processing** | Parsing runs on `Dispatchers.IO`; UI never freezes |
| **Error handling** | Graceful `Toast` messages for malformed files |

---

## 📁 Project Structure

```
StudentGradeApp/
├── app/
│   ├── build.gradle.kts                          # App-level Gradle (deps, packaging)
│   └── src/main/
│       ├── AndroidManifest.xml
│       ├── java/com/example/studentgradeapp/
│       │   ├── data/
│       │   │   └── Student.kt                    # Data model
│       │   ├── excel/
│       │   │   └── ExcelParser.kt                # Apache POI .xlsx parser
│       │   ├── calculator/
│       │   │   └── GradeCalculator.kt            # A–F grading logic
│       │   ├── adapter/
│       │   │   └── StudentAdapter.kt             # RecyclerView ListAdapter
│       │   └── MainActivity.kt                   # File picker + orchestration
│       └── res/
│           ├── layout/
│           │   ├── activity_main.xml             # Main screen layout
│           │   └── item_student.xml              # RecyclerView row
│           ├── drawable/
│           │   ├── bg_grade_badge.xml            # Circular grade badge
│           │   └── ic_upload.xml                 # Cloud-upload vector icon
│           └── values/
│               ├── strings.xml
│               ├── colors.xml
│               └── themes.xml
├── gradle/
│   └── libs.versions.toml                        # Version catalog
├── build.gradle.kts                              # Root Gradle
├── settings.gradle.kts
└── sample_grades.xlsx                            # ← test file (10 students)
```

---

## 🏗️ Technology Stack

| Layer | Library / Tool |
|---|---|
| Language | Kotlin 1.9 |
| Build | Gradle 8.4 with Version Catalog |
| UI | AndroidX AppCompat, Material Components 3, RecyclerView |
| Excel reading | **Apache POI 5.2.5** (`poi-ooxml`) |
| Async | Kotlin Coroutines (`lifecycleScope` + `Dispatchers.IO`) |
| Min SDK | 26 (Android 8.0) |

---

## 📊 Expected Spreadsheet Format

The first row **must** be a header row. Column names are matched **case-insensitively**.

| StudentID | StudentName | Mathematics | Science | English | … |
|---|---|---|---|---|---|
| S001 | Alice Johnson | 95 | 92 | 88 | … |
| S002 | Bob Smith | 78 | 82 | 75 | … |

- Columns `StudentID` and `StudentName` are **required**.
- Any additional columns are treated as **subject scores** (numeric, 0–100).
- A sample file with 10 students is included as **`sample_grades.xlsx`**.

---

## 🔢 Grading Scale

| Average Score | Letter Grade |
|---|---|
| 90 – 100 | **A** |
| 80 – 89 | **B** |
| 70 – 79 | **C** |
| 60 – 69 | **D** |
| Below 60 | **F** |

---

## 🚀 Getting Started

### Prerequisites

- **Android Studio Hedgehog (2023.1.1)** or newer
- **JDK 17** (bundled with recent Android Studio)
- Android device or emulator running API 26+

### Build & Run

```bash
# 1. Clone / copy the project
cd StudentGradeApp

# 2. Open in Android Studio
#    File → Open → select the StudentGradeApp folder

# 3. Let Gradle sync (downloads Apache POI ~10 MB)

# 4. Run on device/emulator
#    Run → Run 'app'  (Shift+F10)
```

### Testing with the sample file

1. Transfer `sample_grades.xlsx` to your device (email, Google Drive, ADB, etc.)
   ```bash
   adb push sample_grades.xlsx /sdcard/Download/
   ```
2. Tap **Upload Grades File**.
3. Navigate to the file in the picker and select it.
4. The app displays 10 students with their calculated grades.

---

## 🔑 Key Implementation Notes

### No Storage Permission Required
The app uses `ACTION_GET_CONTENT` which gives a **temporary URI grant**. The file is read through `ContentResolver.openInputStream(uri)` — no `READ_EXTERNAL_STORAGE` permission is needed.

```kotlin
// MainActivity.kt
val inputStream = contentResolver.openInputStream(uri)
    ?: throw IllegalStateException("Unable to open the selected file.")
```

### InputStream-based Parsing
`ExcelParser.parse()` accepts an `InputStream`, not a file path. This is the correct Android pattern — you never need a real file path.

```kotlin
// ExcelParser.kt
fun parse(inputStream: InputStream): List<Student> {
    val workbook = XSSFWorkbook(inputStream)
    ...
}
```

### Apache POI Packaging Fix
Apache POI ships `META-INF/DEPENDENCIES` and similar files that clash in the APK. The `packaging` block in `build.gradle.kts` excludes them:

```kotlin
packaging {
    resources {
        excludes += setOf("META-INF/DEPENDENCIES", "META-INF/LICENSE", ...)
    }
}
```

### Background Threading
File I/O and Excel parsing run on `Dispatchers.IO` inside a `lifecycleScope` coroutine so the main thread is never blocked:

```kotlin
lifecycleScope.launch {
    val students = withContext(Dispatchers.IO) {
        inputStream.use { excelParser.parse(it) }
    }
    adapter.submitList(gradeCalculator.calculate(students))
}
```

---

## 📸 Screen Layout

```
┌─────────────────────────────────┐
│  Student Grade Calculator        │  ← MaterialToolbar
├─────────────────────────────────┤
│  ┌─────────────────────────┐    │
│  │   ☁ Upload icon         │    │
│  │   Grade Calculator       │    │  ← Upload card (MaterialCardView)
│  │   Select an .xlsx file   │    │
│  │  [ Upload Grades File ]  │    │
│  └─────────────────────────┘    │
│                                  │
│  Loaded 10 student(s) from …    │  ← tvFileInfo
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━   │  ← ProgressBar (while loading)
│                                  │
│  ┌───────────────────── ●A ─┐   │
│  │ Alice Johnson             │   │
│  │ ID: S001   Avg: 92.6     │   │  ← item_student.xml (grade badge = green)
│  └──────────────────────────┘   │
│  ┌───────────────────── ●B ─┐   │
│  │ Bob Smith                 │   │
│  │ ID: S002   Avg: 77.0     │   │
│  └──────────────────────────┘   │
│          … more rows …          │
└─────────────────────────────────┘
```

---

## 🛠️ Extending the App

| Idea | Where to change |
|---|---|
| Support `.xls` (old format) | `ExcelParser` — use `HSSFWorkbook` or `WorkbookFactory.create()` |
| Sort by grade / name | `MainActivity` — sort list before `adapter.submitList()` |
| Show per-subject breakdown | `item_student.xml` + `StudentAdapter` — expand card |
| Export results to PDF | Add a share button; iterate `adapter.currentList` |
| Dark-mode colours | Add `res/values-night/colors.xml` |

---

## 📄 License

MIT — free to use, modify, and distribute.
