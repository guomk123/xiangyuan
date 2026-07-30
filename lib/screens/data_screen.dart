import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_widgets.dart';
import '../widgets/common_widgets.dart';
import '../app_state.dart';
import '../settings_store.dart';
import 'data_detail_pages.dart';
import 'settings_screen.dart' show SettingsStoreScope;
import 'body_metrics_edit_page.dart';

class DataScreen extends StatefulWidget {
  const DataScreen({super.key});

  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  bool showVolumeChart = true;
  int _bodyRev = 0;

  final List<String> dayLabels = const ['一', '二', '三', '四', '五', '六', '日'];
  final List<String> weekDateLabels = const [
    '7/27',
    '7/28',
    '7/29',
    '7/30',
    '7/31',
    '8/01',
    '8/02'
  ];
  final AppState appState = AppState();

  void _tapDay(int i) {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => DayDetailPage(dayIndex: i),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    try {
      final Listenable allNotifiers = Listenable.merge(<Listenable>[
        appState.weekVolume,
        appState.weekCardio,
        appState.weekCalories,
        appState.weekRestingHR,
        appState.weekDeepSleep,
        appState.todaysSets,
        appState.calorieGoal,
        appState.todayMuscleVolume,
        appState.trainingStreak,
        appState.estimatedLeanGain,
        appState.progressiveTrend,
        appState.dailyGoalHit,
      ]);
      return SafeArea(
        top: true,
        bottom: false,
        child: AnimatedBuilder(
          animation: allNotifiers,
          builder: (context, _) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 28),
                  _buildKPIGrid(),
                  const SizedBox(height: 28),
                  _buildVolumeChartCard(),
                  const SizedBox(height: 28),
                  _buildBodyCompCard(),
                  const SizedBox(height: 28),
                  _buildTrendInsightsRow(),
                ],
              ),
            );
          },
        ),
      );
    } catch (e, s) {
      debugPrint('DataScreen build error: $e\n$s');
      return _DataScreenFallback();
    }
  }

  Widget _DataScreenFallback() {
    return ColoredBox(
      color: AppColors.darkBase,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '数据',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 16),
              Text(
                '页面加载中',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '训练与健康表盘',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 6),
              Text(
                '由训练日志推导 · 无需穿戴设备',
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.selectionClick();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => DayDetailPage(dayIndex: appState.todayIndex),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.07),
                  Colors.white.withOpacity(0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: AppColors.brand400,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  '本周 (${weekDateLabels.first}-${weekDateLabels.last})',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKPIGrid() {
    final listenable = Listenable.merge([
      appState.weekVolume,
      appState.weekCalories,
      appState.todaysSets,
      appState.calorieGoal,
      appState.todayMuscleVolume,
      appState.progressiveTrend,
      appState.trainingStreak,
      appState.dailyGoalHit,
      appState.estimatedLeanGain,
      appState.weekCardio,
    ]);
    return AnimatedBuilder(
      animation: listenable,
      builder: (context, _) {
        final int calories = appState.totalCalories;
        final double calGoal = (appState.calorieGoal.value * 7).toDouble();
        final double calPct = (calories / calGoal).clamp(0.0, 1.5);
        final String calTrend = calPct >= 0.95
            ? '已达标 ${((calPct - 1) * 100).toStringAsFixed(0)}%'
            : '还差 ${(((calGoal - calories) / calGoal) * 100).toStringAsFixed(0)}%';
        final Color calTrendColor =
            calPct >= 0.95 ? AppColors.emerald : AppColors.amber;
        final double vol = appState.totalVolume;
        final double volGoal = 23300;
        final double volPct = (vol / volGoal).clamp(0.0, 2.0);
        // 肌肉平衡分 (0~100)
        final int bal = appState.muscleBalanceScore;
        final String balTrend = bal >= 88
            ? '极佳 · 均衡发展'
            : bal >= 75
                ? '良好 · 关注弱项'
                : '待改进 · 有失衡风险';
        final Color balTrendColor = bal >= 88
            ? AppColors.emerald
            : bal >= 75
                ? AppColors.brand300
                : AppColors.amber;
        // 渐进过载 PR 指数 (0~100)
        final int po = appState.progressiveOverloadScore;
        final int prCount = appState.weeklyPRCount;
        final String poTrend = po >= 82
            ? '本周 $prCount 次 PR · 持续过载'
            : po >= 65
                ? '稳步推进 · $prCount 次 PR'
                : '建议加重 · 刺激不足';
        final Color poTrendColor = po >= 82
            ? AppColors.emerald
            : po >= 65
                ? AppColors.cyan
                : AppColors.amber;
        return Column(
          children: [
            SizedBox(
              height: 118,
              child: Row(
                children: [
                  Expanded(
                    child: StatsTile(
                      label: '本周消耗热量',
                      value: calories.toString(),
                      unit: 'kcal',
                      trend: calTrend,
                      trendColor: calTrendColor,
                      trendIcon: Icons.local_fire_department,
                      accentColor: AppColors.amber,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (ctx) => const CalorieDetailPage()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatsTile(
                      label: '训练总容量',
                      value: (vol / 1000).toStringAsFixed(2),
                      unit: '吨',
                      trend:
                          '目标 ${(volPct * 100).toStringAsFixed(0)}% · 今日 ${appState.todaysSets.value} 组',
                      trendColor:
                          volPct >= 1.0 ? AppColors.emerald : AppColors.purple,
                      trendIcon: Icons.fitness_center,
                      accentColor: AppColors.purple,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (ctx) => const VolumeDetailPage()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 118,
              child: Row(
                children: [
                  Expanded(
                    child: StatsTile(
                      label: '肌群平衡分',
                      value: bal.toString(),
                      unit: '/100',
                      trend: balTrend,
                      trendColor: balTrendColor,
                      trendIcon: Icons.balance,
                      accentColor: AppColors.cyan,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (ctx) =>
                                  const MuscleBalanceDetailPage()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatsTile(
                      label: '渐进过载指数',
                      value: po.toString(),
                      unit: '/100',
                      trend: poTrend,
                      trendColor: poTrendColor,
                      trendIcon: Icons.trending_up,
                      accentColor: AppColors.emerald,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (ctx) =>
                                  const ProgressiveOverloadDetailPage()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildVolumeChartCard() {
    final listenable = Listenable.merge(
        [appState.weekVolume, appState.weekCardio, appState.weekCalories]);
    return AnimatedBuilder(
      animation: listenable,
      builder: (context, _) {
        final int t = appState.todaysSets.value;
        final String subtitle = showVolumeChart
            ? '今日 ${appState.weekVolume.value[appState.todayIndex].toInt()} kg · $t 组进行中'
            : '有氧 ${appState.weekCardio.value[appState.todayIndex]} min · 消耗 ${appState.weekCalories.value[appState.todayIndex]} kcal';
        return GlassPanel(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (ctx) => showVolumeChart
                                ? const VolumeDetailPage()
                                : const CalorieDetailPage()),
                      );
                    },
                    child: Row(
                      children: [
                        Icon(
                          showVolumeChart ? Icons.show_chart : Icons.timelapse,
                          color: AppColors.brand400,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          showVolumeChart ? '每周容量与强度趋势' : '每周有氧时长趋势',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withOpacity(0.06)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildChartToggleButton('容量', showVolumeChart, () {
                          HapticFeedback.selectionClick();
                          setState(() => showVolumeChart = true);
                        }),
                        _buildChartToggleButton('时长', !showVolumeChart, () {
                          HapticFeedback.selectionClick();
                          setState(() => showVolumeChart = false);
                        }),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildCustomBarChart(),
              const SizedBox(height: 16),
              _buildChartLegend(),
              const SizedBox(height: 10),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 10.5,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChartToggleButton(
      String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brand500 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.brandGlow,
                    blurRadius: 10,
                    spreadRadius: -3,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textTertiary,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomBarChart() {
    final List<double> dataA = showVolumeChart
        ? List<double>.from(appState.weekVolume.value)
        : appState.weekCardio.value.map((e) => e.toDouble()).toList();
    final List<double> dataB;
    if (showVolumeChart) {
      // 副柱：有氧时长，压缩到 0-40 倍容量的比例
      dataB = appState.weekCardio.value
          .map<int>((e) => e * 40)
          .map<double>((e) => e.toDouble())
          .toList();
    } else {
      // 副柱：消耗 kcal，压缩到 *0.06 比例
      dataB = appState.weekCalories.value
          .map<double>((e) => (e * 0.06).toDouble())
          .toList();
    }
    final List<double> merged = <double>[];
    for (int i = 0; i < dataA.length; i++) {
      merged.add(dataA[i] + dataB[i]);
    }
    double maxVal = 0;
    for (final v in merged) {
      if (v > maxVal) maxVal = v;
    }
    if (maxVal < 1) maxVal = 1;
    return SizedBox(
      height: 200,
      child: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double chartHeight = constraints.maxHeight;
                final int n = dataA.length;
                final double totalW = constraints.maxWidth;
                final double minGap = 2;
                final double barMaxWidth = 36;
                final double barWidth =
                    ((totalW - minGap * (n + 1)) / n).clamp(24.0, barMaxWidth);
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    n,
                    (i) {
                      final double rA = maxVal > 0 ? dataA[i] / maxVal : 0;
                      final double rB = maxVal > 0 ? dataB[i] / maxVal : 0;
                      final double barW = (barWidth - 4).clamp(20.0, 32.0);
                      const double gapH = 5;
                      final double availH = chartHeight - gapH;
                      final double rBCapped = (rB).clamp(0.0, 0.5);
                      final double totalRatio =
                          (rA + rBCapped).clamp(0.0, 100.0);
                      double ratioA;
                      double ratioB;
                      if (totalRatio <= 1.0) {
                        ratioA = rA;
                        ratioB = rBCapped;
                      } else {
                        final double k = 1.0 / totalRatio;
                        ratioA = rA * k;
                        ratioB = rBCapped * k;
                      }
                      final double hA = availH * ratioA;
                      final double hB = availH * ratioB;
                      return SizedBox(
                        width: barWidth,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _tapDay(i),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: barW,
                                height: hA,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      AppColors.brand500,
                                      AppColors.purple
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(7),
                                  boxShadow: ratioA > 0.02
                                      ? [
                                          BoxShadow(
                                            color: AppColors.brandGlow,
                                            blurRadius: 10,
                                            spreadRadius: -3,
                                          ),
                                        ]
                                      : null,
                                ),
                              ),
                              if (hB > 0) ...[
                                const SizedBox(height: gapH),
                                Container(
                                  width: barW,
                                  height: hB,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        AppColors.cyan.withOpacity(0.7),
                                        AppColors.cyan.withOpacity(0.18),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final int n = dayLabels.length;
              final double totalW = constraints.maxWidth;
              final double cellMax = 42;
              final double cellMin = 30;
              final double cellW = ((totalW) / n).clamp(cellMin, cellMax);
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  n,
                  (i) => GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _tapDay(i),
                    child: SizedBox(
                      width: cellW,
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${dayLabels[i]}\n${weekDateLabels[i]}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: i == appState.todayIndex
                                  ? AppColors.emerald
                                  : AppColors.textTertiary,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChartLegend() {
    final String rightLabel = showVolumeChart ? '有氧时长 (min)' : '当日消耗 (kcal)';
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [AppColors.brand500, AppColors.purple],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              showVolumeChart ? '训练容量 (kg)' : '有氧时长 (min)',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(width: 30),
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.cyan.withOpacity(0.8),
                    AppColors.cyan.withOpacity(0.25),
                  ],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              rightLabel,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBodyCompCard() {
    final SettingsStore store = SettingsStoreScope.of(context);
    final BodyStats stats = store.computeBodyStats();
    final double bfPct = stats.bodyFatPct;
    final double weightKg = store.weightKg;
    final double skM = stats.skeletalMuscleKg;
    final int viscLvl = stats.visceralFatLevel;
    final double leanDelta = appState.estimatedLeanGain.value;
    final String deltaLabel = leanDelta >= 0
        ? '+${leanDelta.toStringAsFixed(2)} kg 瘦体重'
        : '${leanDelta.toStringAsFixed(2)} kg';
    final Color deltaColor =
        leanDelta >= 0 ? AppColors.emerald : AppColors.amber;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.of(context).push(
          MaterialPageRoute(builder: (ctx) => const BodyCompositionPage()),
        );
      },
      child: GlassCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.line_weight,
                        color: AppColors.purple,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          '体成分与肌肉量追踪',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.brand500.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '体脂率 ${bfPct.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: AppColors.brand300,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () async {
                        HapticFeedback.selectionClick();
                        try {
                          final bool? saved =
                              await Navigator.of(context).push<bool>(
                            MaterialPageRoute<bool>(
                              builder: (_) => BodyMetricsEditPage(store: store),
                            ),
                          );
                          if (saved == true && mounted) {
                            setState(() => _bodyRev += 1);
                          }
                        } catch (e, s) {
                          debugPrint('open body edit error: $e\n$s');
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.edit_outlined,
                              size: 12,
                              color: AppColors.textTertiary,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '编辑',
                              style: TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: deltaColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: deltaColor.withOpacity(0.22)),
              ),
              child: Row(
                children: [
                  Icon(
                    leanDelta >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                    color: deltaColor,
                    size: 13,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '本周预估变化 $deltaLabel',
                    style: TextStyle(
                      color: deltaColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _buildBodyStatCell(
                    label: '当前体重',
                    value: '${weightKg.toStringAsFixed(1)} kg',
                    valueColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildBodyStatCell(
                    label: '骨骼肌量',
                    value: '${skM.toStringAsFixed(1)} kg',
                    valueColor: AppColors.emerald,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildBodyStatCell(
                    label: '内脏脂肪等级',
                    value: '等级 $viscLvl',
                    valueColor:
                        viscLvl <= 3 ? AppColors.emerald : AppColors.amber,
                  ),
                ),
              ],
            ),
            // ignore: dead_code
            if (_bodyRev == -1) const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyStatCell({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
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
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendInsightsRow() {
    final int streak = appState.trainingStreak.value;
    final int balance = appState.muscleBalanceScore;
    final int prCount = appState.weeklyPRCount;
    final int recover = appState.recoveryScore;
    final List<double> trend =
        List<double>.from(appState.progressiveTrend.value);
    // 归一化 8 周趋势条
    final double trendMin =
        trend.isEmpty ? 0.0 : trend.reduce((a, b) => a < b ? a : b);
    final double trendMax =
        trend.isEmpty ? 1.0 : trend.reduce((a, b) => a > b ? a : b);
    final double trendSpan = (trendMax - trendMin).clamp(0.01, 100);
    final MuscleVolume mv = appState.todayMuscleVolume.value;
    final double total = mv.total > 0 ? mv.total : 1;
    final double legsPct = (mv.legs / total).clamp(0.0, 1.0);
    final double pushPct = (mv.push / total).clamp(0.0, 1.0);
    final double pullPct = (mv.pull / total).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            '训练洞察',
            style: TextStyle(
              color: AppColors.textTertiary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 180,
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (ctx) => const VolumeDetailPage()),
                    );
                  },
                  child: GlassCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppColors.brand400, AppColors.purple],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.local_fire_department,
                            color: Colors.white,
                            size: 17,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '$streak',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          '连续训练天数',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: List.generate(
                            7,
                            (i) => Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(right: i < 6 ? 2 : 0),
                                child: Container(
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: i < (streak.clamp(0, 7))
                                        ? AppColors.brand400
                                        : Colors.white.withOpacity(0.06),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (ctx) => const VolumeDetailPage()),
                    );
                  },
                  child: GlassCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppColors.emerald, AppColors.cyan],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.show_chart,
                            color: Colors.white,
                            size: 17,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${prCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                height: 1,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              '次 PR',
                              style: TextStyle(
                                color: AppColors.emerald,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          '近 8 周渐进过载',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: List.generate(
                              trend.length,
                              (i) {
                                final h = ((trend[i] - trendMin) / trendSpan)
                                    .clamp(0.15, 1.0);
                                return Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        right: i < trend.length - 1 ? 2.5 : 0),
                                    child: FractionallySizedBox(
                                      heightFactor: h,
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            colors: i == trend.length - 1
                                                ? [
                                                    AppColors.emerald,
                                                    AppColors.brand300,
                                                  ]
                                                : [
                                                    AppColors.brand500
                                                        .withOpacity(0.5),
                                                    AppColors.purple
                                                        .withOpacity(0.4),
                                                  ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(3),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (ctx) => const VolumeDetailPage()),
                    );
                  },
                  child: GlassCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppColors.amber, AppColors.brand300],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.balance,
                            color: Colors.white,
                            size: 17,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$balance',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                height: 1,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              recover >= 85
                                  ? '极佳'
                                  : recover >= 70
                                      ? '良好'
                                      : '待恢复',
                              style: TextStyle(
                                color: balance >= 85
                                    ? AppColors.emerald
                                    : balance >= 70
                                        ? AppColors.brand300
                                        : AppColors.amber,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          '肌群平衡 + 恢复',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Column(
                          children: [
                            _buildMuscleRatioBar(
                                label: '腿',
                                pct: legsPct,
                                color: AppColors.brand400),
                            const SizedBox(height: 4),
                            _buildMuscleRatioBar(
                                label: '推',
                                pct: pushPct,
                                color: AppColors.cyan),
                            const SizedBox(height: 4),
                            _buildMuscleRatioBar(
                                label: '拉',
                                pct: pullPct,
                                color: AppColors.emerald),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMuscleRatioBar({
    required String label,
    required double pct,
    required Color color,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 14,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Container(
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(3),
            ),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: pct.clamp(0.06, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
