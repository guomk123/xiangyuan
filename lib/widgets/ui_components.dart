import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final bool isFullWidth;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.borderRadius,
    this.padding,
    this.textStyle,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
      decoration: BoxDecoration(
        gradient: AppTheme.brandGradient,
        borderRadius: BorderRadius.circular(borderRadius ?? 16),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandGlow,
            blurRadius: 25,
            offset: const Offset(0, 0),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: textStyle ??
                const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );

    if (onPressed != null) {
      return InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onPressed!();
        },
        borderRadius: BorderRadius.circular(borderRadius ?? 16),
        child: content,
      );
    }
    return content;
  }
}

class ProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final List<Color>? gradientColors;
  final Color? backgroundColor;

  const ProgressBar({
    super.key,
    required this.progress,
    this.height = 10,
    this.gradientColors,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(height),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: constraints.maxWidth * clampedProgress,
              height: height - 4,
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                gradient: gradientColors != null
                    ? LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: gradientColors!,
                      )
                    : AppTheme.brandGradient,
                borderRadius: BorderRadius.circular(height),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CircularProgress extends StatelessWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final Color? progressColor;
  final Color? backgroundColor;
  final Widget? center;

  const CircularProgress({
    super.key,
    required this.progress,
    this.size = 64,
    this.strokeWidth = 6,
    this.progressColor,
    this.backgroundColor,
    this.center,
  });

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CircularProgressPainter(
          progress: clampedProgress,
          strokeWidth: strokeWidth,
          progressColor: progressColor ?? AppColors.brand500,
          backgroundColor: backgroundColor ?? Colors.white.withOpacity(0.1),
        ),
        child: Center(child: center),
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color progressColor;
  final Color backgroundColor;

  _CircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.progressColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * 3.141592653589793 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.141592653589793 / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}
