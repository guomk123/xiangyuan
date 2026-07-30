import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_widgets.dart';
import '../widgets/ui_components.dart';
import '../widgets/common_widgets.dart';
import '../widgets/detail_page_template.dart';
import 'adjust_detail_pages.dart';

class AIPlanGeneratorPage extends StatefulWidget {
  const AIPlanGeneratorPage({super.key});

  @override
  State<AIPlanGeneratorPage> createState() => _AIPlanGeneratorPageState();
}

class _AIPlanGeneratorPageState extends State<AIPlanGeneratorPage> {
  int selectedGoalIndex = 0;
  int selectedSplitIndex = 1;
  double targetVolume = 75;
  int daysPerWeek = 4;
  bool isGenerating = false;

  final List<String> goals = const ['增肌', '减脂', '力量提升', '体能塑形'];
  final List<String> splits = const ['全身训练', '上下肢分化', '推拉腿(PPL)', '胸/背/腿'];
  final List<IconData> goalIcons = const [
    Icons.fitness_center,
    Icons.local_fire_department,
    Icons.bolt,
    Icons.sports_gymnastics,
  ];
  final List<Color> goalColors = const [
    AppColors.brand400,
    AppColors.danger,
    AppColors.amber,
    AppColors.cyan,
  ];

  @override
  Widget build(BuildContext context) {
    return GenericDetailPage(
      title: 'AI 计划生成器',
      subtitle: '6 个维度 · 48 小时数据训练模型',
      leadingIcon: Icons.auto_awesome,
      accentColor: AppColors.purple,
      child: Column(
        children: [
          SectionCard(
            title: '训练目标',
            icon: Icons.flag,
            accentColor: goalColors[selectedGoalIndex],
            child: Column(
              children: [
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.7,
                  children: List.generate(
                    goals.length,
                    (i) => _buildGoalChip(i),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SectionCard(
            title: '训练分化方式',
            icon: Icons.view_week,
            accentColor: AppColors.cyan,
            child: Column(
              children: [
                ...List.generate(
                  splits.length,
                  (i) => Padding(
                    padding:
                        EdgeInsets.only(bottom: i < splits.length - 1 ? 8 : 0),
                    child: _buildSplitOption(i),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SectionCard(
            title: '每周训练频率',
            icon: Icons.date_range,
            accentColor: AppColors.amber,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ...List.generate(
                      6,
                      (i) => _buildDayBadge(i + 2),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$daysPerWeek 天 / 周',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'AI 推荐 4 天',
                        style: TextStyle(
                          color: AppColors.brand300,
                          fontSize: 12,
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
            title: '训练容量偏好',
            icon: Icons.tune,
            accentColor: AppColors.brand400,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      '低强度',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      '中高强度',
                      style: TextStyle(
                        color: AppColors.brand300,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '高强度',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
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
                    value: targetVolume,
                    min: 40,
                    max: 100,
                    divisions: 12,
                    onChanged: (v) {
                      setState(() => targetVolume = v);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          GradientButton(
            text:
                '开始 AI 生成今日训练（${goals[selectedGoalIndex]} · ${splits[selectedSplitIndex]}）',
            icon: Icons.auto_awesome,
            onPressed: () async {
              HapticFeedback.mediumImpact();
              setState(() => isGenerating = true);
              await Future.delayed(const Duration(seconds: 2));
              if (!mounted) return;
              setState(() => isGenerating = false);
              final generated = _buildGeneratedExercises();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'AI 已为你生成 ${generated.length} 个动作（${goals[selectedGoalIndex]} · $daysPerWeek 天/周）'),
                  backgroundColor: AppColors.darkSurface,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  duration: const Duration(milliseconds: 1200),
                ),
              );
              Navigator.of(context).pop(generated);
            },
          ),
          if (isGenerating) ...[
            const SizedBox(height: 14),
            LinearProgressIndicator(
              backgroundColor: Colors.white.withOpacity(0.06),
              valueColor: const AlwaysStoppedAnimation(AppColors.brand400),
            ),
          ],
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _buildGeneratedExercises() {
    final goal = goals[selectedGoalIndex];
    final split = splits[selectedSplitIndex];
    final vol = targetVolume;
    final baseSets = (4 +
            (vol >= 80
                ? 1
                : vol <= 55
                    ? -1
                    : 0))
        .clamp(3, 6);
    final List<Map<String, dynamic>> pool = <Map<String, dynamic>>[];
    const Color brand = AppColors.brand500;
    const Color cyan = AppColors.cyan;
    const Color emerald = AppColors.emerald;
    const Color amber = AppColors.amber;
    const Color danger = AppColors.danger;
    void addEx({
      required String name,
      required String subtitle,
      required String tag,
      required Color tagColor,
      required String status,
      required Color statusColor,
      required String image,
      required List<Map<String, String>> sets,
    }) {
      pool.add({
        'name': name,
        'subtitle': subtitle,
        'tag': tag,
        'tagColor': tagColor,
        'status': status,
        'statusColor': statusColor,
        'imageUrl': image,
        'sets': sets,
      });
    }

    final imgBench =
        'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?auto=format&fit=crop&w=400&q=80';
    final imgDumbbell =
        'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?auto=format&fit=crop&w=400&q=80';
    final imgCable =
        'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?auto=format&fit=crop&w=400&q=80';
    final imgSquat =
        'https://images.unsplash.com/photo-1551632811-561732d1e306?auto=format&fit=crop&w=400&q=80';
    final imgDeadlift =
        'https://images.unsplash.com/photo-1598971639058-fab0d8fe640c?auto=format&fit=crop&w=400&q=80';
    final imgPull =
        'https://images.unsplash.com/photo-1598971861713-54ad16a1e93c?auto=format&fit=crop&w=400&q=80';
    final imgOhp =
        'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?auto=format&fit=crop&w=400&q=80';
    final imgRow =
        'https://images.unsplash.com/photo-1584735175097-719d848f8449?auto=format&fit=crop&w=400&q=80';
    final repScheme = goal == '力量提升'
        ? '5次'
        : goal == '减脂'
            ? '15次'
            : goal == '体能塑形'
                ? '12次'
                : '10次';
    final lighterWeight = goal == '力量提升'
        ? ' 重'
        : goal == '减脂'
            ? ' 轻'
            : '';
    List<Map<String, String>> mkSets(String baseWeight, String rep) {
      return List.generate(
        baseSets,
        (i) => {'weight': '$baseWeight$lighterWeight', 'reps': rep},
      );
    }

    if (split == '全身训练') {
      addEx(
        name: '杠铃深蹲',
        subtitle: '$baseSets组 × $repScheme · 目标 100kg',
        tag: '股四头肌主导',
        tagColor: danger,
        status: '热身 +',
        statusColor: amber,
        image: imgSquat,
        sets: mkSets('100 kg', repScheme),
      );
      addEx(
        name: '杠铃平卧推举',
        subtitle: '$baseSets组 × $repScheme · 目标 70kg',
        tag: '胸大肌主导',
        tagColor: brand,
        status: '核心动作',
        statusColor: emerald,
        image: imgBench,
        sets: mkSets('70 kg', repScheme),
      );
      addEx(
        name: '引体向上',
        subtitle: '$baseSets组 × $repScheme · 体重',
        tag: '背阔肌主导',
        tagColor: cyan,
        status: '核心动作',
        statusColor: emerald,
        image: imgPull,
        sets: mkSets('BW', repScheme),
      );
      addEx(
        name: '站姿哑铃推举',
        subtitle: '${(baseSets - 1).clamp(3, 6)}组 × $repScheme · 目标 16kg',
        tag: '三角肌中束',
        tagColor: amber,
        status: '辅助',
        statusColor: AppColors.textSecondary,
        image: imgOhp,
        sets: mkSets('16 kg', repScheme),
      );
    } else if (split == '上下肢分化') {
      addEx(
        name: '杠铃深蹲',
        subtitle: '$baseSets组 × $repScheme · 目标 110kg',
        tag: '股四头肌 + 臀大肌',
        tagColor: danger,
        status: '下肢主项',
        statusColor: danger,
        image: imgSquat,
        sets: mkSets('110 kg', repScheme),
      );
      addEx(
        name: '罗马尼亚硬拉',
        subtitle: '$baseSets组 × $repScheme · 目标 90kg',
        tag: '腘绳肌 + 臀大肌',
        tagColor: amber,
        status: '下肢主项',
        statusColor: danger,
        image: imgDeadlift,
        sets: mkSets('90 kg', repScheme),
      );
      addEx(
        name: '保加利亚分腿蹲',
        subtitle: '${(baseSets - 1).clamp(3, 6)}组 × $repScheme · 每侧 20kg',
        tag: '单腿力量',
        tagColor: emerald,
        status: '下肢辅助',
        statusColor: AppColors.textSecondary,
        image: imgDumbbell,
        sets: mkSets('20 kg', repScheme),
      );
      addEx(
        name: '杠铃平卧推举',
        subtitle: '$baseSets组 × $repScheme · 目标 80kg',
        tag: '胸大肌',
        tagColor: brand,
        status: '上肢主项',
        statusColor: emerald,
        image: imgBench,
        sets: mkSets('80 kg', repScheme),
      );
      addEx(
        name: '俯身杠铃划船',
        subtitle: '$baseSets组 × $repScheme · 目标 65kg',
        tag: '背阔肌厚度',
        tagColor: cyan,
        status: '上肢主项',
        statusColor: emerald,
        image: imgRow,
        sets: mkSets('65 kg', repScheme),
      );
    } else if (split == '推拉腿(PPL)') {
      addEx(
        name: '站姿杠铃推举 (OHP)',
        subtitle: '$baseSets组 × $repScheme · 目标 55kg',
        tag: '推日 · 三角肌前束',
        tagColor: amber,
        status: '推日主项',
        statusColor: amber,
        image: imgOhp,
        sets: mkSets('55 kg', repScheme),
      );
      addEx(
        name: '上斜哑铃推举',
        subtitle: '$baseSets组 × $repScheme · 目标 26kg',
        tag: '推日 · 上胸',
        tagColor: brand,
        status: '推日辅助',
        statusColor: brand,
        image: imgDumbbell,
        sets: mkSets('26 kg', repScheme),
      );
      addEx(
        name: '引体向上',
        subtitle: '$baseSets组 × $repScheme · 体重+10kg',
        tag: '拉日 · 背阔肌',
        tagColor: cyan,
        status: '拉日主项',
        statusColor: cyan,
        image: imgPull,
        sets: mkSets('BW+10kg', repScheme),
      );
      addEx(
        name: '单臂哑铃划船',
        subtitle: '$baseSets组 × $repScheme · 目标 28kg',
        tag: '拉日 · 斜方肌中束',
        tagColor: emerald,
        status: '拉日辅助',
        statusColor: emerald,
        image: imgRow,
        sets: mkSets('28 kg', repScheme),
      );
      addEx(
        name: '杠铃深蹲',
        subtitle: '$baseSets组 × $repScheme · 目标 120kg',
        tag: '腿日 · 股四头肌',
        tagColor: danger,
        status: '腿日主项',
        statusColor: danger,
        image: imgSquat,
        sets: mkSets('120 kg', repScheme),
      );
      addEx(
        name: '腿举',
        subtitle: '$baseSets组 × $repScheme · 目标 200kg',
        tag: '腿日 · 股四头肌',
        tagColor: danger,
        status: '腿日辅助',
        statusColor: danger,
        image: imgCable,
        sets: mkSets('200 kg', repScheme),
      );
    } else {
      // 胸/背/腿
      addEx(
        name: '杠铃平卧推举',
        subtitle: '$baseSets组 × $repScheme · 目标 85kg',
        tag: '胸日 · 胸大肌主导',
        tagColor: brand,
        status: '胸日主项',
        statusColor: emerald,
        image: imgBench,
        sets: mkSets('85 kg', repScheme),
      );
      addEx(
        name: '绳索夹胸飞鸟',
        subtitle: '${(baseSets - 1).clamp(3, 6)}组 × $repScheme · 17.5kg',
        tag: '胸日 · 胸肌中缝',
        tagColor: cyan,
        status: '孤立',
        statusColor: AppColors.textSecondary,
        image: imgCable,
        sets: mkSets('17.5 kg', repScheme),
      );
      addEx(
        name: '引体向上',
        subtitle: '$baseSets组 × $repScheme · 体重',
        tag: '背日 · 背阔肌宽度',
        tagColor: emerald,
        status: '背日主项',
        statusColor: emerald,
        image: imgPull,
        sets: mkSets('BW', repScheme),
      );
      addEx(
        name: '俯身杠铃划船',
        subtitle: '$baseSets组 × $repScheme · 70kg',
        tag: '背日 · 背阔肌厚度',
        tagColor: cyan,
        status: '背日主项',
        statusColor: emerald,
        image: imgRow,
        sets: mkSets('70 kg', repScheme),
      );
      addEx(
        name: '杠铃硬拉',
        subtitle: '$baseSets组 × $repScheme · 目标 140kg',
        tag: '腿日 · 后链整体',
        tagColor: danger,
        status: '全身王牌',
        statusColor: danger,
        image: imgDeadlift,
        sets: mkSets('140 kg', repScheme),
      );
      addEx(
        name: '杠铃深蹲',
        subtitle: '$baseSets组 × $repScheme · 目标 120kg',
        tag: '腿日 · 股四头肌',
        tagColor: danger,
        status: '腿日主项',
        statusColor: danger,
        image: imgSquat,
        sets: mkSets('120 kg', repScheme),
      );
    }
    // 如果是减脂目标，追加两个收尾
    if (goal == '减脂') {
      addEx(
        name: '波比跳 (Burpees)',
        subtitle: '3组 × 30秒 · 体重',
        tag: '燃脂收尾',
        tagColor: danger,
        status: '代谢训练',
        statusColor: danger,
        image: imgPull,
        sets: [
          {'weight': 'BW', 'reps': '30 秒'},
          {'weight': 'BW', 'reps': '30 秒'},
          {'weight': 'BW', 'reps': '30 秒'},
        ],
      );
    }
    if (goal == '体能塑形') {
      addEx(
        name: '农夫行走',
        subtitle: '3组 × 40米 · 每只手 32kg',
        tag: '核心与握力',
        tagColor: emerald,
        status: '体能训练',
        statusColor: emerald,
        image: imgDumbbell,
        sets: [
          {'weight': '32 kg', 'reps': '40 米'},
          {'weight': '32 kg', 'reps': '40 米'},
          {'weight': '32 kg', 'reps': '40 米'},
        ],
      );
    }
    return pool;
  }

  Widget _buildGoalChip(int index) {
    final selected = selectedGoalIndex == index;
    final color = goalColors[index];
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => selectedGoalIndex = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: selected
              ? color.withOpacity(0.15)
              : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? color.withOpacity(0.5)
                : Colors.white.withOpacity(0.08),
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.18),
                    blurRadius: 20,
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            Icon(
              goalIcons[index],
              color: selected ? color : AppColors.textSecondary,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                goals[index],
                style: TextStyle(
                  color: selected ? color : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSplitOption(int index) {
    final selected = selectedSplitIndex == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => selectedSplitIndex = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color:
              selected ? AppColors.cyan.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.cyan.withOpacity(0.35)
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
                color: selected ? AppColors.cyan : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? AppColors.cyan
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
                  Text(
                    splits[index],
                    style: TextStyle(
                      color: selected ? Colors.white : AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [
                      '适合初学者 · 每个肌群每周刺激 2 次',
                      '经典 · 恢复与刺激平衡',
                      '高阶 · 每个肌群深度刺激',
                      '经典传统 · 每天一个大肌群',
                    ][index],
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

  Widget _buildDayBadge(int day) {
    final selected = daysPerWeek == day;
    final isRecommended = day == 4;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => daysPerWeek = day);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.amber.withOpacity(0.2)
              : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppColors.amber.withOpacity(0.6)
                : Colors.white.withOpacity(0.08),
            width: selected ? 1.5 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$day',
              style: TextStyle(
                color: selected ? AppColors.amber : AppColors.textSecondary,
                fontSize: 14,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
            if (isRecommended)
              Container(
                width: 3,
                height: 3,
                margin: const EdgeInsets.only(top: 1),
                decoration: BoxDecoration(
                  color: AppColors.brand400,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class MuscleFatiguePage extends StatelessWidget {
  const MuscleFatiguePage({super.key});

  @override
  Widget build(BuildContext context) {
    final muscles = const [
      {'name': '胸部', 'level': 98, 'color': AppColors.emerald, 'status': '恢复极佳'},
      {'name': '背部', 'level': 64, 'color': AppColors.cyan, 'status': '轻度刺激'},
      {'name': '肩部', 'level': 22, 'color': AppColors.amber, 'status': '中度疲劳'},
      {
        'name': '肱二头肌',
        'level': 42,
        'color': AppColors.brand400,
        'status': '轻度疲劳'
      },
      {
        'name': '肱三头肌',
        'level': 18,
        'color': AppColors.danger,
        'status': '建议恢复中'
      },
      {
        'name': '股四头肌',
        'level': 88,
        'color': AppColors.emerald,
        'status': '恢复良好'
      },
      {'name': '腘绳肌', 'level': 72, 'color': AppColors.cyan, 'status': '轻度刺激'},
      {'name': '臀部', 'level': 80, 'color': AppColors.cyan, 'status': '恢复良好'},
    ];
    return GenericDetailPage(
      title: '肌肉疲劳热力图',
      subtitle: '基于近 48 小时训练后恢复度估算',
      leadingIcon: Icons.accessibility,
      accentColor: AppColors.cyan,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: AspectRatio(
                    aspectRatio: 0.55,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.brand500.withOpacity(0.1),
                            AppColors.emerald.withOpacity(0.05),
                          ],
                        ),
                        border: Border.all(
                          color: AppColors.brand500.withOpacity(0.25),
                        ),
                      ),
                      child: Stack(
                        children: const [
                          _MuscleSpot(
                            top: 0.18,
                            left: 0.22,
                            size: 30,
                            color: AppColors.emerald,
                          ),
                          _MuscleSpot(
                            top: 0.18,
                            right: 0.22,
                            size: 30,
                            color: AppColors.emerald,
                          ),
                          _MuscleSpot(
                            top: 0.28,
                            left: 0.3,
                            size: 22,
                            color: AppColors.brand400,
                          ),
                          _MuscleSpot(
                            top: 0.28,
                            right: 0.3,
                            size: 22,
                            color: AppColors.brand400,
                          ),
                          _MuscleSpot(
                            top: 0.38,
                            left: 0.28,
                            size: 18,
                            color: AppColors.danger,
                          ),
                          _MuscleSpot(
                            top: 0.42,
                            right: 0.28,
                            size: 18,
                            color: AppColors.amber,
                          ),
                          _MuscleSpot(
                            top: 0.66,
                            left: 0.2,
                            size: 36,
                            color: AppColors.emerald,
                          ),
                          _MuscleSpot(
                            top: 0.66,
                            right: 0.2,
                            size: 36,
                            color: AppColors.emerald,
                          ),
                          _MuscleSpot(
                            top: 0.8,
                            left: 0.24,
                            size: 22,
                            color: AppColors.cyan,
                          ),
                          _MuscleSpot(
                            top: 0.8,
                            right: 0.24,
                            size: 22,
                            color: AppColors.cyan,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '恢复度阈值',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildLegendItem(AppColors.emerald, '优秀', '> 80'),
                      const SizedBox(height: 8),
                      _buildLegendItem(AppColors.cyan, '良好', '50 - 80'),
                      const SizedBox(height: 8),
                      _buildLegendItem(AppColors.brand400, '轻度', '30 - 50'),
                      const SizedBox(height: 8),
                      _buildLegendItem(AppColors.amber, '中度', '15 - 30'),
                      const SizedBox(height: 8),
                      _buildLegendItem(AppColors.danger, '重度', '< 15'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: '各肌群恢复度明细',
            icon: Icons.format_list_bulleted,
            child: Column(
              children: [
                ...List.generate(
                  muscles.length,
                  (i) => Padding(
                    padding: EdgeInsets.only(
                      bottom: i < muscles.length - 1 ? 12 : 0,
                    ),
                    child: _buildMuscleRow(muscles[i]),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SectionCard(
            title: 'AI 训练建议',
            icon: Icons.lightbulb_outline,
            accentColor: AppColors.amber,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              child: Text(
                '建议今日重点训练：胸部、肱三头肌。肩部处于恢复窗口已恢复良好；下肢肌群等待完全恢复后再进行深蹲类大重量训练。',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.7,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, String range) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color.withOpacity(0.25),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Text(
          range,
          style: TextStyle(
            color: AppColors.textTertiary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildMuscleRow(Map<String, dynamic> muscle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: (muscle['color'] as Color).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: (muscle['color'] as Color).withOpacity(0.35),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.circle,
                    color: muscle['color'] as Color,
                    size: 10,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  muscle['name'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  '${muscle['level']}%',
                  style: TextStyle(
                    color: muscle['color'] as Color,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  muscle['status'] as String,
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: ProgressBar(
            progress: (muscle['level'] as int) / 100,
            height: 8,
            gradientColors: [
              (muscle['color'] as Color),
              (muscle['color'] as Color).withOpacity(0.6),
            ],
          ),
        ),
      ],
    );
  }
}

class _MuscleSpot extends StatelessWidget {
  final double top;
  final double? left;
  final double? right;
  final double size;
  final Color color;

  const _MuscleSpot({
    required this.top,
    this.left,
    this.right,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top * 100,
      left: left != null ? left! * 100 : null,
      right: right != null ? right! * 100 : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.35),
          border: Border.all(
            color: color.withOpacity(0.8),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 14,
              spreadRadius: -2,
            ),
          ],
        ),
      ),
    );
  }
}

class AdjustExercisesPage extends StatefulWidget {
  final List<Map<String, dynamic>> initialExercises;

  const AdjustExercisesPage({
    super.key,
    required this.initialExercises,
  });

  @override
  State<AdjustExercisesPage> createState() => _AdjustExercisesPageState();
}

class _AdjustExercisesPageState extends State<AdjustExercisesPage> {
  late List<Map<String, dynamic>> _exercises;

  double _weightPercent = 0;
  String _repPlan = '标准 (AI 推荐)';
  String _restPlanName = '标准';
  int _restIsolation = 90;
  int _restCompound = 150;

  @override
  void initState() {
    super.initState();
    _exercises = List.generate(
      widget.initialExercises.length,
      (i) => {
        ...widget.initialExercises[i],
        'enabled': true,
      },
    );
  }

  int _calcEstimatedMinutes() {
    final enabled = _exercises.where((e) => e['enabled'] == true).toList();
    int total = 10;
    for (final ex in enabled) {
      final sets = List.from(ex['sets'] ?? const []);
      final compound =
          (ex['name'] as String).contains(RegExp(r'(杠铃|深蹲|硬拉|卧推|划船)'));
      total += sets.length *
              (compound ? _restCompound ~/ 60 : _restIsolation ~/ 60) +
          sets.length;
    }
    return total.clamp(20, 180);
  }

  String _buildWeightLabel() {
    if (_weightPercent == 0) return '+0%（AI 推荐）';
    if (_weightPercent > 0) return '+${_weightPercent.toStringAsFixed(1)}%';
    return '${_weightPercent.toStringAsFixed(1)}%';
  }

  String _buildRestLabel() {
    String fmt(int sec) {
      if (sec >= 60)
        return '${(sec / 60).toStringAsFixed(sec % 60 == 0 ? 0 : 1)}min';
      return '${sec}s';
    }

    return '$_restPlanName (${fmt(_restIsolation)} / ${fmt(_restCompound)})';
  }

  Future<void> _openWeightPage() async {
    final result = await Navigator.of(context).push<double>(
      MaterialPageRoute(
          builder: (ctx) => WeightAdjustPage(currentPercent: _weightPercent)),
    );
    if (result != null && mounted) {
      setState(() {
        _weightPercent = result;
        _applyWeightPercent(result);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('所有动作重量已调整 $result%'),
          backgroundColor: AppColors.darkSurface,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  void _applyWeightPercent(double percent) {
    final factor = 1 + percent / 100;
    for (int i = 0; i < _exercises.length; i++) {
      final sets = List<Map<String, dynamic>>.from(_exercises[i]['sets'] ?? []);
      final updatedSets = sets.map((s) {
        final wStr = s['weight'] as String;
        final match = RegExp(r'([\d.]+)').firstMatch(wStr);
        if (match == null) return s;
        final baseVal = double.tryParse(match.group(1) ?? '');
        if (baseVal == null) return s;
        final newVal = baseVal * factor;
        final suffix = wStr.substring(match.end).trim();
        final formatted = newVal == newVal.roundToDouble()
            ? newVal.round().toString()
            : newVal.toStringAsFixed(1);
        return {'weight': '$formatted $suffix'.trim(), 'reps': s['reps']};
      }).toList();
      _exercises[i] = {..._exercises[i], 'sets': updatedSets};
    }
  }

  Future<void> _openRepsSetsPage() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
          builder: (ctx) => RepsSetsAdjustPage(currentPlan: _repPlan)),
    );
    if (result != null && mounted) {
      setState(() {
        _repPlan = result;
        _applyRepPlan(result);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('组数次数方案：$result'),
          backgroundColor: AppColors.darkSurface,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  void _applyRepPlan(String planName) {
    Map<String, dynamic> scheme = {
          '标准 (AI 推荐)': {'sets': 4, 'repsMin': 8, 'repsMax': 12},
          '高强度力量': {'sets': 5, 'repsMin': 3, 'repsMax': 6},
          '肌质耐力': {'sets': 4, 'repsMin': 15, 'repsMax': 20},
          '超级组组合': {'sets': 4, 'repsMin': 10, 'repsMax': 12, 'tag': '超级组'},
          '渐进阶梯': {'sets': 4, 'repsMin': 6, 'repsMax': 12, 'tag': '阶梯'},
          '降组 (Drop Set)': {
            'sets': 3,
            'repsMin': 12,
            'repsMax': 15,
            'tag': 'Drop'
          },
        }[planName] ??
        {'sets': 4, 'repsMin': 8, 'repsMax': 12};
    final setsCount = scheme['sets'] as int;
    final rMin = scheme['repsMin'] as int;
    final rMax = scheme['repsMax'] as int;
    for (int i = 0; i < _exercises.length; i++) {
      final sets = <Map<String, dynamic>>[];
      for (int s = 0; s < setsCount; s++) {
        final reps = s == setsCount - 1 ? '$rMin 次' : '$rMax 次';
        final baseSets = List.from(_exercises[i]['sets'] ?? const []);
        final oldWeight = s < baseSets.length
            ? (baseSets[s] as Map)['weight'] as String? ?? '— kg'
            : (baseSets.isNotEmpty
                ? (baseSets[0] as Map)['weight'] as String? ?? '— kg'
                : '— kg');
        sets.add({'weight': oldWeight, 'reps': reps});
      }
      _exercises[i] = {..._exercises[i], 'sets': sets};
    }
  }

  Future<void> _openRestPage() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (ctx) => RestTimerAdjustPage(currentPlan: _buildRestLabel()),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _restPlanName = result['planName'] as String;
        _restIsolation = result['isolation'] as int;
        _restCompound = result['compound'] as int;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('休息方案：$_restPlanName 已应用'),
          backgroundColor: AppColors.darkSurface,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  Future<void> _openLibrary() async {
    final existingNames = _exercises.map((e) => e['name'] as String).toList();
    final result = await Navigator.of(context).push<List<Map<String, dynamic>>>(
      MaterialPageRoute(
        builder: (ctx) => ExerciseLibraryPage(existingNames: existingNames),
      ),
    );
    if (result != null && result.isNotEmpty && mounted) {
      setState(() {
        for (final ex in result) {
          _exercises.add({...ex, 'enabled': true});
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('已添加 ${result.length} 个动作'),
          backgroundColor: AppColors.darkSurface,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(milliseconds: 900),
        ),
      );
    }
  }

  Future<void> _editSingleExercise(int index) async {
    final cur = _exercises[index];
    final match = RegExp(r'([\d.]+)').firstMatch(
      (List<Map<String, dynamic>>.from(cur['sets'] ?? const [])).isNotEmpty
          ? (cur['sets'][0] as Map)['weight'] as String? ?? '0'
          : '0',
    );
    final curPct = 0.0;
    final curVal = double.tryParse(match?.group(1) ?? '0') ?? 0;
    final TextEditingController ctrl =
        TextEditingController(text: curVal.toStringAsFixed(0));
    final result = await showDialog<double>(
      context: context,
      builder: (ctx) {
        double pct = curPct;
        return StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            backgroundColor: AppColors.darkSurface,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              '编辑 ${cur['name']}',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '整体重量偏差 (%)',
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 6),
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
                    value: pct,
                    min: -20,
                    max: 20,
                    divisions: 16,
                    onChanged: (v) => setDialogState(() => pct = v),
                  ),
                ),
                Center(
                  child: Text(
                    pct >= 0
                        ? '+${pct.toStringAsFixed(1)}%'
                        : '${pct.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: pct == 0
                          ? AppColors.textSecondary
                          : pct > 0
                              ? AppColors.danger
                              : AppColors.cyan,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('取消',
                    style: TextStyle(color: AppColors.textTertiary)),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(pct),
                child: Text(
                  '应用',
                  style: TextStyle(
                      color: AppColors.brand300, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        );
      },
    );
    if (result != null && mounted) {
      setState(() {
        final factor = 1 + result / 100;
        final sets =
            List<Map<String, dynamic>>.from(_exercises[index]['sets'] ?? []);
        _exercises[index] = {
          ..._exercises[index],
          'sets': sets.map((s) {
            final wStr = s['weight'] as String;
            final m = RegExp(r'([\d.]+)').firstMatch(wStr);
            if (m == null) return s;
            final base = double.tryParse(m.group(1) ?? '');
            if (base == null) return s;
            final newVal = base * factor;
            final formatted = newVal == newVal.roundToDouble()
                ? newVal.round().toString()
                : newVal.toStringAsFixed(1);
            final suffix = wStr.substring(m.end).trim();
            return {...s, 'weight': '$formatted $suffix'.trim()};
          }).toList(),
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final estMins = _calcEstimatedMinutes();
    final enabledCount = _exercises.where((e) => e['enabled'] == true).length;
    return GenericDetailPage(
      title: '微调今日训练',
      subtitle: '共 $enabledCount / ${_exercises.length} 个动作 · 预估 ${estMins} 分钟',
      leadingIcon: Icons.playlist_add_check,
      accentColor: AppColors.brand400,
      child: Column(
        children: [
          SectionCard(
            title: '快速调整',
            icon: Icons.tune,
            child: Column(
              children: [
                InfoTile(
                  icon: Icons.plus_one,
                  label: '整体重量',
                  value: _buildWeightLabel(),
                  iconColor: AppColors.brand400,
                  valueColor: _weightPercent == 0
                      ? AppColors.brand300
                      : _weightPercent > 0
                          ? AppColors.danger
                          : AppColors.cyan,
                  trailingIcon: Icons.chevron_right,
                  onTap: _openWeightPage,
                ),
                const DividerGap(),
                InfoTile(
                  icon: Icons.repeat,
                  label: '组数 × 次数',
                  value: _repPlan,
                  iconColor: AppColors.cyan,
                  valueColor: AppColors.cyan.withOpacity(0.9),
                  trailingIcon: Icons.chevron_right,
                  onTap: _openRepsSetsPage,
                ),
                const DividerGap(),
                InfoTile(
                  icon: Icons.timer_outlined,
                  label: '组间休息',
                  value: _buildRestLabel(),
                  iconColor: AppColors.amber,
                  valueColor: AppColors.amber.withOpacity(0.9),
                  trailingIcon: Icons.chevron_right,
                  onTap: _openRestPage,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SectionCard(
            title: '动作顺序与启用状态',
            description: '点击左侧手柄可单独编辑动作重量；右侧开关可跳过今日动作',
            icon: Icons.list_alt,
            accentColor: AppColors.cyan,
            child: Column(
              children: [
                ...List.generate(
                  _exercises.length,
                  (i) => Column(
                    children: [
                      if (i > 0) const DividerGap(),
                      _buildExerciseTile(i),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GlassCard(
            onTap: _openLibrary,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.emerald.withOpacity(0.35),
                    ),
                  ),
                  child: const Icon(
                    Icons.add_circle_outline,
                    color: AppColors.emerald,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        '从动作库添加动作',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '12 类 · 1200+ 动作，AI 推荐排序',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textTertiary,
                  size: 18,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          GradientButton(
            text: '保存并应用调整 (修改 $enabledCount 个动作)',
            icon: Icons.check,
            onPressed: () {
              HapticFeedback.mediumImpact();
              final output = List<Map<String, dynamic>>.from(_exercises);
              Navigator.of(context).pop(output);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseTile(int index) {
    final ex = _exercises[index];
    final disabled = (ex['enabled'] ?? true) == false;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: disabled ? 0.55 : 1,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => _editSingleExercise(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.brand500.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: AppColors.brand500.withOpacity(0.25)),
                ),
                child: const Icon(
                  Icons.tune,
                  color: AppColors.brand300,
                  size: 16,
                ),
              ),
            ),
            const SizedBox(width: 8),
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
                  Text(
                    ex['name'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      decoration: disabled ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    ex['subtitle'],
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  BadgeTag(
                    text: ex['tag'],
                    backgroundColor: (ex['tagColor'] as Color).withOpacity(0.2),
                    textColor: ex['tagColor'] as Color,
                    borderColor: (ex['tagColor'] as Color).withOpacity(0.3),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 36,
              height: 22,
              child: Switch(
                value: ex['enabled'] as bool? ?? true,
                onChanged: (v) {
                  HapticFeedback.selectionClick();
                  setState(() =>
                      _exercises[index] = {..._exercises[index], 'enabled': v});
                },
                activeColor: AppColors.brand400,
                activeTrackColor: AppColors.brand400.withOpacity(0.3),
                inactiveTrackColor: Colors.white.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
