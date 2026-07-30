import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_widgets.dart';

class GenericDetailPage extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final Color? accentColor;
  final Widget child;

  const GenericDetailPage({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.accentColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final themeAccent = accentColor ?? AppColors.brand400;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.darkBase,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 12),
          child: SafeArea(
            top: true,
            child: AppBar(
              backgroundColor: AppColors.darkBase,
              elevation: 0,
              scrolledUnderElevation: 0,
              toolbarHeight: kToolbarHeight + 6,
              leading: IconButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  Navigator.of(context).pop();
                },
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.chevron_left,
                    color: AppColors.textSecondary,
                    size: 22,
                  ),
                ),
              ),
              title: Column(
                children: [
                  if (leadingIcon != null) ...[
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: themeAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        leadingIcon,
                        color: themeAccent,
                        size: 14,
                      ),
                    ),
                    const SizedBox(height: 3),
                  ],
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
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
              centerTitle: true,
              actions: const [],
            ),
          ),
        ),
        body: SafeArea(
          top: false,
          bottom: true,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: child,
          ),
        ),
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  final String title;
  final String? description;
  final Widget child;
  final IconData? icon;
  final Color? accentColor;
  final Color? iconColor;

  const SectionCard({
    super.key,
    required this.title,
    this.description,
    required this.child,
    this.icon,
    this.accentColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color themeAccent = accentColor ?? iconColor ?? AppColors.brand400;
    final Color themeIconColor = iconColor ?? accentColor ?? AppColors.brand400;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null || title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Row(
              children: [
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: themeAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: themeAccent.withOpacity(0.3),
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: themeIconColor,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Column(
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
                      if (description != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          description!,
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        GlassPanel(
          padding: const EdgeInsets.all(14),
          child: child,
        ),
      ],
    );
  }
}

class InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;
  final Color? valueColor;
  final IconData? trailingIcon;
  final VoidCallback? onTap;

  const InfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
    this.valueColor,
    this.trailingIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeIconColor = iconColor ?? AppColors.brand400;
    final content = Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: themeIconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: themeIconColor.withOpacity(0.25),
              ),
            ),
            child: Icon(
              icon,
              color: themeIconColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor ?? Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (trailingIcon != null)
            Icon(
              trailingIcon,
              color: AppColors.textTertiary,
              size: 18,
            ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          onTap!();
        },
        child: content,
      );
    }
    return content;
  }
}

class DividerGap extends StatelessWidget {
  final double height;

  const DividerGap({
    super.key,
    this.height = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: height),
        Divider(
          height: 0.5,
          thickness: 0.5,
          color: Colors.white.withOpacity(0.08),
        ),
        SizedBox(height: height),
      ],
    );
  }
}
