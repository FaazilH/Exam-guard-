import 'package:flutter/foundation.dart';
import '../models/exam_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class ExamProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  final StorageService _storage = StorageService();

  List<ExamModel> _allExams = [];
  List<ExamModel> _registeredExams = [];
  List<ConflictResult> _conflicts = [];
  bool _isLoading = false;
  bool _isInitialized = false;
  String _errorMsg = '';

  List<ExamModel> get allExams => _allExams;
  List<ExamModel> get registeredExams => _registeredExams;
  List<ConflictResult> get conflicts => _conflicts;
  bool get isLoading => _isLoading;
  String get errorMsg => _errorMsg;

  int get conflictCount => _conflicts.where((c) => c.isConflict && !c.isResolved).length;
  int get clearedCount => _registeredExams.length - conflictCount;

  ExamModel? get nextExam {
    final now = DateTime.now();
    final upcoming = _registeredExams
        .where((e) => e.date.isAfter(now))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return upcoming.isEmpty ? null : upcoming.first;
  }

  int get daysUntilNextExam {
    final next = nextExam;
    if (next == null) return 0;
    return next.date.difference(DateTime.now()).inDays;
  }

  Future<void> initialize() async {
    if (_isInitialized) return;
    _setLoading(true);
    try {
      _registeredExams = await _storage.getRegisteredExams();
      _conflicts = await _storage.getConflicts();
      _isInitialized = true;
      // Load exams in background or concurrently
      loadAllExams(); 
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadAllExams({bool force = false}) async {
    if (_allExams.isNotEmpty && !force) return;
    _setLoading(true);
    _errorMsg = '';
    try {
      _allExams = await _api.getAllExams();
    } catch (e) {
      _errorMsg = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  List<ExamModel> getExamsByBoard(String board) {
    return _allExams.where((e) => e.board == board).toList();
  }

  List<String> get uniqueExamNames {
    final names = <String>{};
    for (final e in _allExams) {
      names.add(e.name);
    }
    return names.toList()..sort();
  }

  List<ExamModel> getSlotsForExam(String examName) {
    return _allExams.where((e) => e.name == examName).toList();
  }

  bool isExamRegistered(String examId) {
    return _registeredExams.any((e) => e.id == examId);
  }

  Future<void> registerExam(ExamModel exam, String regNumber) async {
    final updated = exam.copyWith(isRegistered: true, regNumber: regNumber);
    _registeredExams.removeWhere((e) => e.id == updated.id);
    _registeredExams.add(updated);
    await _storage.saveRegisteredExams(_registeredExams);

    // Auto-check conflicts with all existing exams in parallel
    final conflictFutures = _registeredExams
        .where((e) => e.id != updated.id)
        .map((existing) => _api.detectConflict(existing, updated));
    
    final results = await Future.wait(conflictFutures);
    for (final result in results) {
      if (result.isConflict) {
        _conflicts.removeWhere(
          (c) => (c.exam1.id == result.exam1.id && c.exam2.id == result.exam2.id) ||
                 (c.exam1.id == result.exam2.id && c.exam2.id == result.exam1.id),
        );
        _conflicts.add(result);
      }
    }
    await _storage.saveConflicts(_conflicts);
    notifyListeners();
  }

  Future<Map<String, dynamic>> fetchAndRegister(String regNo, String examId) async {
    _setLoading(true);
    try {
      final res = await _api.fetchFromPortal(regNo, examId);
      if (res['success'] == true) {
        final examData = ExamModel.fromJson(res);
        final updated = examData.copyWith(isRegistered: true, regNumber: regNo);
        
        // Remove old registrations for this same exam name if any
        _registeredExams.removeWhere((e) => e.name == updated.name);
        
        // Check conflicts in parallel
        final conflictFutures = _registeredExams
            .map((existing) => _api.detectConflict(existing, updated));
        
        final results = await Future.wait(conflictFutures);
        List<ConflictResult> newConflicts = results.where((r) => r.isConflict).toList();
        
        _registeredExams.add(updated);
        _conflicts.addAll(newConflicts);
        
        await _storage.saveRegisteredExams(_registeredExams);
        await _storage.saveConflicts(_conflicts);
        
        notifyListeners();
        
        // Add conflict info to response
        res['has_conflict'] = newConflicts.any((c) => c.isConflict);
        res['conflicts'] = newConflicts;
        res['critical_conflict'] = newConflicts.any((c) => c.severity == 'CRITICAL' || c.severity == 'HIGH');
      }
      return res;
    } finally {
      _setLoading(false);
    }
  }

  Future<ConflictResult> checkConflict(ExamModel exam1, ExamModel exam2) async {
    final result = await _api.detectConflict(exam1, exam2);
    if (result.isConflict) {
      _conflicts.removeWhere(
        (c) => (c.exam1.id == exam1.id && c.exam2.id == exam2.id) ||
               (c.exam1.id == exam2.id && c.exam2.id == exam1.id),
      );
      _conflicts.add(result);
      await _storage.saveConflicts(_conflicts);
    }
    notifyListeners();
    return result;
  }

  Future<void> resolveConflict(ConflictResult conflict) async {
    final idx = _conflicts.indexWhere(
      (c) => c.exam1.id == conflict.exam1.id && c.exam2.id == conflict.exam2.id,
    );
    if (idx != -1) {
      _conflicts[idx].isResolved = true;
      await _storage.saveConflicts(_conflicts);
      notifyListeners();
    }
  }

  Future<void> removeExam(String id) async {
    _registeredExams.removeWhere((e) => e.id == id);
    _conflicts.removeWhere(
        (c) => c.exam1.id == id || c.exam2.id == id);
    await _storage.saveRegisteredExams(_registeredExams);
    await _storage.saveConflicts(_conflicts);
    notifyListeners();
  }

  Future<void> updateExamDate(ExamModel exam, ExamModel newSlot) async {
    final updatedExam = newSlot.copyWith(
      isRegistered: true,
      regNumber: exam.regNumber,
    );
    _registeredExams.removeWhere((e) => e.id == exam.id);
    _registeredExams.add(updatedExam);
    _conflicts.removeWhere(
        (c) => c.exam1.id == exam.id || c.exam2.id == exam.id);
    await _storage.saveRegisteredExams(_registeredExams);
    await _storage.saveConflicts(_conflicts);
    notifyListeners();
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  List<String> get registeredBoards {
    return _registeredExams.map((e) => e.board).toSet().toList();
  }
}
