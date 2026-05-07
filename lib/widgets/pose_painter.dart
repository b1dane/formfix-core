import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PosePainter extends CustomPainter {
  final Pose pose;
  final Size imageSize;
  final bool isFrontCamera;

  PosePainter({required this.pose, required this.imageSize, this.isFrontCamera = true});

  @override
  void paint(Canvas canvas, Size size) {
    final jointPaint = Paint()..color = const Color(0xFF00F5C4)..strokeWidth = 6..style = PaintingStyle.fill;
    final bonePaint = Paint()..color = const Color(0xFF00F5C4).withOpacity(0.6)..strokeWidth = 3..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final weakBonePaint = Paint()..color = const Color(0xFF7B61FF).withOpacity(0.4)..strokeWidth = 2..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final lm = pose.landmarks;

    Offset tr(PoseLandmark lmk) {
      final sx = size.width / imageSize.width;
      final sy = size.height / imageSize.height;
      final x = isFrontCamera ? size.width - lmk.x * sx : lmk.x * sx;
      return Offset(x, lmk.y * sy);
    }

    void bone(PoseLandmarkType a, PoseLandmarkType b, {bool weak = false}) {
      final la = lm[a]; final lb = lm[b];
      if (la == null || lb == null) return;
      if (la.likelihood < 0.5 || lb.likeliho