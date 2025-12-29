import 'package:flutter/material.dart';
import 'dart:math';

class FlyingMoneyOverlay extends StatefulWidget {
  const FlyingMoneyOverlay({super.key});

  @override
  State<FlyingMoneyOverlay> createState() => _FlyingMoneyOverlayState();
}

class _FlyingMoneyOverlayState extends State<FlyingMoneyOverlay>
    with TickerProviderStateMixin {
  final List<MoneyParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _generateParticles();
  }

  void _generateParticles() {
    for (int i = 0; i < 30; i++) {
      _particles.add(MoneyParticle(
        random: _random,
        vsync: this,
      ));
    }
  }

  @override
  void dispose() {
    for (var particle in _particles) {
      particle.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: _particles.map((particle) {
        return AnimatedBuilder(
          animation: particle.controller,
          builder: (context, child) {
            return Positioned(
              left: particle.x,
              top: particle.startY +
                  (MediaQuery.of(context).size.height * particle.controller.value),
              child: Transform.rotate(
                angle: particle.rotation * particle.controller.value * 4,
                child: Opacity(
                  opacity: 1.0 - particle.controller.value,
                  child: Text(
                    particle.symbol,
                    style: TextStyle(
                      fontSize: particle.size,
                      color: particle.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}

class MoneyParticle {
  late final AnimationController controller;
  late final double x;
  late final double startY;
  late final double size;
  late final String symbol;
  late final Color color;
  late final double rotation;

  MoneyParticle({
    required Random random,
    required TickerProvider vsync,
  }) {
    x = random.nextDouble() * 400;
    startY = -50;
    size = 20 + random.nextDouble() * 20;
    rotation = (random.nextDouble() - 0.5) * 6.28; // Random rotation in radians
    
    final symbols = ['💵', '💰', '💸', '💴', '💶', '💷', '🤑', '💲'];
    symbol = symbols[random.nextInt(symbols.length)];
    
    final colors = [
      Colors.green,
      Colors.amber,
      Colors.orange,
      Colors.teal,
    ];
    color = colors[random.nextInt(colors.length)];

    controller = AnimationController(
      vsync: vsync,
      duration: Duration(milliseconds: 9000),
    )..forward();
  }

  void dispose() {
    controller.dispose();
  }
}

class FlyingMoneyAnimation {
  static OverlayEntry? _overlayEntry;

  static void show(BuildContext context) {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => const FlyingMoneyOverlay(),
    );

    Overlay.of(context).insert(_overlayEntry!);

    // Auto-remove after animation
    Future.delayed(const Duration(milliseconds: 9000), () {
      remove();
    });
  }

  static void remove() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
