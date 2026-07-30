import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

IconData _slotIcon(String slot) {
  switch (slot) {
    case '早餐':
      return Icons.free_breakfast;
    case '午餐':
      return Icons.lunch_dining;
    case '晚餐':
      return Icons.dinner_dining;
    default:
      return Icons.restaurant;
  }
}

class _DietMeal {
  final String title;
  final List<String> dishes;
  final String time;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  const _DietMeal({
    required this.title,
    required this.dishes,
    required this.time,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}

class _DietDay {
  final String weekday;
  final _DietMeal breakfast;
  final _DietMeal lunch;
  final _DietMeal dinner;

  const _DietDay({
    required this.weekday,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
  });

  int get totalCalories =>
      breakfast.calories + lunch.calories + dinner.calories;
  int get totalProtein => breakfast.protein + lunch.protein + dinner.protein;
  int get totalCarbs => breakfast.carbs + lunch.carbs + dinner.carbs;
  int get totalFat => breakfast.fat + lunch.fat + dinner.fat;
}

const _DietDay _mondayDiet = _DietDay(
  weekday: '周一 · 推日训练 (胸/肩/三头)',
  breakfast: _DietMeal(
    title: '高蛋白增肌早餐',
    dishes: <String>['全麦吐司 2 片', '全蛋 2 个 + 蛋白 2 个', '燕麦奶 300ml', '蓝莓 100g'],
    time: '08:00',
    calories: 580,
    protein: 42,
    carbs: 62,
    fat: 18,
  ),
  lunch: _DietMeal(
    title: '鸡胸藜麦高纤维午餐',
    dishes: <String>['煎鸡胸 220g', '三色藜麦饭 150g', '西兰花 200g', '烤红薯 120g'],
    time: '12:45',
    calories: 920,
    protein: 72,
    carbs: 96,
    fat: 24,
  ),
  dinner: _DietMeal(
    title: '三文鱼糙米恢复晚餐',
    dishes: <String>['三文鱼 180g', '糙米饭 120g', '芦笋 180g', '牛油果 1/4'],
    time: '19:30',
    calories: 900,
    protein: 56,
    carbs: 92,
    fat: 26,
  ),
);

const _DietDay _tuesdayDiet = _DietDay(
  weekday: '周二 · 拉日训练 (背/二头)',
  breakfast: _DietMeal(
    title: '希腊酸奶燕麦碗',
    dishes: <String>['希腊酸奶 250g', '传统燕麦 50g', '奇亚籽 10g', '杏仁碎 15g', '香蕉半根'],
    time: '08:15',
    calories: 560,
    protein: 44,
    carbs: 60,
    fat: 18,
  ),
  lunch: _DietMeal(
    title: '牛肉西兰花杂粮饭',
    dishes: <String>['瘦牛眼肉 200g', '杂粮饭 180g', '西兰花 200g', '胡萝卜 80g'],
    time: '12:45',
    calories: 950,
    protein: 74,
    carbs: 92,
    fat: 28,
  ),
  dinner: _DietMeal(
    title: '虾仁豆腐时蔬',
    dishes: <String>['虾仁 180g', '嫩豆腐 200g', '菠菜 200g', '藜麦饭 100g', '核桃油 5g'],
    time: '19:30',
    calories: 870,
    protein: 62,
    carbs: 88,
    fat: 24,
  ),
);

const _DietDay _wednesdayDiet = _DietDay(
  weekday: '周三 · 休息日 / 主动恢复',
  breakfast: _DietMeal(
    title: '低卡高纤早餐',
    dishes: <String>['燕麦奶 300ml', '奇亚布丁 25g', '浆果 150g', '坚果 10g'],
    time: '08:30',
    calories: 480,
    protein: 32,
    carbs: 52,
    fat: 18,
  ),
  lunch: _DietMeal(
    title: '鸡胸鹰嘴豆沙拉',
    dishes: <String>['鸡胸 180g', '鹰嘴豆 80g', '混合生菜 150g', '牛油果 1/4', '橄榄油 8g'],
    time: '12:45',
    calories: 780,
    protein: 60,
    carbs: 66,
    fat: 28,
  ),
  dinner: _DietMeal(
    title: '比目鱼时令蔬菜',
    dishes: <String>['比目鱼 200g', '烤南瓜 200g', '芦笋 150g', '野米 60g'],
    time: '19:15',
    calories: 840,
    protein: 54,
    carbs: 86,
    fat: 22,
  ),
);

const _DietDay _thursdayDiet = _DietDay(
  weekday: '周四 · 腿日训练 (深蹲硬拉)',
  breakfast: _DietMeal(
    title: '高碳训练日早餐',
    dishes: <String>['钢切燕麦 70g', '乳清蛋白 30g', '香蕉 1 根', '花生酱 10g', '全蛋 1 个'],
    time: '07:45',
    calories: 680,
    protein: 46,
    carbs: 84,
    fat: 20,
  ),
  lunch: _DietMeal(
    title: '鸡腿肉土豆训练餐',
    dishes: <String>['去骨鸡腿 220g', '烤土豆 250g', '青豆 100g', '羽衣甘蓝 100g'],
    time: '12:30',
    calories: 1020,
    protein: 76,
    carbs: 118,
    fat: 28,
  ),
  dinner: _DietMeal(
    title: '牛肉糙米恢复餐',
    dishes: <String>['瘦牛肉 200g', '糙米饭 150g', '烤彩椒 150g', '菠菜 150g'],
    time: '19:45',
    calories: 940,
    protein: 66,
    carbs: 100,
    fat: 26,
  ),
);

const _DietDay _fridayDiet = _DietDay(
  weekday: '周五 · 推日 (肩/胸/三头)',
  breakfast: _DietMeal(
    title: '蛋白松饼早餐',
    dishes: <String>['燕麦蛋白松饼 2 张', '无糖枫糖浆 10g', '蓝莓 120g', '美式咖啡 1 杯'],
    time: '08:15',
    calories: 560,
    protein: 48,
    carbs: 58,
    fat: 16,
  ),
  lunch: _DietMeal(
    title: '三文鱼全麦便当',
    dishes: <String>['三文鱼 180g', '全麦意面 80g', '樱桃番茄 150g', '橄榄油 8g'],
    time: '12:45',
    calories: 900,
    protein: 66,
    carbs: 92,
    fat: 26,
  ),
  dinner: _DietMeal(
    title: '鸡胸紫薯高纤',
    dishes: <String>['鸡胸 220g', '紫薯 200g', '抱子甘蓝 180g', '腰果 12g'],
    time: '19:30',
    calories: 890,
    protein: 70,
    carbs: 92,
    fat: 22,
  ),
);

const _DietDay _saturdayDiet = _DietDay(
  weekday: '周六 · 拉日 (背/臀)',
  breakfast: _DietMeal(
    title: '周末高蛋白早午餐',
    dishes: <String>['蛋白 3 个 + 全蛋 2 个', '全麦贝果 1 个', '牛油果 1/4', '橙汁 150ml'],
    time: '09:00',
    calories: 640,
    protein: 46,
    carbs: 66,
    fat: 22,
  ),
  lunch: _DietMeal(
    title: '猪里脊糙米',
    dishes: <String>['猪里脊 200g', '糙米饭 150g', '菠菜 200g', '烤番茄 120g'],
    time: '13:15',
    calories: 920,
    protein: 72,
    carbs: 96,
    fat: 24,
  ),
  dinner: _DietMeal(
    title: '鳕鱼时蔬藜麦',
    dishes: <String>['鳕鱼 200g', '藜麦饭 120g', '烤节瓜 180g', '橄榄油 8g'],
    time: '19:45',
    calories: 860,
    protein: 58,
    carbs: 90,
    fat: 22,
  ),
);

const _DietDay _sundayDiet = _DietDay(
  weekday: '周日 · 完全休息日',
  breakfast: _DietMeal(
    title: '低卡水果酸奶碗',
    dishes: <String>['希腊酸奶 220g', '什锦莓果 200g', '低糖麦片 30g', '杏仁 10 颗'],
    time: '09:15',
    calories: 460,
    protein: 34,
    carbs: 56,
    fat: 14,
  ),
  lunch: _DietMeal(
    title: '火鸡牛油果卷',
    dishes: <String>['全麦卷饼 1 张', '火鸡胸 160g', '混合生菜 120g', '牛油果 1/4', '番茄片'],
    time: '13:00',
    calories: 760,
    protein: 56,
    carbs: 68,
    fat: 26,
  ),
  dinner: _DietMeal(
    title: '豆腐蔬菜味噌汤',
    dishes: <String>['嫩豆腐 250g', '海带 20g', '菌菇 150g', '糙米饭 100g', '味噌酱 15g'],
    time: '19:00',
    calories: 820,
    protein: 50,
    carbs: 92,
    fat: 22,
  ),
);

List<_DietDay> _buildWeeklyPlan() {
  return const <_DietDay>[
    _mondayDiet,
    _tuesdayDiet,
    _wednesdayDiet,
    _thursdayDiet,
    _fridayDiet,
    _saturdayDiet,
    _sundayDiet,
  ];
}

_DietDay _todayPlan() {
  final int i = (DateTime.now().weekday - 1) % 7;
  final List<_DietDay> week = _buildWeeklyPlan();
  if (i < 0 || i >= week.length) return week.first;
  return week[i];
}

class DietScreen extends StatefulWidget {
  const DietScreen({super.key});

  @override
  State<DietScreen> createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  @override
  Widget build(BuildContext context) {
    try {
      final _DietDay today = _todayPlan();
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '今日饮食推荐',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '按训练计划定制 · 一周 7 天科学配餐',
                            style: TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildWeeklyButton(context),
                  ],
                ),
                const SizedBox(height: 20),
                _buildTodayBadge(today.weekday, today.totalCalories),
                const SizedBox(height: 16),
                _buildMacroCard(today),
                const SizedBox(height: 24),
                _buildSectionTitle(
                  '今日三餐推荐',
                  Icons.restaurant_menu,
                  AppColors.brand400,
                ),
                const SizedBox(height: 12),
                _DietMealCardCompact(
                  slot: '早餐',
                  accent: AppColors.amber,
                  meal: today.breakfast,
                ),
                const SizedBox(height: 12),
                _DietMealCardCompact(
                  slot: '午餐',
                  accent: AppColors.brand400,
                  meal: today.lunch,
                ),
                const SizedBox(height: 12),
                _DietMealCardCompact(
                  slot: '晚餐',
                  accent: AppColors.cyan,
                  meal: today.dinner,
                ),
                const SizedBox(height: 20),
                _buildAdviceBanner(today.weekday),
              ],
            ),
          ),
        ),
      );
    } catch (e, s) {
      debugPrint('DietScreen build error: $e\n$s');
      return Scaffold(
        backgroundColor: AppColors.darkBase,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '今日饮食推荐',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  '内容加载中，请稍后重试',
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
  }

  Widget _buildWeeklyButton(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        try {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const WeeklyDietPlanPage(),
            ),
          );
        } catch (e, s) {
          debugPrint('Diet weekly push error: $e\n$s');
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xFF4F7CFF), Color(0xFF8B5CF6)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4F7CFF).withOpacity(0.3),
              blurRadius: 22,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.calendar_month, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text(
              '查看一周',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayBadge(String weekdayLabel, int goalKcal) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.brand500.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.brand500.withOpacity(0.28),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.auto_awesome,
            color: AppColors.brand300,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              weekdayLabel,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '目标 $goalKcal kcal',
            style: TextStyle(
              color: AppColors.brand300,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String text, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildMacroCard(_DietDay today) {
    final double eaten = 0.64;
    final int curCal = (today.totalCalories * eaten).round();
    final double calProgress =
        (curCal / _max(1, today.totalCalories)).clamp(0.0, 1.0).toDouble();
    final int pct = (calProgress * 100).toInt();
    final int curPro = (today.totalProtein * eaten).round();
    final int curCarb = (today.totalCarbs * eaten).round();
    final int curFat = (today.totalFat * eaten).round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard.withOpacity(0.75),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.37),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '今日摄入目标',
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$curCal',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        ' / ${today.totalCalories} kcal',
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              _buildRing(pct),
            ],
          ),
          const SizedBox(height: 20),
          _buildMacroRow(
            label: '蛋白质',
            desc: '高摄入 (增肌期)',
            color: AppColors.brand400,
            current: curPro,
            target: today.totalProtein,
            unit: 'g',
          ),
          const SizedBox(height: 10),
          _buildMacroRow(
            label: '碳水化合物',
            desc: '能量供给',
            color: AppColors.cyan,
            current: curCarb,
            target: today.totalCarbs,
            unit: 'g',
          ),
          const SizedBox(height: 10),
          _buildMacroRow(
            label: '脂肪',
            desc: '优质脂肪为主',
            color: AppColors.amber,
            current: curFat,
            target: today.totalFat,
            unit: 'g',
          ),
        ],
      ),
    );
  }

  int _max(int a, int b) => a > b ? a : b;

  Widget _buildRing(int pct) {
    final double d = 64;
    final double sw = 6;
    final double inner = d - sw * 2;
    final double arc = pct.clamp(0, 100) / 100;
    final int quarter = (arc * 4).floor();
    final double rem = (arc * 4 - quarter);
    final List<BoxShadow> noShadows = const <BoxShadow>[];
    Color c(double a) => const Color(0xFF4F7CFF).withOpacity(a);
    Color track() => Colors.white.withOpacity(0.1);

    BoxDecoration decoration = BoxDecoration(
      color: Colors.transparent,
      shape: BoxShape.circle,
      border: Border.all(color: track(), width: sw),
      boxShadow: noShadows,
    );

    // 用四个 Corner + 容器裁切渐进模拟环形
    Widget progress = Container(
      width: d,
      height: d,
      decoration: decoration.copyWith(
        border: Border.all(color: c(1.0), width: sw),
      ),
      alignment: Alignment.center,
      child: Container(
        width: inner,
        height: inner,
        decoration: const BoxDecoration(
          color: AppColors.darkBase,
          shape: BoxShape.circle,
        ),
      ),
    );

    if (quarter < 4) {
      progress = ClipPath(
        clipper: _ArcClipper(quarter, rem),
        child: progress,
      );
    }

    return SizedBox(
      width: d,
      height: d,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: d,
            height: d,
            decoration: decoration,
          ),
          progress,
          SizedBox(
            width: inner,
            height: inner,
            child: Center(
              child: Text(
                '$pct%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroRow({
    required String label,
    required String desc,
    required Color color,
    required int current,
    required int target,
    required String unit,
  }) {
    final double p = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    const double h = 6.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '$label · $desc',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Text(
              '$current / $target$unit',
              style: TextStyle(
                color: color.withOpacity(0.95),
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          height: h,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(h),
          ),
          child: LayoutBuilder(
            builder: (_, BoxConstraints c) {
              final double w = (c.maxWidth * p - 4).clamp(0.0, double.infinity);
              return Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.all(2),
                  width: w,
                  height: (h - 4).clamp(0.0, double.infinity),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: <Color>[color, color.withOpacity(0.65)],
                    ),
                    borderRadius: BorderRadius.circular(h),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAdviceBanner(String weekdayLabel) {
    final bool isTrainingDay =
        weekdayLabel.contains('训练') || weekdayLabel.contains('腿日');
    final String title = isTrainingDay ? '训练日营养提示 · 高能高碳' : '恢复日营养提示 · 优质蛋白';
    final String tip = isTrainingDay
        ? '今天是训练日，碳水摄入已上调 25%，请务必在训练前 45 分钟完成午餐，训练后 60 分钟内补充 20~30g 快速吸收蛋白质 + 60g 以上碳水以促进糖原恢复。'
        : '今天是休息日/恢复日，蛋白质保持 1.6~2.0 g/kg 体重，碳水下调 15%，建议增加深绿色蔬菜与 Omega-3 来源（深海鱼/奇亚籽/核桃）以支持关节与炎症恢复。';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.brand500.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.brand500.withOpacity(0.28),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_outline,
            color: AppColors.brand400,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.brand300,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  tip,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ArcClipper extends CustomClipper<Path> {
  final int quarter;
  final double rem;

  _ArcClipper(this.quarter, this.rem);

  @override
  Path getClip(Size size) {
    final double w = size.width;
    final double h = size.height;
    final Offset c = Offset(w / 2, h / 2);
    final double r = w / 2;

    // 起点 12 点钟方向（-pi/2）
    const double start = -3.1415926535 / 2;
    // quarter: 0~4, rem: 0~1 该 90° 内的进度
    final double sweep =
        (quarter * (3.1415926535 / 2)) + (rem * (3.1415926535 / 2));
    final Path p = Path()
      ..moveTo(c.dx, c.dy)
      ..arcTo(
        Rect.fromCircle(center: c, radius: r),
        start,
        sweep,
        false,
      )
      ..close();
    return p;
  }

  @override
  bool shouldReclip(covariant _ArcClipper oldClipper) {
    return oldClipper.quarter != quarter || oldClipper.rem != rem;
  }
}

class _DietMealCardCompact extends StatelessWidget {
  final String slot;
  final Color accent;
  final _DietMeal meal;

  const _DietMealCardCompact({
    required this.slot,
    required this.accent,
    required this.meal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[accent, accent.withOpacity(0.65)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_slotIcon(slot), color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${meal.time} · ${meal.calories} kcal · 蛋白质 ${meal.protein}g · 碳水 ${meal.carbs}g',
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                for (int i = 0; i < meal.dishes.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 5),
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            meal.dishes[i],
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11.5,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WeeklyDietPlanPage extends StatelessWidget {
  const WeeklyDietPlanPage({super.key});

  String _shortWeekday(String full) {
    if (full.startsWith('周一')) return '周一';
    if (full.startsWith('周二')) return '周二';
    if (full.startsWith('周三')) return '周三';
    if (full.startsWith('周四')) return '周四';
    if (full.startsWith('周五')) return '周五';
    if (full.startsWith('周六')) return '周六';
    return '周日';
  }

  int _max(int a, int b) => a > b ? a : b;

  @override
  Widget build(BuildContext context) {
    try {
      final List<_DietDay> week = _buildWeeklyPlan();
      final int todayIdx = (DateTime.now().weekday - 1) % 7;
      final int avgKcal = week.isEmpty
          ? 2200
          : (week.fold<int>(0, (int sum, _DietDay d) => sum + d.totalCalories) /
                  _max(1, week.length))
              .round();
      return Scaffold(
        backgroundColor: AppColors.darkBase,
        appBar: AppBar(
          backgroundColor: AppColors.darkBase,
          elevation: 0,
          title: const Text(
            '一周饮食推荐',
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
              try {
                Navigator.of(context).pop();
              } catch (e) {
                debugPrint('pop error: $e');
              }
            },
            child: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 18,
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.brand500.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.brand500.withOpacity(0.35),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                '周均 $avgKcal kcal',
                style: TextStyle(
                  color: AppColors.brand300,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        body: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          itemCount: week.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (BuildContext ctx, int i) {
            final _DietDay day = week[i];
            final bool isToday = i == todayIdx;
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isToday
                    ? AppColors.brand500.withOpacity(0.14)
                    : AppColors.darkCard.withOpacity(0.75),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isToday
                      ? AppColors.brand500.withOpacity(0.5)
                      : Colors.white.withOpacity(0.08),
                  width: isToday ? 1.5 : 1,
                ),
                boxShadow: isToday
                    ? <BoxShadow>[
                        BoxShadow(
                          color: AppColors.brand500.withOpacity(0.22),
                          blurRadius: 22,
                          offset: const Offset(0, 5),
                        ),
                      ]
                    : <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: isToday
                              ? AppColors.brand500.withOpacity(0.25)
                              : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _shortWeekday(day.weekday),
                          style: TextStyle(
                            color: isToday ? AppColors.brand300 : Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (isToday) ...[
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: AppColors.brand300,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    '今天',
                                    style: TextStyle(
                                      color: AppColors.brand300,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Expanded(
                                  child: Text(
                                    day.weekday,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${day.totalCalories} kcal · 蛋白质 ${day.totalProtein}g · 碳水 ${day.totalCarbs}g · 脂肪 ${day.totalFat}g',
                              style: const TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _MiniMealRow(
                    meal: day.breakfast,
                    slot: '早餐',
                    accent: AppColors.amber,
                  ),
                  const SizedBox(height: 8),
                  _MiniMealRow(
                    meal: day.lunch,
                    slot: '午餐',
                    accent: AppColors.brand400,
                  ),
                  const SizedBox(height: 8),
                  _MiniMealRow(
                    meal: day.dinner,
                    slot: '晚餐',
                    accent: AppColors.cyan,
                  ),
                ],
              ),
            );
          },
        ),
      );
    } catch (e, s) {
      debugPrint('WeeklyDietPlanPage error: $e\n$s');
      return Scaffold(
        backgroundColor: AppColors.darkBase,
        appBar: AppBar(
          backgroundColor: AppColors.darkBase,
          elevation: 0,
          title: const Text(
            '一周饮食推荐',
            style: TextStyle(color: Colors.white),
          ),
          leading: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              try {
                Navigator.of(context).pop();
              } catch (_) {}
            },
            child: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
          ),
        ),
        body: const SafeArea(
          child: Center(
            child: Text(
              '一周饮食推荐加载中...',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ),
      );
    }
  }
}

class _MiniMealRow extends StatelessWidget {
  final _DietMeal meal;
  final String slot;
  final Color accent;

  const _MiniMealRow({
    required this.meal,
    required this.slot,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> display =
        meal.dishes.length <= 4 ? meal.dishes : meal.dishes.sublist(0, 4);
    final String more =
        meal.dishes.length > 4 ? ' +${meal.dishes.length - 4}' : '';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: accent.withOpacity(0.22),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(
            _slotIcon(slot),
            color: accent,
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '$slot · ',
                    style: TextStyle(
                      color: accent,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      meal.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${meal.calories} kcal',
                    style: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: <Widget>[
                  for (final String d in display)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.06),
                        ),
                      ),
                      child: Text(
                        d,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10.5,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  if (more.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      child: Text(
                        more,
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
