import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final Color? borderColor;
  final List<Color>? gradientColors;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.borderColor,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradientColors != null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors!,
              )
            : null,
        color: gradientColors == null
            ? AppColors.darkCard.withOpacity(0.75)
            : null,
        borderRadius: BorderRadius.circular(borderRadius ?? 24),
        border: Border.all(
          color: borderColor ?? Colors.white.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.37),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final VoidCallback? onTap;
  final Color? leftBorderColor;
  final double? leftBorderWidth;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.onTap,
    this.leftBorderColor,
    this.leftBorderWidth,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.07),
            Colors.white.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(borderRadius ?? 16),
        border: leftBorderColor != null
            ? Border(
                left: BorderSide(
                  color: leftBorderColor!,
                  width: leftBorderWidth ?? 4,
                ),
                top: BorderSide(
                  color: Colors.white.withOpacity(0.08),
                  width: 1,
                ),
                right: BorderSide(
                  color: Colors.white.withOpacity(0.08),
                  width: 1,
                ),
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.08),
                  width: 1,
                ),
              )
            : Border.all(
                color: Colors.white.withOpacity(0.08),
                width: 1,
              ),
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap!();
        },
        borderRadius: BorderRadius.circular(borderRadius ?? 16),
        child: card,
      );
    }
    return card;
  }
}
