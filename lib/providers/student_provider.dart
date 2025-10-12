import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../models/student_profile.dart';
import '../services/student_service.dart';

class StudentProvider extends ChangeNotifier {
  final StudentService _studentService = StudentService();
  
  List<StudentProfile> _students = [];
  StudentProfile? _selectedStudent;
  bool _isLoading = false;
  String _error = '';

  // Getters
  List<StudentProfile> get students => _students;
  StudentProfile? get selectedStudent => _selectedStudent;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Mengambil daftar siswa dengan retry mechanism
  Future<void> fetchStudents({int retryCount = 2}) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    for (int attempt = 0; attempt <= retryCount; attempt++) {
      try {
        _students = await _studentService.getStudents();
        print('Debug _students: $_students'); // Tambahan print debug untuk variabel _students
        if (_students.isNotEmpty && _selectedStudent == null) {
          _selectedStudent = _students.first;
        }
        // Jika berhasil, keluar dari loop
        _error = '';
        break;
      } catch (e) {
        // Jika ini percobaan terakhir, simpan error
        if (attempt == retryCount) {
          _error = e.toString();
          developer.log('Error fetchStudents (final attempt): $e', name: 'StudentProvider', error: e);
        } else {
          developer.log('Error fetchStudents (attempt ${attempt+1}): $e', name: 'StudentProvider', error: e);
          // Tunggu sebentar sebelum mencoba lagi
          await Future.delayed(Duration(milliseconds: 500));
        }
      }
    }
    
    _isLoading = false;
    notifyListeners();
  }

  // Mengambil detail siswa
  Future<void> fetchStudentDetail(String studentId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _selectedStudent = await _studentService.getStudentDetail(studentId);
    } catch (e) {
      _error = e.toString();
      developer.log('Error fetchStudentDetail: $e', name: 'StudentProvider', error: e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Memilih siswa dari daftar yang sudah ada
  void selectStudent(StudentProfile student) {
    _selectedStudent = student;
    notifyListeners();
  }

  // Memperbarui data siswa
  Future<void> updateStudent(String studentId, StudentProfile updatedStudent) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _selectedStudent = await _studentService.updateStudent(studentId, updatedStudent);
      
      // Update daftar siswa juga
      final index = _students.indexWhere((s) => s.studentId == studentId);
      if (index != -1) {
        _students[index] = _selectedStudent!;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}