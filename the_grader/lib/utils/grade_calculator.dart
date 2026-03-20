// ============================================================
// UTILITY: grade_calculator.dart
//
// Contains:
//   processStudents()  — higher-order function on List<Student>
//   applyTransform()   — custom HOF that accepts a lambda
//   Collection ops: where, map, fold, sort, groupBy
// ============================================================

import '../models/student.dart';

// ── HIGHER-ORDER FUNCTION on List<Student> ────────────────
// Accepts a predicate function — caller passes in a lambda.
List<ProcessedStudent> processStudents(
  List<Student> students,
  bool Function(Student) predicate, // HOF: function as parameter
) {
  return students
      .where(predicate) // collection op: filter
      .map((s) => ProcessedStudent(student: s, result: s.computeGrade()))
      .toList(); // collection op: transform
}

// ── CUSTOM HIGHER-ORDER FUNCTION (receives a lambda) ──────
// Generic T→R transform over any list.
// A lambda is passed to this in main().
List<R> applyTransform<T, R>(
  List<T> items,
  R Function(T) transform, // the lambda slot
) {
  return items.map(transform).toList();
}

// ── Subject average (nullable return — safe with ?. at call site) ─
double? subjectAverage(
  List<Student> students,
  double? Function(Student) picker,
) {
  final values = students
      .map(picker)
      .where((v) => v != null)
      .cast<double>()
      .toList();

  if (values.isEmpty) return null; // nullable — Elvis-ready for caller

  return values.fold(0.0, (sum, v) => sum + v) / values.length;
}

// ── Grade distribution via fold (collection op: groupBy) ──
Map<String, int> gradeDistribution(List<Student> students) {
  return students.fold<Map<String, int>>(
    {},
    (map, s) {
      final grade = s.computeGrade().letterGrade;
      map[grade] = (map[grade] ?? 0) + 1; // Elvis: default 0 then increment
      return map;
    },
  );
}

// ── Top N students sorted by average ──────────────────────
List<Student> topStudents(List<Student> students, int n) {
  final sorted = [...students]
    ..sort((a, b) => b.computeAverage().compareTo(a.computeAverage()));
  return sorted.take(n).toList();
}

// ── Class-wide statistics ──────────────────────────────────
ClassStats computeClassStats(List<Student> students) {
  if (students.isEmpty) {
    return const ClassStats(
      classAverage: 0,
      highest: 0,
      lowest: 0,
      passCount: 0,
      failCount: 0,
      totalStudents: 0,
    );
  }

  final averages = students.map((s) => s.computeAverage()).toList();
  final classAvg = averages.fold(0.0, (a, b) => a + b) / averages.length;
  final highest = averages.reduce((a, b) => a > b ? a : b);
  final lowest = averages.reduce((a, b) => a < b ? a : b);
  final passCount = students.where((s) => s.computeAverage() >= 50).length;

  return ClassStats(
    classAverage: classAvg,
    highest: highest,
    lowest: lowest,
    passCount: passCount,
    failCount: students.length - passCount,
    totalStudents: students.length,
  );
}

// ── Supporting value objects ───────────────────────────────
class ProcessedStudent {
  final Student student;
  final GradeResult result;
  const ProcessedStudent({required this.student, required this.result});
}

class ClassStats {
  final double classAverage;
  final double highest;
  final double lowest;
  final int passCount;
  final int failCount;
  final int totalStudents;

  const ClassStats({
    required this.classAverage,
    required this.highest,
    required this.lowest,
    required this.passCount,
    required this.failCount,
    required this.totalStudents,
  });

  double get passRate =>
      totalStudents == 0 ? 0 : (passCount / totalStudents) * 100;
}
