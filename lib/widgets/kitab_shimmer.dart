import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Shared shimmer utility — wraps [Shimmer.fromColors] with automatic
/// dark/light colour selection. Use [KitabShimmer.box] for individual
/// placeholder boxes, or [KitabShimmer.wrap] to shimmer any child tree.
class KitabShimmer extends StatelessWidget {
  const KitabShimmer({super.key, required this.child});

  final Widget child;

  static Color _base(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? const Color(0xFF2A2D35)
          : Colors.grey.shade300;

  static Color _highlight(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? const Color(0xFF3A3D48)
          : Colors.grey.shade100;

  /// Wraps [child] in a shimmer animation.
  static Widget wrap({required BuildContext context, required Widget child}) =>
      Shimmer.fromColors(
        baseColor: _base(context),
        highlightColor: _highlight(context),
        child: child,
      );

  /// A single rectangular shimmer placeholder.
  static Widget box({
    required BuildContext context,
    required double width,
    required double height,
    double radius = 10,
    Color? color,
  }) {
    final fill = color ??
        (Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E2128)
            : Colors.white);

    return Shimmer.fromColors(
      baseColor: _base(context),
      highlightColor: _highlight(context),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  /// A circle shimmer placeholder (for avatars).
  static Widget circle({
    required BuildContext context,
    required double size,
    Color? color,
  }) {
    final fill = color ??
        (Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E2128)
            : Colors.white);

    return Shimmer.fromColors(
      baseColor: _base(context),
      highlightColor: _highlight(context),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) =>
      Shimmer.fromColors(
        baseColor: _base(context),
        highlightColor: _highlight(context),
        child: child,
      );
}
