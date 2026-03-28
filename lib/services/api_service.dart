import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/exam_model.dart';

class ConflictEngine {
  static String computeSeverity(int daysDiff, bool sameShift) {
    if (daysDiff == 0 && sameShift) return 'CRITICAL';
    if (daysDiff == 0) return 'HIGH';
    if (daysDiff <= 1) return 'MEDIUM';
    if (daysDiff <= 3) return 'LOW';
    return 'NONE';
  }

  static bool predictConflict(int daysDiff, bool sameShift, bool sameBoard) {
    int votes = 0;
    if (daysDiff == 0) votes += 3;
    if (daysDiff == 0 && sameShift) votes += 4;
    if (daysDiff <= 1 && sameBoard) votes += 2;
    if (daysDiff == 0 && !sameBoard) votes += 3;
    return votes >= 3;
  }

  static double riskScore(ExamModel e1, ExamModel e2) {
    final diff = e1.date.difference(e2.date).inDays.abs();
    final sameShift = e1.shift == e2.shift;
    final sameBoard = e1.board == e2.board;
    double score = 0;
    if (diff == 0) score += 80;
    if (diff == 0 && sameShift) score += 20;
    if (sameBoard && diff <= 7) score += 10;
    if (!sameBoard && diff == 0) score += 15;
    return score.clamp(0, 100);
  }
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client _client = http.Client();
  static const Duration _timeout = Duration(seconds: 3);

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'bypass-tunnel-reminder': 'true',
      };

  List<ExamModel> _buildLocalExams() {
    return EXAM_DATASET.map((m) => ExamModel.fromJson(m)).toList();
  }

  Future<List<ExamModel>> getAllExams() async {
    try {
      final response = await _client.get(Uri.parse('$BASE_URL/api/exams'), headers: _headers).timeout(_timeout);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        return data.map((e) => ExamModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('[ApiService] getAllExams failed, using local fallback: $e');
    }
    return _buildLocalExams();
  }

  Future<Map<String, dynamic>> fetchFromPortal(String regNo, String examId) async {
    try {
      final response = await _client.post(
        Uri.parse('$BASE_URL/api/fetch-from-portal'),
        headers: _headers,
        body: jsonEncode({'registration_no': regNo, 'exam_id': examId}),
      ).timeout(_timeout);

      if (response.statusCode != 200) {
        return {
          'success': false,
          'message': 'Server Error (${response.statusCode}): The backend or tunnel might be down.'
        };
      }

      final dynamic data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        return data;
      } else {
        return {'success': false, 'message': 'Invalid response format from server.'};
      }
    } catch (e) {
      if (e is FormatException) {
        return {'success': false, 'message': 'Server returned an invalid response (not JSON). The tunnel might be broken.'};
      }
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<ConflictResult> detectConflict(ExamModel exam1, ExamModel exam2) async {
    final daysDiff = exam1.date.difference(exam2.date).inDays.abs();
    final sameShift = exam1.shift == exam2.shift;
    final sameBoard = exam1.board == exam2.board;
    try {
      final response = await _client.post(
        Uri.parse('$BASE_URL/api/detect-conflict'),
        headers: _headers,
        body: jsonEncode({
          'exam1_name': exam1.name,
          'exam1_date': exam1.date.toIso8601String().split('T')[0],
          'exam2_name': exam2.name,
          'exam2_date': exam2.date.toIso8601String().split('T')[0],
        }),
      ).timeout(_timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return ConflictResult(
          exam1: exam1,
          exam2: exam2,
          isConflict: data['conflict'] as bool,
          severity: data['severity'] as String,
          daysDiff: data['days_diff'] as int,
          message: data['message'] as String,
        );
      }
    } catch (_) {}

    final isConflict = ConflictEngine.predictConflict(daysDiff, sameShift, sameBoard);
    final severity = ConflictEngine.computeSeverity(daysDiff, sameShift);
    String message;
    if (!isConflict) {
      message = 'No conflict detected. Both exams are on different dates.';
    } else if (severity == 'CRITICAL') {
      message = 'CRITICAL: Both exams fall on the same day and same shift. Immediate action required.';
    } else if (severity == 'HIGH') {
      message = 'HIGH RISK: Both exams fall on the same day but different shifts. Consider rescheduling.';
    } else {
      message = 'Potential conflict detected. Exams are ${daysDiff} day(s) apart.';
    }
    return ConflictResult(
      exam1: exam1,
      exam2: exam2,
      isConflict: isConflict,
      severity: severity,
      daysDiff: daysDiff,
      message: message,
    );
  }

  Future<List<SlotSuggestion>> suggestSlots(String examName, DateTime conflictedDate, String city) async {
    try {
      final response = await _client.post(
        Uri.parse('$BASE_URL/api/suggest-slots'),
        headers: _headers,
        body: jsonEncode({
          'exam_name': examName,
          'conflicted_date': conflictedDate.toIso8601String().split('T')[0],
          'city': city,
        }),
      ).timeout(_timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final suggestions = data['suggestions'] as List<dynamic>;
        return suggestions.map((e) => SlotSuggestion.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return _localSuggestSlots(examName, conflictedDate, city);
  }

  List<SlotSuggestion> _localSuggestSlots(String examName, DateTime conflictedDate, String city) {
    final rng = Random();
    final alternatives = EXAM_DATASET.where((e) => e['name'] == examName && DateTime.parse(e['date'] as String) != conflictedDate).toList();
    if (alternatives.isEmpty) {
      return [
        SlotSuggestion(rank: 1, date: conflictedDate.add(const Duration(days: 7)), shift: 'Morning', city: city, availableSlots: 30000, confidence: 92.5, reason: 'Next available slot with maximum capacity'),
        SlotSuggestion(rank: 2, date: conflictedDate.add(const Duration(days: 14)), shift: 'Morning', city: 'Delhi', availableSlots: 25000, confidence: 78.3, reason: 'Alternative city with good availability'),
        SlotSuggestion(rank: 3, date: conflictedDate.add(const Duration(days: 21)), shift: 'Afternoon', city: 'Mumbai', availableSlots: 20000, confidence: 65.1, reason: 'Afternoon slot with moderate availability'),
      ];
    }
    alternatives.sort((a, b) => (b['slots'] as int).compareTo(a['slots'] as int));
    final top3 = alternatives.take(3).toList();
    final maxSlots = (top3.first['slots'] as int).toDouble();
    return top3.asMap().entries.map((entry) {
      final idx = entry.key;
      final e = entry.value;
      final slots = e['slots'] as int;
      final confidence = (slots / maxSlots * 100).clamp(0.0, 100.0);
      return SlotSuggestion(
        rank: idx + 1,
        date: DateTime.parse(e['date'] as String),
        shift: e['shift'] as String,
        city: e['city'] as String,
        availableSlots: slots,
        confidence: confidence + rng.nextDouble() * 5,
        reason: idx == 0 ? 'Optimal match — high availability' : idx == 1 ? 'Good match - flexible selection' : 'Alternative available',
      );
    }).toList();
  }
}
