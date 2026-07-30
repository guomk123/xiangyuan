import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_widgets.dart';
import '../widgets/ui_components.dart';
import '../widgets/common_widgets.dart';
import '../widgets/detail_page_template.dart';
import 'detail_pages_1.dart' show CircleBadge, OutlineButton;
import 'train_screen.dart';

class WeeklyPlanPage extends StatelessWidget {
  const WeeklyPlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final days = [
      {'label': '周一', 'tag': '推 · 胸肩三', 'title': '杠铃平卧推举 5×5', 'color': AppColors.brand400, 'done': true},
      {'label': '周二', 'tag': '拉 · 背二头', 'title': '硬拉 6×3', 'color': AppColors.cyan, 'done': true},
      {'label': '周三', 'tag': '腿 · 下半身', 'title': '深蹲 4×8', 'color': AppColors.amber, 'done': true},
      {'label': '周四', 'tag': '推 · 变式', 'title': '哑铃上斜 4×10', 'color': AppColors.brand400, 'done': false, 'today': true},
      {'label': '周五', 'tag': '拉 · 变式', 'title': '引体向上 4×8', 'color': AppColors.cyan, 'done': false},
      {'label': '周六', 'tag': '主动恢复', 'title': '30 分钟低强度有氧', 'color': AppColors.emerald, 'done': false},
      {'label': '周日', 'tag': '休息日', 'title': '完全休息 · 拉伸', 'color': AppColors.textTertiary, 'done': false},
    ];

    return GenericDetailPage(
      title: '本周训练计划',
      subtitle: '推拉腿分化 · 第 3/4 周超负荷',
      leadingIcon: Icons.date_range,
      accentColor: AppColors.cyan,
      child: Column(
        children: [
          SectionCard(
            title: '本周进度概览',
            icon: Icons.donut_large,
            child: Column(
              children: [
                Row(
                  children: [
                    CircularProgress(
                      progress: 3 / 7,
                      size: 72,
                      strokeWidth: 7,
                      progressColor: AppColors.cyan,
                      center: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            '3',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            '已完成',
                            style: TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 18),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InfoTileCompact(
                            icon: Icons.local_fire_department,
                            label: '本周消耗',
                            value: '3,820 kcal',
                            iconColor: AppColors.danger,
                          ),
                          SizedBox(height: 8),
                          InfoTileCompact(
                            icon: Icons.timer_outlined,
                            label: '累计时长',
                            value: '7 小时 42 分',
                            iconColor: AppColors.purple,
                          ),
                          SizedBox(height: 8),
                          InfoTileCompact(
                            icon: Icons.trending_up,
                            label: '总容量变化',
                            value: '+6.8% 高于上周',
                            iconColor: AppColors.emerald,
                            valueColor: AppColors.emerald,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          SectionCard(
            title: '每日训练安排',
            icon: Icons.calendar_view_week,
            accentColor: AppColors.cyan,
            child: Column(
              children: [
                ...List.generate(
                  days.length,
                  (i) => Column(
                    children: [
                      if (i > 0) const DividerGap(),
                      _buildDayRow(days[i], () {
                        if ((days[i]['today'] ?? false) == true) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => const TrainScreen(),
                            ),
                          );
                        }
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          GradientButton(
            text: '查看完整周期 (12 周)',
            icon: Icons.timeline,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildDayRow(Map<String, dynamic> day, VoidCallback? onTap) {
    final isToday = (day['today'] ?? false) == true;
    final isDone = (day['done'] ?? false) == true;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: isToday
              ? (day['color'] as Color).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isToday
                ? (day['color'] as Color).withOpacity(0.4)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDone
                    ? (day['color'] as Color).withOpacity(0.2)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDone
                      ? (day['color'] as Color).withOpacity(0.4)
                      : Colors.white.withOpacity(0.08),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isToday)
                    Text(
                      'TODAY',
                      style: TextStyle(
                        color: day['color'] as Color,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    )
                  else
                    Icon(
                      isDone ? Icons.check : Icons.circle,
                      color: isDone
                          ? day['color'] as Color
                          : AppColors.textTertiary.withOpacity(0.4),
                      size: isDone ? 16 : 8,
                    ),
                  const SizedBox(height: 2),
                  Text(
                    day['label'] as String,
                    style: TextStyle(
                      color: isDone || isToday
                          ? Colors.white
                          : AppColors.textTertiary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    day['title'] as String,
                    style: TextStyle(
                      color:
                          isDone || isToday ? Colors.white : AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      decorationColor: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  BadgeTag(
                    text: day['tag'] as String,
                    backgroundColor:
                        (day['color'] as Color).withOpacity(0.15),
                    textColor: day['color'] as Color,
                    borderColor: Colors.transparent,
                  ),
                ],
              ),
            ),
            if (isToday)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: day['color'] as Color,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: (day['color'] as Color).withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: -4,
                    ),
                  ],
                ),
                child: const Text(
                  '开始',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class InfoTileCompact extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;
  final Color? valueColor;

  const InfoTileCompact({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: iconColor ?? AppColors.brand400,
          size: 14,
        ),
        const SizedBox(width: 6),
        Text(
          '$label  ',
          style: TextStyle(
            color: AppColors.textTertiary,
            fontSize: 11,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class ExerciseDetailPage extends StatelessWidget {
  final Map<String, dynamic> exercise;

  const ExerciseDetailPage({
    super.key,
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    final sets = List<Map<String, dynamic>>.from(exercise['sets'] ?? []);
    final tagColor = exercise['tagColor'] as Color? ?? AppColors.brand400;
    return GenericDetailPage(
      title: exercise['name'] as String,
      subtitle: exercise['tag'] as String? ?? '复合动作',
      leadingIcon: Icons.fitness_center,
      accentColor: tagColor,
      child: Column(
        children: [
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: tagColor.withOpacity(0.3)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: NetworkImagePlaceholder(
                      url: exercise['imageUrl'] as String? ?? '',
                      width: double.infinity,
                      height: double.infinity,
                      borderRadius: 20,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.darkBase.withOpacity(0.85),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 14,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BadgeTag(
                                text: exercise['status'] ?? '标准动作',
                                backgroundColor: tagColor.withOpacity(0.2),
                                textColor: tagColor,
                                borderColor: tagColor.withOpacity(0.35),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                exercise['subtitle'] ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.brand500,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.brandGlow,
                                blurRadius: 20,
                                spreadRadius: -4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          SectionCard(
            title: '训练目标方案',
            icon: Icons.flag,
            accentColor: tagColor,
            child: Column(
              children: [
                ...List.generate(
                  sets.length,
                  (i) => Column(
                    children: [
                      if (i > 0) const DividerGap(),
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: tagColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: tagColor.withOpacity(0.35),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${i + 1}',
                              style: TextStyle(
                                color: tagColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '目标重量  ${sets[i]['weight']}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            sets[i]['reps'] as String,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.chevron_right,
                            color: AppColors.textTertiary,
                            size: 16,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SectionCard(
            title: 'AI 动作要点',
            icon: Icons.lightbulb_outline,
            accentColor: AppColors.amber,
            child: Column(
              children: [
                ...List.generate(3, (i) {
                  final points = const [
                    '下放至胸肌中下部附近 (胸骨剑突位置)，控制 2 秒离心阶段',
                    '推起时保持肩胛骨收紧，不要耸肩，肘关节微内收',
                    '锁定时不要过度超伸肘关节，避免肱骨前移造成肩峰撞击',
                  ];
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: i == 1 ? 10 : 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleBadge(
                          text: '${i + 1}',
                          color: AppColors.amber,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              points[i],
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                height: 1.6,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionCard(
            title: '个人历史最佳 (PR)',
            icon: Icons.emoji_events,
            accentColor: AppColors.amber,
            child: Column(
              children: [
                InfoTile(
                  icon: Icons.workspace_premium,
                  label: '1RM 预测',
                  value: '98.2 kg',
                  iconColor: AppColors.amber,
                  valueColor: AppColors.amber,
                ),
                DividerGap(),
                InfoTile(
                  icon: Icons.analytics,
                  label: '最大训练重量',
                  value: '90 kg × 4 (上周三)',
                  iconColor: AppColors.brand400,
                ),
                DividerGap(),
                InfoTile(
                  icon: Icons.trending_up,
                  label: '30 天平均容量',
                  value: '+14.6% 增长',
                  iconColor: AppColors.emerald,
                  valueColor: AppColors.emerald,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: OutlinedIconButton(
                  text: '替换动作',
                  icon: Icons.swap_horiz,
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: GradientButton(
                  text: '在今日训练中启动',
                  icon: Icons.play_arrow,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OutlinedIconButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onPressed;

  const OutlinedIconButton({
    super.key,
    required this.text,
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.brand500.withOpacity(0.4),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppColors.brand300,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: const TextStyle(
                color: AppColors.brand300,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
