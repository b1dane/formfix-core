import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PoseAnalyzer {
  static double _angle(PoseLandmark a, PoseLandmark b, PoseLandmark c) {
    final ab = Offset(b.x - a.x, b.y - a.y);
    final cb = Offset(b.x - c.x, b.y - c.y);
    final dot = ab.dx * cb.dx + ab.dy * cb.dy;
    final cross = ab.dx * cb.dy - ab.dy * cb.dx;
    return (atan2(cross.abs(), dot) * 180 / pi).abs();
  }

  static double _lateralTilt(PoseLandmark left, PoseLandmark right) {
    return ((left.y - right.y) / (right.x - left.x) * 180 / pi).abs();
  }

  static ScanResult analyze(Pose pose) {
    final lm = pose.landmarks;
    final issues = <PostureIssue>[];
    final scores = <String, int>{};

    final lShoulder = lm[PoseLandmarkType.leftShoulder];
    final rShoulder = lm[PoseLandmarkType.rightShoulder];
    if (lShoulder != null && rShoulder != null) {
      final tilt = _lateralTilt(lShoulder, rShoulder);
      if (tilt > 8) {
        issues.add(PostureIssue(
          area: 'Shoulder Imbalance',
          severity: tilt > 15 ? Severity.high : Severity.medium,
          detail: 'Shoulder height differs by ${tilt.toStringAsFixed(1)}°',
          exercises: [
            Exercise('Unilateral Dumbbell Row', 'Strengthens lower shoulder side', '3×10 each'),
            Exercise('Side-Lying External Rotation', 'Corrects rotator cuff imbalance', '3×15 each'),
            Exercise('Doorway Chest Stretch', 'Opens tight pec on elevated side', '3×30 sec'),
          ],
        ));
        scores['shoulders'] = max(0, 100 - (tilt * 3).toInt());
      } else {
        scores['shoulders'] = 100;
      }
    }

    final lHip = lm[PoseLandmarkType.leftHip];
    final rHip = lm[PoseLandmarkType.rightHip];
    if (lHip != null && rHip != null) {
      final hipTilt = _lateralTilt(lHip, rHip);
      if (hipTilt > 5) {
        issues.add(PostureIssue(
          area: 'Hip Alignment',
          severity: hipTilt > 12 ? Severity.high : Severity.medium,
          detail: 'Pelvic tilt detected at ${hipTilt.toStringAsFixed(1)}°',
          exercises: [
            Exercise('Glute Bridge', 'Activates glutes to level pelvis', '3×12'),
            Exercise('Lateral Band Walk', 'Strengthens hip abductors', '3×20 steps each'),
            Exercise('Hip Flexor Lunge Stretch', 'Releases tight hip flexors', '3×45 sec each'),
          ],
        ));
        scores['hips'] = max(0, 100 - (hipTilt * 4).toInt());
      } else {
        scores['hips'] = 100;
      }
    }

    final lKnee = lm[PoseLandmarkType.leftKnee];
    final lAnkle = lm[PoseLandmarkType.leftAnkle];
    if (lHip != null && lKnee != null && lAnkle != null) {
      final lKneeAngle = _angle(lHip, lKnee, lAnkle);
      if (lKneeAngle < 160) {
        issues.add(PostureIssue(
          area: 'Knee Valgus (Left)',
          severity: lKneeAngle < 145 ? Severity.high : Severity.low,
          detail: 'Left knee angle ${lKneeAngle.toStringAsFixed(0)}°',
          exercises: [
            Exercise('Clamshells', 'Activates gluteus medius', '3×15 each'),
            Exercise('Single-Leg Squat', 'Trains knee alignment', '3×8 each'),
            Exercise('VMO Squat', 'Strengthens inner quad', '3×12'),
          ],
        ));
        scores['knees'] = max(0, (lKneeAngle - 130).toInt());
      } else {
        scores['knees'] = 100;
      }
    }

    final nose = lm[PoseLandmarkType.nose];
    if (nose != null && lShoulder != null && rShoulder != null) {
      final shoulderMidX = (lShoulder.x + rShoulder.x) / 2;
      final forwardOffset = (nose.x - shoulderMidX).abs();
      if (forwardOffset > 40) {
        issues.add(PostureIssue(
          area: 'Forward Head Posture',
          severity: forwardOffset > 80 ? Severity.high : Severity.medium,
          detail: 'Head is ${forwardOffset.toStringAsFixed(0)}px forward of shoulder line',
          exercises: [
            Exercise('Chin Tuck', 'Retracts head over spine', '3×10 reps, 5 sec hold'),
            Exercise('Neck Flexor Stretch', 'Releases tight suboccipitals', '3×30 sec'),
            Exercise('Face Pull', 'Strengthens posterior chain', '3×15'),
          ],
        ));
        scores['spine'] = max(0, 100 - ((forwardOffset - 40) * 1.5).toInt());
      } else {
        scores['spine'] = 100;
      }
    }

    final overallScore = scores.isEmpty
        ? 85
        : (scores.values.reduce((a, b) => a + b) / scores.length).round();

    return ScanResult(
      score: overallScore,
      issues: issues,
      scannedAt: DateTime.now(),
    );
  }
}

enum Severity { low, medium, high }

class Exercise {
  final String name;
  final String rationale;
  final String prescription;
  const Exercise(this.name, this.rationale, this.prescription);
}

class PostureIssue {
  final String area;
  final Severity severity;
  final String detail;
  final List<Exercise> exercises;
  const PostureIssue({
    required this.area,
    required this.severity,
    required this.detail,
    required this.exercises,
  });

  Color get severityColor {
    switch (severity) {
      case Severity.high: return const Color(0xFFFF5555);
      case Severity.medium: return const Color(0xFFF1C40F);
      case Severity.low: return const Color(0xFF00F5C4);
    }
  }

  String get severityLabel {
    switch (severity) {
      case Severity.high: return 'NEEDS WORK';
      case Severity.medium: return 'MODERATE';
      case Severity.low: return 'MINOR';
    }
  }
}

class ScanResult {
  final int score;
  final List<PostureIssue> issues;
  final DateTime scannedAt;
  const ScanResult({
    required this.score,
    required this.issues,
    required this.scannedAt,
  });

  String get grade {
    if (score >= 90) return 'EXCELLENT';
    if (score >= 75) return 'GOOD';
    if (score >= 60) return 'FAIR';
    return 'NEEDS WORK';
  }

  Color get gradeColor {
    if (score >= 90) return const Color(0xFF00F5C4);
    if (score >= 75) return const Color(0xFF7B61FF);
    if (score >= 60) return const Color(0xFFF1C40F);
    return const Color(0xFFFF5555);
  }

  Map<String, dynamic> toJson() => {
    'score': score,
    'grade': grade,
    'issues': issues.map((i) => i.area).toList(),
    'scannedAt': scannedAt.toIso8601String(),
  };
}