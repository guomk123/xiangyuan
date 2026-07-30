import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_widgets.dart';
import '../widgets/ui_components.dart';
import '../widgets/common_widgets.dart';
import '../widgets/detail_page_template.dart';
import '../app_state.dart';

class CalorieDetailPage extends StatelessWidget {
  const CalorieDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState s = AppState();
    final int totalCals = s.totalCalories;
    final int weekGoal = s.calorieGoal.value * 7;
    // 来源：训练/有氧/NEAT 真实推导
    final int kcalStrength =
        s.weekVolume.value.fold<double>(0, (a, b) => a + b * 0.045).round();
    final int kcalCardio =
        s.weekCardio.value.fold<int>(0, (a, b) => a + (b * 7.5).round());
    final int baseMin = 140 * 7;
    final int kcalNEAT =
        (totalCals - kcalStrength - kcalCardio - baseMin).clamp(100, 5000);
    final double denom = totalCals > 0 ? totalCals.toDouble() : 1;
    final double pctStrength = (kcalStrength / denom).clamp(0.0, 0.95);
    final double pctCardio = (kcalCardio / denom).clamp(0.0, 0.8);
    final double pctNEAT = (kcalNEAT / denom).clamp(0.05, 0.6);
    return GenericDetailPage(
      title: '本周消耗热量',
      subtitle: '目标 $weekGoal kcal / 周 · 训练日志推导',
      leadingIcon: Icons.local_fire_department,
      accentColor: AppColors.amber,
      child: Column(
        children: [
          _BigKPI(
            value: totalCals.toString(),
            unit: 'kcal',
            subLabel:
                '达成目标 ${((totalCals / (weekGoal > 0 ? weekGoal : 1)) * 100).toStringAsFixed(0)}%',
            subColor: AppColors.brand300,
            accentColor: AppColors.amber,
            progress:
                (totalCals / (weekGoal > 0 ? weekGoal : 1)).clamp(0.0, 1.0),
          ),
          const SizedBox(height: 22),
          SectionCard(
            title: '每日消耗明细',
            icon: Icons.view_week,
            child: Column(
              children: List.generate(
                s.weekCalories.value.length,
                (i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: _DayBar(
                    label: const ['周一', '周二', '周三', '周四', '周五', '周六', '周日'][i],
                    value: s.weekCalories.value[i],
                    unit: 'kcal',
                    maxVal:
                        s.weekCalories.value.reduce((a, b) => a > b ? a : b),
                    accentColor:
                        i == s.todayIndex ? AppColors.emerald : AppColors.amber,
                    isToday: i == s.todayIndex,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          SectionCard(
            title: '消耗来源分布 · 训练推导',
            icon: Icons.pie_chart,
            iconColor: AppColors.brand400,
            child: Column(
              children: [
                _SourceRow(
                    label: '力量训练',
                    pct: pctStrength,
                    color: AppColors.brand500,
                    amount: '~$kcalStrength kcal'),
                SizedBox(height: 10),
                _SourceRow(
                    label: '有氧/步行',
                    pct: pctCardio,
                    color: AppColors.cyan,
                    amount: '~$kcalCardio kcal'),
                SizedBox(height: 10),
                _SourceRow(
                    label: 'NEAT 日常活动',
                    pct: pctNEAT,
                    color: AppColors.emerald,
                    amount: '~$kcalNEAT kcal'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VolumeDetailPage extends StatelessWidget {
  const VolumeDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState s = AppState();
    final double goal = 23300;
    final double t = s.totalVolume;
    final MuscleVolume mv = s.todayMuscleVolume.value;
    // 近似整周分解：今日分解 * (totalVolume / todayVolume or 1)
    final double todayVol =
        s.weekVolume.value[s.todayIndex].clamp(1.0, double.infinity);
    final double scale = (t / todayVol).clamp(1.0, 10.0);
    final double legsT = mv.legs * scale;
    final double pushT = mv.push * scale;
    final double pullT = mv.pull * scale;
    final double coreT = mv.core * scale;
    final double sumParts = (legsT + pushT + pullT + coreT).clamp(1.0, 1e9);
    final double pLegs = legsT / sumParts;
    final double pPush = pushT / sumParts;
    final double pPull = pullT / sumParts;
    final double pCore = coreT / sumParts;
    return GenericDetailPage(
      title: '训练总容量',
      subtitle:
          '目标 ${(goal / 1000).toStringAsFixed(1)} 吨/周 · 连续 ${s.trainingStreak.value} 天',
      leadingIcon: Icons.assessment,
      accentColor: AppColors.brand500,
      child: Column(
        children: [
          _BigKPI(
            value: '${(t / 1000).toStringAsFixed(2)}吨',
            unit: 'kg',
            subLabel:
                '达成 ${((t / goal) * 100).toStringAsFixed(0)}% · 今日 ${s.todaysSets.value} 组 · 平衡 ${s.muscleBalanceScore} 分',
            subColor: AppColors.brand300,
            accentColor: AppColors.brand500,
            progress: (t / goal).clamp(0.0, 1.1),
          ),
          const SizedBox(height: 22),
          SectionCard(
            title: '每日容量明细 (kg)',
            icon: Icons.fitness_center,
            child: Column(
              children: List.generate(
                s.weekVolume.value.length,
                (i) {
                  final double maxV =
                      s.weekVolume.value.reduce((a, b) => a > b ? a : b);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: _DayBar(
                      label: const ['一', '二', '三', '四', '五', '六', '日'][i],
                      value: s.weekVolume.value[i].toInt(),
                      unit: 'kg',
                      maxVal: maxV.toInt(),
                      accentColor: i == s.todayIndex
                          ? AppColors.emerald
                          : AppColors.purple,
                      isToday: i == s.todayIndex,
                      goalHit: s.dailyGoalHit.value[i],
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 18),
          SectionCard(
            title: '肌群容量占比 · 本周估算',
            icon: Icons.bar_chart,
            iconColor: AppColors.cyan,
            child: Column(
              children: [
                _SourceRow(
                    label: '腿部 (股四+腘绳+臀)',
                    pct: pLegs,
                    color: AppColors.danger,
                    amount: '~${(legsT / 1000).toStringAsFixed(1)} 吨'),
                SizedBox(height: 10),
                _SourceRow(
                    label: '推 (胸+肩+三头)',
                    pct: pPush,
                    color: AppColors.brand500,
                    amount: '~${(pushT / 1000).toStringAsFixed(1)} 吨'),
                SizedBox(height: 10),
                _SourceRow(
                    label: '拉 (背+二头)',
                    pct: pPull,
                    color: AppColors.cyan,
                    amount: '~${(pullT / 1000).toStringAsFixed(1)} 吨'),
                SizedBox(height: 10),
                _SourceRow(
                    label: '核心 / 复合稳定',
                    pct: pCore,
                    color: AppColors.emerald,
                    amount: '~${(coreT / 1000).toStringAsFixed(1)} 吨'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MuscleBalanceDetailPage extends StatelessWidget {
  const MuscleBalanceDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState s = AppState();
    final MuscleVolume mv = s.todayMuscleVolume.value;
    final double total = mv.total <= 0 ? 1 : mv.total;
    final double legsP = (mv.legs / total).clamp(0.0, 1.0);
    final double pushP = (mv.push / total).clamp(0.0, 1.0);
    final double pullP = (mv.pull / total).clamp(0.0, 1.0);
    final double coreP = (mv.core / total).clamp(0.0, 1.0);
    final int score = s.muscleBalanceScore;
    final String weakest = () {
      final Map<String, double> m = <String, double>{
        '腿部训练': mv.legs,
        '推类训练': mv.push,
        '拉类训练': mv.pull,
        '核心训练': mv.core,
      };
      double minV = 1e12;
      String name = '综合';
      m.forEach((k, v) {
        if (v < minV && total > 100) {
          minV = v;
          name = k;
        }
      });
      return name;
    }();
    final double wTarget = total * 0.45;
    final double pTarget = total * 0.25;
    final double puTarget = total * 0.22;
    final double cTarget = total * 0.08;
    final double legsTargetKg =
        (wTarget - mv.legs).clamp(-10000, 100000).toDouble();
    final double pushTargetKg =
        (pTarget - mv.push).clamp(-10000, 100000).toDouble();
    final double pullTargetKg =
        (puTarget - mv.pull).clamp(-10000, 100000).toDouble();
    final double coreTargetKg =
        (cTarget - mv.core).clamp(-10000, 100000).toDouble();
    final List<double> weekVols = s.weekVolume.value;
    final List<double> weekBal = weekVols.map<double>((double v) {
      final double ratio = (v / s.avgVolume.clamp(1, 1000000)).clamp(0.4, 1.6);
      final double base = score + (ratio - 1) * 16;
      return base.clamp(50, 98);
    }).toList();
    return GenericDetailPage(
      title: '肌群平衡分析',
      subtitle: '今日评分 $score/100 · 薄弱项建议：$weakest',
      leadingIcon: Icons.balance,
      accentColor: AppColors.cyan,
      child: Column(
        children: [
          _BigKPI(
            value: score.toString(),
            unit: '/100',
            subLabel: score >= 88
                ? '四肢发展非常均衡 · 继续保持分化训练'
                : score >= 75
                    ? '基本平衡 · 建议每周加强 $weakest 1 次'
                    : '有失衡风险 · 推荐插入专项日补齐 $weakest',
            subColor: score >= 88
                ? AppColors.emerald
                : score >= 75
                    ? AppColors.brand300
                    : AppColors.amber,
            accentColor: AppColors.cyan,
            progress: (score / 100).clamp(0.0, 1.0),
          ),
          const SizedBox(height: 22),
          GlassPanel(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            borderColor: AppColors.cyan.withOpacity(0.2),
            child: Row(
              children: [
                Expanded(
                  child: _MiniStat(
                      label: '腿部容量',
                      value: '${mv.legs.toInt()} kg',
                      color: AppColors.cyan),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 1,
                  height: 38,
                  color: Colors.white.withOpacity(0.08),
                ),
                Expanded(
                  child: _MiniStat(
                      label: '推类容量',
                      value: '${mv.push.toInt()} kg',
                      color: AppColors.purple),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 1,
                  height: 38,
                  color: Colors.white.withOpacity(0.08),
                ),
                Expanded(
                  child: _MiniStat(
                      label: '拉类容量',
                      value: '${mv.pull.toInt()} kg',
                      color: AppColors.emerald),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 1,
                  height: 38,
                  color: Colors.white.withOpacity(0.08),
                ),
                Expanded(
                  child: _MiniStat(
                      label: '核心容量',
                      value: '${mv.core.toInt()} kg',
                      color: AppColors.amber),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SectionCard(
            title: '肌群占比 · 今日训练',
            icon: Icons.pie_chart_outline,
            iconColor: AppColors.cyan,
            child: Column(
              children: [
                _SourceRow(
                    label: '腿部 (建议 45%)',
                    pct: legsP,
                    color: AppColors.cyan,
                    amount: legsTargetKg >= 0
                        ? '再加 ${legsTargetKg.toInt()} kg 达标'
                        : '${legsTargetKg.abs().toInt()} kg 超配'),
                SizedBox(height: 10),
                _SourceRow(
                    label: '推类 · 胸肩三头 (建议 25%)',
                    pct: pushP,
                    color: AppColors.purple,
                    amount: pushTargetKg >= 0
                        ? '再加 ${pushTargetKg.toInt()} kg 达标'
                        : '${pushTargetKg.abs().toInt()} kg 超配'),
                SizedBox(height: 10),
                _SourceRow(
                    label: '拉类 · 背二头 (建议 22%)',
                    pct: pullP,
                    color: AppColors.emerald,
                    amount: pullTargetKg >= 0
                        ? '再加 ${pullTargetKg.toInt()} kg 达标'
                        : '${pullTargetKg.abs().toInt()} kg 超配'),
                SizedBox(height: 10),
                _SourceRow(
                    label: '核心 (建议 8%)',
                    pct: coreP,
                    color: AppColors.amber,
                    amount: coreTargetKg >= 0
                        ? '再加 ${coreTargetKg.toInt()} kg 达标'
                        : '${coreTargetKg.abs().toInt()} kg 超配'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SectionCard(
            title: '本周每日平衡趋势',
            icon: Icons.show_chart,
            iconColor: AppColors.brand400,
            child: Column(
              children: List.generate(
                weekBal.length,
                (i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 36,
                          child: Text(
                            const ['一', '二', '三', '四', '五', '六', '日'][i],
                            style: TextStyle(
                              color: i == s.todayIndex
                                  ? AppColors.emerald
                                  : AppColors.textTertiary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: LinearProgressIndicator(
                              value: (weekBal[i] / 100).clamp(0.0, 1.0),
                              minHeight: 8,
                              backgroundColor: Colors.white.withOpacity(0.05),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                weekBal[i] >= 85
                                    ? AppColors.emerald
                                    : weekBal[i] >= 72
                                        ? AppColors.cyan
                                        : AppColors.amber,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${weekBal[i].toInt()}',
                          style: TextStyle(
                            color: i == s.todayIndex
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 18),
          SectionCard(
            title: '平衡训练建议',
            icon: Icons.auto_awesome,
            iconColor: AppColors.brand400,
            child: Column(
              children: [
                _Advise(
                    text: score >= 88
                        ? '当前均衡度极高，保持推/拉/腿/核心 45:25:22:8 的配比即可稳步增肌。'
                        : '建议将 $weakest 提升 1 个专项日（如 ${weakest.contains('腿') ? '保加利亚分腿蹲 / 腿弯举' : weakest.contains('推') ? '坐姿推举 / 双杠臂屈伸' : weakest.contains('拉') ? '引体向上 / 单臂划船' : '悬垂举腿 / 杠铃片体侧屈'}）。'),
                SizedBox(height: 10),
                _Advise(
                    text:
                        '每训练 6 周自检一次：相对弱项优先加 5% 容量；若拉类 < 推类 80%，立即插入「拉类强化日」。'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProgressiveOverloadDetailPage extends StatelessWidget {
  const ProgressiveOverloadDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState s = AppState();
    final List<double> trend = s.progressiveTrend.value;
    final int score = s.progressiveOverloadScore;
    final int streak = s.trainingStreak.value;
    final int pr = s.weeklyPRCount;
    final int hit = s.goalHitDays;
    final double lean = s.estimatedLeanGain.value;
    final double consistency = s.trainingConsistencyScore.toDouble();
    final double first = trend.isEmpty ? 0.8 : trend.first;
    final double last = trend.isEmpty ? 1.0 : trend.last;
    final double totalPct = first > 0 ? ((last - first) / first * 100) : 0;
    const List<String> wk = ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7', 'W8'];
    return GenericDetailPage(
      title: '渐进过载追踪',
      subtitle:
          '$score/100 过载指数 · 8 周 ${totalPct >= 0 ? "+" : ""}${totalPct.toStringAsFixed(1)}%',
      leadingIcon: Icons.trending_up,
      accentColor: AppColors.emerald,
      child: Column(
        children: [
          _BigKPI(
            value: score.toString(),
            unit: '/100',
            subLabel: score >= 82
                ? '持续过载 · 预计月增肌 ${(lean * 4 * 0.85).abs().toStringAsFixed(2)} kg 瘦体重'
                : score >= 65
                    ? '稳步推进 · 建议每次训练加重 2.5%'
                    : '刺激不足 · 需在主项上加重量或增组',
            subColor: score >= 82
                ? AppColors.emerald
                : score >= 65
                    ? AppColors.brand300
                    : AppColors.amber,
            accentColor: AppColors.emerald,
            progress: (score / 100).clamp(0.0, 1.0),
          ),
          const SizedBox(height: 22),
          GlassPanel(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: _MiniStat(
                      label: '连续训练',
                      value: '$streak 天',
                      color: AppColors.emerald),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 1,
                  height: 38,
                  color: Colors.white.withOpacity(0.08),
                ),
                Expanded(
                  child: _MiniStat(
                      label: '本周 PR', value: '$pr 次', color: AppColors.purple),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 1,
                  height: 38,
                  color: Colors.white.withOpacity(0.08),
                ),
                Expanded(
                  child: _MiniStat(
                      label: '容量达标', value: '$hit / 7', color: AppColors.cyan),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 1,
                  height: 38,
                  color: Colors.white.withOpacity(0.08),
                ),
                Expanded(
                  child: _MiniStat(
                      label: '规律度',
                      value: '${consistency.toInt()}',
                      color: AppColors.amber),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SectionCard(
            title: '近 8 周渐进过载趋势',
            icon: Icons.show_chart,
            iconColor: AppColors.emerald,
            child: Column(
              children: [
                SizedBox(height: 6),
                _MiniLineRow(
                  values: trend,
                  labels: wk,
                ),
                SizedBox(height: 8),
                Text(
                  totalPct >= 0
                      ? '8 周过载指数 ${totalPct.toStringAsFixed(1)}% 提升 · 健康区间 (+5~15% / 8 周)'
                      : '8 周倒退 ${totalPct.abs().toStringAsFixed(1)}% · 尽快恢复加重节奏',
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SectionCard(
            title: '每周过载情况',
            icon: Icons.calendar_view_week,
            iconColor: AppColors.brand400,
            child: Column(
              children: List.generate(
                trend.length,
                (i) {
                  final bool isPR = i > 0 && (trend[i] - trend[i - 1]) > 0.02;
                  final bool isDeload =
                      i > 0 && (trend[i] - trend[i - 1]) < -0.05;
                  final double maxT = trend.reduce((a, b) => a > b ? a : b);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: _DayBar(
                      label: wk[i],
                      value: (trend[i] * 100).toInt(),
                      unit: 'x',
                      displayValue: '${trend[i].toStringAsFixed(2)}x',
                      maxVal: (maxT * 100 + 5).toInt(),
                      accentColor: isPR
                          ? AppColors.emerald
                          : isDeload
                              ? AppColors.amber
                              : (i == trend.length - 1
                                  ? AppColors.emerald
                                  : AppColors.cyan),
                      isToday: i == trend.length - 1,
                      goalHit: isPR,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 18),
          SectionCard(
            title: '下阶段过载计划',
            icon: Icons.flag,
            iconColor: AppColors.amber,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _GoalTile(
                      title: '主项 2.5% 线性加重',
                      desc: score >= 65
                          ? '深蹲/卧推/硬拉 每次训练 +2.5kg (哑铃 +1kg)'
                          : '当前刺激不足，先 +5% 冲击容量',
                      eta: score >= 80 ? '已达标 · 继续' : '本周执行'),
                  SizedBox(height: 12),
                  _GoalTile(
                      title: '8 周减载安排',
                      desc: '每 8 周第 8 周 容量 × 50% · 强度 × 60%',
                      eta: '距离下一次减载 ${((8 - (trend.length % 8)) % 8)} 周'),
                  SizedBox(height: 12),
                  _GoalTile(
                      title: '预期肌肉增长',
                      desc:
                          '按当前节奏 · 8 周瘦体重 ${(lean * 8 * 0.85).toStringAsFixed(2)} kg',
                      eta: lean >= 0 ? '增肌期' : '减脂期'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BodyCompositionPage extends StatelessWidget {
  const BodyCompositionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState s = AppState();
    final double bfPct = s.estimatedBodyFatPct;
    final double weight = s.estimatedWeightKg;
    final double lean = s.estimatedLeanMassKg;
    final double muscle = s.estimatedSkeletalMuscleKg;
    final int visceral = s.estimatedVisceralFatLevel;
    final int bmr = s.estimatedBMR;
    final double bfMass =
        double.parse((weight * bfPct / 100.0).toStringAsFixed(1));
    final double leanDelta = s.estimatedLeanGain.value;
    final double bfDelta =
        double.parse((-leanDelta * 0.7).toStringAsFixed(1)); // 脂肪反向变化
    final double wDelta =
        double.parse((leanDelta + bfDelta).toStringAsFixed(1));
    final List<double> bf8 = s.bodyFat8Weeks;
    final double bfFirst = bf8.isEmpty ? bfPct : bf8.first;
    final double bfDelta8 = double.parse((bfPct - bfFirst).toStringAsFixed(1));
    final List<double> trend = s.progressiveTrend.value;
    final double prRate = trend.length < 2
        ? 1.0
        : ((trend.last - trend[trend.length - 2]) + 1).clamp(0.8, 1.3);
    // 预测：以当前 PR rate 继续
    final double bfTargetPct = 12.0;
    final double weeksNeeded =
        ((bfPct - bfTargetPct) / (bfDelta8.abs() * 0.9).clamp(0.1, 10))
            .clamp(1.0, 52.0);
    final double muscleTargetKg = 40;
    final double muscleWeeks =
        ((muscleTargetKg - muscle) / (leanDelta * 1.3).clamp(0.05, 3.0))
            .clamp(0.0, 52.0);
    final double bmrDelta = double.parse(
        (bmr - (1710 + prRate * 30)).clamp(-500, 500).toStringAsFixed(0));
    return GenericDetailPage(
      title: '体成分追踪',
      subtitle:
          '体脂率 ${bfPct.toStringAsFixed(1)}% · 骨骼肌 ${(muscle / weight * 100).toStringAsFixed(1)}% (训练推导)',
      leadingIcon: Icons.line_weight,
      accentColor: AppColors.brand400,
      child: Column(
        children: [
          _BigKPI(
            value: weight.toStringAsFixed(1),
            unit: 'kg',
            subLabel: leanDelta >= 0
                ? '周变化：体重 $wDelta kg · 瘦体重 +${leanDelta.abs().toStringAsFixed(2)} kg'
                : '周变化：体重 $wDelta kg · 瘦体重 -${leanDelta.abs().toStringAsFixed(2)} kg',
            subColor: leanDelta >= 0 ? AppColors.emerald : AppColors.amber,
            accentColor: AppColors.brand400,
            progress: (1 - (bfPct / 25)).clamp(0.0, 1.0),
          ),
          SizedBox(height: 22),
          SectionCard(
            title: '核心指标',
            icon: Icons.line_weight,
            child: Column(
              children: [
                _InfoRow(
                    label: '当前体重',
                    value: '${weight.toStringAsFixed(1)} kg',
                    trend:
                        '${wDelta >= 0 ? "+" : ""}${wDelta.toStringAsFixed(1)} kg/周',
                    trendColor:
                        wDelta <= 0 ? AppColors.emerald : AppColors.amber),
                DividerGap(),
                _InfoRow(
                    label: '骨骼肌量',
                    value: '${muscle.toStringAsFixed(1)} kg',
                    trend: leanDelta >= 0
                        ? '+${(leanDelta * 0.6).toStringAsFixed(2)} kg/周'
                        : '${(leanDelta * 0.6).toStringAsFixed(2)} kg/周',
                    trendColor:
                        leanDelta >= 0 ? AppColors.emerald : AppColors.amber),
                DividerGap(),
                _InfoRow(
                    label: '体脂重量',
                    value: '$bfMass kg',
                    trend: '${bfDelta.toStringAsFixed(1)} kg/周',
                    trendColor:
                        bfDelta <= 0 ? AppColors.cyan : AppColors.danger),
                DividerGap(),
                _InfoRow(
                    label: '体脂率',
                    value: '${bfPct.toStringAsFixed(1)}%',
                    trend: '${bfDelta8.toStringAsFixed(1)}% / 8周',
                    trendColor:
                        bfDelta8 <= 0 ? AppColors.emerald : AppColors.amber),
                DividerGap(),
                _InfoRow(
                    label: '内脏脂肪等级',
                    value: '等级 $visceral',
                    trend: visceral <= 3 ? '健康范围' : '建议有氧',
                    trendColor:
                        visceral <= 3 ? AppColors.brand300 : AppColors.amber),
                DividerGap(),
                _InfoRow(
                    label: '基础代谢 (BMR)',
                    value: '$bmr kcal',
                    trend:
                        '${bmrDelta >= 0 ? "+" : ""}${bmrDelta.toStringAsFixed(0)} kcal',
                    trendColor:
                        bmrDelta >= 0 ? AppColors.emerald : AppColors.amber),
              ],
            ),
          ),
          SizedBox(height: 18),
          SectionCard(
            title: '最近 8 周体脂趋势',
            icon: Icons.show_chart,
            iconColor: AppColors.brand400,
            child: Column(
              children: [
                SizedBox(height: 6),
                _MiniLineRow(
                  values: bf8,
                  labels: const [
                    'W1',
                    'W2',
                    'W3',
                    'W4',
                    'W5',
                    'W6',
                    'W7',
                    'W8'
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  bfDelta8 <= 0
                      ? '8 周累计下降 ${bfDelta8.abs().toStringAsFixed(1)}% · 稳步推进 (健康 0.5-1% / 周)'
                      : '8 周累计上升 ${bfDelta8.toStringAsFixed(1)}% · 注意热量赤字',
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 18),
          SectionCard(
            title: '目标与预测',
            icon: Icons.flag,
            iconColor: AppColors.amber,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _GoalTile(
                      title: '第一阶段目标体脂',
                      desc:
                          '$bfTargetPct% (再降 ${(bfPct - bfTargetPct).toStringAsFixed(1)}%)',
                      eta: '约 ${weeksNeeded.toStringAsFixed(0)} 周'),
                  SizedBox(height: 12),
                  _GoalTile(
                      title: '理想肌肉量上限',
                      desc: '$muscleTargetKg kg 骨骼肌',
                      eta:
                          '约 ${muscleWeeks.toStringAsFixed(0)} 周 · 渐进过载 ×${prRate.toStringAsFixed(2)}'),
                  SizedBox(height: 12),
                  _GoalTile(
                      title: '维持期体重',
                      desc:
                          '${(lean / (1 - bfTargetPct / 100)).toStringAsFixed(0)}-${(lean / (1 - (bfTargetPct - 1) / 100)).toStringAsFixed(0)} kg (体脂 ${bfTargetPct.toStringAsFixed(0)}%)',
                      eta: '稳态 · PR rate ${prRate.toStringAsFixed(2)}x'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DayDetailPage extends StatelessWidget {
  final int dayIndex;
  const DayDetailPage({super.key, required this.dayIndex});

  @override
  Widget build(BuildContext context) {
    final AppState s = AppState();
    final String dayName =
        const ['周一', '周二', '周三', '周四', '周五', '周六', '周日'][dayIndex];
    final bool isToday = dayIndex == s.todayIndex;
    return GenericDetailPage(
      title: '$dayName 训练与健康详情',
      subtitle: isToday ? '今日 · 正在进行中' : '历史数据',
      leadingIcon: Icons.calendar_today,
      accentColor: isToday ? AppColors.emerald : AppColors.brand500,
      child: Column(
        children: [
          GlassPanel(
            padding: const EdgeInsets.all(18),
            borderColor: (isToday ? AppColors.emerald : AppColors.brand500)
                .withOpacity(0.2),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _MiniStat(
                        label: '训练容量',
                        value: '${s.weekVolume.value[dayIndex].toInt()} kg',
                        color: AppColors.brand500,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 46,
                      color: Colors.white.withOpacity(0.08),
                    ),
                    Expanded(
                      child: _MiniStat(
                        label: '消耗热量',
                        value: '${s.weekCalories.value[dayIndex]} kcal',
                        color: AppColors.amber,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 46,
                      color: Colors.white.withOpacity(0.08),
                    ),
                    Expanded(
                      child: _MiniStat(
                        label: '有氧时长',
                        value: '${s.weekCardio.value[dayIndex]} min',
                        color: AppColors.cyan,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _MiniStat(
                        label: '静息心率',
                        value: '${s.weekRestingHR.value[dayIndex]} bpm',
                        color: AppColors.cyan,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 46,
                      color: Colors.white.withOpacity(0.08),
                    ),
                    Expanded(
                      child: _MiniStat(
                        label: '深睡',
                        value:
                            '${s.weekDeepSleep.value[dayIndex].toStringAsFixed(1)} h',
                        color: AppColors.emerald,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Builder(
            builder: (BuildContext ctx) {
              final List<Map<String, dynamic>> source = isToday
                  ? s.todaysExercises.value
                  : <Map<String, dynamic>>[
                      <String, dynamic>{
                        'name': '杠铃深蹲',
                        'sets': 4,
                        'reps': 10,
                        'weight': 105.0,
                        'muscle': '腿部',
                      },
                      <String, dynamic>{
                        'name': '罗马尼亚硬拉',
                        'sets': 3,
                        'reps': 12,
                        'weight': 80.0,
                        'muscle': '腿部',
                      },
                      <String, dynamic>{
                        'name': '高位下拉',
                        'sets': 4,
                        'reps': 10,
                        'weight': 60.0,
                        'muscle': '拉类',
                      },
                    ];
              return SectionCard(
                title: isToday
                    ? '今日训练动作清单 · 共 ${source.length} 个动作'
                    : '$dayName 训练动作清单 · 共 ${source.length} 个动作',
                icon: Icons.fitness_center,
                child: Column(
                  children: List<Widget>.generate(
                    source.length,
                    (int i) {
                      final Map<String, dynamic> e = source[i];
                      final int sets = (e['sets'] as num).toInt();
                      final int reps = (e['reps'] as num).toInt();
                      final double w = (e['weight'] as num).toDouble();
                      final int vol = (w * sets * reps).toInt();
                      final String muscle = (e['muscle'] as String?) ?? '综合';
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: i == source.length - 1 ? 0 : 4,
                        ),
                        child: Column(
                          children: <Widget>[
                            _WorkoutRow(
                                name: e['name'] as String,
                                sets: '$sets × $reps',
                                vol: '$vol kg',
                                muscle: muscle),
                            if (i != source.length - 1) DividerGap(),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============ 通用子组件 ============

class _BigKPI extends StatelessWidget {
  final String value;
  final String unit;
  final String subLabel;
  final Color subColor;
  final Color accentColor;
  final double progress;
  const _BigKPI({
    required this.value,
    required this.unit,
    required this.subLabel,
    required this.subColor,
    required this.accentColor,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(20),
      borderColor: accentColor.withOpacity(0.22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ProgressBar(
            progress: progress,
            height: 10,
            gradientColors: [accentColor, accentColor.withOpacity(0.5)],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: subColor,
                size: 13,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  subLabel,
                  style: TextStyle(
                    color: subColor,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayBar extends StatelessWidget {
  final String label;
  final int value;
  final String unit;
  final String? displayValue;
  final int maxVal;
  final Color accentColor;
  final bool isToday;
  final bool goalHit;
  const _DayBar({
    required this.label,
    required this.value,
    required this.unit,
    required this.maxVal,
    required this.accentColor,
    this.displayValue,
    this.isToday = false,
    this.goalHit = false,
  });

  @override
  Widget build(BuildContext context) {
    final double ratio = maxVal == 0 ? 0 : (value / maxVal).clamp(0.0, 1.0);
    return Row(
      children: [
        SizedBox(
          width: 36,
          child: Text(
            label,
            style: TextStyle(
              color: isToday ? AppColors.emerald : AppColors.textTertiary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 10,
              backgroundColor: Colors.white.withOpacity(0.05),
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (goalHit) ...[
              Icon(Icons.check_circle,
                  size: 12, color: AppColors.emerald.withOpacity(0.9)),
              const SizedBox(width: 4),
            ],
            Text(
              '${displayValue ?? value} $unit',
              style: TextStyle(
                color: isToday ? Colors.white : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SourceRow extends StatelessWidget {
  final String label;
  final double pct;
  final Color color;
  final String amount;
  const _SourceRow({
    required this.label,
    required this.pct,
    required this.color,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${(pct * 100).toInt()}% · $amount',
                style: TextStyle(
                  color: color,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 7,
              backgroundColor: Colors.white.withOpacity(0.05),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _Advise extends StatelessWidget {
  final String text;
  const _Advise({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: AppColors.brand500.withOpacity(0.16),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.lightbulb_outline,
              color: AppColors.brand300,
              size: 12,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12.5,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final String trend;
  final Color trendColor;
  const _InfoRow({
    required this.label,
    required this.value,
    required this.trend,
    required this.trendColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.5,
            ),
          ),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                trend,
                style: TextStyle(
                  color: trendColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoalTile extends StatelessWidget {
  final String title;
  final String desc;
  final String eta;
  const _GoalTile({
    required this.title,
    required this.desc,
    required this.eta,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.amber,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.amber.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              eta,
              style: const TextStyle(
                color: AppColors.amber,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniLineRow extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  const _MiniLineRow({
    required this.values,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    final double min = values.reduce((a, b) => a < b ? a : b);
    final double max = values.reduce((a, b) => a > b ? a : b);
    const double barMax = 64;
    return SizedBox(
      height: 90,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(values.length, (i) {
          final double h = (values[i] - min) / (max - min);
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 22,
                height: 16 + h * barMax,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      AppColors.brand500.withOpacity(0.7),
                      AppColors.purple.withOpacity(0.95),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                labels[i],
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _WorkoutRow extends StatelessWidget {
  final String name;
  final String sets;
  final String vol;
  final String muscle;
  const _WorkoutRow({
    required this.name,
    required this.sets,
    required this.vol,
    required this.muscle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            sets,
            style: const TextStyle(
              color: AppColors.brand300,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            vol,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.brand500.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              muscle,
              style: const TextStyle(
                color: AppColors.brand300,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
