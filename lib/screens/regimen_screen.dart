import 'package:flutter/material.dart';
import 'dart:ui';
import '../services/history_service.dart';
import '../services/pose_analyzer.dart';

class RegimenScreen extends StatefulWidget {
  const RegimenScreen({super.key});
  @override
  State<RegimenScreen> createState() => _RegimenScreenState();
}

class _RegimenScreenState extends State<RegimenScreen> {
  List<ScanResult> _history = [];
  bool _loading = true;

  static const List<_RegimenExercise> _baseline = [
    _RegimenExercise('Plank', '3 × 45 sec', 'Core', Icons.fitness_center),
    _RegimenExercise('Dead Bug', '3 × 10 each', 'Core Stability', Icons.fitness_center),
    _RegimenExercise('Cat-Cow Stretch', '2 × 10 reps', 'Mobility', Icons.self_improvement),
    _RegimenExercise('World Greatest Stretch', '2 × 5 each', 'Full Body', Icons.accessibility_new),
    _RegimenExercise('Hip 90/90 Stretch', '3 × 45 sec each', 'Hip Mobility', Icons.airline_seat_flat),
  ];

  static const Map<String, List<_RegimenExercise>> _corrective = {
    'SHOULDER IMBALANCE': [
      _RegimenExercise('Unilateral DB Row', '3 × 10 each', 'Pull', Icons.fitness_center),
      _RegimenExercise('Side-Lying External Rotation', '3 × 15 each', 'Corrective', Icons.rotate_right),
      _RegimenExercise('Doorway Chest Stretch', '3 × 30 sec', 'Mobility', Icons.self_improvement),
      _RegimenExercise('Face Pull', '3 × 15', 'Rear Chain', Icons.fitness_center),
    ],
    'HIP ALIGNMENT': [
      _RegimenExercise('Glute Bridge', '3 × 12', 'Glutes', Icons.airline_seat_flat),
      _RegimenExercise('Lateral Band Walk', '3 × 20 steps', 'Abductors', Icons.directions_walk),
      _RegimenExercise('Hip Flexor Lunge Stretch', '3 × 45 sec', 'Mobility', Icons.self_improvement),
      _RegimenExercise('Single-Leg RDL', '3 × 8 each', 'Stability', Icons.balance),
    ],
    'FORWARD HEAD POSTURE': [
      _RegimenExercise('Chin Tuck', '3 × 10 × 5 sec', 'Corrective', Icons.face),
      _RegimenExercise('Neck Flexor Stretch', '3 × 30 sec', 'Mobility', Icons.self_improvement),
      _RegimenExercise('Face Pull', '3 × 15', 'Rear Chain', Icons.fitness_center),
      _RegimenExercise('Thoracic Extension', '2 min daily', 'Mobility', Icons.airline_seat_flat),
    ],
    'KNEE VALGUS': [
      _RegimenExercise('Clamshells', '3 × 15 each', 'Glute Med', Icons.fitness_center),
      _RegimenExercise('Single-Leg Squat', '3 × 8 each', 'Alignment', Icons.accessibility_new),
      _RegimenExercise('VMO Squat', '3 × 12', 'Inner Quad', Icons.fitness_center),
    ],
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final results = await HistoryService.load();
    setState(() {
      _history = results;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080B14),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF00F5C4)))
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('REGIMEN',
                            style: TextStyle(
                              fontFamily: 'Courier', fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF00F5C4), letterSpacing: 4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _history.isEmpty
                                ? 'Complete a scan to personalize your plan'
                                : 'Based on your ${_history.length} scan${_history.length == 1 ? "" : "s"}',
                            style: const TextStyle(color: Color(0xFF3D4663), fontSize: 13),
                          ),
                          const SizedBox(height: 28),
                          const Text('DAILY FOUNDATION',
                            style: TextStyle(fontSize: 11, letterSpacing: 3, color: Color(0xFF7B61FF), fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          const Text('Every session — regardless of scan results',
                            style: TextStyle(color: Color(0xFF3D4663), fontSize: 12),
                          ),
                          const SizedBox(height: 12),
                          _RegimenModule(exercises: _baseline, accentColor: const Color(0xFF7B61FF)),
                          const SizedBox(height: 28),
                          const Text('CORRECTIVE PROTOCOL',
                            style: TextStyle(fontSize: 11, letterSpacing: 3, color: Color(0xFF00F5C4), fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          const Text('Targeted based on detected issues',
                            style: TextStyle(color: Color(0xFF3D4663), fontSize: 12),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final entry = _corrective.entries.toList()[i];
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(entry.key,
                                style: const TextStyle(fontSize: 10, letterSpacing: 2.5, color: Color(0xFF00F5C4), fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 8),
                              _RegimenModule(exercises: entry.value, accentColor: const Color(0xFF00F5C4)),
                            ],
                          ),
                        );
                      },
                      childCount: _corrective.length,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
                ],
              ),
      ),
    );
  }
}

class _RegimenModule extends StatelessWidget {
  final List<_RegimenExercise> exercises;
  final Color accentColor;
  const _RegimenModule({required this.exercises, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F1525).withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1A2035)),
          ),
          child: Column(
            children: exercises.asMap().entries.map((e) {
              final isLast = e.key == exercises.length - 1;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(e.value.icon, color: accentColor, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(e.value.name,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                              const SizedBox(height: 2),
                              Text(e.value.category,
                                style: const TextStyle(color: Color(0xFF3D4663), fontSize: 11, letterSpacing: 1),
                              ),
                            ],
                          ),
                        ),
                        Text(e.value.prescription,
                          style: TextStyle(fontFamily: 'Courier', color: accentColor, fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    const Divider(height: 1, thickness: 1, color: Color(0xFF1A2035), indent: 70),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _RegimenExercise {
  final String name;
  final String prescription;
  final String category;
  final IconData icon;
  const _RegimenExercise(this.name, this.prescription, this.category, this.icon);
}
