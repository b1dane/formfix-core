import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'screens/splash_screen.dart';

late List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  cameras = await availableCameras();

  runApp(const FormFixApp());
}

class FormFixApp extends StatelessWidget {
  const FormFixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FormFix',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF080B14),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00F5C4),
          secondary: Color(0xFF7B61FF),
          surface: Color(0xFF0F1525),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}