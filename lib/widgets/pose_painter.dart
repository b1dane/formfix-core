import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PosePainter extends CustomPainter {
  final Pose pose;
  final Size imageSize;
  final bool isFrontCamera;

  PosePainter({required this.pose, required this.imageSize, this.isFrontCamera = true});

  @override
  void paint(Canvas canvas, Size size) {
    final jp = Paint()..color = const Color(0xFF00F5C4)..strokeWidth = 6..style = PaintingStyle.fill;
    final bp = Paint()..color = const Color(0xFF00F5C4).withOpacity(0.6)..strokeWidth = 3..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final wp = Paint()..color = const Color(0xFF7B61FF).withOpacity(0.4)..strokeWidth = 2..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final lm = pose.landmarks;

    Offset tr(PoseLandmark k) {
      final x = isFrontCamera ? size.width - k.x * size.width / imageSize.width : k.x * size.width / imageSize.width;
      return Offset(x, k.y * size.height / imageSize.height);
    }

    void bn(PoseLandmarkType a, PoseLandmarkType b, {bool w = false}) {
      final la = lm[a]; final lb = lm[b];
      if (la == null || lb == null) return;
      if (la.likelihood < 0.5 || lb.likelihood < 0.5) return;
      canvas.drawLine(tr(la), tr(lb), w ? wp : bp);
    }

    void jt(PoseLandmarkType t) {
      final l = lm[t];
      if (l == null || l.likelihood < 0.5) return;
      canvas.drawCircle(tr(l), 5, jp);
    }

    // Draw the pose skeleton and joints
    // Left side
    bn(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow);
    bn(PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist);
    bn(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip);
    bn(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee);
    bn(PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle);
    // Right side
    bn(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow);
    bn(PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist);
    bn(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip);
    bn(PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee);
    bn(PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle);
    // Center
    bn(PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder);
    bn(PoseLandmarkType.leftHip, PoseLandmarkType.rightHip);

    // Draw joints
    jt(PoseLandmarkType.nose);
    jt(PoseLandmarkType.leftEye);
    jt(PoseLandmarkType.rightEye);
    jt(PoseLandmarkType.leftEar);
    jt(PoseLandmarkType.rightEar);
    jt(PoseLandmarkType.leftShoulder);
    jt(PoseLandmarkType.rightShoulder);
    jt(PoseLandmarkType.leftElbow);
    jt(PoseLandmarkType.rightElbow);
    jt(PoseLandmarkType.leftWrist);
    jt(PoseLandmarkType.rightWrist);
    jt(PoseLandmarkType.leftHip);
    jt(PoseLandmarkType.rightHip);
    jt(PoseLandmarkType.leftKnee);
    jt(PoseLandmarkType.rightKnee);
    jt(PoseLandmarkType.leftAnkle);
    jt(PoseLandmarkType.rightAnkle);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
