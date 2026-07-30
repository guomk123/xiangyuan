import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../settings_store.dart';
import '../theme/app_theme.dart';

class BodyMetricsEditPage extends StatefulWidget {
  final SettingsStore store;

  const BodyMetricsEditPage({
    super.key,
    required this.store,
  });

  @override
  State<BodyMetricsEditPage> createState() => _BodyMetricsEditPageState();
}

class _BodyMetricsEditPageState extends State<BodyMetricsEditPage> {
  late TextEditingController _heightCtrl;
  late TextEditingController _weightCtrl;
  late TextEditingController _ageCtrl;
  late int _sexIndex;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final SettingsStore s = widget.store;
    _heightCtrl = TextEditingController(text: _formatOne(s.heightCm));
    _weightCtrl = TextEditingController(text: _formatOne(s.weightKg));
    _ageCtrl = TextEditingController(text: '${s.ageYears}');
    _sexIndex = (s.allSexes.indexOf(s.biologicalSex)).clamp(0, s.allSexes.length - 1);
  }

  @override
  void dispose() {
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  String _formatOne(double v) {
    if (v == v.roundToDouble()) return '${v.round()}';
    return v.toStringAsFixed(1);
  }

  double? _parseDouble(String src) {
    final String s = src.trim().replaceAll(',', '.');
    if (s.isEmpty) return null;
    return double.tryParse(s);
  }

  int? _parseInt(String src) {
    final String s = src.trim();
    if (s.isEmpty) return null;
    return int.tryParse(s);
  }

  Future<void> _onSave() async {
    if (_saving) return;
    final double? h = _parseDouble(_heightCtrl.text);
    final double? w = _parseDouble(_weightCtrl.text);
    final int? age = _parseInt(_ageCtrl.text);
    final String? errorMsg;
    if (h == null || h < 100 || h > 250) {
      errorMsg = '身高需要在 100~250cm';
    } else if (w == null || w < 30 || w > 300) {
      errorMsg = '体重需要在 30~300kg';
    } else if (age == null || age < 10 || age > 100) {
      errorMsg = '年龄需要在 10~100';
    } else {
      errorMsg = null;
    }
    if (errorMsg != null) {
      if (!mounted) return;
      try {
        HapticFeedback.vibrate();
      } catch (_) {}
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: const Color(0xFFE04B6A),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      HapticFeedback.selectionClick();
    } catch (_) {}
    final SettingsStore s = widget.store;
    final String sex = s.allSexes[_sexIndex.clamp(0, s.allSexes.length - 1)];
    await s.update(
      heightCm: h,
      weightKg: w,
      ageYears: age,
      biologicalSex: sex,
    );
    if (mounted) Navigator.of(context).pop<bool>(true);
  }

  @override
  Widget build(BuildContext context) {
    final SettingsStore s = widget.store;
    return Scaffold(
      backgroundColor: AppColors.darkBase,
      appBar: AppBar(
        backgroundColor: AppColors.darkBase,
        elevation: 0,
        title: const Text(
          '编辑身高体重',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        leading: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (mounted) Navigator.of(context).pop<bool>(false);
          },
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _buildHintCard(),
              const SizedBox(height: 20),
              _buildSectionTitle('基础信息'),
              const SizedBox(height: 10),
              _buildNumberField(
                controller: _heightCtrl,
                icon: Icons.straighten,
                title: '身高',
                suffix: 'cm',
                keyboard: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              _buildNumberField(
                controller: _weightCtrl,
                icon: Icons.monitor_weight_outlined,
                title: '体重',
                suffix: 'kg',
                keyboard: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              _buildNumberField(
                controller: _ageCtrl,
                icon: Icons.cake_outlined,
                title: '年龄',
                suffix: '岁',
                keyboard: TextInputType.number,
              ),
              const SizedBox(height: 12),
              _buildSectionTitle('生理性别（用于计算体脂率/BMR）'),
              const SizedBox(height: 10),
              Row(
                children: [
                  for (int i = 0; i < s.allSexes.length; i++) ...[
                    Expanded(
                      child: _buildSexChip(
                        label: s.allSexes[i],
                        selected: _sexIndex == i,
                        onTap: () {
                          try {
                            HapticFeedback.selectionClick();
                          } catch (_) {}
                          setState(() => _sexIndex = i);
                        },
                      ),
                    ),
                    if (i != s.allSexes.length - 1) const SizedBox(width: 12),
                  ],
                ],
              ),
              const SizedBox(height: 24),
              _buildLivePreview(),
              const SizedBox(height: 24),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHintCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.brand500.withOpacity(0.18),
            AppColors.purple.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.brand500.withOpacity(0.28),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(
            Icons.info_outline,
            color: AppColors.brand300,
            size: 18,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              '修改后会重新计算 BMI、体脂率估算、骨骼肌量和 BMR，所有数值保存在本地。',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textTertiary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required IconData icon,
    required String title,
    required String suffix,
    required TextInputType keyboard,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textTertiary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboard,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              cursorColor: AppColors.brand400,
              decoration: InputDecoration(
                labelText: title,
                labelStyle: const TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 12,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
              inputFormatters: <TextInputFormatter>[
                if (keyboard != TextInputType.number)
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^(\d+\.?\d{0,1})?'),
                  ),
                if (keyboard == TextInputType.number)
                  FilteringTextInputFormatter.digitsOnly,
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            suffix,
            style: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSexChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.brand500.withOpacity(0.18)
              : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.brand500.withOpacity(0.55)
                : Colors.white.withOpacity(0.08),
            width: selected ? 1.2 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildLivePreview() {
    final double? h = _parseDouble(_heightCtrl.text);
    final double? w = _parseDouble(_weightCtrl.text);
    final int? age = _parseInt(_ageCtrl.text);
    final SettingsStore s = widget.store;
    final String sex = s.allSexes[_sexIndex.clamp(0, s.allSexes.length - 1)];
    final BodyStats stats;
    final bool ok = h != null && w != null && age != null;
    if (ok) {
      final SettingsStore tmp = SettingsStore();
      tmp.update(
        heightCm: h,
        weightKg: w,
        ageYears: age,
        biologicalSex: sex,
      );
      stats = tmp.computeBodyStats();
    } else {
      stats = s.computeBodyStats();
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Colors.white.withOpacity(0.06),
            Colors.white.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '实时预览',
            style: TextStyle(
              color: AppColors.textTertiary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildPreviewCell(
                  'BMI',
                  '${stats.bmi.toStringAsFixed(1)}',
                  AppColors.brand300,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildPreviewCell(
                  '体脂率',
                  '${stats.bodyFatPct.toStringAsFixed(1)}%',
                  AppColors.purple,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildPreviewCell(
                  '骨骼肌',
                  '${stats.skeletalMuscleKg.toStringAsFixed(1)} kg',
                  AppColors.emerald,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildPreviewCell(
                  '瘦体重',
                  '${stats.leanMassKg.toStringAsFixed(1)} kg',
                  Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildPreviewCell(
                  'BMR',
                  '${stats.bmrKcal} kcal',
                  AppColors.amber,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildPreviewCell(
                  '内脏脂等级',
                  '等级 ${stats.visceralFatLevel}',
                  stats.visceralFatLevel <= 3
                      ? AppColors.emerald
                      : AppColors.amber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCell(String label, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _saving ? null : _onSave,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xFF4F7CFF), Color(0xFF8B5CF6)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.brandGlow,
              blurRadius: 25,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: _saving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  backgroundColor: Colors.transparent,
                ),
              )
            : const Text(
                '保存并重新计算',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
