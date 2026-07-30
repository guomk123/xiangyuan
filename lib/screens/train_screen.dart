import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_widgets.dart';
import '../widgets/ui_components.dart';
import '../widgets/common_widgets.dart';
import '../app_state.dart';
import 'detail_pages_1.dart';
import 'detail_pages_2.dart';
import 'detail_pages_3.dart';

class TrainScreen extends StatefulWidget {
  const TrainScreen({super.key});

  @override
  State<TrainScreen> createState() => _TrainScreenState();
}

class _TrainScreenState extends State<TrainScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(Duration.zero, () {
      if (mounted) _syncAppStateFromExercises();
    });
  }

  late List<Map<String, dynamic>> exercises = [
    {
      'name': '杠铃平卧推举',
      'subtitle': '4组 × 8-10次 · 目标 80kg',
      'tag': '胸大肌主导',
      'tagColor': AppColors.brand500,
      'status': '已准备',
      'statusColor': AppColors.emerald,
      'imageUrl':
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?auto=format&fit=crop&w=400&q=80',
      'sets': [
        {'weight': '80 kg', 'reps': '10 次'},
        {'weight': '80 kg', 'reps': '10 次'},
        {'weight': '82.5 kg', 'reps': '8 次'},
      ],
    },
    {
      'name': '上斜哑铃推举',
      'subtitle': '3组 × 12次 · 目标 24kg',
      'tag': '上胸强化',
      'tagColor': AppColors.purple,
      'status': '待执行',
      'statusColor': AppColors.textTertiary,
      'imageUrl':
          'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?auto=format&fit=crop&w=400&q=80',
      'sets': [
        {'weight': '24 kg', 'reps': '12 次'},
        {'weight': '24 kg', 'reps': '12 次'},
        {'weight': '24 kg', 'reps': '12 次'},
      ],
    },
    {
      'name': '绳索夹胸飞鸟',
      'subtitle': '3组 × 15次 · 目标 17.5kg',
      'tag': '胸肌充血',
      'tagColor': AppColors.cyan,
      'status': '待执行',
      'statusColor': AppColors.textTertiary,
      'imageUrl':
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?auto=format&fit=crop&w=400&q=80',
      'sets': [
        {'weight': '17.5 kg', 'reps': '15 次'},
        {'weight': '17.5 kg', 'reps': '15 次'},
        {'weight': '17.5 kg', 'reps': '15 次'},
      ],
    },
  ];

  String _getCurrentDate() {
    final now = DateTime.now();
    final weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    return '${now.year}年${now.month}月${now.day}日  星期${weekdays[now.weekday - 1]}';
  }

  ({double volumeKg, int sets, int estKcal}) _summarize(
      List<Map<String, dynamic>> list) {
    double v = 0;
    int s = 0;
    final RegExp numReg = RegExp(r'(\d+(?:\.\d+)?)');
    for (final e in list) {
      final setsList = e['sets'];
      if (setsList is! List) continue;
      for (final sItem in setsList) {
        if (sItem is! Map) continue;
        s++;
        final String w = (sItem['weight'] ?? '0').toString();
        final String r = (sItem['reps'] ?? '0').toString();
        final double? wNum =
            double.tryParse(numReg.firstMatch(w)?.group(0) ?? '');
        final double? rNum =
            double.tryParse(numReg.firstMatch(r)?.group(0) ?? '');
        if (wNum != null && rNum != null) {
          v += (wNum * rNum);
        } else if (wNum != null) {
          v += wNum;
        }
      }
    }
    final int kcal = (v * 0.035).round();
    return (volumeKg: v, sets: s, estKcal: kcal);
  }

  // 按动作名关键字粗分到肌群
  String _muscleCategoryOf(String name) {
    final String n = name.toLowerCase();
    if (n.contains('深蹲') ||
        n.contains('硬拉') ||
        n.contains('腿举') ||
        n.contains('箭步') ||
        n.contains('弓步') ||
        n.contains('腿弯') ||
        n.contains('腿屈伸') ||
        n.contains('小腿') ||
        n.contains('提踵')) {
      return 'legs';
    }
    if (n.contains('卧推') ||
        n.contains('推举') ||
        n.contains('肩推') ||
        n.contains('推胸') ||
        n.contains('夹胸') ||
        n.contains('飞鸟') ||
        n.contains('侧平举') ||
        n.contains('前平举') ||
        n.contains('臂屈伸') ||
        n.contains('三头')) {
      return 'push';
    }
    if (n.contains('引体') ||
        n.contains('划船') ||
        n.contains('下拉') ||
        n.contains('高拉') ||
        n.contains('面拉') ||
        n.contains('二头') ||
        n.contains('弯举')) {
      return 'pull';
    }
    if (n.contains('平板支撑') ||
        n.contains('卷腹') ||
        n.contains('仰卧') ||
        n.contains('俄罗斯转体') ||
        n.contains('核心') ||
        n.contains('腹部')) {
      return 'core';
    }
    return 'push';
  }

  void _syncAppStateFromExercises() {
    final AppState s = AppState();
    final info = _summarize(exercises);
    s.setTodaysSets(info.sets);
    double legs = 0;
    double push = 0;
    double pull = 0;
    double core = 0;
    final RegExp numReg = RegExp(r'(\d+(?:\.\d+)?)');
    for (final e in exercises) {
      final String name = (e['name'] ?? '').toString();
      final String cat = _muscleCategoryOf(name);
      final setsList = e['sets'];
      if (setsList is! List) continue;
      double vForThis = 0;
      for (final sItem in setsList) {
        if (sItem is! Map) continue;
        final String w = (sItem['weight'] ?? '0').toString();
        final String r = (sItem['reps'] ?? '0').toString();
        final double? wNum =
            double.tryParse(numReg.firstMatch(w)?.group(0) ?? '');
        final double? rNum =
            double.tryParse(numReg.firstMatch(r)?.group(0) ?? '');
        if (wNum != null && rNum != null) {
          vForThis += wNum * rNum;
        } else if (wNum != null) {
          vForThis += wNum;
        }
      }
      if (cat == 'legs') {
        legs += vForThis;
      } else if (cat == 'push') {
        push += vForThis;
      } else if (cat == 'pull') {
        pull += vForThis;
      } else {
        core += vForThis;
      }
    }
    final double sum = legs + push + pull + core;
    if (sum < 1) {
      legs = info.volumeKg * 0.6;
      push = info.volumeKg * 0.2;
      pull = info.volumeKg * 0.15;
      core = info.volumeKg * 0.05;
    }
    s.setTodayMuscleVolume(
      MuscleVolume(
        legs: legs,
        push: push,
        pull: pull,
        core: core,
        total: info.volumeKg > 0 ? info.volumeKg : (legs + push + pull + core),
      ),
    );
    // 同步动作清单到数据页联动
    s.todaysExercises.value =
        exercises.map<Map<String, dynamic>>((Map<String, dynamic> e) {
      final num? w = e['weight'] as num?;
      final num? sets = e['completedSets'] as num?;
      final num? reps = e['completedReps'] as num?;
      final String name = (e['name'] as String?) ?? '训练动作';
      return <String, dynamic>{
        'name': name,
        'sets': (sets ?? e['sets'] as num).toInt(),
        'reps': (reps ?? e['reps'] as num).toInt(),
        'weight': (w ?? 0).toDouble(),
        'muscle': () {
          final String n = name;
          if (n.contains('蹲') ||
              n.contains('硬拉') ||
              n.contains('腿') ||
              n.contains('弓步') ||
              n.contains('保加利亚')) return '腿部';
          if (n.contains('推') ||
              n.contains('卧推') ||
              n.contains('肩推') ||
              n.contains('推举') ||
              n.contains('胸')) return '推类';
          if (n.contains('拉') ||
              n.contains('划船') ||
              n.contains('下拉') ||
              n.contains('引体') ||
              n.contains('背')) return '拉类';
          if (n.contains('卷腹') ||
              n.contains('平板') ||
              n.contains('腹') ||
              n.contains('core')) return '核心';
          return '综合';
        }(),
      };
    }).toList();
    s.recomputeDerivedFromVolume();
  }

  void _startWorkoutSession() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => _WorkoutSessionPage(
          exercises: exercises,
        ),
      ),
    );
  }

  void _tapProfile() {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => const ProfileDetailPage(),
      ),
    );
  }

  void _tapPROBadge() {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => const PROMembershipPage(),
      ),
    );
  }

  Future<void> _tapAIGenerator() async {
    final result = await Navigator.of(context).push<List<Map<String, dynamic>>>(
      MaterialPageRoute(
        builder: (ctx) => const AIPlanGeneratorPage(),
      ),
    );
    if (result != null && result.isNotEmpty && mounted) {
      setState(() {
        exercises = result.map((e) => Map<String, dynamic>.from(e)).toList();
      });
      _syncAppStateFromExercises();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('AI 已生成今日 ${exercises.length} 个动作，已替换首页训练计划'),
          backgroundColor: AppColors.darkSurface,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(milliseconds: 1100),
        ),
      );
    }
  }

  void _tapMuscleMap() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => const MuscleFatiguePage(),
      ),
    );
  }

  Future<void> _tapAdjustExercises() async {
    final snapshot = List<Map<String, dynamic>>.from(exercises);
    final result = await Navigator.of(context).push<List<Map<String, dynamic>>>(
      MaterialPageRoute(
        builder: (ctx) => AdjustExercisesPage(initialExercises: snapshot),
      ),
    );
    if (result != null && result.isNotEmpty && mounted) {
      final filtered =
          result.where((e) => (e['enabled'] ?? true) == true).toList();
      setState(() {
        exercises = filtered.map((e) => Map<String, dynamic>.from(e)).toList();
      });
      _syncAppStateFromExercises();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('训练已更新：${exercises.length} 个动作已应用'),
          backgroundColor: AppColors.darkSurface,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(milliseconds: 1000),
        ),
      );
    }
  }

  void _tapExerciseSectionHeader() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => const WeeklyPlanPage(),
      ),
    );
  }

  void _tapExerciseItem(int index) {
    final ex = exercises[index];
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => ExerciseDetailPage(exercise: ex),
      ),
    );
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.darkSurface,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 800),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    try {
      return _buildMainContent();
    } catch (e, s) {
      debugPrint('TrainScreen build error: $e\n$s');
      return _SafeFallback(title: '训练');
    }
  }

  Widget _buildMainContent() {
    return SafeArea(
      top: true,
      bottom: false,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserHeader(),
            const SizedBox(height: 28),
            _buildQuickActions(),
            const SizedBox(height: 20),
            _buildStartCTA(),
            const SizedBox(height: 28),
            _buildExerciseList(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.selectionClick();
            _showToast('日期与状态');
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.emerald,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _getCurrentDate(),
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                '早上好，Alex 👋',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _tapProfile,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.brand500,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brandGlow,
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const NetworkImagePlaceholder(
                  url:
                      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
                  width: 44,
                  height: 44,
                  borderRadius: 22,
                ),
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: GestureDetector(
                  onTap: _tapPROBadge,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.brand500,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.darkBase,
                        width: 1.5,
                      ),
                    ),
                    child: const Text(
                      'PRO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
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

  Widget _buildStartCTA() {
    final int count = exercises.length;
    int totalSets = 0;
    for (final e in exercises) {
      final sets = e['sets'];
      if (sets is List) totalSets += sets.length;
    }
    final est = (totalSets * 2.2).round().clamp(20, 120);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GlassPanel(
          padding: const EdgeInsets.all(20),
          borderColor: AppColors.brand500.withOpacity(0.25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.brand500.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.brand500.withOpacity(0.3),
                      ),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: AppColors.brand400,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AI 推荐训练已就绪',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '$count 个动作 · $totalSets 组 · 预估 ~$est 分钟',
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.emerald.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.bolt,
                          color: AppColors.emerald,
                          size: 12,
                        ),
                        SizedBox(width: 3),
                        Text(
                          '推荐',
                          style: TextStyle(
                            color: AppColors.emerald,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              GradientButton(
                text: '开启今日 AI 推荐训练',
                icon: Icons.play_arrow,
                onPressed: _startWorkoutSession,
              ),
            ],
          ),
        ),
        Positioned(
          right: -28,
          top: -28,
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: AppColors.brand500.withOpacity(0.14),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.brand500.withOpacity(0.18),
                  blurRadius: 60,
                  spreadRadius: 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.0,
      children: [
        _buildActionCard(
          icon: Icons.auto_awesome,
          iconColor: AppColors.purple,
          title: 'AI 计划生成器',
          subtitle: '定制专属周周期',
          onTap: _tapAIGenerator,
        ),
        _buildActionCard(
          icon: Icons.accessibility,
          iconColor: AppColors.cyan,
          title: '肌肉疲劳热力图',
          subtitle: '胸部恢复度 98%',
          onTap: _tapMuscleMap,
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: iconColor.withOpacity(0.3),
              ),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: '今日训练动作清单 (${exercises.length}个动作)',
          icon: Icons.playlist_add_check,
          onTap: _tapExerciseSectionHeader,
          trailing: Text(
            '微调动作',
            style: TextStyle(
              color: AppColors.brand300,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          onTrailingTap: _tapAdjustExercises,
        ),
        const SizedBox(height: 12),
        ...List.generate(
          exercises.length,
          (index) => Padding(
            padding: EdgeInsets.only(
              bottom: index < exercises.length - 1 ? 10 : 0,
            ),
            child: _buildExerciseItem(index),
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseItem(int index) {
    final exercise = exercises[index];
    return GlassCard(
      padding: const EdgeInsets.all(14),
      onTap: () => _tapExerciseItem(index),
      child: Row(
        children: [
          NetworkImagePlaceholder(
            url: exercise['imageUrl'],
            width: 52,
            height: 52,
            borderRadius: 12,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  exercise['subtitle'],
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 6),
                BadgeTag(
                  text: exercise['tag'],
                  backgroundColor:
                      (exercise['tagColor'] as Color).withOpacity(0.2),
                  textColor: (exercise['tagColor'] as Color).withOpacity(0.9),
                  borderColor: (exercise['tagColor'] as Color).withOpacity(0.3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                exercise['status'],
                style: TextStyle(
                  color: exercise['statusColor'],
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Icon(
                Icons.chevron_right,
                color: AppColors.textTertiary,
                size: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WorkoutSessionPage extends StatefulWidget {
  final List<Map<String, dynamic>> exercises;

  const _WorkoutSessionPage({
    required this.exercises,
  });

  @override
  State<_WorkoutSessionPage> createState() => _WorkoutSessionPageState();
}

class _WorkoutSessionPageState extends State<_WorkoutSessionPage> {
  int currentExerciseIndex = 0;
  int restTimerSeconds = 45;
  List<bool> setCompletions = [false, false, false];

  @override
  void initState() {
    super.initState();
    _startRestTimer();
  }

  ({double volumeKg, int sets, int estKcal}) _summarizeSession(
      {bool completed = false}) {
    final AppState s = AppState();
    int totalSets = 0;
    final RegExp numReg = RegExp(r'(\d+(?:\.\d+)?)');
    double vol = 0;
    for (final e in widget.exercises) {
      final setsList = e['sets'];
      if (setsList is! List) continue;
      final perEx = setsList.length;
      totalSets += perEx;
      for (final sItem in setsList) {
        if (sItem is! Map) continue;
        final String w = (sItem['weight'] ?? '0').toString();
        final String r = (sItem['reps'] ?? '0').toString();
        final double? wNum =
            double.tryParse(numReg.firstMatch(w)?.group(0) ?? '');
        final double? rNum =
            double.tryParse(numReg.firstMatch(r)?.group(0) ?? '');
        if (wNum != null && rNum != null) {
          vol += (wNum * rNum) * (completed ? 1 : 0.5);
        } else if (wNum != null) {
          vol += wNum * (completed ? 1 : 0.5);
        }
      }
    }
    final int kcal = (vol * 0.035).round().clamp(10, 2500);
    final int cardio =
        (totalSets * (completed ? 1.6 : 0.8)).round().clamp(3, 90);
    if (completed || totalSets >= 2) {
      s.addTodayVolume(vol);
      s.addTodayCalories(kcal);
      s.addTodayCardio(cardio);
    }
    return (volumeKg: vol, sets: totalSets, estKcal: kcal);
  }

  void _closeWorkoutSession({bool forceComplete = false}) {
    HapticFeedback.mediumImpact();
    final info = _summarizeSession(
        completed: forceComplete ||
            currentExerciseIndex + 1 >= widget.exercises.length);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          forceComplete
              ? '训练完成 🎉 容量 ${info.volumeKg.toStringAsFixed(0)} kg · 消耗 ${info.estKcal} kcal'
              : info.sets >= 2
                  ? '训练记录已累计至数据页 · 容量 ${info.volumeKg.toStringAsFixed(0)} kg'
                  : '训练已结束',
        ),
        backgroundColor: AppColors.darkSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 1400),
      ),
    );
    Navigator.of(context).pop();
  }

  void _startRestTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      if (restTimerSeconds > 0) {
        setState(() {
          restTimerSeconds--;
        });
        _startRestTimer();
      }
    });
  }

  void _toggleSetCheck(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      setCompletions[index] = !setCompletions[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.exercises[currentExerciseIndex];
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
              backgroundColor: AppColors.darkSurface,
              elevation: 0,
              scrolledUnderElevation: 0,
              toolbarHeight: kToolbarHeight + 6,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
                ),
                onPressed: _closeWorkoutSession,
              ),
              title: Column(
                children: [
                  Text(
                    '沉浸训练模式',
                    style: TextStyle(
                      color: AppColors.brand300,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    '胸部超负荷增长 Phase 1',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              centerTitle: true,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      backgroundColor: AppColors.brand500.withOpacity(0.15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      '暂停',
                      style: TextStyle(
                        color: AppColors.brand400,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: SafeArea(
          top: false,
          bottom: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              120 + MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              children: [
                _buildCurrentExerciseCard(current),
                const SizedBox(height: 20),
                _buildHRAndTimerRow(),
                const SizedBox(height: 20),
                _buildSetsTracker(current),
              ],
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: GradientButton(
              text: '完成本动作，进入下一个',
              onPressed: _closeWorkoutSession,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentExerciseCard(Map<String, dynamic> exercise) {
    return Container(
      height: 240,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.brand500.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandGlow,
            blurRadius: 30,
            spreadRadius: -5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned.fill(
              child: NetworkImagePlaceholder(
                url: exercise['imageUrl'],
                width: double.infinity,
                height: double.infinity,
                borderRadius: 24,
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
                      AppColors.darkBase.withOpacity(0.4),
                      AppColors.darkBase,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '动作 ${currentExerciseIndex + 1} / ${widget.exercises.length}',
                    style: const TextStyle(
                      color: AppColors.emerald,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    exercise['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '控制沉肩 2秒，爆发式推起',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
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

  Widget _buildHRAndTimerRow() {
    return Row(
      children: [
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: AppColors.danger,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '实时心率',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: const [
                        Text(
                          '142',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(width: 3),
                        Text(
                          'bpm',
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.brand400.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.timer_outlined,
                    color: AppColors.brand400,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '组间休息倒计时',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '00:${restTimerSeconds.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: restTimerSeconds < 10
                            ? AppColors.danger
                            : AppColors.brand300,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSetsTracker(Map<String, dynamic> exercise) {
    final sets = List<Map<String, dynamic>>.from(exercise['sets']);
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: const [
                Expanded(
                  child: Center(
                    child: Text(
                      '组数',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '目标重量',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '目标次数',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '打卡完成',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Divider(height: 0.5, thickness: 0.5),
          ),
          ...List.generate(
            sets.length,
            (i) => Padding(
              padding: EdgeInsets.only(
                bottom: i < sets.length - 1 ? 10 : 0,
              ),
              child: _buildSetRow(i + 1, sets[i], i),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetRow(
    int setNum,
    Map<String, dynamic> setData,
    int completionIndex,
  ) {
    final isCompleted = setCompletions[completionIndex];
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.brand500.withOpacity(0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted
              ? AppColors.brand500.withOpacity(0.25)
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.brand500
                      : Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  setNum.toString(),
                  style: TextStyle(
                    color: isCompleted ? Colors.white : AppColors.textTertiary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                setData['weight'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                setData['reps'],
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: () => _toggleSetCheck(completionIndex),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color:
                        isCompleted ? AppColors.brand500 : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isCompleted
                          ? AppColors.brand500
                          : AppColors.textTertiary.withOpacity(0.5),
                      width: 1.5,
                    ),
                    boxShadow: isCompleted
                        ? [
                            BoxShadow(
                              color: AppColors.brandGlow,
                              blurRadius: 10,
                              spreadRadius: -3,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    Icons.check,
                    color: isCompleted ? Colors.white : Colors.transparent,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SafeFallback extends StatelessWidget {
  final String title;
  const _SafeFallback({required this.title});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.darkBase,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.darkCard.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
                child: const Text(
                  '页面加载中，请尝试重新打开此 Tab，内容会自动恢复。',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
