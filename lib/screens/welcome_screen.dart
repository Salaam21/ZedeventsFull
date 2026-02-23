import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'auth_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late AnimationController _carouselController;
  late Animation<double> _pulse;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _carouselController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _carouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background
          _AnimatedGradientBackground(),
          // Floating orbs
          ...List.generate(5, (i) => _FloatingOrb(delay: i * 0.2)),
          // Main content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 32),
                // Logo with pulse
                SlideTransition(
                  position: _slideUp,
                  child: ScaleTransition(
                    scale: _pulse,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.25),
                            blurRadius: 24,
                            spreadRadius: 2,
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                        color: Colors.white,
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/app_icon.png',
                          width: 140,
                          height: 140,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.auto_awesome,
                            size: 64,
                            color: Color(0xFF6C2BD9),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                SlideTransition(
                  position: _slideUp,
                  child: Column(
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [Colors.white, Colors.white.withValues(alpha: 0.9)],
                        ).createShader(bounds),
                        child: const Text(
                          'ZedEvents',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Discover events. Watch reels. Get tickets.',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withValues(alpha: 0.85),
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),
                // Feature carousel with auto-scroll and "Reels" highlight
                Expanded(
                  child: SlideTransition(
                    position: _slideUp,
                    child: _FeatureCarousel(animation: _carouselController),
                  ),
                ),
                const SizedBox(height: 24),
                // Get Started button
                SlideTransition(
                  position: _slideUp,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, a, __) => const AuthScreen(),
                              transitionsBuilder: (_, a, __, child) {
                                return FadeTransition(
                                  opacity: CurvedAnimation(
                                    parent: a,
                                    curve: Curves.easeOut,
                                  ),
                                  child: child,
                                );
                              },
                              transitionDuration: const Duration(milliseconds: 400),
                            ),
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF6C2BD9),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: const Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Looping gradient that shifts over time.
class _AnimatedGradientBackground extends StatefulWidget {
  @override
  State<_AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<_AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(
                math.cos(_animation.value * 2 * math.pi),
                math.sin(_animation.value * 2 * math.pi),
              ),
              end: Alignment(
                -math.cos(_animation.value * 2 * math.pi),
                -math.sin(_animation.value * 2 * math.pi),
              ),
              colors: [
                const Color(0xFF5B21B6),
                const Color(0xFF7C3AED),
                const Color(0xFF6D28D9),
                const Color(0xFF5B21B6),
              ],
              stops: const [0.0, 0.35, 0.7, 1.0],
            ),
          ),
        );
      },
    );
  }
}

class _FloatingOrb extends StatefulWidget {
  final double delay;

  const _FloatingOrb({required this.delay});

  @override
  State<_FloatingOrb> createState() => _FloatingOrbState();
}

class _FloatingOrbState extends State<_FloatingOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 2500 + (widget.delay * 1000).round()),
      vsync: this,
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final positions = [
      Offset(size.width * 0.1, size.height * 0.15),
      Offset(size.width * 0.85, size.height * 0.22),
      Offset(size.width * 0.15, size.height * 0.7),
      Offset(size.width * 0.8, size.height * 0.65),
      Offset(size.width * 0.5, size.height * 0.35),
    ];
    final index = (widget.delay * 5).round() % 5;
    final base = positions[index.clamp(0, 4)];
    final radius = 40.0 + widget.delay * 20;

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        final dy = 12 * math.sin(_anim.value * 2 * math.pi);
        return Positioned(
          left: base.dx - radius,
          top: base.dy - radius + dy,
          child: Container(
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(
                alpha: 0.06 + widget.delay * 0.04,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Auto-advancing carousel that highlights Reels (driven by animation).
class _FeatureCarousel extends StatelessWidget {
  final Animation<double> animation;

  const _FeatureCarousel({required this.animation});

  static const _cards = [
    _FeatureCard(
      icon: Icons.explore,
      title: 'Explore events',
      subtitle: 'Festivals, sports, meetups & more',
      isReels: false,
    ),
    _FeatureCard(
      icon: Icons.video_library_rounded,
      title: 'Reels',
      subtitle: 'Short clips from events — tap Reels in the app',
      isReels: true,
    ),
    _FeatureCard(
      icon: Icons.confirmation_number_outlined,
      title: 'Get tickets',
      subtitle: 'Pay with MoMo or card, instantly',
      isReels: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = (animation.value * 3) % 3.0;
        final index = t.floor().clamp(0, 2);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 120,
              child: Stack(
                children: [
                  for (int i = 0; i < 3; i++)
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 400),
                      opacity: i == index ? 1.0 : 0.0,
                      child: _cards[i],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                final active = i == index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isReels;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isReels = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isReels
                ? Colors.white.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.2),
            width: isReels ? 2 : 1,
          ),
          color: Colors.white.withValues(alpha: isReels ? 0.18 : 0.1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
