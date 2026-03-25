package com.example.studentgradeapp

import com.example.studentgradeapp.calculator.GradeCalculator
import com.example.studentgradeapp.excel.ExcelParser
import java.io.File
import java.io.FileInputStream

/**
 * A CLI entry point to run the Grade Calculator from a console/terminal.
 *
 * Usage: Provide the absolute path to an Excel (.xlsx) file as the first argument.
 */
fun main(args: Array<String>) {
    if (args.isEmpty()) {
        println("❌ Error: Please provide the path to an Excel (.xlsx) file.")
        println("Usage: ConsoleRunner <file-path>")
        return
    }

    val filePath = args[0]
    val file = File(filePath)

    if (!file.exists() || !file.isFile) {
        println("❌ Error: File not found at path: $filePath")
        return
    }

    try {
        println("📂 Reading spreadsheet: ${file.name}...")
        val inputStream = FileInputStream(file)
        
        // 1. Parse the Excel file
        val rawStudents = ExcelParser().parse(inputStream)
        
        // 2. Calculate the grades
        val gradedStudents = GradeCalculator().calculate(rawStudents)

        // 3. Display results in a table-like format
        println("\n--- 🎓 Grade Results ---")
        println("%-10s | %-20s | %-8s | %-5s".format("ID", "Name", "Average", "Grade"))
        println("-".repeat(52))

        gradedStudents.forEach { student ->
            println("%-10s | %-20s | %-8.2f | %-5s".format(
                student.studentId,
                student.studentName,
                student.average ?: 0.0,
                student.finalGrade ?: "N/A"
            ))
        }
        println("-".repeat(52))
        println("✅ Successfully processed ${gradedStudents.size} students.\n")

    } catch (e: Exception) {
        println("❌ An error occurred while processing the file:")
        e.printStackTrace()
    }
}
