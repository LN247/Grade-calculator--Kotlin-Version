package com.example.studentgradeapp.excel

import com.example.studentgradeapp.data.Student
import org.apache.poi.ss.usermodel.Cell
import org.apache.poi.ss.usermodel.CellType
import org.apache.poi.ss.usermodel.Row
import org.apache.poi.xssf.usermodel.XSSFWorkbook
import java.io.InputStream

/**
 * Parses an .xlsx Excel file into a list of [Student] objects.
 *
 * Expected spreadsheet format
 * ───────────────────────────
 * Row 0 (header): StudentID | StudentName | Subject1 | Subject2 | …
 * Row 1+         : data rows, one per student
 *
 * Column matching is case-insensitive and trims surrounding whitespace,
 * so "studentid", "Student ID", or "STUDENTID" all work.
 */
class ExcelParser {

    /**
     * Parses the supplied [InputStream] (must be a valid .xlsx workbook)
     * and returns a [List] of [Student] objects.
     *
     * The caller is responsible for closing the stream after this call returns.
     *
     * @throws IllegalArgumentException if the required header columns are missing.
     * @throws Exception for any underlying POI / IO error.
     */
    fun parse(inputStream: InputStream): List<Student> {
        val workbook = XSSFWorkbook(inputStream)
        val sheet = workbook.getSheetAt(0)

        val students = mutableListOf<Student>()

        // ── 1. Read header row ───────────────────────────────────────────
        val headerRow: Row = sheet.getRow(0)
            ?: throw IllegalArgumentException("The spreadsheet has no header row.")

        // Build a map: normalised-column-name -> column index
        val columnIndex = mutableMapOf<String, Int>()
        for (cellIndex in 0 until headerRow.lastCellNum) {
            val cell = headerRow.getCell(cellIndex)
            val header = cell?.stringCellValue?.trim()?.lowercase()?.replace(" ", "")
            if (!header.isNullOrBlank()) {
                columnIndex[header] = cellIndex
            }
        }

        val idCol = columnIndex["studentid"]
            ?: throw IllegalArgumentException("Missing 'StudentID' column in the header row.")
        val nameCol = columnIndex["studentname"]
            ?: throw IllegalArgumentException("Missing 'StudentName' column in the header row.")

        // Everything that is neither studentid nor studentname is treated as a subject
        val subjectColumns: Map<String, Int> = columnIndex
            .filterKeys { it != "studentid" && it != "studentname" }

        // ── 2. Read data rows ────────────────────────────────────────────
        for (rowIndex in 1..sheet.lastRowNum) {
            val row: Row = sheet.getRow(rowIndex) ?: continue

            val studentId = row.getCell(idCol)?.toCellString()?.trim() ?: continue
            if (studentId.isBlank()) continue                          // skip empty rows

            val studentName = row.getCell(nameCol)?.toCellString()?.trim() ?: ""

            // Build grades map: use the original-cased header (not lowercased key)
            val grades = mutableMapOf<String, Double>()
            for ((subjectKey, colIdx) in subjectColumns) {
                val cell = row.getCell(colIdx)
                val score = when {
                    cell == null -> 0.0
                    cell.cellType == CellType.NUMERIC -> cell.numericCellValue
                    cell.cellType == CellType.STRING  -> cell.stringCellValue.toDoubleOrNull() ?: 0.0
                    else -> 0.0
                }
                // Re-map to the original-cased header for display
                val originalHeader = headerRow.getCell(colIdx).stringCellValue.trim()
                grades[originalHeader] = score
            }

            students.add(
                Student(
                    studentId = studentId,
                    studentName = studentName,
                    grades = grades
                )
            )
        }

        workbook.close()
        return students
    }

    // ── Helpers ──────────────────────────────────────────────────────────

    /** Converts any cell to a readable string regardless of its type. */
    private fun Cell.toCellString(): String = when (cellType) {
        CellType.STRING  -> stringCellValue
        CellType.NUMERIC -> {
            val d = numericCellValue
            // Avoid "1.0" for whole numbers
            if (d == kotlin.math.floor(d)) d.toLong().toString() else d.toString()
        }
        CellType.BOOLEAN -> booleanCellValue.toString()
        CellType.FORMULA -> try { numericCellValue.toString() } catch (_: Exception) { stringCellValue }
        else -> ""
    }
}
