import 'package:flutter_test/flutter_test.dart';
import 'package:the_grader/models/student.dart';
import 'package:the_grader/utils/grade_calculator.dart';

void main() {
  group('Student data class', () {
    test('computeAverage skips null scores', () {
      const s = Student(
        id: 'T001', name: 'Test',
        mathScore: 80, englishScore: 90,
        scienceScore: null, // nullable — should be excluded
        socialStudiesScore: 70, computerScore: 60,
      );
      expect(s.computeAverage(), equals(75.0));
    });

    test('computeAverage returns 0 when all scores null', () {
      const s = Student(id: 'T002', name: 'Empty');
      expect(s.computeAverage(), equals(0.0));
    });

    test('computeGrade returns F for zero average', () {
      const s = Student(id: 'T003', name: 'Fail');
      expect(s.computeGrade().letterGrade, equals('F'));
      expect(s.computeGrade().remarks, equals('FAIL'));
    });

    test('computeGrade returns A+ for 95 average', () {
      const s = Student(
        id: 'T004', name: 'Top',
        mathScore: 95, englishScore: 95,
        scienceScore: 95, socialStudiesScore: 95, computerScore: 95,
      );
      expect(s.computeGrade().letterGrade, equals('A+'));
      expect(s.computeGrade().gpa, equals(4.0));
    });
  });

  group('Grade calculator utilities', () {
    final students = [
      const Student(id: 'S1', name: 'Alice', mathScore: 90, englishScore: 90,
          scienceScore: 90, socialStudiesScore: 90, computerScore: 90),
      const Student(id: 'S2', name: 'Bob', mathScore: 40, englishScore: 40,
          scienceScore: 40, socialStudiesScore: 40, computerScore: 40),
    ];

    test('processStudents filters by predicate (HOF)', () {
      final passed = processStudents(students, (s) => s.computeAverage() >= 50);
      expect(passed.length, equals(1));
      expect(passed.first.student.name, equals('Alice'));
    });

    test('applyTransform applies lambda to every item', () {
      final names = applyTransform<Student, String>(students, (s) => s.name);
      expect(names, equals(['Alice', 'Bob']));
    });

    test('gradeDistribution groups correctly', () {
      final dist = gradeDistribution(students);
      expect(dist['A+'], equals(1));
      expect(dist['F'], equals(1));
    });

    test('subjectAverage returns null when all null', () {
      final empty = [const Student(id: 'E', name: 'Empty')];
      expect(subjectAverage(empty, (s) => s.mathScore), isNull);
    });
  });
}
