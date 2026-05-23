import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';
import 'package:kitab_mandi/features/splash/controller/splash_controller.dart';

class SplashView extends StatelessWidget {
  SplashView({super.key});

  final controller = Get.find<SplashController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryDark,
              AppColors.primary,
              AppColors.secondaryDark, // orange touch for premium look
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// 🔝 Top Spacer
              const SizedBox(height: 40),

              ///  Center Content
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /// Animated Logo Section
                    FadeTransition(
                      opacity: controller.fadeAnimation,
                      child: ScaleTransition(
                        scale: controller.scaleAnimation,
                        child: Column(
                          children: [
                            ///  Use your logo here
                            Image.asset(
                              "assets/splash.png", // <-- replace with your path
                              height: 200,
                            ),

                            const SizedBox(height: 20),

                            /// App Name
                            const AnimatedGradientText(text: "KitabMandi"),

                            const SizedBox(height: 10),

                            /// Tagline
                            const Text(
                              "Buy • Sell • Save • Learn",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white70,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 60),

                    ///  Loading Indicator (styled)
                    const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              ///  Bottom Branding (Premium Touch)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  children: const [
                    Text(
                      "Smart marketplace for used books",
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),

                    SizedBox(height: 8),

                    Text(
                      "© 2026 KitabMandi",
                      style: TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedGradientText extends StatefulWidget {
  final String text;

  const AnimatedGradientText({super.key, required this.text});

  @override
  State<AnimatedGradientText> createState() => _AnimatedGradientTextState();
}

class _AnimatedGradientTextState extends State<AnimatedGradientText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: const [
                Color(0xFFFF7A00), // orange
                Color(0xFF43A047), // green
                Color(0xFF1B5E20), // deep green
              ],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              tileMode: TileMode.mirror,
            ).createShader(bounds);
          },
          child: Text(
            widget.text,
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        );
      },
    );
  }
}
