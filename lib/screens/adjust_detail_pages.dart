import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_widgets.dart';
import '../widgets/ui_components.dart';
import '../widgets/common_widgets.dart';
import '../widgets/detail_page_template.dart';

class WeightAdjustPage extends StatefulWidget {
  final double currentPercent;

  const WeightAdjustPage({
    super.key,
    this.currentPercent = 0,
  });

  @override
  State<WeightAdjustPage> createState() => _WeightAdjustPageState();
}

class _WeightAdjustPageState extends State<WeightAdjustPage> {
  late double _percent;
  static const presets = [-10, -5, 0, 5, 10, 15];

  @override
  void initState() {
    super.initState();
    _percent = widget.currentPercent;
  }

  @override
  Widget build(BuildContext context) {
    return GenericDetailPage(
      title: '整体重量调整',
      subtitle: '统一应用到全部动作的目标重量',
      leadingIcon: Icons.plus_one,
      accentColor: AppColors.brand400,
      child: Column(
        children: [
          SectionCard(
            title: '快速选择',
            icon: Icons.bolt,
            child: Column(
              children: [
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.7,
                  children: List.generate(
                    presets.length,
                    (i) => _buildPresetChip(presets[i]),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SectionCard(
            title: '精确调节',
            icon: Icons.tune,
            accentColor: AppColors.cyan,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      _buildMiniButton(
                        icon: Icons.remove,
                        onTap: _percent > -20
                            ? () {
                                HapticFeedback.selectionClick();
                                setState(() => _percent -= 2.5);
                              }
                            : null,
                      ),
                      const SizedBox(width: 28),
                      Text(
                        _percent >= 0
                            ? '+${_percent.toStringAsFixed(1)}'
                            : _percent.toStringAsFixed(1),
                        style: TextStyle(
                          color: _percent == 0
                              ? AppColors.textSecondary
                              : _percent > 0
                                  ? AppColors.danger
                                  : AppColors.cyan,
                          fontSize: 56,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '%',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 28),
                      _buildMiniButton(
                        icon: Icons.add,
                        onTap: _percent < 30
                            ? () {
                                HapticFeedback.selectionClick();
                                setState(() => _percent += 2.5);
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: AppColors.brand500,
                    inactiveTrackColor: Colors.white.withOpacity(0.08),
                    thumbColor: AppColors.brand400,
                    overlayColor: AppColors.brandGlow,
                    activeTickMarkColor: Colors.transparent,
                    inactiveTickMarkColor: Colors.transparent,
                  ),
                  child: Slider(
                    value: _percent,
                    min: -20,
                    max: 30,
                    divisions: 20,
                    onChanged: (v) {
                      setState(() => _percent = v);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '-20%',
                        style: TextStyle(
                          color: AppColors.cyan,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '0% (AI 推荐)',
                        style: TextStyle(
                          color: AppColors.brand300,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '+30%',
                        style: TextStyle(
                          color: AppColors.danger,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SectionCard(
            title: '预览效果（以当前动作 80kg 为例）',
            icon: Icons.visibility,
            accentColor: AppColors.emerald,
            child: Column(
              children: [
                _buildPreviewRow('杠铃平卧推举 80kg', _percent, 80),
                const DividerGap(),
                _buildPreviewRow('上斜哑铃推举 24kg', _percent, 24),
                const DividerGap(),
                _buildPreviewRow('绳索夹胸飞鸟 17.5kg', _percent, 17.5),
              ],
            ),
          ),
          const SizedBox(height: 28),
          GradientButton(
            text: '应用调整',
            icon: Icons.check,
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.of(context).pop(_percent);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip(int value) {
    final selected = _percent == value.toDouble();
    final color = value < 0
        ? AppColors.cyan
        : value == 0
            ? AppColors.textSecondary
            : AppColors.danger;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _percent = value.toDouble());
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: selected
              ? color.withOpacity(0.18)
              : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? color.withOpacity(0.55)
                : Colors.white.withOpacity(0.08),
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.15),
                    blurRadius: 18,
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          value >= 0 ? '+$value%' : '$value%',
          style: TextStyle(
            color: selected ? color : AppColors.textSecondary,
            fontSize: 14,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildMiniButton({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    final disabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: disabled
              ? Colors.white.withOpacity(0.03)
              : AppColors.brand500.withOpacity(0.18),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: disabled
                ? Colors.white.withOpacity(0.06)
                : AppColors.brand500.withOpacity(0.4),
          ),
        ),
        child: Icon(
          icon,
          color: disabled
              ? AppColors.textTertiary.withOpacity(0.5)
              : AppColors.brand300,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildPreviewRow(String name, double percent, double baseWeight) {
    final newWeight = baseWeight * (1 + percent / 100);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          Text(
            '→',
            style: TextStyle(
              color: AppColors.textTertiary,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${newWeight.toStringAsFixed(newWeight == newWeight.roundToDouble() ? 0 : 1)} kg',
            style: TextStyle(
              color: percent == 0
                  ? AppColors.textSecondary
                  : percent > 0
                      ? AppColors.danger
                      : AppColors.cyan,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class RepsSetsAdjustPage extends StatefulWidget {
  final String currentPlan;

  const RepsSetsAdjustPage({
    super.key,
    this.currentPlan = '标准 (AI 推荐)',
  });

  @override
  State<RepsSetsAdjustPage> createState() => _RepsSetsAdjustPageState();
}

class _RepsSetsAdjustPageState extends State<RepsSetsAdjustPage> {
  int _selectedPlan = 0;
  final List<Map<String, dynamic>> plans = const [
    {
      'name': '标准 (AI 推荐)',
      'tag': '肌肉肥大',
      'desc': '3-4 组 × 8-12 次 · 70-75% 1RM',
      'color': AppColors.brand400,
    },
    {
      'name': '高强度力量',
      'tag': '力量提升',
      'desc': '5-6 组 × 3-6 次 · 80-88% 1RM',
      'color': AppColors.danger,
    },
    {
      'name': '肌质耐力',
      'tag': '耐力塑形',
      'desc': '3-4 组 × 15-20 次 · 60-65% 1RM',
      'color': AppColors.cyan,
    },
    {
      'name': '超级组组合',
      'tag': '高密度训练',
      'desc': 'A/B 动作交替 · 组间休息减半',
      'color': AppColors.amber,
    },
    {
      'name': '渐进阶梯',
      'tag': '突破平台',
      'desc': '组间每 1 组重量 +5%，次数 -2',
      'color': AppColors.purple,
    },
    {
      'name': '降组 (Drop Set)',
      'tag': '极限充血',
      'desc': '至力竭后降重 20% 再力竭 × 3',
      'color': AppColors.emerald,
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedPlan = plans.indexWhere(
      (p) => p['name'] == widget.currentPlan,
    );
    if (_selectedPlan < 0) _selectedPlan = 0;
  }

  @override
  Widget build(BuildContext context) {
    return GenericDetailPage(
      title: '组数 × 次数方案',
      subtitle: '统一修改所有动作的组数和次数',
      leadingIcon: Icons.repeat,
      accentColor: AppColors.cyan,
      child: Column(
        children: [
          const SectionCard(
            title: '选择训练方案',
            icon: Icons.layers,
            child: Text(
              '选择后会自动调整每一个动作的组数次数配置；动作间休息时间也会随之变化。',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 20),
          SectionCard(
            title: '6 种训练方案',
            icon: Icons.format_list_numbered,
            accentColor: AppColors.cyan,
            child: Column(
              children: [
                ...List.generate(
                  plans.length,
                  (i) => Column(
                    children: [
                      if (i > 0) const DividerGap(),
                      _buildPlanCard(i),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          GradientButton(
            text: '应用此方案',
            icon: Icons.check,
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.of(context).pop(plans[_selectedPlan]['name'] as String);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(int index) {
    final plan = plans[index];
    final selected = _selectedPlan == index;
    final color = plan['color'] as Color;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedPlan = index);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? color.withOpacity(0.45)
                : Colors.white.withOpacity(0.06),
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.15),
                    blurRadius: 20,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? color : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? color
                      : AppColors.textTertiary.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        plan['name'] as String,
                        style: TextStyle(
                          color:
                              selected ? Colors.white : AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: color.withOpacity(0.3)),
                        ),
                        child: Text(
                          plan['tag'] as String,
                          style: TextStyle(
                            color: color,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    plan['desc'] as String,
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 10,
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

class RestTimerAdjustPage extends StatefulWidget {
  final String currentPlan;

  const RestTimerAdjustPage({
    super.key,
    this.currentPlan = '标准 (90s / 2.5min)',
  });

  @override
  State<RestTimerAdjustPage> createState() => _RestTimerAdjustPageState();
}

class _RestTimerAdjustPageState extends State<RestTimerAdjustPage> {
  int _selectedPlan = 0;
  int _customIsolation = 90;
  int _customCompound = 150;

  final List<Map<String, dynamic>> plans = const [
    {
      'name': '标准',
      'tag': 'AI 推荐',
      'iso': 90,
      'cmp': 150,
      'color': AppColors.brand400,
    },
    {
      'name': '短间歇高强度',
      'tag': '代谢压力',
      'iso': 45,
      'cmp': 90,
      'color': AppColors.danger,
    },
    {
      'name': '力量举长间歇',
      'tag': '充分恢复',
      'iso': 120,
      'cmp': 240,
      'color': AppColors.amber,
    },
    {
      'name': '自定义',
      'tag': '手动设置',
      'iso': 0,
      'cmp': 0,
      'color': AppColors.cyan,
    },
  ];

  @override
  void initState() {
    super.initState();
    final match = plans
        .indexWhere((p) => widget.currentPlan.contains(p['name'] as String));
    if (match >= 0) _selectedPlan = match;
  }

  @override
  Widget build(BuildContext context) {
    final p = plans[_selectedPlan];
    final displayIso =
        (p['name'] == '自定义') ? _customIsolation : (p['iso'] as int);
    final displayCmp =
        (p['name'] == '自定义') ? _customCompound : (p['cmp'] as int);

    return GenericDetailPage(
      title: '组间休息设置',
      subtitle: '不同动作类型对应不同休息时长',
      leadingIcon: Icons.timer_outlined,
      accentColor: AppColors.amber,
      child: Column(
        children: [
          SectionCard(
            title: '休息方案选择',
            icon: Icons.speed,
            child: Column(
              children: [
                ...List.generate(
                  plans.length,
                  (i) => Column(
                    children: [
                      if (i > 0) const DividerGap(),
                      _buildPlanRow(i),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (plans[_selectedPlan]['name'] == '自定义') ...[
            SectionCard(
              title: '自定义休息时长（秒）',
              icon: Icons.timeline,
              accentColor: AppColors.cyan,
              child: Column(
                children: [
                  _buildTimerAdjuster(
                    label: '孤立动作 (例如：飞鸟、侧平举)',
                    value: _customIsolation,
                    min: 20,
                    max: 180,
                    step: 10,
                    color: AppColors.cyan,
                    onChanged: (v) => setState(() => _customIsolation = v),
                  ),
                  const DividerGap(),
                  _buildTimerAdjuster(
                    label: '复合动作 (例如：深蹲、卧推)',
                    value: _customCompound,
                    min: 60,
                    max: 300,
                    step: 15,
                    color: AppColors.danger,
                    onChanged: (v) => setState(() => _customCompound = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
          SectionCard(
            title: '当前预览',
            icon: Icons.visibility,
            accentColor: AppColors.emerald,
            child: Column(
              children: [
                _buildPreviewRow(
                  label: '孤立动作组间',
                  timeSec: displayIso,
                  color: AppColors.cyan,
                ),
                const DividerGap(),
                _buildPreviewRow(
                  label: '复合动作组间',
                  timeSec: displayCmp,
                  color: AppColors.danger,
                ),
                const DividerGap(),
                _buildPreviewTotal(displayIso, displayCmp),
              ],
            ),
          ),
          const SizedBox(height: 28),
          GradientButton(
            text: '保存休息时长',
            icon: Icons.check,
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.of(context).pop({
                'planName': p['name'] as String,
                'isolation': displayIso,
                'compound': displayCmp,
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlanRow(int index) {
    final p = plans[index];
    final selected = _selectedPlan == index;
    final color = p['color'] as Color;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedPlan = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.14) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? color.withOpacity(0.45)
                : Colors.white.withOpacity(0.06),
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? color : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? color
                      : AppColors.textTertiary.withOpacity(0.5),
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.white, size: 12)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        p['name'] as String,
                        style: TextStyle(
                          color:
                              selected ? Colors.white : AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          p['tag'] as String,
                          style: TextStyle(
                            color: color,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  if (p['name'] != '自定义')
                    Text(
                      '孤立 ${_fmt(p['iso'] as int)} · 复合 ${_fmt(p['cmp'] as int)}',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 10,
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

  Widget _buildTimerAdjuster({
    required String label,
    required int value,
    required int min,
    required int max,
    required int step,
    required Color color,
    required ValueChanged<int> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              GestureDetector(
                onTap: value > min
                    ? () {
                        HapticFeedback.selectionClick();
                        onChanged(value - step);
                      }
                    : null,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: value > min
                        ? color.withOpacity(0.18)
                        : Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: value > min
                          ? color.withOpacity(0.4)
                          : Colors.white.withOpacity(0.06),
                    ),
                  ),
                  child: Icon(
                    Icons.remove,
                    color: value > min
                        ? color
                        : AppColors.textTertiary.withOpacity(0.5),
                    size: 16,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    _fmt(value),
                    style: TextStyle(
                      color: color,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: value < max
                    ? () {
                        HapticFeedback.selectionClick();
                        onChanged(value + step);
                      }
                    : null,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: value < max
                        ? color.withOpacity(0.18)
                        : Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: value < max
                          ? color.withOpacity(0.4)
                          : Colors.white.withOpacity(0.06),
                    ),
                  ),
                  child: Icon(
                    Icons.add,
                    color: value < max
                        ? color
                        : AppColors.textTertiary.withOpacity(0.5),
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: color,
              inactiveTrackColor: Colors.white.withOpacity(0.08),
              thumbColor: color,
              overlayColor: color.withOpacity(0.2),
              activeTickMarkColor: Colors.transparent,
              inactiveTickMarkColor: Colors.transparent,
            ),
            child: Slider(
              value: value.toDouble(),
              min: min.toDouble(),
              max: max.toDouble(),
              divisions: ((max - min) / step).round(),
              onChanged: (v) => onChanged(v.round()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewRow({
    required String label,
    required int timeSec,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Row(
        children: [
          Icon(Icons.all_inclusive, color: color, size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          Text(
            _fmt(timeSec),
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewTotal(int iso, int cmp) {
    final perSessionMinutes = ((iso * 8 + cmp * 4) / 60).round();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.hourglass_disabled,
              color: AppColors.emerald, size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: const Text(
              '预估训练总时长变化',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          Text(
            '约 +${perSessionMinutes - 48 >= 0 ? perSessionMinutes - 48 : 0} min',
            style: const TextStyle(
              color: AppColors.emerald,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    if (m == 0) return '${s}s';
    if (s == 0) return '${m}min';
    return '${m}m ${s}s';
  }
}

class ExerciseLibraryPage extends StatefulWidget {
  final List<String> existingNames;

  const ExerciseLibraryPage({
    super.key,
    this.existingNames = const [],
  });

  @override
  State<ExerciseLibraryPage> createState() => _ExerciseLibraryPageState();
}

class _ExerciseLibraryPageState extends State<ExerciseLibraryPage> {
  String _query = '';
  String _currentCategory = '全部';
  final Set<int> _selected = {};

  static const List<String> categories = [
    '全部',
    '胸部',
    '背部',
    '肩部',
    '手臂',
    '腿部',
    '核心',
  ];

  static final List<Map<String, dynamic>> library = [
    {
      'name': '窄距杠铃卧推',
      'category': '胸部',
      'subtitle': '3组 × 10次 · 60kg',
      'tag': '三头肌长头',
      'tagColor': AppColors.brand400,
      'imageUrl':
          'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?auto=format&fit=crop&w=400&q=80',
      'sets': [
        {'weight': '60 kg', 'reps': '10 次'},
        {'weight': '60 kg', 'reps': '10 次'},
        {'weight': '60 kg', 'reps': '10 次'},
      ],
      'status': 'AI 推荐',
      'statusColor': AppColors.brand400,
    },
    {
      'name': '哑铃飞鸟',
      'category': '胸部',
      'subtitle': '3组 × 15次 · 14kg',
      'tag': '胸肌中缝',
      'tagColor': AppColors.cyan,
      'imageUrl':
          'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?auto=format&fit=crop&w=400&q=80',
      'sets': [
        {'weight': '14 kg', 'reps': '15 次'},
        {'weight': '14 kg', 'reps': '15 次'},
        {'weight': '14 kg', 'reps': '15 次'},
      ],
      'status': '孤立',
      'statusColor': AppColors.textTertiary,
    },
    {
      'name': '俯卧撑 (负重)',
      'category': '胸部',
      'subtitle': '3组 × 力竭',
      'tag': '热身/预疲劳',
      'tagColor': AppColors.emerald,
      'imageUrl':
          'https://images.unsplash.com/photo-1598971639058-fab0d8fe640c?auto=format&fit=crop&w=400&q=80',
      'sets': [
        {'weight': 'BW+20kg', 'reps': '15 次'},
        {'weight': 'BW+20kg', 'reps': '12 次'},
        {'weight': 'BW+20kg', 'reps': '力竭'},
      ],
      'status': '辅助',
      'statusColor': AppColors.textTertiary,
    },
    {
      'name': '引体向上 (宽握)',
      'category': '背部',
      'subtitle': '4组 × 8次',
      'tag': '背阔肌宽度',
      'tagColor': AppColors.emerald,
      'imageUrl':
          'https://images.unsplash.com/photo-1598971861713-54ad16a1e93c?auto=format&fit=crop&w=400&q=80',
      'sets': [
        {'weight': 'BW', 'reps': '8 次'},
        {'weight': 'BW', 'reps': '8 次'},
        {'weight': 'BW+10kg', 'reps': '6 次'},
        {'weight': 'BW+10kg', 'reps': '6 次'},
      ],
      'status': '黄金动作',
      'statusColor': AppColors.amber,
    },
    {
      'name': '杠铃划船',
      'category': '背部',
      'subtitle': '4组 × 10次 · 60kg',
      'tag': '背阔肌厚度',
      'tagColor': AppColors.danger,
      'imageUrl':
          'https://images.unsplash.com/photo-1598971639058-fab0d8fe640c?auto=format&fit=crop&w=400&q=80',
      'sets': [
        {'weight': '60 kg', 'reps': '10 次'},
        {'weight': '60 kg', 'reps': '10 次'},
        {'weight': '60 kg', 'reps': '10 次'},
        {'weight': '60 kg', 'reps': '10 次'},
      ],
      'status': '复合',
      'statusColor': AppColors.purple,
    },
    {
      'name': '坐姿哑铃推举',
      'category': '肩部',
      'subtitle': '3组 × 12次 · 18kg',
      'tag': '三角肌前/中束',
      'tagColor': AppColors.purple,
      'imageUrl':
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?auto=format&fit=crop&w=400&q=80',
      'sets': [
        {'weight': '18 kg', 'reps': '12 次'},
        {'weight': '18 kg', 'reps': '12 次'},
        {'weight': '18 kg', 'reps': '12 次'},
      ],
      'status': '标准',
      'statusColor': AppColors.textTertiary,
    },
    {
      'name': '侧平举 (递减组)',
      'category': '肩部',
      'subtitle': '3组 × 12/12/12 次',
      'tag': '三角肌中束',
      'tagColor': AppColors.amber,
      'imageUrl':
          'https://images.unsplash.com/photo-1540497077202-7c8a3999166f?auto=format&fit=crop&w=400&q=80',
      'sets': [
        {'weight': '8→6→4 kg', 'reps': '12/12/12 次'},
        {'weight': '8→6→4 kg', 'reps': '12/12/12 次'},
        {'weight': '8→6→4 kg', 'reps': '12/12/12 次'},
      ],
      'status': '强化',
      'statusColor': AppColors.danger,
    },
    {
      'name': '杠铃深蹲 (低杠位)',
      'category': '腿部',
      'subtitle': '5组 × 5次 · 120kg',
      'tag': '力量举体系',
      'tagColor': AppColors.danger,
      'imageUrl':
          'https://images.unsplash.com/photo-1551632811-561732d1e306?auto=format&fit=crop&w=400&q=80',
      'sets': [
        {'weight': '120 kg', 'reps': '5 次'},
        {'weight': '120 kg', 'reps': '5 次'},
        {'weight': '120 kg', 'reps': '5 次'},
        {'weight': '120 kg', 'reps': '5 次'},
        {'weight': '120 kg', 'reps': '5 次'},
      ],
      'status': '大重量',
      'statusColor': AppColors.danger,
    },
    {
      'name': '腿举 (45°)',
      'category': '腿部',
      'subtitle': '4组 × 15次 · 180kg',
      'tag': '股四头肌',
      'tagColor': AppColors.cyan,
      'imageUrl':
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?auto=format&fit=crop&w=400&q=80',
      'sets': [
        {'weight': '180 kg', 'reps': '15 次'},
        {'weight': '180 kg', 'reps': '15 次'},
        {'weight': '180 kg', 'reps': '15 次'},
        {'weight': '180 kg', 'reps': '15 次'},
      ],
      'status': '标准',
      'statusColor': AppColors.textTertiary,
    },
    {
      'name': '杠铃弯举',
      'category': '手臂',
      'subtitle': '3组 × 10次 · 20kg',
      'tag': '肱二头肌长头',
      'tagColor': AppColors.brand400,
      'imageUrl':
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?auto=format&fit=crop&w=400&q=80',
      'sets': [
        {'weight': '20 kg', 'reps': '10 次'},
        {'weight': '20 kg', 'reps': '10 次'},
        {'weight': '20 kg', 'reps': '10 次'},
      ],
      'status': '孤立',
      'statusColor': AppColors.textTertiary,
    },
    {
      'name': '悬垂举腿',
      'category': '核心',
      'subtitle': '4组 × 12次',
      'tag': '腹直肌下部',
      'tagColor': AppColors.emerald,
      'imageUrl':
          'https://images.unsplash.com/photo-1540497077202-7c8a3999166f?auto=format&fit=crop&w=400&q=80',
      'sets': [
        {'weight': 'BW', 'reps': '12 次'},
        {'weight': 'BW', 'reps': '12 次'},
        {'weight': 'BW', 'reps': '12 次'},
        {'weight': 'BW', 'reps': '12 次'},
      ],
      'status': '强化',
      'statusColor': AppColors.amber,
    },
    {
      'name': '平板支撑',
      'category': '核心',
      'subtitle': '3组 × 60秒',
      'tag': '核心稳定',
      'tagColor': AppColors.cyan,
      'imageUrl':
          'https://images.unsplash.com/photo-1518611012118-696072aa579a?auto=format&fit=crop&w=400&q=80',
      'sets': [
        {'weight': 'BW', 'reps': '60 秒'},
        {'weight': 'BW', 'reps': '60 秒'},
        {'weight': 'BW', 'reps': '60 秒'},
      ],
      'status': '辅助',
      'statusColor': AppColors.textTertiary,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = library.where((ex) {
      final matchCat =
          _currentCategory == '全部' || ex['category'] == _currentCategory;
      final q = _query.trim().toLowerCase();
      final matchQ = q.isEmpty ||
          (ex['name'] as String).toLowerCase().contains(q) ||
          (ex['tag'] as String).toLowerCase().contains(q);
      return matchCat && matchQ;
    }).toList();

    return GenericDetailPage(
      title: 'AI Coach 动作库',
      subtitle: '已选 ${_selected.length} 个动作准备加入今日训练',
      leadingIcon: Icons.library_books,
      accentColor: AppColors.emerald,
      child: Column(
        children: [
          _buildSearchBar(),
          const SizedBox(height: 16),
          _buildCategoryChips(),
          const SizedBox(height: 16),
          GlassPanel(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                ...List.generate(
                  filtered.length,
                  (i) {
                    final idx = library.indexOf(filtered[i]);
                    final alreadyExists =
                        widget.existingNames.contains(filtered[i]['name']);
                    return Column(
                      children: [
                        if (i > 0)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Divider(
                              height: 0.5,
                              thickness: 0.5,
                              color: Colors.white.withOpacity(0.08),
                            ),
                          ),
                        _buildLibraryItem(
                          filtered[i],
                          idx,
                          alreadyExists,
                        ),
                      ],
                    );
                  },
                ),
                if (filtered.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(28),
                    child: Text(
                      '没有匹配的动作',
                      style: TextStyle(
                          color: AppColors.textTertiary, fontSize: 13),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          GradientButton(
            text: '加入 ${_selected.length} 个动作到今日训练',
            icon: Icons.add_circle,
            onPressed: _selected.isEmpty
                ? null
                : () {
                    HapticFeedback.mediumImpact();
                    final selectedExercises = _selected
                        .map((i) => Map<String, dynamic>.from(library[i]))
                        .toList();
                    Navigator.of(context).pop(selectedExercises);
                  },
          ),
          if (_selected.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                '请先选择至少一个动作',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: AppColors.textTertiary,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
              decoration: InputDecoration(
                hintText: '搜索动作或肌肉群…',
                hintStyle: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 13,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(
          categories.length,
          (i) {
            final selected = _currentCategory == categories[i];
            return Padding(
              padding:
                  EdgeInsets.only(right: i < categories.length - 1 ? 8 : 0),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _currentCategory = categories[i]);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.emerald.withOpacity(0.18)
                        : Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected
                          ? AppColors.emerald.withOpacity(0.45)
                          : Colors.white.withOpacity(0.08),
                    ),
                  ),
                  child: Text(
                    categories[i],
                    style: TextStyle(
                      color: selected
                          ? AppColors.emerald
                          : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLibraryItem(
    Map<String, dynamic> ex,
    int libraryIndex,
    bool alreadyExists,
  ) {
    final selected = _selected.contains(libraryIndex);
    final tagColor = ex['tagColor'] as Color;
    final disabled = alreadyExists;

    return GestureDetector(
      onTap: disabled
          ? null
          : () {
              HapticFeedback.selectionClick();
              setState(() {
                if (selected) {
                  _selected.remove(libraryIndex);
                } else {
                  _selected.add(libraryIndex);
                }
              });
            },
      behavior: HitTestBehavior.opaque,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: disabled ? 0.45 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.emerald.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? AppColors.emerald.withOpacity(0.4)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              NetworkImagePlaceholder(
                url: ex['imageUrl'],
                width: 44,
                height: 44,
                borderRadius: 10,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            ex['name'] as String,
                            style: TextStyle(
                              color: disabled
                                  ? AppColors.textTertiary
                                  : selected
                                      ? Colors.white
                                      : AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              decoration:
                                  disabled ? TextDecoration.lineThrough : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        if (disabled)
                          Text(
                            '已在训练中',
                            style: TextStyle(
                              color: AppColors.emerald.withOpacity(0.8),
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ex['subtitle'] as String,
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: tagColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(5),
                            border:
                                Border.all(color: tagColor.withOpacity(0.3)),
                          ),
                          child: Text(
                            ex['tag'] as String,
                            style: TextStyle(
                              color: tagColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          ex['status'] as String,
                          style: TextStyle(
                            color: ex['statusColor'] as Color,
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: disabled
                      ? Colors.white.withOpacity(0.04)
                      : selected
                          ? AppColors.emerald
                          : Colors.transparent,
                  border: Border.all(
                    color: disabled
                        ? AppColors.textTertiary.withOpacity(0.3)
                        : selected
                            ? AppColors.emerald
                            : AppColors.textTertiary.withOpacity(0.5),
                  ),
                ),
                child: disabled
                    ? Icon(
                        Icons.close,
                        color: AppColors.textTertiary.withOpacity(0.5),
                        size: 12,
                      )
                    : selected
                        ? const Icon(Icons.check, color: Colors.white, size: 14)
                        : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
