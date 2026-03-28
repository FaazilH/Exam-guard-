import 'package:flutter/material.dart';

const String BASE_URL = 'https://exam-guard-master-059.loca.lt';

const List<String> examBoards = ['UPSC', 'SSC', 'TNPSC', 'RRB', 'IBPS', 'SBI'];

const Map<String, Color> boardColors = {
  'UPSC': Color(0xFFFFD700),
  'SSC': Color(0xFF0066FF),
  'TNPSC': Color(0xFF00FF88),
  'RRB': Color(0xFFFF6B35),
  'IBPS': Color(0xFF9B5DE5),
  'SBI': Color(0xFF00C9A7),
};

const Map<String, Color> severityColors = {
  'CRITICAL': Color(0xFFFF3333),
  'HIGH': Color(0xFFFF6B35),
  'MEDIUM': Color(0xFFFFD700),
  'LOW': Color(0xFF00FF88),
  'NONE': Color(0xFF00C9A7),
};

const List<String> indianStates = [
  'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
  'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
  'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram',
  'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu',
  'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal',
  'Delhi', 'Jammu & Kashmir', 'Ladakh', 'Puducherry', 'Chandigarh',
];

const List<Map<String, dynamic>> EXAM_DATASET = [
  {"id": 1, "name": "UPSC CSE Prelims", "board": "UPSC", "date": "2025-05-25", "shift": "Morning", "slots": 12000, "city": "Delhi"},
  {"id": 2, "name": "UPSC CSE Prelims", "board": "UPSC", "date": "2025-06-01", "shift": "Morning", "slots": 8000, "city": "Mumbai"},
  {"id": 3, "name": "SSC CGL Tier 1", "board": "SSC", "date": "2025-05-25", "shift": "Morning", "slots": 25000, "city": "Delhi"},
  {"id": 4, "name": "SSC CGL Tier 1", "board": "SSC", "date": "2025-05-28", "shift": "Morning", "slots": 28000, "city": "Delhi"},
  {"id": 5, "name": "SSC CGL Tier 1", "board": "SSC", "date": "2025-06-04", "shift": "Morning", "slots": 30000, "city": "Chennai"},
  {"id": 6, "name": "SSC CGL Tier 1", "board": "SSC", "date": "2025-06-11", "shift": "Morning", "slots": 22000, "city": "Bangalore"},
  {"id": 7, "name": "RRB NTPC CBT 1", "board": "RRB", "date": "2025-05-25", "shift": "Morning", "slots": 40000, "city": "Delhi"},
  {"id": 8, "name": "RRB NTPC CBT 1", "board": "RRB", "date": "2025-06-01", "shift": "Morning", "slots": 45000, "city": "Mumbai"},
  {"id": 9, "name": "RRB NTPC CBT 1", "board": "RRB", "date": "2025-06-08", "shift": "Morning", "slots": 38000, "city": "Chennai"},
  {"id": 10, "name": "TNPSC Group 1", "board": "TNPSC", "date": "2025-05-25", "shift": "Morning", "slots": 5000, "city": "Chennai"},
  {"id": 11, "name": "TNPSC Group 1", "board": "TNPSC", "date": "2025-06-08", "shift": "Morning", "slots": 12000, "city": "Coimbatore"},
  {"id": 12, "name": "TNPSC Group 1", "board": "TNPSC", "date": "2025-06-15", "shift": "Morning", "slots": 18000, "city": "Madurai"},
  {"id": 13, "name": "TNPSC Group 2", "board": "TNPSC", "date": "2025-05-25", "shift": "Afternoon", "slots": 8000, "city": "Chennai"},
  {"id": 14, "name": "TNPSC Group 2", "board": "TNPSC", "date": "2025-06-22", "shift": "Morning", "slots": 20000, "city": "Trichy"},
  {"id": 15, "name": "TNPSC Group 4", "board": "TNPSC", "date": "2025-07-06", "shift": "Morning", "slots": 25000, "city": "Chennai"},
  {"id": 16, "name": "TNPSC Group 4", "board": "TNPSC", "date": "2025-07-13", "shift": "Morning", "slots": 30000, "city": "Coimbatore"},
  {"id": 17, "name": "IBPS PO Prelims", "board": "IBPS", "date": "2025-10-04", "shift": "Morning", "slots": 35000, "city": "Delhi"},
  {"id": 18, "name": "IBPS PO Prelims", "board": "IBPS", "date": "2025-10-05", "shift": "Morning", "slots": 40000, "city": "Mumbai"},
  {"id": 19, "name": "IBPS PO Prelims", "board": "IBPS", "date": "2025-10-11", "shift": "Morning", "slots": 38000, "city": "Chennai"},
  {"id": 20, "name": "IBPS PO Prelims", "board": "IBPS", "date": "2025-10-12", "shift": "Morning", "slots": 42000, "city": "Bangalore"},
  {"id": 21, "name": "IBPS Clerk Prelims", "board": "IBPS", "date": "2025-10-04", "shift": "Afternoon", "slots": 30000, "city": "Delhi"},
  {"id": 22, "name": "IBPS Clerk Prelims", "board": "IBPS", "date": "2025-11-08", "shift": "Morning", "slots": 40000, "city": "Chennai"},
  {"id": 23, "name": "SBI PO Prelims", "board": "SBI", "date": "2025-11-08", "shift": "Morning", "slots": 20000, "city": "Delhi"},
  {"id": 24, "name": "SBI PO Prelims", "board": "SBI", "date": "2025-11-15", "shift": "Morning", "slots": 22000, "city": "Chennai"},
  {"id": 25, "name": "SBI PO Prelims", "board": "SBI", "date": "2025-11-16", "shift": "Morning", "slots": 28000, "city": "Bangalore"},
  {"id": 26, "name": "SBI Clerk Prelims", "board": "SBI", "date": "2025-11-08", "shift": "Afternoon", "slots": 18000, "city": "Delhi"},
  {"id": 27, "name": "NDA 1", "board": "UPSC", "date": "2025-04-13", "shift": "Morning", "slots": 15000, "city": "Delhi"},
  {"id": 28, "name": "CDS 1", "board": "UPSC", "date": "2025-04-13", "shift": "Morning", "slots": 10000, "city": "Chennai"},
  {"id": 29, "name": "SSC CHSL Tier 1", "board": "SSC", "date": "2025-06-01", "shift": "Morning", "slots": 28000, "city": "Delhi"},
  {"id": 30, "name": "SSC CHSL Tier 1", "board": "SSC", "date": "2025-06-08", "shift": "Morning", "slots": 32000, "city": "Mumbai"},
  {"id": 31, "name": "SSC CPO", "board": "SSC", "date": "2025-06-23", "shift": "Morning", "slots": 20000, "city": "Delhi"},
  {"id": 32, "name": "SSC MTS", "board": "SSC", "date": "2025-07-14", "shift": "Morning", "slots": 45000, "city": "Delhi"},
  {"id": 33, "name": "SSC MTS", "board": "SSC", "date": "2025-07-15", "shift": "Morning", "slots": 48000, "city": "Mumbai"},
  {"id": 34, "name": "RRB Group D", "board": "RRB", "date": "2025-08-10", "shift": "Morning", "slots": 80000, "city": "Delhi"},
  {"id": 35, "name": "RRB Group D", "board": "RRB", "date": "2025-08-11", "shift": "Morning", "slots": 85000, "city": "Mumbai"},
  {"id": 36, "name": "RRB Group D", "board": "RRB", "date": "2025-08-12", "shift": "Morning", "slots": 78000, "city": "Chennai"},
  {"id": 37, "name": "IBPS RRB PO", "board": "IBPS", "date": "2025-08-03", "shift": "Morning", "slots": 32000, "city": "Delhi"},
  {"id": 38, "name": "IBPS RRB PO", "board": "IBPS", "date": "2025-08-09", "shift": "Morning", "slots": 35000, "city": "Mumbai"},
  {"id": 39, "name": "IBPS RRB Clerk", "board": "IBPS", "date": "2025-08-03", "shift": "Afternoon", "slots": 38000, "city": "Chennai"},
  {"id": 40, "name": "TNPSC VAO", "board": "TNPSC", "date": "2025-10-19", "shift": "Morning", "slots": 15000, "city": "Chennai"},
  {"id": 41, "name": "TNPSC VAO", "board": "TNPSC", "date": "2025-10-26", "shift": "Morning", "slots": 18000, "city": "Coimbatore"},
  {"id": 42, "name": "RRB ALP", "board": "RRB", "date": "2025-11-23", "shift": "Morning", "slots": 60000, "city": "Delhi"},
  {"id": 43, "name": "RRB ALP", "board": "RRB", "date": "2025-11-24", "shift": "Morning", "slots": 65000, "city": "Mumbai"},
  {"id": 44, "name": "UPSC EPFO", "board": "UPSC", "date": "2025-09-14", "shift": "Morning", "slots": 18000, "city": "Delhi"},
  {"id": 45, "name": "NDA 2", "board": "UPSC", "date": "2025-09-14", "shift": "Morning", "slots": 18000, "city": "Delhi"},
  {"id": 46, "name": "IBPS PO Mains", "board": "IBPS", "date": "2025-11-30", "shift": "Morning", "slots": 30000, "city": "Delhi"},
  {"id": 47, "name": "SBI PO Mains", "board": "SBI", "date": "2025-12-07", "shift": "Morning", "slots": 20000, "city": "Mumbai"},
  {"id": 48, "name": "IBPS Clerk Mains", "board": "IBPS", "date": "2025-12-13", "shift": "Morning", "slots": 28000, "city": "Delhi"},
  {"id": 49, "name": "SBI Clerk Mains", "board": "SBI", "date": "2025-12-14", "shift": "Morning", "slots": 25000, "city": "Mumbai"},
  {"id": 50, "name": "UPSC CSE Mains", "board": "UPSC", "date": "2025-09-20", "shift": "Morning", "slots": 3000, "city": "Delhi"},
];
