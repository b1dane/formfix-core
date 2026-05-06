import 'package:flutter/material.dart';
import 'dart:ui';
import '../services/pose_analyzer.dart';

class ResultsScreen extends StatefulWidget {
  final ScanResult result;
  const ResultsScreen({super.key, required this.result});
  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scoreAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scoreAnim = Tween<double>(begin: 0, end: widget.result.score.toDouble())
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080B14),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFF080B14),
            foregroundColor: const Color(0xFF00F5C4),
            pinned: true,
            title: const Text('SCAN RESULTS',
              style: TextStyle(
                fontFamily: 'Courier', fontSize: 16,
                letterSpacing: 4, fontWeight: FontWeight.w900,
                color: Color(0xFF00F5C4),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('DONE',
                  style: TextStyle(color: Color(0xFF7B61FF), letterSpacing: 2, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _GlassCard(
                    child: Column(
                      children: [
                        AnimatedBuilder(
                          animation: _scoreAnim,
                          builder: (_, __) => Text(
                            '${_scoreAnim.value.toInt()}',
                            style: TextStyle(
                              fontFamily: 'Courier', fontSize: 96,
                              fontWeight: FontWeight.w900,
                              color: widget.result.gradeColor, height: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(widget.result.grade,
                          style: TextStyle(
                            fontSize: 13, letterSpacing: 4,
                            fontWeight: FontWeight.w700,
                            color: widget.result.gradeColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: AnimatedBuilder(
                            animation: _scoreAnim,
                            builder: (_, __) => LinearProgressIndicator(
                              value: _scoreAnim.value / 100,
                              minHeight: 6,
                              backgroundColor: const Color(0xFF1A2035),
                              valueColor: AlwaysStoppedAnimation(widget.result.gradeColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (widget.result.issues.isEmpty)
                    _GlassCard(
                      borderColor: const Color(0xFF00F5C4),
                      child: Row(
                        children: const [
                          Icon(Icons.check_circle_outline, color: Color(0xFF00F5C4), size: 28),
                          SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'No significant postural issues detected.',
                              style: TextStyle(color: Colors.white70, height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    const Text('FINDINGS',
                      style: TextStyle(fontSize: 11, letterSpacing: 3, color: Color(0xFF3D4663), fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    ...widget.result.issues.map((issue) => _IssueCard(issue: issue)),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IssueCard extends StatefulWidget {
  final PostureIssue issue;
  const _IssueCard({required this.issue});
  @override
  State<_IssueCard> createState() => _IssueCardState();
}

class _IssueCardState extends State<_IssueCard> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _GlassCard(
        borderColor: widget.issue.severityColor.withOpacity(0.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Row(
                children: [
                  Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: widget.issue.severityColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(widget.issue.area,
                      style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 15),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: widget.issue.severityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: widget.issue.severityColor.withOpacity(0.4)),
                    ),
                    child: Text(widget.issue.severityLabel,
                      style: TextStyle(fontSize: 9, letterSpacing: 1.5, color: widget.issue.severityColor, fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: const Color(0xFF3D4663), size: 20),
                ],
              ),
            ),
            if (_expanded) ...[
              const SizedBox(height: 12),
              Text(widget.issue.detail,
                style: const TextStyle(color: Color(0xFF8899BB), fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 16),
              const Text('CORRECTIVE EXERCISES',
                style: TextStyle(fontSize: 10, letterSpacing: 3, color: Color(0xFF7B61FF), fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              ...widget.issue.exercises.map((ex) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('▸ ', style: TextStyle(color: Color(0xFF00F5C4))),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(ex.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                              Text(ex.prescription, style: const TextStyle(color: Color(0xFF00F5C4), fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'Courier')),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(ex.rationale, style: const TextStyle(color: Color(0xFF5566AA), fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final Color? borderColor;
  const _GlassCard({required this.child, this.borderColor});
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1525).withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor ?? const Color(0xFF1A2035)),
          ),
          child: child,
        ),
      ),
    );
  }
}
