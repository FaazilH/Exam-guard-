import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/exam_model.dart';

class StorageService {
  static const String _userKey = 'exam_guard_user';
  static const String _examsKey = 'exam_guard_registered_exams';
  static const String _conflictsKey = 'exam_guard_conflicts';

  Future<SharedPreferences> get _prefs async =>
      SharedPreferences.getInstance();

  // ── User ──────────────────────────────────────────────────────────
  Future<void> saveUser(String name, String email) async {
    final prefs = await _prefs;
    await prefs.setString(_userKey, jsonEncode({'name': name, 'email': email}));
  }

  Future<Map<String, String>> getUser() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_userKey);
    if (raw == null) return {};
    final data = jsonDecode(raw) as Map<String, dynamic>;
    return data.map((k, v) => MapEntry(k, v.toString()));
  }

  Future<bool> isLoggedIn() async {
    final user = await getUser();
    return user.isNotEmpty;
  }

  // ── Registered Exams ──────────────────────────────────────────────
  Future<void> saveRegisteredExams(List<ExamModel> exams) async {
    final prefs = await _prefs;
    final raw = jsonEncode(exams.map((e) => e.toJson()).toList());
    await prefs.setString(_examsKey, raw);
  }

  Future<List<ExamModel>> getRegisteredExams() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_examsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => ExamModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Conflicts ──────────────────────────────────────────────────────
  Future<void> saveConflicts(List<ConflictResult> conflicts) async {
    final prefs = await _prefs;
    final raw = jsonEncode(conflicts.map((c) => c.toJson()).toList());
    await prefs.setString(_conflictsKey, raw);
  }

  Future<List<ConflictResult>> getConflicts() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_conflictsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => ConflictResult.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Clear ──────────────────────────────────────────────────────────
  Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.clear();
  }
}
