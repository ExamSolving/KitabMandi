import 'package:flutter/material.dart';

class ListingGridCardShimmer extends StatefulWidget {
  const ListingGridCardShimmer({super.key});

  @override
  State<ListingGridCardShimmer> createState() => _ListingGridCardShimmerState();
}

class _ListingGridCardShimmerState extends State<ListingGridCardShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _animation = Tween<double>(begin: -1, end: 2).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _shimmerBox({
    required double height,
    double? width,
    BorderRadius? radius,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            borderRadius: radius ?? BorderRadius.circular(4),
            gradient: LinearGradient(
              begin: const Alignment(-1, -0.3),
              end: const Alignment(1, 0.3),
              colors: [baseColor, highlightColor, baseColor],
              stops: [
                (_animation.value - 0.3).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 0.3).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }

  // Icon-dot + text bar — mirrors _MetaRow in the real card
  Widget _metaRow({required double textWidth}) {
    return Row(
      children: [
        _shimmerBox(height: 12, width: 12, radius: BorderRadius.circular(12)),
        const SizedBox(width: 4),
        _shimmerBox(height: 11, width: textWidth),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1A1D23) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.07),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image area ──────────────────────────────────────────────────
          Stack(
            children: [
              _shimmerBox(
                height: 156,
                width: double.infinity,
                radius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              // Heart button (top-right) — mirrors Positioned(top:8, right:8)
              Positioned(
                top: 8,
                right: 8,
                child: _shimmerBox(
                  height: 31,
                  width: 31,
                  radius: BorderRadius.circular(16),
                ),
              ),
              // Views pill (bottom-left) — mirrors Positioned(bottom:9, left:9)
              Positioned(
                bottom: 9,
                left: 9,
                child: _shimmerBox(
                  height: 18,
                  width: 52,
                  radius: BorderRadius.circular(20),
                ),
              ),
              // Time pill (bottom-right) — mirrors Positioned(bottom:9, right:9)
              Positioned(
                bottom: 9,
                right: 9,
                child: _shimmerBox(
                  height: 18,
                  width: 38,
                  radius: BorderRadius.circular(20),
                ),
              ),
            ],
          ),

          // ── Details — padding matches card: fromLTRB(11, 8, 11, 8) ─────
          Padding(
            padding: const EdgeInsets.fromLTRB(11, 8, 11, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Price — fontSize 19, w800 in real card
                _shimmerBox(height: 22, width: 64),

                const SizedBox(height: 4),

                // Title line 1 (full width)
                _shimmerBox(height: 13, width: double.infinity),
                const SizedBox(height: 4),
                // Title line 2 (partial — second line of maxLines:2)
                _shimmerBox(height: 13, width: 100),

                const SizedBox(height: 7),

                // Location row
                _metaRow(textWidth: 90),
                const SizedBox(height: 3),

                // Distance row
                _metaRow(textWidth: 70),
                const SizedBox(height: 3),

                // Listed by row
                _metaRow(textWidth: 84),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
