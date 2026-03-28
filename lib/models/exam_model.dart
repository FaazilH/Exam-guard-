import 'dart:convert';

class ExamModel {
  final String id;
  final String name;
  final String board;
  final String displayDate;
  final DateTime rawDate;
  final String shift;
  final int availableSlots;
  final String city;
  final bool isRegistered;
  final String regNumber;
  final bool isConfidential;

  DateTime get date => rawDate;

  ExamModel({
    required this.id,
    required this.name,
    required this.board,
    required this.displayDate,
    required this.rawDate,
    required this.shift,
    required this.availableSlots,
    required this.city,
    this.isRegistered = false,
    this.regNumber = '',
    this.isConfidential = false,
  });

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    final rawDateStr = (json['raw_date'] ?? json['date'] ?? DateTime.now().toIso8601String()) as String;
    return ExamModel(
      id: (json['id'] ?? json['exam_id'] ?? '').toString(),
      name: (json['name'] ?? json['exam_name'] ?? 'Unknown Exam') as String,
      board: (json['board'] ?? 'GOVT') as String,
      displayDate: (json['display_date'] ?? json['date'] ?? 'TBA') as String,
      rawDate: DateTime.parse(rawDateStr),
      shift: (json['shift'] ?? 'Morning') as String,
      availableSlots: (json['slots'] ?? json['available_slots'] ?? 0) as int,
      city: (json['city'] ?? 'TBA') as String,
      isRegistered: json['isRegistered'] as bool? ?? json['success'] as bool? ?? false,
      regNumber: json['regNumber'] as String? ?? json['registration_no'] as String? ?? '',
      isConfidential: (json['is_confidential'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'board': board,
      'display_date': displayDate,
      'raw_date': rawDate.toIso8601String(),
      'shift': shift,
      'slots': availableSlots,
      'city': city,
      'isRegistered': isRegistered,
      'regNumber': regNumber,
      'is_confidential': isConfidential,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory ExamModel.fromJsonString(String str) =>
      ExamModel.fromJson(jsonDecode(str) as Map<String, dynamic>);

  ExamModel copyWith({
    String? id, String? name, String? board, String? displayDate,
    DateTime? rawDate, String? shift, int? availableSlots, String? city,
    bool? isRegistered, String? regNumber, bool? isConfidential,
  }) {
    return ExamModel(
      id: id ?? this.id,
      name: name ?? this.name,
      board: board ?? this.board,
      displayDate: displayDate ?? this.displayDate,
      rawDate: rawDate ?? this.rawDate,
      shift: shift ?? this.shift,
      availableSlots: availableSlots ?? this.availableSlots,
      city: city ?? this.city,
      isRegistered: isRegistered ?? this.isRegistered,
      regNumber: regNumber ?? this.regNumber,
      isConfidential: isConfidential ?? this.isConfidential,
    );
  }
}

class ConflictResult {
  final ExamModel exam1;
  final ExamModel exam2;
  final bool isConflict;
  final String severity;
  final int daysDiff;
  final String message;
  bool isResolved;
  final DateTime detectedAt;

  ConflictResult({
    required this.exam1,
    required this.exam2,
    required this.isConflict,
    required this.severity,
    required this.daysDiff,
    required this.message,
    this.isResolved = false,
    DateTime? detectedAt,
  }) : detectedAt = detectedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'exam1': exam1.toJson(),
      'exam2': exam2.toJson(),
      'isConflict': isConflict,
      'severity': severity,
      'daysDiff': daysDiff,
      'message': message,
      'isResolved': isResolved,
      'detectedAt': detectedAt.toIso8601String(),
    };
  }

  factory ConflictResult.fromJson(Map<String, dynamic> json) {
    return ConflictResult(
      exam1: ExamModel.fromJson(json['exam1'] as Map<String, dynamic>),
      exam2: ExamModel.fromJson(json['exam2'] as Map<String, dynamic>),
      isConflict: json['isConflict'] as bool,
      severity: json['severity'] as String,
      daysDiff: json['daysDiff'] as int,
      message: json['message'] as String,
      isResolved: json['isResolved'] as bool? ?? false,
      detectedAt: json['detectedAt'] != null
          ? DateTime.parse(json['detectedAt'] as String)
          : DateTime.now(),
    );
  }
}

class SlotSuggestion {
  final int rank;
  final DateTime date;
  final String shift;
  final String city;
  final int availableSlots;
  final double confidence;
  final String reason;

  SlotSuggestion({
    required this.rank,
    required this.date,
    required this.shift,
    required this.city,
    required this.availableSlots,
    required this.confidence,
    required this.reason,
  });

  factory SlotSuggestion.fromJson(Map<String, dynamic> json) {
    return SlotSuggestion(
      rank: json['rank'] as int,
      date: DateTime.parse(json['date'] as String),
      shift: json['shift'] as String,
      city: json['city'] as String,
      availableSlots: json['available_slots'] as int,
      confidence: (json['confidence'] as num).toDouble(),
      reason: json['reason'] as String,
    );
  }
}
