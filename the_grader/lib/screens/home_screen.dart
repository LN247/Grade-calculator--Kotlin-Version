import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../utils/excel_parser.dart';
import 'result_screen.dart';
import 'manual_entry_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  String? _lastFile;
  late AnimationController _pulse;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.95, end: 1.05).animate(
        CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    setState(() => _isLoading = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );
      if (result == null || result.files.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }
      final path = result.files.first.path;
      if (path == null) {
        _snack('Could not read file path.', error: true);
        setState(() => _isLoading = false);
        return;
      }
      final students = ExcelParser.parseMarkSheet(path);
      if (students.isEmpty) {
        _snack('No valid student data found. Check your Excel format.',
            error: true);
        setState(() => _isLoading = false);
        return;
      }
      setState(() {
        _lastFile = result.files.first.name;
        _isLoading = false;
      });
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
              students: students,
              sourceFileName: result.files.first.name),
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _snack('Error: ${e.toString()}', error: true);
    }
  }

  Future<void> _downloadTemplate() async {
    setState(() => _isLoading = true);
    try {
      final path = await ExcelParser.generateTemplate();
      setState(() => _isLoading = false);
      _snack('Template saved to: $path');
    } catch (e) {
      setState(() => _isLoading = false);
      _snack('Error: ${e.toString()}', error: true);
    }
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? Colors.red.shade700 : Colors.green.shade700,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              _header(),
              const SizedBox(height: 48),
              _card(
                gradient: const LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF0288D1)]),
                icon: Icons.upload_file_rounded,
                title: 'Upload Mark Sheet',
                subtitle: _lastFile ?? 'Import your Excel (.xlsx) file',
                label: 'Choose File',
                onTap: _pickFile,
              ),
              const SizedBox(height: 16),
              _card(
                gradient: const LinearGradient(
                    colors: [Color(0xFF6A1B9A), Color(0xFFAD1457)]),
                icon: Icons.edit_note_rounded,
                title: 'Manual Entry',
                subtitle: 'Add students and scores by hand',
                label: 'Enter Data',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const ManualEntryScreen())),
              ),
              const SizedBox(height: 16),
              _card(
                gradient: const LinearGradient(
                    colors: [Color(0xFF00695C), Color(0xFF2E7D32)]),
                icon: Icons.download_rounded,
                title: 'Download Template',
                subtitle: 'Get a pre-formatted Excel mark sheet',
                label: 'Download',
                onTap: _downloadTemplate,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Column(children: [
      ScaleTransition(
        scale: _scale,
        child: Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF00ACC1)]),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFF1565C0).withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 4)
            ],
          ),
          child: const Icon(Icons.school_rounded,
              color: Colors.white, size: 52),
        ),
      ),
      const SizedBox(height: 20),
      const Text('THE GRADER',
          style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 4)),
      const SizedBox(height: 6),
      Text('Smart Grade Calculator for Teachers',
          style:
              TextStyle(fontSize: 13, color: Colors.blueGrey.shade300)),
    ]);
  }

  Widget _card({
    required LinearGradient gradient,
    required IconData icon,
    required String title,
    required String subtitle,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: gradient.colors.first.withOpacity(0.3),
              blurRadius: 14,
              offset: const Offset(0, 5))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 3),
                      Text(subtitle,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 12)),
                    ]),
              ),
              const SizedBox(width: 8),
              _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(label,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ),
            ]),
          ),
        ),
      ),
    );
  }
}
