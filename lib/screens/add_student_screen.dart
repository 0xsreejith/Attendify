import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/student.dart';
import '../services/hive_database_helper.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({Key? key}) : super(key: key);

  @override
  _AddStudentScreenState createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _rollNumberController = TextEditingController();
  final _classController = TextEditingController();
  late final HiveDatabaseHelper _databaseHelper;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _databaseHelper = Provider.of<HiveDatabaseHelper>(
      context,
      listen: false,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rollNumberController.dispose();
    _classController.dispose();
    super.dispose();
  }

  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final newStudent = Student.create(
      name: _nameController.text.trim(),
      rollNumber: _rollNumberController.text.trim(),
      className: _classController.text.trim(),
    );

    try {
      await _databaseHelper.insertStudent(newStudent);
      if (!mounted) return;
      
      Navigator.pop(context, true); // Return success
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student added successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Student'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter student name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _rollNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Roll Number',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.confirmation_number),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter roll number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _classController,
                      decoration: const InputDecoration(
                        labelText: 'Class',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.school),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter class';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveStudent,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Save Student',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
