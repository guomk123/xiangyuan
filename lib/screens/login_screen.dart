import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../settings_store.dart';
import 'settings_screen.dart' show SettingsStoreScope;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _logging = false;

  Future<void> _onStart() async {
    try {
      HapticFeedback.selectionClick();
    } catch (_) {}
    if (_logging || !mounted) return;
    setState(() => _logging = true);
    try {
      final SettingsStore store = SettingsStoreScope.of(context);
      await store.markLoggedIn();
      if (!mounted) return;
      setState(() => _logging = false);
    } catch (e) {
      if (mounted) setState(() => _logging = false);
      debugPrint('login start error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBase,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 56),
              _buildBrandLogo(),
              const SizedBox(height: 40),
              const Text(
                '欢迎使用',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '科学周计划 · 渐进过载 · 数据可视化\n让每一次训练都有迹可循',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
              const Spacer(),
              _buildFeatureRows(),
              const SizedBox(height: 40),
              _buildPrimaryButton(),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandLogo() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.brand400,
            AppColors.purple,
            AppColors.brand500,
          ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.brandGlow.withOpacity(0.35),
            blurRadius: 40,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(
        Icons.bolt,
        color: Colors.white,
        size: 40,
      ),
    );
  }

  Widget _buildFeatureRows() {
    final List<_Feature> features = <_Feature>[
      const _Feature(
        icon: Icons.fitness_center,
        title: '个性化训练计划',
        subtitle: '推 / 拉 / 腿 / 休 周节律',
      ),
      const _Feature(
        icon: Icons.show_chart,
        title: '训练容量追踪',
        subtitle: '渐进过载 · 8 周趋势',
      ),
      const _Feature(
        icon: Icons.restaurant,
        title: '饮食 & 体成分',
        subtitle: '热量 · 宏量 · BMI/BMR',
      ),
    ];
    return Column(
      children: <Widget>[
        for (int i = 0; i < features.length; i++) ...<Widget>[
          _FeatureRow(feature: features[i]),
          if (i != features.length - 1) const SizedBox(height: 18),
        ],
      ],
    );
  }

  Widget _buildPrimaryButton() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _logging ? null : _onStart,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 17),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              AppColors.brand400,
              AppColors.brand500,
              AppColors.purple,
            ],
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.brandGlow.withOpacity(0.45),
              blurRadius: 28,
              offset: const Offset(0, 10),
              spreadRadius: -2,
            ),
          ],
        ),
        child: Center(
          child: _logging
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withOpacity(0.95),
                    ),
                  ),
                )
              : const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.rocket_launch,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Text(
                      '立即开始',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _Feature {
  final IconData icon;
  final String title;
  final String subtitle;
  const _Feature({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class _FeatureRow extends StatelessWidget {
  final _Feature feature;
  const _FeatureRow({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.darkCard.withOpacity(0.65),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  AppColors.brand500.withOpacity(0.22),
                  AppColors.purple.withOpacity(0.22),
                ],
              ),
            ),
            child: Icon(
              feature.icon,
              color: AppColors.brand400,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  feature.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  feature.subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Colors.white.withOpacity(0.22),
            size: 20,
          ),
        ],
      ),
    );
  }
}
