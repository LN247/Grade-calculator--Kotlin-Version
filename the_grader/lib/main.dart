// ============================================================
// THE GRADER — main.dart
//
// Demonstrates all required Dart features:
//  ✔ Data class (Student)
//  ✔ Nullable inputs with ?. safe calls & ?? Elvis
//  ✔ Edge case handling
//  ✔ 2 member functions on the data class
//  ✔ Higher-order function on List<Student>
//  ✔ Lambda passed to a custom higher-order function
//  ✔ Collection operations (where, map, fold, sort, groupBy)
// ============================================================

import 'package:flutter/material.dart';

import 'models/student.dart';
import 'utils/grade_calculator.dart';
import 'screens/home_screen.dart';

void main() {
  // ── Sample students: some scores are null (not yet submitted) ──
  final students = <Student>[
    const Student(
      id: 'S001', name: 'Alice Johnson',
      mathScore: 88, englishScore: 92,
      scienceScore: 85, socialStudiesScore: 79, computerScore: 95,
    ),
    const Student(
      id: 'S002', name: 'Bob Smith',
      mathScore: 72, englishScore: 68,
      scienceScore: null,          // ← nullable: not submitted
      socialStudiesScore: 74, computerScore: 80,
    ),
    const Student(
      id: 'S003', name: 'Carol White',
      mathScore: 55, englishScore: 60, scienceScore: 58,
      socialStudiesScore: null,    // ← nullable: absent for exam
      computerScore: 62,
    ),
    const Student(
      id: 'S004', name: 'David Brown',
      mathScore: 40, englishScore: 45,
      scienceScore: 38, socialStudiesScore: 42,
      computerScore: null,         // ← nullable: pending
    ),
    const Student(
      id: 'S005', name: 'Eve Davis',
      mathScore: 95, englishScore: 97,
      scienceScore: 93, socialStudiesScore: 98, computerScore: 99,
    ),
  ];

  // ── MEMBER FUNCTION 1: computeAverage() ───────────────────
  for (final s in students) {
    debugPrint('${s.name} → avg: ${s.computeAverage().toStringAsFixed(1)}');
  }

  // ── MEMBER FUNCTION 2: computeGrade() ─────────────────────
  for (final s in students) {
    final g = s.computeGrade();
    // Safe call + Elvis: remarks guaranteed non-null but pattern shown
    final display = g.remarks.isNotEmpty ? g.remarks : 'N/A';
    debugPrint('${s.name} → ${g.letterGrade} | GPA ${g.gpa} | $display');
  }

  // ── HIGHER-ORDER FUNCTION on List<Student> ────────────────
  // processStudents() takes a predicate lambda — filter passing students
  final passed = processStudents(
    students,
    (s) => s.computeAverage() >= 50, // ← lambda as predicate argument
  );
  debugPrint('\nPassed: ${passed.length} of ${students.length}');

  // ── LAMBDA PASSED TO CUSTOM HIGHER-ORDER FUNCTION ─────────
  // applyTransform<T, R>() receives any T→R lambda
  final summaries = applyTransform<Student, String>(
    students,
    (s) {
      // Safe call (?.) and Elvis (??) used explicitly inside lambda
      final mathDisplay = s.mathScore?.toStringAsFixed(0) ?? 'N/A';
      final g = s.computeGrade();
      return '[${s.id}] ${s.name} | Math: $mathDisplay | '
          'Avg: ${g.average.toStringAsFixed(1)} | ${g.letterGrade}';
    },
  );
  for (final line in summaries) {
    debugPrint(line);
  }

  // ── COLLECTION OPERATIONS ──────────────────────────────────

  // 1. where — students with at least one missing score
  final incomplete = students.where((s) =>
      s.mathScore == null ||
      s.englishScore == null ||
      s.scienceScore == null ||
      s.socialStudiesScore == null ||
      s.computerScore == null).toList();
  debugPrint('\nIncomplete records: ${incomplete.length}');

  // 2. map — extract names of top performers
  final topNames = topStudents(students, 3).map((s) => s.name).toList();
  debugPrint('Top 3: $topNames');

  // 3. fold — compute overall class total
  final total = students.fold<double>(
    0.0,
    (sum, s) => sum + s.computeAverage(),
  );
  debugPrint('Class average (fold): ${(total / students.length).toStringAsFixed(2)}%');

  // 4. sort — rank all students
  final ranked = [...students]
    ..sort((a, b) => b.computeAverage().compareTo(a.computeAverage()));
  for (int i = 0; i < ranked.length; i++) {
    debugPrint('  ${i + 1}. ${ranked[i].name} — '
        '${ranked[i].computeAverage().toStringAsFixed(1)}%');
  }

  // 5. groupBy via fold — grade distribution map
  final dist = gradeDistribution(students);
  debugPrint('Distribution: $dist');

  // 6. Nullable subject average with safe call at usage site
  final mathAvg = subjectAverage(students, (s) => s.mathScore);
  // Safe call: mathAvg is double? — use ?. and ?? to guard
  debugPrint('Math avg: ${mathAvg?.toStringAsFixed(1) ?? 'N/A'}');

  // ── Launch Flutter UI ──────────────────────────────────────
  runApp(const TheGraderApp());
}

class TheGraderApp extends StatelessWidget {
  const TheGraderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'THE GRADER',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
