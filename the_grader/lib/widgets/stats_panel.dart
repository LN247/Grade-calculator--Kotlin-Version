import 'package:flutter/material.dart';
import '../utils/grade_calculator.dart';

class StatsPanel extends StatelessWidget {
  final ClassStats stats;
  final Map<String, int> distribution;

  const StatsPanel(
      {super.key, required this.stats, required this.distribution});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0D1B2A),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Column(children: [
        Row(children: [
          _box('Students', '${stats.totalStudents}',
              Icons.group_rounded, const Color(0xFF1565C0)),
          const SizedBox(width: 10),
          _box('Class Avg',
              '${stats.classAverage.toStringAsFixed(1)}%',
              Icons.analytics_rounded, const Color(0xFF00695C)),
          const SizedBox(width: 10),
          _box('Pass Rate',
              '${stats.passRate.toStringAsFixed(0)}%',
              Icons.check_circle_rounded,
              stats.passRate >= 70
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFB71C1C)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          _box('Highest', '${stats.highest.toStringAsFixed(1)}%',
              Icons.arrow_upward_rounded, const Color(0xFF6A1B9A)),
          const SizedBox(width: 10),
          _box('Lowest', '${stats.lowest.toStringAsFixed(1)}%',
              Icons.arrow_downward_rounded, const Color(0xFFAD1457)),
          const SizedBox(width: 10),
          _box('Fail', '${stats.failCount}',
              Icons.cancel_rounded, const Color(0xFFB71C1C)),
        ]),
        if (distribution.isNotEmpty) ...[
          const SizedBox(height: 10),
          _dist(),
        ],
      ]),
    );
  }

  Widget _box(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(children: [
          Icon(icon, color: color, size: 17),
          const SizedBox(width: 6),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(value,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w800,
                        fontSize: 14)),
                Text(label,
                    style: TextStyle(
                        color: Colors.blueGrey.shade400, fontSize: 10)),
              ])),
        ]),
      ),
    );
  }

  Widget _dist() {
    final sorted = distribution.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2A3A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(children: [
        Text('Grades:',
            style: TextStyle(
                color: Colors.blueGrey.shade400, fontSize: 11)),
        const SizedBox(width: 8),
        Expanded(
          child: Wrap(
            spacing: 6,
            children: sorted
                .map((e) => Chip(
                      label: Text('${e.key}: ${e.value}',
                          style: const TextStyle(
                              fontSize: 10, color: Colors.white)),
                      backgroundColor: const Color(0xFF0D1B2A),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                    ))
                .toList(),
          ),
        ),
      ]),
    );
  }
}
