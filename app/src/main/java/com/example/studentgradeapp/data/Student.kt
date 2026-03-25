package com.example.studentgradeapp.data

/**
 * Data model representing a single student with their ID, name,
 * subject grades, and their computed final letter grade.
 *
 * @param studentId   Unique identifier (e.g. "S001")
 * @param studentName Full name of the student
 * @param grades      Map of subject name -> score (0.0 – 100.0)
 * @param finalGrade  Letter grade computed by GradeCalculator; null until calculated
 * @param average     Numeric average computed by GradeCalculator; null until calculated
 */
data class Student(
    val studentId: String,
    val studentName: String,
    val grades: Map<String, Double>,
    val finalGrade: String? = null,
    val average: Double? = null
)
