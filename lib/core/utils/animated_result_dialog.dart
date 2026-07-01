import 'package:flutter/material.dart';
import 'dart:math' as math;

void showAnimatedResultDialog({
  required BuildContext context,
  required bool isSuccess,
  required String message,
  required VoidCallback onNext,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: "Result",
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const SizedBox.shrink(); // Not used
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curve = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack, // Gives a nice bounce effect
      );
      
      return ScaleTransition(
        scale: curve,
        child: FadeTransition(
          opacity: animation,
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: _AnimatedResultContent(
              isSuccess: isSuccess,
              message: message,
              onNext: onNext,
            ),
          ),
        ),
      );
    },
  );
}

class _AnimatedResultContent extends StatefulWidget {
  final bool isSuccess;
  final String message;
  final VoidCallback onNext;

  const _AnimatedResultContent({
    required this.isSuccess,
    required this.message,
    required this.onNext,
  });

  @override
  State<_AnimatedResultContent> createState() => _AnimatedResultContentState();
}

class _AnimatedResultContentState extends State<_AnimatedResultContent>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Pulse animation for success (Dopamine effect)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _pulseAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.2), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 1.2, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    // Shake animation for failure (Penalty effect)
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _shakeAnimation = Tween<double>(begin: 0.0, end: 24.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    if (widget.isSuccess) {
      _pulseController.repeat();
    } else {
      _shakeController.forward().then((_) {
        _pulseController.repeat(reverse: true); // subtle pulse after shake
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isSuccess ? const Color(0xFF4CAF50) : const Color(0xFFF44336);
    final lightColor = widget.isSuccess ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);
    final icon = widget.isSuccess ? Icons.star_rounded : Icons.close_rounded;
    final title = widget.isSuccess ? 'Luar Biasa!' : 'Aduh, Salah!';

    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _shakeController]),
      builder: (context, child) {
        // Calculate shake offset
        double shakeOffset = 0;
        if (!widget.isSuccess && _shakeController.isAnimating) {
          shakeOffset = math.sin(_shakeController.value * math.pi * 4) * 10;
        }

        return Transform.translate(
          offset: Offset(shakeOffset, 0),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 30,
                  spreadRadius: widget.isSuccess ? (_pulseAnimation.value * 10) : 5,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated Icon with Glow
                Transform.scale(
                  scale: widget.isSuccess ? _pulseAnimation.value : 1.0,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: lightColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 60,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Title
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: color,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Message
                Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onNext();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      shadowColor: color.withOpacity(0.5),
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      widget.isSuccess ? 'Lanjut' : 'Coba Lagi',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
