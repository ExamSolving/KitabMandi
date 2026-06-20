import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class FullScreenImageView extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const FullScreenImageView({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<FullScreenImageView> createState() => _FullScreenImageViewState();
}

class _FullScreenImageViewState extends State<FullScreenImageView> {
  late int _current;
  late PageController _pageCtrl;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _pageCtrl = PageController(initialPage: _current);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final topPad = MediaQuery.of(context).padding.top;
    final total = widget.images.length;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // ── Zoomable swipeable gallery ─────────────────────────────
            PhotoViewGallery.builder(
              pageController: _pageCtrl,
              itemCount: total,
              onPageChanged: (i) => setState(() => _current = i),
              builder: (_, i) => PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(widget.images[i]),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2.5,
                heroAttributes:
                    PhotoViewHeroAttributes(tag: widget.images[i]),
              ),
              backgroundDecoration:
                  const BoxDecoration(color: Colors.black),
              loadingBuilder: (context2, event) => const Center(
                child: CircularProgressIndicator(
                    color: Colors.white54, strokeWidth: 1.5),
              ),
            ),

            // ── Close button (floating, top-left) ─────────────────────
            Positioned(
              top: topPad + 8,
              left: 12,
              child: GestureDetector(
                onTap: Get.back,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: const Icon(Icons.close_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
            ),

            // ── Counter pill (top-right) ───────────────────────────────
            if (total > 1)
              Positioned(
                top: topPad + 8,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: Text(
                    '${_current + 1} / $total',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

            // ── Dot indicators (bottom) ────────────────────────────────
            if (total > 1)
              Positioned(
                bottom: bottomPad + 20,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(total, (i) {
                    final active = _current == i;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: 5,
                      width: active ? 22 : 5,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: active
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.35),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
