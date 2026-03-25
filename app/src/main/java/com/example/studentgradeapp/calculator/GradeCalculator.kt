package com.example.studentgradeapp.calculator

import com.example.studentgradeapp.data.Student

/**
 * Calculates letter grades for a list of students.
 *
 * Grading scale
 * ─────────────
 *  90 – 100  →  A
 *  80 –  89  →  B
 *  70 –  79  →  C
 *  60 –  69  →  D
 *   0 –  59  →  F
 */
class GradeCalculator {

    /**
     * Processes [students] and returns a new list where each [Student] is enriched
     * with its computed [Student.average] and [Student.finalGrade].
     */
    fun calculate(students: List<Student>): List<Student> =
        students.map { student -> student.withCalculatedGrade() }

    // ── Private helpers ───────────────────────────────────────────────────

    /** Returns a copy of this student with [average] and [finalGrade] filled in. */
    private fun Student.withCalculatedGrade(): Student {
        val avg = computeAverage()
        return copy(
            average    = avg,
            finalGrade = avg.toLetterGrade()
        )
    }

    /** Average score across all subjects; 0.0 when there are no grades. */
    private fun Student.computeAverage(): Double {
        if (grades.isEmpty()) return 0.0
        return grades.values.average()
    }

    /** Converts a numeric average to a letter grade string. */
    private fun Double.toLetterGrade(): String = when {
        this >= 90.0 -> "A"
        this >= 80.0 -> "B"
        this >= 70.0 -> "C"
        this >= 60.0 -> "D"
        else         -> "F"
    }
}
