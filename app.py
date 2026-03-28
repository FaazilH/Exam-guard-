import time
import random
from datetime import datetime, timedelta
from flask import Flask, request, jsonify
from flask_cors import CORS
import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestClassifier
from sklearn.tree import DecisionTreeClassifier

app = Flask(__name__)
CORS(app)

CSV_PATH = "data/exam_dataset.csv"

def load_exam_slots():
    try:
        df = pd.read_csv(CSV_PATH)
        return df.to_dict('records')
    except Exception as e:
        print(f"[ERROR] Failed to load CSV: {e}")
        return []

EXAM_SLOTS = load_exam_slots()

def compute_severity(days_diff, same_shift):
    if days_diff == 0 and same_shift:
        return "CRITICAL"
    elif days_diff == 0:
        return "HIGH"
    elif days_diff <= 1:
        return "MEDIUM"
    elif days_diff <= 3:
        return "LOW"
    return "NONE"

def generate_training_data():
    records = []
    random.seed(42)
    np.random.seed(42)

    for i in range(len(EXAM_SLOTS)):
        for j in range(i+1, len(EXAM_SLOTS)):
            e1 = EXAM_SLOTS[i]
            e2 = EXAM_SLOTS[j]
            try:
                date1 = datetime.strptime(str(e1["date"]), "%Y-%m-%d")
                date2 = datetime.strptime(str(e2["date"]), "%Y-%m-%d")
                days_diff = abs((date1 - date2).days)
                same_shift = 1 if e1["shift"] == e2["shift"] else 0
                
                label = compute_severity(days_diff, same_shift == 1)
                records.append([days_diff, same_shift, label])
            except:
                continue
    
    for _ in range(500):
        days = random.randint(0, 10)
        shift = random.randint(0, 1)
        label = compute_severity(days, shift == 1)
        records.append([days, shift, label])
        
    return pd.DataFrame(records, columns=["days_diff", "same_shift", "label"])

df_train = generate_training_data()
X = df_train[["days_diff", "same_shift"]]
y = df_train["label"]

model = RandomForestClassifier(n_estimators=100, random_state=42)
model.fit(X, y)

@app.route("/api/exams", methods=["GET"])
def get_all_exams():
    return jsonify(EXAM_SLOTS)

@app.route("/api/detect-conflict", methods=["POST"])
def detect_conflict():
    data = request.get_json()
    e1_name = data.get("exam1_name")
    e1_date_str = data.get("exam1_date")
    e2_name = data.get("exam2_name")
    e2_date_str = data.get("exam2_date")

    try:
        d1 = datetime.strptime(e1_date_str, "%Y-%m-%d")
        d2 = datetime.strptime(e2_date_str, "%Y-%m-%d")
        days_diff = abs((d1 - d2).days)
        
        # Simple shift logic for mock
        shift1 = "Morning" 
        shift2 = "Morning"

        severity = compute_severity(days_diff, shift1 == shift2)
        is_conflict = days_diff == 0

        message = ""
        if not is_conflict:
            message = f"No conflict detected. Both exams are on different dates ({days_diff} days apart)."
        elif severity == 'CRITICAL':
            message = 'CRITICAL: Both exams fall on the same day and same shift. Immediate action required.'
        elif severity == 'HIGH':
            message = 'HIGH RISK: Both exams fall on the same day but different shifts. Consider rescheduling.'

        return jsonify({
            "success": True,
            "conflict": is_conflict,
            "severity": severity,
            "days_diff": days_diff,
            "message": message
        })
    except Exception as e:
        return jsonify({"success": False, "message": str(e)}), 400

@app.route("/api/suggest-slots", methods=["POST"])
def suggest_slots():
    data = request.get_json()
    exam_name = data.get("exam_name", "")
    conflicted_date_str = data.get("conflicted_date", "")

    try:
        conflicted_date = datetime.strptime(conflicted_date_str, "%Y-%m-%d")
    except ValueError:
        conflicted_date = None

    alternatives = [
        e for e in EXAM_SLOTS
        if str(e["name"]).lower() == str(exam_name).lower()
        and (conflicted_date is None or str(e["date"]) != conflicted_date_str)
    ]

    total_max = max([e["slots"] for e in EXAM_SLOTS]) if EXAM_SLOTS else 1
    alternatives.sort(key=lambda e: e["slots"], reverse=True)

    suggestions = []
    reasons = ["Best available slot with maximum capacity", "Good alternative with flexible city options", "Acceptable slot with moderate availability"]

    for i, slot in enumerate(alternatives[:3]):
        confidence = round((slot["slots"] / total_max) * 100, 2)
        suggestions.append({
            "rank": i + 1,
            "date": slot["date"],
            "shift": slot["shift"],
            "city": slot["city"],
            "available_slots": slot["slots"],
            "confidence": confidence,
            "reason": reasons[i] if i < len(reasons) else "Alternative slot",
        })

    return jsonify({"suggestions": suggestions})

MOCK_PORTAL_REGISTRATIONS = {
    "SSC777": {"exam_id": 4, "date": "2025-05-28", "shift": "Morning", "city": "Delhi"},
    "IBPS555": {"exam_id": 17, "date": "2025-10-04", "shift": "Morning", "city": "Delhi"},
    "SSC_MTS_2025": {"exam_id": 32, "date": "2026-05-30", "shift": "Morning", "city": "Mumbai"},
    "SSC_CHSL_2025": {"exam_id": 29, "date": "2026-05-30", "shift": "Morning", "city": "Mumbai"},
}

@app.route("/api/fetch-from-portal", methods=["POST"])
def fetch_from_portal():
    data = request.get_json()
    reg_no = data.get("registration_no", "").strip().upper()
    exam_id = data.get("exam_id")

    print(f"[DEBUG] Fetching Portal: Reg={reg_no}, ExamID={exam_id}")

    if reg_no in MOCK_PORTAL_REGISTRATIONS:
        reg_data = MOCK_PORTAL_REGISTRATIONS[reg_no]
    else:
        if reg_no.upper().startswith("SAFE"):
            target_date = "2026-07-15"
            target_shift = "Evening"
        else:
            target_date = "2026-05-30" 
            target_shift = "Morning"

        reg_data = {
            "exam_id": exam_id,
            "date": target_date,
            "shift": target_shift,
            "city": "Mumbai Center"
        }

    target_exam = next((e for e in EXAM_SLOTS if str(e["id"]) == str(exam_id)), None)
    
    if not target_exam:
        target_exam = EXAM_SLOTS[0] 

    if target_exam:
            raw_date_str = str(reg_data["date"])
            exam_date = datetime.strptime(raw_date_str, "%Y-%m-%d")
            days_until = (exam_date - datetime.now()).days
            
            is_confidential = days_until > 30
            display_date = "CONFIDENTIAL (Fetched)" if is_confidential else reg_data["date"]

            return jsonify({
                "success": True,
                "registration_no": reg_no,
                "exam_id": target_exam["id"],
                "exam_name": target_exam["name"],
                "board": target_exam["board"],
                "raw_date": reg_data["date"],
                "display_date": display_date,
                "is_confidential": is_confidential,
                "shift": reg_data["shift"],
                "city": reg_data["city"],
                "message": f"Successfully fetched registration for {target_exam['name']}"
            })

    return jsonify({
        "success": False,
        "message": "Registration number not found on government portal. Ensure the ID is correct."
    }), 404

if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0', port=5000)
