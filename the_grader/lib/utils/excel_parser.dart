// ============================================================
// UTILITY: excel_parser.dart
// Reads uploaded .xlsx mark sheets → List<Student>
// Writes graded results back to .xlsx
// Uses safe calls & Elvis throughout for robustness
// ============================================================

import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import '../models/student.dart';

class ExcelParser {
  // ── Parse uploaded Excel → List<Student> ─────────────────
  static List<Student> parseMarkSheet(String filePath) {
    final bytes = File(filePath).readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);

    final students = <Student>[];

    // Safe call: first sheet may not exist
    final sheetName = excel.tables.keys.isNotEmpty
        ? excel.tables.keys.first
        : null;
    if (sheetName == null) return students;

    final sheet = excel.tables[sheetName];
    if (sheet == null) return students;

    final rows = sheet.rows;
    if (rows.length < 2) return students; // edge case: header-only or empty

    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];

      // Safe cell reader — returns null when column is missing or blank
      String? cell(int col) {
        if (col >= row.length) return null;
        return row[col]?.value?.toString().trim();
      }

      final id = cell(0) ?? 'S${i.toString().padLeft(3, '0')}'; // Elvis fallback
      final name = cell(1) ?? 'Unknown Student';

      final math    = _parseScore(cell(2));
      final english = _parseScore(cell(3));
      final science = _parseScore(cell(4));
      final social  = _parseScore(cell(5));
      final computer= _parseScore(cell(6));

      // Edge case: skip entirely blank rows
      if (name == 'Unknown Student' &&
          math == null && english == null &&
          science == null && social == null && computer == null) {
        continue;
      }

      students.add(Student(
        id: id,
        name: name,
        mathScore: math,
        englishScore: english,
        scienceScore: science,
        socialStudiesScore: social,
        computerScore: computer,
      ));
    }

    return students;
  }

  // ── Safe score parser ──────────────────────────────────────
  static double? _parseScore(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final value = double.tryParse(raw); // null on failure — not an exception
    if (value == null) return null;
    if (value < 0 || value > 100) return null; // edge case: out-of-range
    return value;
  }

  // ── Export graded result sheet ─────────────────────────────
  static Future<String> exportResultSheet(List<Student> students) async {
    final excel = Excel.createExcel();
    final sheet = excel['Grade Report'];

    // Delete the default sheet if it exists
    if (excel.sheets.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }

    final headers = [
      'Student ID', 'Student Name',
      'Math', 'English', 'Science', 'Social Studies', 'Computer',
      'Average', 'Letter Grade', 'GPA', 'Remarks',
    ];

    // Write header row
    for (int col = 0; col < headers.length; col++) {
      final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0));
      cell.value = TextCellValue(headers[col]);
      cell.cellStyle = CellStyle(bold: true);
    }

    // Write data rows
    for (int i = 0; i < students.length; i++) {
      final s = students[i];
      final grade = s.computeGrade();
      final row = i + 1;

      void w(int col, CellValue val) {
        sheet.cell(CellIndex.indexByColumnRow(
            columnIndex: col, rowIndex: row)).value = val;
      }

      w(0,  TextCellValue(s.id));
      w(1,  TextCellValue(s.name));
      // Safe call pattern: nullable score displayed as 'N/A' when absent
      w(2,  s.mathScore    != null ? DoubleCellValue(s.mathScore!)    : TextCellValue('N/A'));
      w(3,  s.englishScore != null ? DoubleCellValue(s.englishScore!) : TextCellValue('N/A'));
      w(4,  s.scienceScore != null ? DoubleCellValue(s.scienceScore!) : TextCellValue('N/A'));
      w(5,  s.socialStudiesScore != null
              ? DoubleCellValue(s.socialStudiesScore!)
              : TextCellValue('N/A'));
      w(6,  s.computerScore != null ? DoubleCellValue(s.computerScore!) : TextCellValue('N/A'));
      w(7,  DoubleCellValue(double.parse(grade.average.toStringAsFixed(2))));
      w(8,  TextCellValue(grade.letterGrade));
      w(9,  DoubleCellValue(grade.gpa));
      w(10, TextCellValue(grade.remarks));
    }

    // Save to app documents directory
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final outputPath = '${dir.path}/grade_report_$timestamp.xlsx';

    final fileBytes = excel.encode();
    if (fileBytes == null) throw Exception('Failed to encode Excel file');

    File(outputPath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(fileBytes);

    return outputPath;
  }

  // ── Download a blank teacher template ─────────────────────
  static Future<String> generateTemplate() async {
    final excel = Excel.createExcel();
    final sheet = excel['Mark Sheet'];

    if (excel.sheets.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }

    final headers = [
      'Student ID', 'Student Name',
      'Math (/100)', 'English (/100)', 'Science (/100)',
      'Social Studies (/100)', 'Computer (/100)',
    ];

    for (int col = 0; col < headers.length; col++) {
      final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0));
      cell.value = TextCellValue(headers[col]);
      cell.cellStyle = CellStyle(bold: true);
    }

    // Sample rows so teacher knows the format
    final samples = [
      ['S001', 'Alice Johnson', '88', '92', '85', '79', '95'],
      ['S002', 'Bob Smith',     '72', '68', '',   '74', '80'],
      ['S003', 'Carol White',   '55', '60', '58', '',   '62'],
      ['S004', 'David Brown',   '40', '45', '38', '42', ''  ],
      ['S005', 'Eve Davis',     '95', '97', '93', '98', '99'],
    ];

    for (int i = 0; i < samples.length; i++) {
      for (int col = 0; col < samples[i].length; col++) {
        final cell = sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: col, rowIndex: i + 1));
        final val = samples[i][col];
        if (col >= 2 && val.isNotEmpty) {
          cell.value = IntCellValue(int.parse(val));
        } else {
          cell.value = TextCellValue(val);
        }
      }
    }

    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/marksheet_template.xlsx';

    final bytes = excel.encode();
    if (bytes == null) throw Exception('Encode failed');
    File(path)
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes);

    return path;
  }
}
