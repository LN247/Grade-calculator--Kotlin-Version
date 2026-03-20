import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../models/student.dart';
import '../utils/grade_calculator.dart';
import '../utils/excel_parser.dart';
import '../widgets/student_grade_card.dart';
import '../widgets/stats_panel.dart';

class ResultScreen extends StatefulWidget {
  final List<Student> students;
  final String sourceFileName;

  const ResultScreen(
      {super.key, required this.students, required this.sourceFileName});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  String _filter = 'All';
  String _sortBy = 'Average';
  bool _exporting = false;

  List<ProcessedStudent> get _list {
    // Higher-order function call with lambda predicate
    final predicate = _filter == 'Pass'
        ? (Student s) => s.computeAverage() >= 50
        : _filter == 'Fail'
            ? (Student s) => s.computeAverage() < 50
            : (Student s) => true;

    final result = processStudents(widget.students, predicate);

    result.sort((a, b) => switch (_sortBy) {
          'Name'    => a.student.name.compareTo(b.student.name),
          'Average' => b.result.average.compareTo(a.result.average),
          'Grade'   => a.result.letterGrade.compareTo(b.result.letterGrade),
          _         => 0,
        });

    return result;
  }

  Future<void> _export() async {
    setState(() => _exporting = true);
    try {
      final path = await ExcelParser.exportResultSheet(widget.students);
      if (!mounted) return;
      await Share.shareXFiles([XFile(path)],
          text: 'Grade Report — THE GRADER');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: Colors.red.shade700));
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = computeClassStats(widget.students);
    final dist  = gradeDistribution(widget.students);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Results',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          Text(widget.sourceFileName,
              style:
                  TextStyle(fontSize: 11, color: Colors.blueGrey.shade400)),
        ]),
        actions: [
          _exporting
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2)))
              : IconButton(
                  icon: const Icon(Icons.ios_share_rounded),
                  onPressed: _export,
                ),
        ],
      ),
      body: Column(children: [
        StatsPanel(stats: stats, distribution: dist),
        _controls(),
        Expanded(
          child: _list.isEmpty
              ? Center(
                  child: Text('No students match this filter',
                      style: TextStyle(color: Colors.blueGrey.shade400)))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: _list.length,
                  itemBuilder: (_, i) => StudentGradeCard(
                    student: _list[i].student,
                    result: _list[i].result,
                    rank: i + 1,
                  ),
                ),
        ),
      ]),
    );
  }

  Widget _controls() {
    return Container(
      color: const Color(0xFF0D1B2A),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(children: [
        _chip(Icons.filter_list_rounded, 'Filter: $_filter',
            () => _pick(['All', 'Pass', 'Fail'], (v) => _filter = v)),
        const SizedBox(width: 10),
        _chip(Icons.sort_rounded, 'Sort: $_sortBy',
            () => _pick(['Name', 'Average', 'Grade'], (v) => _sortBy = v)),
      ]),
    );
  }

  Widget _chip(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2A3A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blueGrey.shade700),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.blueGrey.shade300, size: 15),
              const SizedBox(width: 5),
              Text(label,
                  style: TextStyle(
                      color: Colors.blueGrey.shade300, fontSize: 12)),
              Icon(Icons.arrow_drop_down_rounded,
                  color: Colors.blueGrey.shade400, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  void _pick(List<String> options, void Function(String) onSelect) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A2A3A),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: options
            .map((o) => ListTile(
                  title: Text(o,
                      style: const TextStyle(color: Colors.white)),
                  onTap: () {
                    setState(() => onSelect(o));
                    Navigator.pop(context);
                  },
                ))
            .toList(),
      ),
    );
  }
}
