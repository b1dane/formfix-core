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
    bn(PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder);
    bn(PoseLandmarkType.leftHip, PoseLandmarkType.rightHip);
    bn(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip);
    bn(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip);
    bn(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow);
    bn(PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist);
    bn(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow);
    bn(PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist);
    bn(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee);
    bn(PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle);
    bn(PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee);
    bn(PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle);
    bn(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftEar, w: true);
    bn(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightEar, w: true);
    final types = [PoseLandmarkType.nose, PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder, PoseLandmarkType.leftElbow, PoseLandmarkType.rightElbow, PoseLandmarkType.leftWrist, PoseLandmarkType.rightWrist, PoseLandmarkType.leftHip, PoseLandmarkType.rightHip, PoseLandmarkType.leftKnee, PoseLandmarkType.rightKnee, PoseLandmarkType.leftAnkle, PoseLandmarkType.rightAnkle];
    for (final t in types) { jt(t); }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
