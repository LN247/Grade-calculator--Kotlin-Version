import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/student.dart';
import 'result_screen.dart';

class ManualEntryScreen extends StatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  final List<_Form> _forms = [];
  int _counter = 1;

  void _add() => setState(() {
        _forms.add(_Form('S${_counter.toString().padLeft(3, '0')}'));
        _counter++;
      });

  void _remove(int i) => setState(() => _forms.removeAt(i));

  // Nullable score parser — empty field → null (Elvis-ready)
  double? _parseScore(String text) {
    final t = text.trim();
    if (t.isEmpty) return null;
    final v = double.tryParse(t);
    if (v == null || v < 0 || v > 100) return null; // edge case guard
    return v;
  }

  void _calculate() {
    final students = <Student>[];
    for (final f in _forms) {
      final name = f.name.text.trim();
      if (name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Fill in all student names.'),
          backgroundColor: Colors.orange,
        ));
        return;
      }
      students.add(Student(
        id: f.id,
        name: name,
        mathScore: _parseScore(f.math.text),
        englishScore: _parseScore(f.english.text),
        scienceScore: _parseScore(f.science.text),
        socialStudiesScore: _parseScore(f.social.text),
        computerScore: _parseScore(f.computer.text),
      ));
    }
    if (students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Add at least one student.'),
        backgroundColor: Colors.orange,
      ));
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
            students: students, sourceFileName: 'Manual Entry'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Manual Entry',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          if (_forms.isNotEmpty)
            TextButton(
              onPressed: _calculate,
              child: const Text('Calculate',
                  style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: Column(children: [
        // Column headers
        Container(
          color: const Color(0xFF1A2A3A),
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(children: [
            const SizedBox(width: 180),
            ...['Math', 'Eng', 'Sci', 'Soc', 'Comp'].map((s) => Expanded(
                  child: Center(
                      child: Text(s,
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.blueGrey.shade400,
                              fontWeight: FontWeight.w600))),
                )),
            const SizedBox(width: 32),
          ]),
        ),
        Expanded(
          child: _forms.isEmpty
              ? Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      Icon(Icons.person_outline_rounded,
                          size: 64, color: Colors.blueGrey.shade700),
                      const SizedBox(height: 12),
                      Text('Tap + to add a student',
                          style: TextStyle(
                              color: Colors.blueGrey.shade400,
                              fontSize: 16)),
                    ]))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: _forms.length,
                  itemBuilder: (_, i) => _FormRow(
                    form: _forms[i],
                    index: i + 1,
                    onRemove: () => _remove(i),
                  ),
                ),
        ),
      ]),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_forms.isNotEmpty) ...[
            FloatingActionButton.extended(
              heroTag: 'calc',
              onPressed: _calculate,
              backgroundColor: const Color(0xFF1565C0),
              icon: const Icon(Icons.bar_chart_rounded),
              label: const Text('Generate Report'),
            ),
            const SizedBox(height: 10),
          ],
          FloatingActionButton(
            heroTag: 'add',
            onPressed: _add,
            backgroundColor: const Color(0xFF6A1B9A),
            child: const Icon(Icons.person_add_rounded),
          ),
        ],
      ),
    );
  }
}

// ── Form data holder ───────────────────────────────────────
class _Form {
  final String id;
  final name    = TextEditingController();
  final math    = TextEditingController();
  final english = TextEditingController();
  final science = TextEditingController();
  final social  = TextEditingController();
  final computer= TextEditingController();
  _Form(this.id);
}

// ── Row widget ─────────────────────────────────────────────
class _FormRow extends StatelessWidget {
  final _Form form;
  final int index;
  final VoidCallback onRemove;

  const _FormRow(
      {required this.form, required this.index, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2A3A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blueGrey.shade800),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0).withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(form.id,
                style: const TextStyle(
                    color: Color(0xFF64B5F6),
                    fontWeight: FontWeight.w700,
                    fontSize: 11)),
          ),
          const SizedBox(width: 8),
          Expanded(child: _tf(form.name, 'Student Name', text: true)),
          IconButton(
            icon: const Icon(Icons.close_rounded,
                color: Colors.red, size: 18),
            onPressed: onRemove,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _tf(form.math, '—')),
          const SizedBox(width: 5),
          Expanded(child: _tf(form.english, '—')),
          const SizedBox(width: 5),
          Expanded(child: _tf(form.science, '—')),
          const SizedBox(width: 5),
          Expanded(child: _tf(form.social, '—')),
          const SizedBox(width: 5),
          Expanded(child: _tf(form.computer, '—')),
        ]),
      ]),
    );
  }

  Widget _tf(TextEditingController c, String hint,
      {bool text = false}) {
    return TextField(
      controller: c,
      keyboardType: text ? TextInputType.name : TextInputType.number,
      inputFormatters:
          text ? [] : [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
      style: const TextStyle(color: Colors.white, fontSize: 12),
      textAlign: text ? TextAlign.left : TextAlign.center,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            TextStyle(color: Colors.blueGrey.shade600, fontSize: 12),
        filled: true,
        fillColor: const Color(0xFF0D1B2A),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
                color: Color(0xFF1565C0), width: 1.5)),
      ),
    );
  }
}
