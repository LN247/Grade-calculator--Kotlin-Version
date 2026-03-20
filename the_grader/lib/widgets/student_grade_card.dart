import 'package:flutter/material.dart';
import '../models/student.dart';

class StudentGradeCard extends StatelessWidget {
  final Student student;
  final GradeResult result;
  final int rank;

  const StudentGradeCard({
    super.key,
    required this.student,
    required this.result,
    required this.rank,
  });

  Color get _color {
    final a = result.average;
    if (a >= 80) return const Color(0xFF43A047);
    if (a >= 65) return const Color(0xFF1E88E5);
    if (a >= 50) return const Color(0xFFFB8C00);
    return const Color(0xFFE53935);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2A3A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blueGrey.shade800.withOpacity(0.5)),
      ),
      child: ExpansionTile(
        collapsedShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        tilePadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: _rankBadge(),
        title: Text(student.name,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15)),
        subtitle: Text(
            '${student.id}  ·  Avg: ${result.average.toStringAsFixed(1)}%',
            style:
                TextStyle(color: Colors.blueGrey.shade400, fontSize: 11)),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          _gradeBadge(),
          const SizedBox(width: 4),
          Icon(Icons.expand_more_rounded,
              color: Colors.blueGrey.shade500, size: 20),
        ]),
        children: [_breakdown()],
      ),
    );
  }

  Widget _rankBadge() {
    final medals = [
      const Color(0xFFFFD700),
      const Color(0xFFC0C0C0),
      const Color(0xFFCD7F32)
    ];
    final c = rank <= 3 ? medals[rank - 1] : Colors.blueGrey.shade600;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
          color: c.withOpacity(0.15),
          borderRadius: BorderRadius.circular(9)),
      child: Center(
          child: Text('#$rank',
              style: TextStyle(
                  color: c,
                  fontWeight: FontWeight.w800,
                  fontSize: 12))),
    );
  }

  Widget _gradeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: _color.withOpacity(0.4)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(result.letterGrade,
            style: TextStyle(
                color: _color, fontWeight: FontWeight.w900, fontSize: 14)),
        Text(result.remarks,
            style: TextStyle(
                color: _color.withOpacity(0.8),
                fontSize: 9,
                fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _breakdown() {
    final subjects = {
      'Math': student.mathScore,
      'English': student.englishScore,
      'Science': student.scienceScore,
      'Social Studies': student.socialStudiesScore,
      'Computer': student.computerScore,
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Divider(color: Colors.blueGrey.shade800, height: 16),
        ...subjects.entries.map((e) => _subjectRow(e.key, e.value)),
        Divider(color: Colors.blueGrey.shade800, height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _chip('${result.average.toStringAsFixed(1)}%', 'Average',
                Colors.blue),
            _chip(result.gpa.toStringAsFixed(1), 'GPA', Colors.purple),
            _chip(result.letterGrade, 'Grade', _color),
          ],
        ),
      ]),
    );
  }

  Widget _subjectRow(String subject, double? score) {
    // Safe call: score?.toStringAsFixed(1) ?? 'N/A'
    final display = score?.toStringAsFixed(1) ?? 'N/A';
    final progress = score != null ? score / 100.0 : 0.0;
    final barColor = score == null
        ? Colors.blueGrey.shade700
        : score >= 70
            ? Colors.green.shade400
            : score >= 50
                ? Colors.orange.shade400
                : Colors.red.shade400;

    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(children: [
        SizedBox(
            width: 112,
            child: Text(subject,
                style: TextStyle(
                    color: Colors.blueGrey.shade300, fontSize: 12))),
        Expanded(
            child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.blueGrey.shade800,
            valueColor: AlwaysStoppedAnimation(barColor),
            minHeight: 6,
          ),
        )),
        const SizedBox(width: 10),
        SizedBox(
            width: 40,
            child: Text(display,
                textAlign: TextAlign.right,
                style: TextStyle(
                    color: score == null
                        ? Colors.blueGrey.shade600
                        : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12))),
      ]),
    );
  }

  Widget _chip(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(children: [
        Text(value,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w800, fontSize: 15)),
        Text(label,
            style: TextStyle(
                color: color.withOpacity(0.7),
                fontSize: 10,
                fontWeight: FontWeight.w500)),
      ]),
    );
  }
}
