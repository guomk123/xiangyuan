import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onTap;
  final VoidCallback? onTrailingTap;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.icon,
    this.iconColor,
    this.onTap,
    this.onTrailingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap != null
              ? () {
                  HapticFeedback.selectionClick();
                  onTap!();
                }
              : null,
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: iconColor ?? AppColors.brand400,
                  size: 16,
                ),
                const SizedBox(width: 8),
              ],
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        if (trailing != null)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTrailingTap != null
                ? () {
                    HapticFeedback.selectionClick();
                    onTrailingTap!();
                  }
                : null,
            child: trailing,
          ),
      ],
    );
  }
}

class BadgeTag extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? fontSize;

  const BadgeTag({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.brand500.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: borderColor ?? AppColors.brand500.withOpacity(0.3),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor ?? AppColors.brand300,
          fontSize: fontSize ?? 9,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class StatsTile extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final String? trend;
  final Color? trendColor;
  final IconData? trendIcon;
  final Color? accentColor;
  final IconData? leadingIcon;
  final VoidCallback? onTap;

  const StatsTile({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.trend,
    this.trendColor,
    this.trendIcon,
    this.accentColor,
    this.leadingIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color accent = accentColor ?? AppColors.brand500;
    final child = Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withOpacity(0.08),
            Colors.white.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accent.withOpacity(0.22),
          width: 1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: accent.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: accent.withOpacity(0.32),
                  ),
                ),
                child: Icon(
                  leadingIcon ?? trendIcon ?? Icons.insights,
                  color: accent,
                  size: 14,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.88),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                    shadows: <Shadow>[
                      Shadow(
                        color: accent.withOpacity(0.45),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 3),
                Text(
                  unit!,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
          if (trend != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (trendIcon != null) ...[
                    Icon(
                      trendIcon,
                      color: trendColor ?? accent,
                      size: 11,
                    ),
                    const SizedBox(width: 4),
                  ],
                  Flexible(
                    child: Text(
                      trend!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: trendColor ?? accent,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
    if (onTap == null) return child;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap!();
      },
      child: child,
    );
  }
}

class NetworkImagePlaceholder extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxFit? fit;

  const NetworkImagePlaceholder({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.borderRadius = 12,
    this.fit,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.network(
        url,
        width: width,
        height: height,
        fit: fit ?? BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: AppColors.darkSurface,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(AppColors.brand400),
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: AppColors.darkSurface,
            child: Icon(
              Icons.broken_image,
              color: AppColors.textTertiary,
              size: 24,
            ),
          );
        },
      ),
    );
  }
}
