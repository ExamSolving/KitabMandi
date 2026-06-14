import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AppCachedImageNetwork extends StatelessWidget {
  final String imageUrl;
  final double? height;
  final double? width;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const AppCachedImageNetwork({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(0),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        height: height,
        width: width,
        fit: fit,

        /// 🔄 LOADING
        placeholder: (context, url) => _shimmer(context),

        /// ❌ ERROR
        errorWidget: (context, url, error) => _errorWidget(context),
      ),
    );
  }

  /// 🔥 SHIMMER EFFECT
  Widget _shimmer(BuildContext context) {
    final theme = Theme.of(context);

    final baseColor = theme.brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.grey.shade300;

    final highlightColor = theme.brightness == Brightness.dark
        ? Colors.grey.shade700
        : Colors.grey.shade100;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: -1, end: 2),
      duration: const Duration(milliseconds: 1200),
      builder: (context, value, child) {
        return Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: LinearGradient(
              begin: Alignment(-1, -0.3),
              end: Alignment(1, 0.3),
              colors: [baseColor, highlightColor, baseColor],
              stops: [
                (value - 0.3).clamp(0.0, 1.0),
                value.clamp(0.0, 1.0),
                (value + 0.3).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }

  /// ❌ ERROR UI
  Widget _errorWidget(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: borderRadius,
      ),
      child: Icon(
        Icons.broken_image_outlined,
        color: theme.hintColor,
        size: 40,
      ),
    );
  }
}
