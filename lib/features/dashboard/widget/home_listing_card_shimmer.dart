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

  /// 🔥 SHIMMER BOX
  Widget shimmerBox({
    required double height,
    required double width,
    BorderRadius? radius,
  }) {
    final theme = Theme.of(context);

    final baseColor = theme.brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.grey.shade300;

    final highlightColor = theme.brightness == Brightness.dark
        ? Colors.grey.shade700
        : Colors.grey.shade100;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            borderRadius: radius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment(-1, -0.3),
              end: Alignment(1, 0.3),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// IMAGE SHIMMER
          shimmerBox(
            height: 130,
            width: double.infinity,
            radius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),

          /// DETAILS SHIMMER
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                shimmerBox(height: 14, width: 60),

                const SizedBox(height: 8),

                shimmerBox(height: 12, width: double.infinity),
                const SizedBox(height: 4),
                shimmerBox(height: 12, width: 120),

                const SizedBox(height: 10),

                /// SELLER
                Row(
                  children: [
                    shimmerBox(
                      height: 20,
                      width: 20,
                      radius: BorderRadius.circular(20),
                    ),
                    const SizedBox(width: 6),
                    shimmerBox(height: 10, width: 100),
                  ],
                ),

                const SizedBox(height: 10),

                /// LOCATION + TIME
                Row(
                  children: [
                    shimmerBox(height: 10, width: 80),
                    const SizedBox(width: 6),
                    shimmerBox(height: 10, width: 40),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
