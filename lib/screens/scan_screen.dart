import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:permission_handler/permission_handler.dart';
import '../main.dart';
import '../services/pose_analyzer.dart';
import '../services/history_service.dart';
import '../widgets/pose_painter.dart';
import 'results_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});
  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  CameraController? _camera;
  PoseDetector? _detector;
  Pose? _currentPose;
  bool _isProcessing = false;
  bool _isScanning = false;
  bool _permissionGranted = false;
  int _scanCountdown = 3;
  String _statusMessage = 'Stand back so your full body is visible';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestPermissionAndInit();
  }

  Future<void> _requestPermissionAndInit() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      setState(() => _permissionGranted = true);
      _initDetector();
      await _initCamera();
    }
  }

  void _initDetector() {
    _detector = PoseDetector(
      options: PoseDetectorOptions(
        model: PoseDetectionModel.accurate,
        mode: PoseDetectionMode.stream,
      ),
    );
  }

  Future<void> _initCamera() async {
    if (cameras.isEmpty) return;
    final frontCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );
    _camera = CameraController(
      frontCamera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21,
    );
    await _camera!.initialize();
    if (!mounted) return;
    setState(() {});
    _camera!.startImageStream(_processFrame);
  }

  Future<void> _processFrame(CameraImage image) async {
    if (_isProcessing || _detector == null) return;
    _isProcessing = true;
    try {
      final inputImage = _buildInputImage(image);
      if (inputImage == null) return;
      final poses = await _detector!.processImage(inputImage);
      if (poses.isNotEmpty && mounted) {
        setState(() => _currentPose = poses.first);
      }
    } catch (_) {
    } finally {
      _isProcessing = false;
    }
  }

  InputImage? _buildInputImage(CameraImage image) {
    final camera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );
    final rotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    if (rotation == null) return null;
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();
    return InputImage.fromBytes(
      bytes: bytes,
      inputImageData: InputImageData(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        imageRotation: rotation,
        inputImageFormat: format,
        planeData: image.planes.map((Plane plane) {
          return InputImagePlaneMetadata(
            bytesPerRow: plane.bytesPerRow,
            height: plane.height,
            width: plane.width,
          );
        }).toList(),
      ),
    );
  }

  Future<void> _startScan() async {
    if (_currentPose == null) {
      setState(() => _statusMessage = 'No pose detected — step back and face the camera');
      return;
    }
    setState(() {
      _isScanning = true;
      _scanCountdown = 3;
      _statusMessage = 'Hold still...';
    });
    for (int i = 3; i >= 1; i--) {
      setState(() => _scanCountdown = i);
      await Future.delayed(const Duration(seconds: 1));
    }
    final pose = _currentPose!;
    final result = PoseAnalyzer.analyze(pose);
    await HistoryService.save(result);
    setState(() {
      _isScanning = false;
      _statusMessage = 'Stand back so your full body is visible';
    });
    if (mounted) {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => ResultsScreen(result: result),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _camera?.dispose();
    _detector?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_permissionGranted) return _buildPermissionPrompt();
    if (_camera == null || !_camera!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Color(0xFF080B14),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF00F5C4))),
      );
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_camera!),
          if (_currentPose != null)
            CustomPaint(
              painter: PosePainter(
                pose: _currentPose!,
                imageSize: Size(
                  _camera!.value.previewSize!.height,
                  _camera!.value.previewSize!.width,
                ),
              ),
            ),
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('FORMFIX',
                    style: TextStyle(
                      fontFamily: 'Courier', fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF00F5C4), letterSpacing: 4,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _currentPose != null
                          ? const Color(0xFF00F5C4).withOpacity(0.15)
                          : Colors.red.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _currentPose != null ? const Color(0xFF00F5C4) : Colors.red,
                      ),
                    ),
                    child: Text(
                      _currentPose != null ? '● POSE LOCKED' : '○ SEARCHING',
                      style: TextStyle(
                        fontSize: 10, letterSpacing: 2,
                        color: _currentPose != null ? const Color(0xFF00F5C4) : Colors.red,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isScanning)
            Container(
              color: Colors.black54,
              child: Center(
                child: Text('$_scanCountdown',
                  style: const TextStyle(
                    fontFamily: 'Courier', fontSize: 120,
                    fontWeight: FontWeight.w900, color: Color(0xFF00F5C4),
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 48),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_statusMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _isScanning ? null : _startScan,
                    child: Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _currentPose != null
                              ? const Color(0xFF00F5C4) : Colors.white30,
                          width: 3,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 56, height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentPose != null
                                ? const Color(0xFF00F5C4) : Colors.white24,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('TAP TO SCAN',
                    style: TextStyle(fontSize: 10, letterSpacing: 3, color: Colors.white54),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionPrompt() {
    return Scaffold(
      backgroundColor: const Color(0xFF080B14),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera_alt_outlined, color: Color(0xFF00F5C4), size: 60),
              const SizedBox(height: 24),
              const Text('Camera Access Required',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 12),
              const Text(
                'FormFix uses your camera for on-device pose detection. No video is recorded or uploaded.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60, height: 1.5),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _requestPermissionAndInit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00F5C4),
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('GRANT ACCESS',
                  style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
