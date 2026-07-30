import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../settings_store.dart';
import '../theme/app_theme.dart';
import 'profile_edit_page.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool autoWeightAdjust = true;
  bool progressiveOverload = true;
  bool deloadAutoPlan = false;
  bool _loggingOut = false;

  List<LinearGradient> get _avatarGradients {
    return const <LinearGradient>[
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFF4F7CFF), Color(0xFF8B5CF6)],
      ),
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFF22D3EE), Color(0xFF4F7CFF)],
      ),
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFFFBBF24), Color(0xFFF97316)],
      ),
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFF34D399), Color(0xFF06B6D4)],
      ),
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFFEC4899), Color(0xFF8B5CF6)],
      ),
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFFA855F7), Color(0xFF6366F1)],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    try {
      final SettingsStore store = SettingsStoreScope.of(context);
      return Scaffold(
        backgroundColor: AppColors.darkBase,
        body: SafeArea(
          top: true,
          bottom: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(store),
                const SizedBox(height: 24),
                _buildAICoachSection(),
                const SizedBox(height: 24),
                _buildDeviceSection(),
                const SizedBox(height: 28),
                _buildLogoutButton(store),
              ],
            ),
          ),
        ),
      );
    } catch (e, s) {
      debugPrint('SettingsScreen build error: $e\n$s');
      return _buildFallback();
    }
  }

  Widget _buildFallback() {
    return Scaffold(
      backgroundColor: AppColors.darkBase,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '设置',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 16),
              Text(
                '页面加载中，请稍后重试',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(SettingsStore store) {
    final List<LinearGradient> gradients = _avatarGradients;
    final int avatarIdx = store.avatarIndex.clamp(0, gradients.length - 1);
    final bool useFile =
        store.avatarPath != null && store.avatarPath!.isNotEmpty;
    final String letter = store.nickname.trim().isEmpty
        ? 'A'
        : store.nickname.trim().characters.first;
    final DecorationImage? img;
    if (useFile) {
      img = DecorationImage(
        image: FileImage(File(store.avatarPath!)),
        fit: BoxFit.cover,
      );
    } else {
      img = null;
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openEditPage(store),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Colors.white.withOpacity(0.07),
              Colors.white.withOpacity(0.02),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: useFile ? null : gradients[avatarIdx],
                image: img,
                border: Border.all(
                  color: Colors.white.withOpacity(0.14),
                  width: 1.6,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brandGlow,
                    blurRadius: 20,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: useFile
                  ? null
                  : Text(
                      letter,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          store.nickname,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.textTertiary,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.brand500.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.brand500.withOpacity(0.35),
                      ),
                    ),
                    child: Text(
                      '目标：${store.goal}',
                      style: const TextStyle(
                        color: AppColors.brand300,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
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

  Future<void> _openEditPage(SettingsStore store) async {
    try {
      HapticFeedback.selectionClick();
    } catch (_) {}
    try {
      final bool? saved = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => ProfileEditPage(store: store),
        ),
      );
      if (saved == true && mounted) setState(() {});
    } catch (e, s) {
      debugPrint('open profile edit error: $e\n$s');
    }
  }

  Widget _buildAICoachSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'AI 教练个性化偏好',
            style: TextStyle(
              color: AppColors.textTertiary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildCard(
          child: _buildSettingsRow(
            icon: Icons.tune,
            iconColor: AppColors.purple,
            title: '动态重量调整敏感度',
            subtitle: '高（根据训练容量实时增减）',
            trailing: Switch(
              value: autoWeightAdjust,
              onChanged: (bool val) {
                try {
                  HapticFeedback.selectionClick();
                } catch (_) {}
                if (mounted) setState(() => autoWeightAdjust = val);
              },
              activeColor: AppColors.brand500,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            '训练偏好',
            style: TextStyle(
              color: AppColors.textTertiary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildCard(
          child: Column(
            children: [
              _buildSettingsRow(
                icon: Icons.trending_up,
                iconColor: AppColors.purple,
                title: '渐进过载自动建议',
                subtitle: '连续 3 周容量达标后自动 +2.5kg',
                trailing: _buildStatusChip(
                  progressiveOverload ? '已开启' : '关闭',
                  progressiveOverload,
                ),
                onTap: () {
                  try {
                    HapticFeedback.selectionClick();
                  } catch (_) {}
                  if (mounted) {
                    setState(() => progressiveOverload = !progressiveOverload);
                  }
                },
              ),
              const _Divider(),
              _buildSettingsRow(
                icon: Icons.restore,
                iconColor: AppColors.emerald,
                title: '自动减载周计划',
                subtitle: '每 8 周降 50% 容量帮助恢复',
                trailing: _buildStatusChip(
                  deloadAutoPlan ? '已开启' : '关闭',
                  deloadAutoPlan,
                ),
                onTap: () {
                  try {
                    HapticFeedback.selectionClick();
                  } catch (_) {}
                  if (mounted) {
                    setState(() => deloadAutoPlan = !deloadAutoPlan);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Colors.white.withOpacity(0.07),
            Colors.white.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
      ),
      child: child,
    );
  }

  Widget _buildSettingsRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChevron() {
    return const Icon(
      Icons.chevron_right,
      color: AppColors.textTertiary,
      size: 18,
    );
  }

  Widget _buildStatusChip(String text, bool isOn) {
    return Text(
      text,
      style: TextStyle(
        color: isOn ? AppColors.emerald : AppColors.textTertiary,
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Future<void> _onLogout(SettingsStore store) async {
    try {
      HapticFeedback.selectionClick();
    } catch (_) {}
    if (_loggingOut || !mounted) return;
    setState(() => _loggingOut = true);
    try {
      await store.markLoggedOut();
    } catch (e) {
      debugPrint('logout error: $e');
    }
    if (mounted) setState(() => _loggingOut = false);
  }

  Widget _buildLogoutButton(SettingsStore store) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _loggingOut ? null : () => _onLogout(store),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.redAccent.withOpacity(0.08),
          border: Border.all(
            color: Colors.redAccent.withOpacity(0.35),
          ),
        ),
        child: Center(
          child: _loggingOut
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.redAccent.withOpacity(0.85),
                    ),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const <Widget>[
                    Icon(
                      Icons.logout,
                      color: Colors.redAccent,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      '退出登录',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class SettingsStoreScope extends InheritedWidget {
  final SettingsStore store;

  const SettingsStoreScope({
    super.key,
    required this.store,
    required super.child,
  });

  static SettingsStore of(BuildContext context) {
    final SettingsStoreScope? scope =
        context.dependOnInheritedWidgetOfExactType<SettingsStoreScope>();
    if (scope != null) return scope.store;
    throw FlutterError('SettingsStoreScope not found in context');
  }

  @override
  bool updateShouldNotify(covariant SettingsStoreScope oldWidget) {
    return oldWidget.store != store;
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 56),
      child: Container(
        height: 0.5,
        color: Colors.white.withOpacity(0.08),
      ),
    );
  }
}
