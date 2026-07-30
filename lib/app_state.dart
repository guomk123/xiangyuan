import 'package:flutter/foundation.dart';

class MuscleVolume {
  final double legs;
  final double push;
  final double pull;
  final double core;
  final double total;

  const MuscleVolume({
    required this.legs,
    required this.push,
    required this.pull,
    required this.core,
    required this.total,
  });
}

class DietMeal {
  final String title;
  final List<String> dishes;
  final String time;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  const DietMeal({
    required this.title,
    required this.dishes,
    required this.time,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}

class DietDay {
  final String weekday;
  final DietMeal breakfast;
  final DietMeal lunch;
  final DietMeal dinner;

  const DietDay({
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

class _ProfileSnapshot {
  final double weightKg;
  final double heightCm;
  final int ageYears;
  final bool male;
  final String goalKey;

  const _ProfileSnapshot({
    required this.weightKg,
    required this.heightCm,
    required this.ageYears,
    required this.male,
    required this.goalKey,
  });
}

class AppState {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  _ProfileSnapshot _profile = const _ProfileSnapshot(
    weightKg: 72.0,
    heightCm: 180.0,
    ageYears: 26,
    male: true,
    goalKey: '增肌减脂 · 进阶训练者',
  );

  void syncFromProfile({
    required double weightKg,
    required double heightCm,
    required int ageYears,
    required String biologicalSex,
    required String goal,
  }) {
    _profile = _ProfileSnapshot(
      weightKg: weightKg.clamp(30.0, 300.0),
      heightCm: heightCm.clamp(100.0, 250.0),
      ageYears: ageYears.clamp(10, 100),
      male: biologicalSex != '女',
      goalKey: goal,
    );
    _recomputeWeekDataFromProfile();
    recomputeDerivedFromVolume();
  }

  void _recomputeWeekDataFromProfile() {
    final double w = _profile.weightKg;
    final double h = _profile.heightCm;
    final int age = _profile.ageYears;
    final bool male = _profile.male;
    final String goal = _profile.goalKey;

    // 基础系数：体重 72 × 训练日 58 ≈ 4176 基准。用 w*系数 按体重线性缩放
    double baseVolumePerDay = w * 56.0; // 72 公斤 → 4032 kg
    double volumeVar = 0.82; // 最小天数相对比例
    int cardioBase = 22;   // 有氧基础分钟
    int cardioMax = 48;
    bool cut = goal.contains('减脂');
    bool bulk = goal.contains('纯增肌') || goal.contains('追求围度');
    bool maintain = goal.contains('维持健康');
    if (cut) {
      baseVolumePerDay *= 0.94;
      cardioBase = 34;
      cardioMax = 60;
    } else if (bulk) {
      baseVolumePerDay *= 1.08;
      cardioBase = 10;
      cardioMax = 28;
    } else if (maintain) {
      baseVolumePerDay *= 0.88;
      cardioBase = 28;
      cardioMax = 42;
    }
    // 身高高于 185 → 训练量略多（长杆做功多）
    if (h >= 185) baseVolumePerDay *= 1.06;
    // 年龄 >= 35 → 训练量略降，有氧略升
    if (age >= 35) {
      baseVolumePerDay *= 0.94;
      cardioBase += 6;
      cardioMax += 6;
    }
    // 性别：默认男系数，女降 0.88
    if (!male) baseVolumePerDay *= 0.88;

    const List<int> schedule = <int>[0, 1, -1, 2, 0, 1, -1];
    // 0 = 推，1 = 拉，2 = 腿，-1 = 休
    final List<double> vols = <double>[];
    final List<int> cardios = <int>[];
    final List<double> progressivePattern = <double>[
      0.90, 0.95, 0.92, 1.04, 1.08, 1.14, 1.10,
    ];
    for (int i = 0; i < 7; i++) {
      final int mode = schedule[i];
      if (mode == -1) {
        vols.add(double.parse(
            (baseVolumePerDay * 0.36 * progressivePattern[i])
                .toStringAsFixed(0)));
        cardios.add((cardioBase + (i % 3) * 4).clamp(cardioBase, cardioMax));
      } else if (mode == 2) {
        // 腿日：最大
        vols.add(double.parse(
            (baseVolumePerDay * 1.18 * progressivePattern[i])
                .toStringAsFixed(0)));
        cardios.add((cardioBase - 4 + i).clamp(0, cardioMax));
      } else if (mode == 1) {
        // 拉日
        vols.add(double.parse(
            (baseVolumePerDay * 0.96 * progressivePattern[i])
                .toStringAsFixed(0)));
        cardios.add((cardioBase + (i % 2) * 6).clamp(0, cardioMax));
      } else {
        // 推日
        vols.add(double.parse(
            (baseVolumePerDay * (volumeVar + 0.06 * i).clamp(0.82, 1.04) *
                    progressivePattern[i])
                .toStringAsFixed(0)));
        cardios.add((cardioBase + (i % 3) * 5).clamp(0, cardioMax));
      }
    }
    weekVolume.value = vols;
    weekCardio.value = cardios;
    // calorieGoal 按基础代谢 × 0.22/7 估算训练目标消耗
    final double hm = (h / 100.0).clamp(0.01, 3.0);
    final double bmrEst =
        (10 * w + 6.25 * h - 5 * age + (male ? 5 : -161)).clamp(1000, 5000);
    calorieGoal.value = (bmrEst * (cut ? 0.28 : 0.19) / 7.0).round().clamp(250, 1200);
    // 今日容量分解：按今日模式
    final int tMode = schedule[todayIndex.clamp(0, 6)];
    final double today = vols[todayIndex.clamp(0, 6)];
    final MuscleVolume mv;
    if (tMode == 2) {
      mv = MuscleVolume(
        legs: today * 0.60,
        push: today * 0.10,
        pull: today * 0.22,
        core: today * 0.08,
        total: today,
      );
    } else if (tMode == 1) {
      mv = MuscleVolume(
        legs: today * 0.10,
        push: today * 0.14,
        pull: today * 0.66,
        core: today * 0.10,
        total: today,
      );
    } else if (tMode == -1) {
      mv = MuscleVolume(
        legs: today * 0.24,
        push: today * 0.24,
        pull: today * 0.24,
        core: today * 0.28,
        total: today,
      );
    } else {
      mv = MuscleVolume(
        legs: today * 0.10,
        push: today * 0.66,
        pull: today * 0.14,
        core: today * 0.10,
        total: today,
      );
    }
    todayMuscleVolume.value = MuscleVolume(
      legs: double.parse(mv.legs.toStringAsFixed(0)),
      push: double.parse(mv.push.toStringAsFixed(0)),
      pull: double.parse(mv.pull.toStringAsFixed(0)),
      core: double.parse(mv.core.toStringAsFixed(0)),
      total: today,
    );
    // 渐进过载趋势 8 周：根据目标
    final List<double> baseTrend;
    if (bulk) {
      baseTrend = <double>[0.68, 0.74, 0.78, 0.86, 0.94, 1.00, 1.08, 1.16];
    } else if (cut) {
      baseTrend = <double>[0.82, 0.86, 0.84, 0.90, 0.96, 1.00, 1.05, 1.08];
    } else if (maintain) {
      baseTrend = <double>[0.92, 0.94, 0.93, 0.97, 0.99, 1.00, 1.01, 1.02];
    } else {
      baseTrend = <double>[0.72, 0.80, 0.78, 0.88, 0.95, 1.00, 1.06, 1.12];
    }
    progressiveTrend.value = List<double>.from(baseTrend);
  }

  // 本周 7 天 训练容量 (kg) - 周一=index 0
  final ValueNotifier<List<double>> weekVolume = ValueNotifier<List<double>>(
    <double>[3200, 3800, 2900, 4200, 3600, 4500, 3850],
  );

  // 本周 7 天 有氧时长 (min)
  final ValueNotifier<List<int>> weekCardio = ValueNotifier<List<int>>(
    <int>[18, 28, 0, 35, 42, 0, 22],
  );

  // 本周 7 天 消耗热量 (kcal) - 训练容量 + 有氧 + 日常活动 合成
  final ValueNotifier<List<int>> weekCalories = ValueNotifier<List<int>>(
    <int>[420, 580, 360, 620, 490, 780, 600],
  );

  // 本周 7 天 静息心率 (bpm) - 根据前一日训练量/恢复 推导
  final ValueNotifier<List<int>> weekRestingHR = ValueNotifier<List<int>>(
    <int>[59, 57, 62, 56, 58, 54, 57],
  );

  // 本周 7 天 深睡时长 (小时) - 根据当日训练量 推导
  final ValueNotifier<List<double>> weekDeepSleep = ValueNotifier<List<double>>(
    <double>[2.1, 2.6, 1.8, 2.5, 2.3, 2.8, 2.7],
  );

  // 今日动作组数（用于微调后总容量联动）
  final ValueNotifier<int> todaysSets = ValueNotifier<int>(16);

  // 今日消耗 kcal 目标
  final ValueNotifier<int> calorieGoal = ValueNotifier<int>(550);

  // 今日肌群容量分解（腿部/推/拉/核心）
  final ValueNotifier<MuscleVolume> todayMuscleVolume =
      ValueNotifier<MuscleVolume>(
    const MuscleVolume(
        legs: 2520, push: 880, pull: 680, core: 120, total: 4200),
  );

  // 今日训练动作清单（来自训练页，与数据页联动）
  final ValueNotifier<List<Map<String, dynamic>>> todaysExercises =
      ValueNotifier<List<Map<String, dynamic>>>(
    <Map<String, dynamic>>[
      <String, dynamic>{
        'name': '杠铃深蹲',
        'sets': 4,
        'reps': 10,
        'weight': 110.0,
        'muscle': '腿部',
      },
      <String, dynamic>{
        'name': '杠铃卧推',
        'sets': 4,
        'reps': 10,
        'weight': 70.0,
        'muscle': '推类',
      },
      <String, dynamic>{
        'name': '引体向上',
        'sets': 4,
        'reps': 8,
        'weight': 75.0,
        'muscle': '拉类',
      },
      <String, dynamic>{
        'name': '哑铃推举',
        'sets': 3,
        'reps': 12,
        'weight': 24.0,
        'muscle': '推类',
      },
    ],
  );

  // ---------- 一周饮食推荐 ----------
  // 训练日：高蛋白 170g + 中碳水 250g + 总热量 2400 kcal
  // 休息日：蛋白质 150g + 低碳水 180g + 总热量 2100 kcal
  static final List<DietDay> weeklyDietPlan = <DietDay>[
    DietDay(
      weekday: '周一 · 推日训练',
      breakfast: DietMeal(
        title: '高蛋白增肌早餐',
        dishes: <String>[
          '全麦吐司 2 片',
          '全蛋 2 个 + 蛋白 2 个',
          '牛油果 1/4',
          '燕麦奶 300ml',
          '蓝莓 100g'
        ],
        time: '08:00',
        calories: 580,
        protein: 42,
        carbs: 62,
        fat: 18,
      ),
      lunch: DietMeal(
        title: '鸡胸藜麦高纤维午餐',
        dishes: <String>[
          '煎鸡胸 220g',
          '三色藜麦饭 150g',
          '西兰花 200g',
          '烤红薯 120g',
          '橄榄油拌沙拉'
        ],
        time: '12:45',
        calories: 920,
        protein: 72,
        carbs: 96,
        fat: 24,
      ),
      dinner: DietMeal(
        title: '三文鱼糙米恢复晚餐',
        dishes: <String>['三文鱼 180g', '糙米饭 120g', '芦笋 180g', '牛油果 1/4', '紫菜味噌汤'],
        time: '19:30',
        calories: 900,
        protein: 56,
        carbs: 92,
        fat: 26,
      ),
    ),
    DietDay(
      weekday: '周二 · 拉日训练',
      breakfast: DietMeal(
        title: '燕麦蛋白粉能量碗',
        dishes: <String>[
          '钢切燕麦 80g',
          '乳清蛋白粉 1 勺',
          '奇亚籽 10g',
          '香蕉 1 根',
          '无糖花生酱 15g'
        ],
        time: '07:45',
        calories: 610,
        protein: 44,
        carbs: 70,
        fat: 16,
      ),
      lunch: DietMeal(
        title: '牛肉意面增肌餐',
        dishes: <String>[
          '瘦牛腱子 200g',
          '全麦意面 130g (干)',
          '番茄酱 + 洋葱蒜',
          '菠菜沙拉 150g',
          '帕玛森 10g'
        ],
        time: '12:40',
        calories: 940,
        protein: 74,
        carbs: 98,
        fat: 22,
      ),
      dinner: DietMeal(
        title: '虾仁豆腐减脂餐',
        dishes: <String>[
          '虾仁 220g',
          '嫩豆腐 250g',
          '糙米饭 100g',
          '时蔬杂炒 200g',
          '姜黄黑胡椒'
        ],
        time: '19:35',
        calories: 850,
        protein: 58,
        carbs: 82,
        fat: 20,
      ),
    ),
    DietDay(
      weekday: '周三 · 休息日',
      breakfast: DietMeal(
        title: '希腊酸奶轻食碗',
        dishes: <String>[
          '脱脂希腊酸奶 300g',
          '蓝莓草莓 180g',
          '低糖麦片 40g',
          '杏仁碎 10g',
          '蜂蜜 1 小勺'
        ],
        time: '08:30',
        calories: 460,
        protein: 36,
        carbs: 58,
        fat: 10,
      ),
      lunch: DietMeal(
        title: '金枪鱼鹰嘴豆沙拉',
        dishes: <String>[
          '水浸金枪鱼 200g',
          '鹰嘴豆 150g',
          '混合生菜 200g',
          '全麦杂粮包 1 个',
          '柠檬橄榄油'
        ],
        time: '12:50',
        calories: 760,
        protein: 58,
        carbs: 72,
        fat: 20,
      ),
      dinner: DietMeal(
        title: '去皮鸡腿时蔬煲',
        dishes: <String>[
          '去皮鸡腿 2 只 (220g)',
          '莲藕 + 胡萝卜共 250g',
          '杂粮饭 90g',
          '海带结 50g',
          '少盐酱油'
        ],
        time: '19:15',
        calories: 880,
        protein: 56,
        carbs: 68,
        fat: 28,
      ),
    ),
    DietDay(
      weekday: '周四 · 腿日训练',
      breakfast: DietMeal(
        title: '高碳能量早餐',
        dishes: <String>[
          '大燕麦粥 100g',
          '全蛋 1 个 + 蛋清 4 个',
          '香蕉 1 根',
          '乳清蛋白 1 勺',
          '核桃碎 8g'
        ],
        time: '07:40',
        calories: 640,
        protein: 48,
        carbs: 74,
        fat: 16,
      ),
      lunch: DietMeal(
        title: '三文鱼藜麦能量碗',
        dishes: <String>[
          '三文鱼 200g',
          '藜麦饭 180g',
          '烤南瓜 180g',
          '羽衣甘蓝 150g',
          '柠檬蜂蜜酱'
        ],
        time: '12:55',
        calories: 980,
        protein: 70,
        carbs: 108,
        fat: 28,
      ),
      dinner: DietMeal(
        title: '牛肉西兰花超量恢复',
        dishes: <String>[
          '瘦牛柳 220g',
          '白米饭 150g',
          '西兰花 + 胡萝卜 250g',
          '蒸蛋 1 份',
          '芝麻少许'
        ],
        time: '19:45',
        calories: 900,
        protein: 66,
        carbs: 84,
        fat: 22,
      ),
    ),
    DietDay(
      weekday: '周五 · 推日再训练',
      breakfast: DietMeal(
        title: '全麦牛油果蛋堡',
        dishes: <String>[
          '全麦汉堡胚 2 个',
          '全蛋 2 个 + 蛋白 2 个',
          '牛油果 1/2',
          '脱脂芝士 1 片',
          '番茄生菜'
        ],
        time: '08:00',
        calories: 600,
        protein: 46,
        carbs: 60,
        fat: 20,
      ),
      lunch: DietMeal(
        title: '鸡胸红薯套餐',
        dishes: <String>['空气炸鸡胸 220g', '蒸红薯 200g', '芦笋 200g', '玉米半根', '无脂沙拉酱'],
        time: '12:45',
        calories: 880,
        protein: 70,
        carbs: 92,
        fat: 18,
      ),
      dinner: DietMeal(
        title: '鳕鱼藜麦轻脂餐',
        dishes: <String>[
          '鳕鱼 220g',
          '藜麦 100g',
          '秋葵 + 彩椒 200g',
          '小番茄 100g',
          '黑胡椒橄榄油'
        ],
        time: '19:30',
        calories: 820,
        protein: 54,
        carbs: 84,
        fat: 18,
      ),
    ),
    DietDay(
      weekday: '周六 · 高强度综合',
      breakfast: DietMeal(
        title: '法式全麦高蛋白吐司',
        dishes: <String>[
          '全麦吐司 3 片 (蛋液浸)',
          '全蛋 2 个 + 蛋白 3 个',
          '无糖枫糖浆 10ml',
          '蓝莓 120g',
          '无糖豆浆 300ml'
        ],
        time: '08:15',
        calories: 590,
        protein: 46,
        carbs: 62,
        fat: 14,
      ),
      lunch: DietMeal(
        title: '泰式虾仁荞麦面',
        dishes: <String>[
          '虾仁 200g',
          '荞麦面 130g (干)',
          '豆芽 + 黄瓜 + 胡萝卜 250g',
          '花生碎 8g',
          '青柠鱼露汁'
        ],
        time: '13:10',
        calories: 900,
        protein: 64,
        carbs: 96,
        fat: 22,
      ),
      dinner: DietMeal(
        title: '羊肉蔬菜杂粮锅',
        dishes: <String>[
          '瘦羊腿肉 200g',
          '小米饭 120g',
          '土豆 + 洋葱 + 番茄共 280g',
          '小白菜 150g',
          '孜然少许'
        ],
        time: '19:20',
        calories: 930,
        protein: 60,
        carbs: 90,
        fat: 30,
      ),
    ),
    DietDay(
      weekday: '周日 · 主动恢复',
      breakfast: DietMeal(
        title: '杂粮鸡蛋蔬菜饼',
        dishes: <String>[
          '全麦粉 + 燕麦共 60g',
          '全蛋 2 个',
          '菠菜 + 蘑菇 + 彩椒 150g',
          '脱脂酸奶 150g',
          '橙子 1 个'
        ],
        time: '08:45',
        calories: 490,
        protein: 38,
        carbs: 54,
        fat: 14,
      ),
      lunch: DietMeal(
        title: '火鸡胸鲜蔬卷',
        dishes: <String>[
          '火鸡胸片 200g',
          '全麦卷饼 2 张',
          '生菜 + 番茄 + 黄瓜 200g',
          '鹰嘴豆泥 30g',
          '紫薯 120g'
        ],
        time: '13:00',
        calories: 790,
        protein: 54,
        carbs: 78,
        fat: 22,
      ),
      dinner: DietMeal(
        title: '清蒸鲈鱼 + 杂粮',
        dishes: <String>[
          '海鲈鱼 250g',
          '杂粮饭 90g',
          '上海青 + 金针菇 220g',
          '豆腐 100g',
          '葱姜丝 + 豉油'
        ],
        time: '19:00',
        calories: 820,
        protein: 60,
        carbs: 68,
        fat: 20,
      ),
    ),
  ];

  // 今日饮食计划（防御式：任何异常都返回默认 3 餐兜底）
  DietDay get todayDiet {
    try {
      final int i = todayIndex.clamp(0, 6);
      if (weeklyDietPlan.length == 7) {
        final DietDay d = weeklyDietPlan[i];
        // 再校验一下 dishes 不为空（防止静态数据被误改）
        if (d.breakfast.dishes.isNotEmpty &&
            d.lunch.dishes.isNotEmpty &&
            d.dinner.dishes.isNotEmpty) {
          return d;
        }
      }
    } catch (_) {}
    return const DietDay(
      weekday: '今日推荐配餐',
      breakfast: DietMeal(
        title: '高蛋白增肌早餐',
        dishes: <String>['全麦吐司 2 片', '全蛋 2 个 + 蛋白 2 个', '燕麦奶 300ml', '蓝莓 100g'],
        time: '08:00',
        calories: 580,
        protein: 42,
        carbs: 62,
        fat: 18,
      ),
      lunch: DietMeal(
        title: '鸡胸藜麦高纤维午餐',
        dishes: <String>['煎鸡胸 220g', '三色藜麦饭 150g', '西兰花 200g', '烤红薯 120g'],
        time: '12:45',
        calories: 920,
        protein: 72,
        carbs: 96,
        fat: 24,
      ),
      dinner: DietMeal(
        title: '三文鱼糙米恢复晚餐',
        dishes: <String>['三文鱼 180g', '糙米饭 120g', '芦笋 180g', '牛油果 1/4'],
        time: '19:30',
        calories: 900,
        protein: 56,
        carbs: 92,
        fat: 26,
      ),
    );
  }

  // 今日营养目标（根据是否训练日动态调）
  int get todayTargetCalories => todayDiet.totalCalories;
  int get todayTargetProtein => todayDiet.totalProtein;
  int get todayTargetCarbs => todayDiet.totalCarbs;
  int get todayTargetFat => todayDiet.totalFat;

  // 一周营养汇总（防御式：除 0 保护）
  int get weekTotalCalories {
    int s = 0;
    for (final d in weeklyDietPlan) {
      s += d.totalCalories;
    }
    return s;
  }

  int get weekAvgCalories {
    final int total = weekTotalCalories;
    final int n = weeklyDietPlan.isEmpty ? 1 : weeklyDietPlan.length;
    return (total / n).round();
  }

  // 连续训练天数
  final ValueNotifier<int> trainingStreak = ValueNotifier<int>(5);

  // 本周预估瘦体重变化 (kg)，正数 = 肌肉增长，负数 = 消耗
  final ValueNotifier<double> estimatedLeanGain = ValueNotifier<double>(0.18);

  // 渐进过载趋势：最近 8 周相对容量变化指数
  final ValueNotifier<List<double>> progressiveTrend =
      ValueNotifier<List<double>>(
    <double>[0.72, 0.80, 0.78, 0.88, 0.95, 1.00, 1.06, 1.12],
  );

  // 本周是否达成各训练天 容量目标
  final ValueNotifier<List<bool>> dailyGoalHit = ValueNotifier<List<bool>>(
    <bool>[true, true, false, true, true, true, true],
  );

  // ---------- 派生 getters ----------

  // 静息心率日平均
  int get avgRestingHR {
    final l = weekRestingHR.value;
    if (l.isEmpty) return 58;
    final s = l.reduce((a, b) => a + b);
    return (s / l.length).round();
  }

  // 深睡日平均
  double get avgDeepSleep {
    final l = weekDeepSleep.value;
    if (l.isEmpty) return 2.0;
    final s = l.reduce((a, b) => a + b);
    return double.parse((s / l.length).toStringAsFixed(1));
  }

  // 本周总容量 kg
  double get totalVolume {
    return weekVolume.value.fold<double>(0, (a, b) => a + b);
  }

  // 周均容量 kg
  double get avgVolume {
    final List<double> l = weekVolume.value;
    if (l.isEmpty) return 23300 / 7;
    return totalVolume / l.length;
  }

  // 本周总消耗 kcal
  int get totalCalories {
    return weekCalories.value.fold<int>(0, (a, b) => a + b);
  }

  // 本周总有氧时长 min
  int get totalCardio {
    return weekCardio.value.fold<int>(0, (a, b) => a + b);
  }

  // 本周达成目标天数
  int get goalHitDays => dailyGoalHit.value.where((e) => e).length;

  // 体脂率估算：按训练连续周数/累计渐进过载趋势 估算一个下降速率
  // 这里给一个看起来合理的派生值，范围 13.0-17.5%
  double get estimatedBodyFatPct {
    final last =
        progressiveTrend.value.isEmpty ? 1.0 : progressiveTrend.value.last;
    final first =
        progressiveTrend.value.isEmpty ? 1.0 : progressiveTrend.value.first;
    final rel = (last - first).clamp(-0.4, 0.4);
    return double.parse((15.2 - rel * 5.0).toStringAsFixed(1));
  }

  // 瘦体重估算：182cm - 基础 66.8kg + 渐进过载 带来的 lean 变化
  double get estimatedLeanMassKg {
    final trend =
        progressiveTrend.value.isEmpty ? 1.0 : progressiveTrend.value.last;
    return double.parse((60.6 + (trend - 0.72) * 2.8).toStringAsFixed(1));
  }

  // 骨骼肌质量：leanMass * 0.75 + 训练周数带来的 +~ 1.2kg
  double get estimatedSkeletalMuscleKg {
    final t = trainingStreak.value;
    final bonus = (t / 30.0).clamp(0.0, 1.2);
    return double.parse(
        (estimatedLeanMassKg * 0.54 + bonus).toStringAsFixed(1));
  }

  // 内脏脂肪等级估算 (1~10)：训练频率越高越低
  int get estimatedVisceralFatLevel {
    final days = goalHitDays;
    return (11 - days - (trainingStreak.value ~/ 10)).clamp(1, 10);
  }

  // 基础代谢：leanMass * 21.6 + 370（Katch-McArdle 近似）
  int get estimatedBMR {
    return (estimatedLeanMassKg * 21.6 + 370).round();
  }

  // 体重估算：瘦体重 / (1 - bodyFat)
  double get estimatedWeightKg {
    return double.parse(
        (estimatedLeanMassKg / (1.0 - estimatedBodyFatPct / 100.0))
            .toStringAsFixed(1));
  }

  // 本周 8 周体脂趋势（用于体成分页 MiniLineRow 条）
  List<double> get bodyFat8Weeks {
    final List<double> base = <double>[
      15.8,
      15.6,
      15.4,
      15.3,
      15.2,
      15.1,
      15.0,
      estimatedBodyFatPct,
    ];
    return base;
  }

  // 肌群平衡分数：0~100，基于腿部/推/拉三者的最大差
  int get muscleBalanceScore {
    final MuscleVolume mv = todayMuscleVolume.value;
    final List<double> ratios = <double>[
      mv.legs / mv.total,
      mv.push / mv.total,
      mv.pull / mv.total,
    ];
    final double maxR = ratios.reduce((a, b) => a > b ? a : b);
    final double minR = ratios.reduce((a, b) => a < b ? a : b);
    final double spread = (maxR - minR).clamp(0.0, 1.0);
    return (100 - spread * 260).round().clamp(60, 98);
  }

  // 恢复状态分：静息心率接近 60 + 深睡接近 2.4 = 高分
  int get recoveryScore {
    final int hrDelta = (avgRestingHR - 58).abs();
    final double sleepDelta = (avgDeepSleep - 2.4).abs();
    return (95 - hrDelta * 2 - sleepDelta * 8).round().clamp(50, 100);
  }

  // 本周 PR 次数估算：根据 progressiveTrend 最后一周较上周上升 > 0.02 → 记 PR
  int get weeklyPRCount {
    final trend = progressiveTrend.value;
    if (trend.length < 2) return 2;
    final delta = trend.last - trend[trend.length - 2];
    if (delta > 0.04) return 4;
    if (delta > 0.02) return 2;
    return 1;
  }

  // 渐进过载 PR 指数（0~100）：综合近 8 周趋势斜率 + 本周 PR 数 + 连续天数
  int get progressiveOverloadScore {
    final List<double> t = progressiveTrend.value;
    if (t.isEmpty) return 70;
    final double slope = t.length >= 2
        ? ((t.last - t.first) / (t.length - 1)).clamp(-0.1, 0.3)
        : 0.0;
    final int streak = trainingStreak.value;
    final int pr = weeklyPRCount;
    final double score =
        50 + slope * 380 + streak * 1.1 + pr * 6 + goalHitDays * 2.5;
    return score.round().clamp(40, 100);
  }

  // 训练规律度（0~100）：本周 7 天中 dailyGoalHit=true 的天数 + 容量 CV（变异系数越低越规律）
  int get trainingConsistencyScore {
    final List<double> vols = weekVolume.value;
    final int hit = goalHitDays;
    if (vols.isEmpty) return 65;
    final double mean = vols.reduce((a, b) => a + b) / vols.length;
    final double variance = mean > 0
        ? vols
                .map((double v) => (v - mean) * (v - mean))
                .reduce((a, b) => a + b) /
            vols.length
        : 0;
    final double cv =
        mean > 0 ? ((variance > 0 ? (variance / (mean * mean)) : 0.0)) : 1.0;
    final double cvScore = (1 - cv.clamp(0.0, 1.0)) * 50;
    final double hitScore = hit / 7 * 50;
    return (cvScore + hitScore).round().clamp(40, 99);
  }

  // ---------- 基本 setter ----------

  // 今日索引 (周一=0, ... 周日=6)
  int get todayIndex {
    final int w = DateTime.now().weekday;
    return (w - 1) % 7;
  }

  // 增加今日训练容量（训练页/微调/AI生成后调用）
  void addTodayVolume(double kg) {
    final list = List<double>.from(weekVolume.value);
    list[todayIndex] = (list[todayIndex] + kg);
    weekVolume.value = list;
    recomputeDerivedFromVolume();
  }

  // 增加今日消耗 kcal（训练页打卡调用）
  void addTodayCalories(int kcal) {
    final list = List<int>.from(weekCalories.value);
    list[todayIndex] = (list[todayIndex] + kcal).clamp(0, 5000);
    weekCalories.value = list;
  }

  // 增加今日有氧时长
  void addTodayCardio(int minutes) {
    final list = List<int>.from(weekCardio.value);
    list[todayIndex] = (list[todayIndex] + minutes).clamp(0, 600);
    weekCardio.value = list;
    recomputeDerivedFromVolume();
  }

  // 更新今日静息心率
  void updateTodayRestingHR(int bpm) {
    final list = List<int>.from(weekRestingHR.value);
    list[todayIndex] = bpm.clamp(40, 120);
    weekRestingHR.value = list;
  }

  // 更新今日深睡时长
  void updateTodayDeepSleep(double hours) {
    final list = List<double>.from(weekDeepSleep.value);
    list[todayIndex] = hours.clamp(0, 10);
    weekDeepSleep.value = list;
  }

  // 设置今日总组数（微调动作保存后调用）
  void setTodaysSets(int n) {
    todaysSets.value = n;
  }

  // 设置今日肌群容量分解（训练页 _syncAppStateFromExercises 里计算后调用）
  void setTodayMuscleVolume(MuscleVolume mv) {
    todayMuscleVolume.value = mv;
  }

  // 根据训练周累计容量重新合成 weekRestingHR / weekDeepSleep / weekCalories
  // 这样所有 3 条健康数据都完全来自训练日志，不需要穿戴设备
  void recomputeDerivedFromVolume() {
    final vols = weekVolume.value;
    final cardios = weekCardio.value;
    if (vols.isEmpty) return;
    final double avgVol =
        vols.reduce((a, b) => a + b) / vols.length; // ~3720 基线
    final List<int> hrs = List<int>.from(weekRestingHR.value);
    final List<double> sleeps = List<double>.from(weekDeepSleep.value);
    final List<int> cals = List<int>.from(weekCalories.value);
    final List<bool> goals = List<bool>.from(dailyGoalHit.value);
    for (int i = 0; i < vols.length; i++) {
      final double v = vols[i];
      final double ratio = avgVol > 0 ? v / avgVol : 1.0; // 0.78~1.21
      // 训练量低 = 恢复好 → 心率低 + 深睡稍差（训练刺激不够）
      // 训练量高 = 恢复压力 → 心率略高 + 深睡增加（超量恢复需求）
      // 参考范围 52~64 bpm
      hrs[i] = (58 + (ratio - 1.0) * 14 + (i % 2 == 0 ? 0 : -1))
          .round()
          .clamp(50, 68);
      // 深睡 1.6~3.0h
      sleeps[i] = double.parse(
          (2.2 + (ratio - 1.0) * 1.6 + (i == 5 ? 0.25 : 0.0))
              .clamp(1.5, 3.1)
              .toStringAsFixed(1));
      // 消耗 kcal 完全由训练量 + 有氧 按系数合成：1 kg 容量 ~0.07 kcal？
      // 实际上 v 很大，1 kg × reps × sets → 我们用 0.035 系数，再加 cardio*7.5
      final int baseKcal = (v * 0.045 + cardios[i] * 7.5 + 140).round();
      cals[i] = baseKcal.clamp(180, 4000);
      goals[i] = ratio >= 0.92;
    }
    weekRestingHR.value = hrs;
    weekDeepSleep.value = sleeps;
    weekCalories.value = cals;
    dailyGoalHit.value = goals;
    // 重新估算瘦体重变化：本周总容量 / 基准
    final double t = totalVolume;
    estimatedLeanGain.value = double.parse(
        ((t - 23300) / 100000.0).clamp(-0.5, 0.6).toStringAsFixed(2));
    // streak：连续从 todayIndex 往前找 dailyGoalHit=true 的次数
    int streak = 0;
    for (int i = todayIndex; i >= 0; i--) {
      if (goals[i]) {
        streak++;
      } else {
        break;
      }
    }
    // 之前周累积也给 1-10 额外
    trainingStreak.value = streak + (goalHitDays >= 5 ? 2 : 0);
  }
}
