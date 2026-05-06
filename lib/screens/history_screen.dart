import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import '../services/history_service.dart';
import '../services/pose_analyzer.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<ScanResult> _history = [];
  bool _loading = true;

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
                          const Text('PROGRESS',
                            style: TextStyle(
                              fontFamily: 'Courier', fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF00F5C4), letterSpacing: 4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('${_history.length} scans recorded',
                            style: const TextStyle(color: Color(0xFF3D4663), fontSize: 13, letterSpacing: 1),
                          ),
                          const SizedBox(height: 24),
                          if (_history.length >= 2) ...[
                            _buildChart(),
                            const SizedBox(height: 24),
                          ],
                          if (_history.isEmpty)
                            _buildEmptyState()
                          else ...[
                            const Text('SCAN LOG',
                              style: TextStyle(fontSize: 11, letterSpacing: 3, color: Color(0xFF3D4663), fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ],
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                        child: _ScanLogItem(result: _history[i], index: i),
                      ),
                      childCount: _history.length,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
      ),
    );
  }

  Widget _buildChart() {
    final spots = _history.reversed.toList().asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.score.toDouble());
    }).toList();
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          height: 180,
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1525).withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1A2035)),
          ),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 25,
                getDrawingHorizontalLine: (_) => FlLine(color: const Color(0xFF1A2035), strokeWidth: 1),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 25,
                    reservedSize: 32,
                    getTitlesWidget: (v, _) => Text('${v.toInt()}',
                      style: const TextStyle(color: Color(0xFF3D4663), fontSize: 10)),
                  ),
                ),
                bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              minY: 0,
              maxY: 100,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: const Color(0xFF00F5C4),
                  barWidth: 2,
                  dotData: FlDotData(
                    getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                      radius: 3,
                      color: const Color(0xFF00F5C4),
                      strokeWidth: 0,
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF00F5C4).withOpacity(0.2),
                        const Color(0xFF00F5C4).withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: const [
            Icon(Icons.bar_chart_outlined, color: Color(0xFF1A2035), size: 64),
            SizedBox(height: 16),
            Text('No scans yet',
              style: TextStyle(color: Color(0xFF3D4663), fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text('Complete your first body scan\nto start tracking progress',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF2A3050), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanLogItem extends StatelessWidget {
  final ScanResult result;
  final int index;
  const _ScanLogItem({required this.result, required this.index});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1525).withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1A2035)),
          ),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: result.gradeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: result.gradeColor.withOpacity(0.3)),
                ),
                child: Center(
                  child: Text('${result.score}',
                    style: TextStyle(
                      fontFamily: 'Courier', fontWeight: FontWeight.w900,
                      color: result.gradeColor, fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(result.grade,
                      style: TextStyle(color: result.gradeColor, fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 1),
                    ),
                    const SizedBox(height: 2),
                    Text(_formatDate(result.scannedAt),
                      style: const TextStyle(color: Color(0xFF3D4663), fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text('#${index + 1}',
                style: const TextStyle(fontFamily: 'Courier', color: Color(0xFF2A3050), fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final h = dt.hour > 12 ? dt.hour - 12 : dt.hour == 0 ? 12 : dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}  $h:$m $ampm';
  }
}
