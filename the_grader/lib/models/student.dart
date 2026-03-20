// ============================================================
// DATA CLASS: Student
// - Nullable scores (double?)
// - Elvis operator (??) in computeAverage & computeGrade
// - Safe calls (?.) used at call sites
// - Member function 1: computeAverage()
// - Member function 2: computeGrade()
// ============================================================

class Student {
  final String id;
  final String name;

  // Nullable scores — a teacher may not have submitted every mark
  final double? mathScore;
  final double? englishScore;
  final double? scienceScore;
  final double? socialStudiesScore;
  final double? computerScore;

  const Student({
    required this.id,
    required this.name,
    this.mathScore,
    this.englishScore,
    this.scienceScore,
    this.socialStudiesScore,
    this.computerScore,
  });

  // ── MEMBER FUNCTION 1 ─────────────────────────────────────
  // Computes average of non-null scores only.
  // Elvis (??) used to safely unwrap each nullable double.
  double computeAverage() {
    final allScores = <double?>[
      mathScore,
      englishScore,
      scienceScore,
      socialStudiesScore,
      computerScore,
    ];

    // Filter only submitted scores (non-null)
    final submitted = allScores.where((s) => s != null).toList();

    // Edge case: no scores submitted at all
    if (submitted.isEmpty) return 0.0;

    final total = submitted.fold<double>(
      0.0,
      (sum, score) => sum + (score ?? 0.0), // Elvis: guard even after filter
    );

    return total / submitted.length;
  }

  // ── MEMBER FUNCTION 2 ─────────────────────────────────────
  // Converts average to a GradeResult (letter, GPA, remarks).
  GradeResult computeGrade() {
    final avg = computeAverage();

    // Chained Elvis-style ternary — same pattern as Kotlin's when/Elvis
    final letter = avg >= 90
        ? 'A+'
        : avg >= 85
            ? 'A'
            : avg >= 80
                ? 'A-'
                : avg >= 75
                    ? 'B+'
                    : avg >= 70
                        ? 'B'
                        : avg >= 65
                            ? 'B-'
                            : avg >= 60
                                ? 'C+'
                                : avg >= 55
                                    ? 'C'
                                    : avg >= 50
                                        ? 'D'
                                        : 'F';

    final gpa = avg >= 90
        ? 4.0
        : avg >= 85
            ? 3.7
            : avg >= 80
                ? 3.3
                : avg >= 75
                    ? 3.0
                    : avg >= 70
                        ? 2.7
                        : avg >= 65
                            ? 2.3
                            : avg >= 60
                                ? 2.0
                                : avg >= 55
                                    ? 1.7
                                    : avg >= 50
                                        ? 1.0
                                        : 0.0;

    final remarks = avg >= 70
        ? 'PASS'
        : avg >= 50
            ? 'MARGINAL'
            : 'FAIL';

    return GradeResult(
      average: avg,
      letterGrade: letter,
      gpa: gpa,
      remarks: remarks,
    );
  }

  // Utility: copyWith pattern for editing entries
  Student copyWith({
    String? id,
    String? name,
    double? mathScore,
    double? englishScore,
    double? scienceScore,
    double? socialStudiesScore,
    double? computerScore,
    bool clearMath = false,
    bool clearEnglish = false,
    bool clearScience = false,
    bool clearSocial = false,
    bool clearComputer = false,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      mathScore: clearMath ? null : (mathScore ?? this.mathScore),
      englishScore: clearEnglish ? null : (englishScore ?? this.englishScore),
      scienceScore: clearScience ? null : (scienceScore ?? this.scienceScore),
      socialStudiesScore:
          clearSocial ? null : (socialStudiesScore ?? this.socialStudiesScore),
      computerScore:
          clearComputer ? null : (computerScore ?? this.computerScore),
    );
  }

  @override
  String toString() {
    final g = computeGrade();
    return 'Student{id: $id, name: $name, '
        'avg: ${g.average.toStringAsFixed(1)}, grade: ${g.letterGrade}}';
  }
}

// ── Value object returned by computeGrade() ───────────────
class GradeResult {
  final double average;
  final String letterGrade;
  final double gpa;
  final String remarks;

  const GradeResult({
    required this.average,
    required this.letterGrade,
    required this.gpa,
    required this.remarks,
  });
}
