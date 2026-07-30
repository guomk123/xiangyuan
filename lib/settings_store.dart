import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProfile {
  final String nickname;
  final int avatarIndex;
  final String goal;
  final String? avatarPath;
  final double heightCm;
  final double weightKg;
  final int ageYears;
  final String biologicalSex;

  const SettingsProfile({
    required this.nickname,
    required this.avatarIndex,
    required this.goal,
    this.avatarPath,
    required this.heightCm,
    required this.weightKg,
    required this.ageYears,
    required this.biologicalSex,
  });

  SettingsProfile copyWith({
    String? nickname,
    int? avatarIndex,
    String? goal,
    Object? avatarPath = const _Sentinel(),
    double? heightCm,
    double? weightKg,
    int? ageYears,
    String? biologicalSex,
  }) {
    return SettingsProfile(
      nickname: nickname ?? this.nickname,
      avatarIndex: avatarIndex ?? this.avatarIndex,
      goal: goal ?? this.goal,
      avatarPath:
          avatarPath is _Sentinel ? this.avatarPath : avatarPath as String?,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      ageYears: ageYears ?? this.ageYears,
      biologicalSex: biologicalSex ?? this.biologicalSex,
    );
  }
}

class _Sentinel {
  const _Sentinel();
}

class BodyStats {
  final double bmi;
  final double bodyFatPct;
  final double leanMassKg;
  final double skeletalMuscleKg;
  final double ffmi;
  final int visceralFatLevel;
  final int bmrKcal;
  final double idealWeightRangeMinKg;
  final double idealWeightRangeMaxKg;

  const BodyStats({
    required this.bmi,
    required this.bodyFatPct,
    required this.leanMassKg,
    required this.skeletalMuscleKg,
    required this.ffmi,
    required this.visceralFatLevel,
    required this.bmrKcal,
    required this.idealWeightRangeMinKg,
    required this.idealWeightRangeMaxKg,
  });
}

class SettingsStore extends ChangeNotifier {
  static const String _kNickname = 'profile_nickname';
  static const String _kAvatarIndex = 'profile_avatar_index';
  static const String _kGoal = 'profile_goal';
  static const String _kAvatarPath = 'profile_avatar_path';
  static const String _kHeightCm = 'body_height_cm';
  static const String _kWeightKg = 'body_weight_kg';
  static const String _kAgeYears = 'body_age_years';
  static const String _kBiologicalSex = 'body_biological_sex';
  static const String _kOnboardingDone = 'profile_onboarding_done';
  static const String _kLoggedIn = 'auth_logged_in';

  static const String defaultNickname = 'Alex Morgan';
  static const int defaultAvatarIndex = 0;
  static const String defaultGoal = '增肌减脂 · 进阶训练者';
  static const double defaultHeightCm = 180.0;
  static const double defaultWeightKg = 72.0;
  static const int defaultAgeYears = 26;
  static const String defaultBiologicalSex = '男';

  static const List<String> goals = <String>[
    '增肌减脂 · 进阶训练者',
    '纯增肌 · 追求围度',
    '减脂塑形 · 低体脂',
    '维持健康 · 保持运动习惯',
  ];
  static const List<String> sexes = <String>['男', '女'];

  SettingsProfile _profile = const SettingsProfile(
    nickname: defaultNickname,
    avatarIndex: defaultAvatarIndex,
    goal: defaultGoal,
    avatarPath: null,
    heightCm: defaultHeightCm,
    weightKg: defaultWeightKg,
    ageYears: defaultAgeYears,
    biologicalSex: defaultBiologicalSex,
  );
  bool _onboardingCompleted = false;
  bool _loggedIn = false;

  SettingsProfile get profile => _profile;
  String get nickname => _profile.nickname;
  int get avatarIndex => _profile.avatarIndex;
  String get goal => _profile.goal;
  String? get avatarPath => _profile.avatarPath;
  double get heightCm => _profile.heightCm;
  double get weightKg => _profile.weightKg;
  int get ageYears => _profile.ageYears;
  String get biologicalSex => _profile.biologicalSex;
  bool get isOnboardingCompleted => _onboardingCompleted;
  bool get isLoggedIn => _loggedIn;
  List<String> get allGoals => goals;
  List<String> get allSexes => sexes;

  BodyStats computeBodyStats() {
    final double h = _profile.heightCm;
    final double w = _profile.weightKg;
    final int age = _profile.ageYears;
    final bool male = _profile.biologicalSex == '男';
    final double heightM = (h / 100.0).clamp(0.01, 3.0);
    final String bmiStr = (w / (heightM * heightM)).toStringAsFixed(1);
    final double bmi = double.parse(bmiStr);
    // 体脂率估算 BMI 基础：男 1.2*BMI + 0.23*age - 10.8*sex - 5.4
    // 此处用一个平滑版，范围 10~26。
    final double baseBf = 1.2 * bmi + 0.23 * age - (male ? 16.2 : 5.4);
    final double bfPct =
        double.parse(baseBf.clamp(10.0, 28.0).toStringAsFixed(1));
    final double leanKg =
        double.parse((w * (1.0 - bfPct / 100.0)).toStringAsFixed(1));
    final double skmKg =
        double.parse((leanKg * (male ? 0.56 : 0.46)).toStringAsFixed(1));
    // FFMI (Fat Free Mass Index): leanKg / (heightM * heightM) + (male 调整 + 6.1*(1.8 - heightM / 100) 简化版
    final double ffmiBase = leanKg / (heightM * heightM);
    final double ffmi = double.parse(ffmiBase.toStringAsFixed(1));
    // 内脏脂肪等级: 根据 BMI+年龄
    final double vfBase = (bmi - 18.5) * 0.5 + (age / 10.0) + (male ? 1 : 0.5);
    final int viscLvl = vfBase.round().clamp(1, 10);
    // 理想体重范围：BMI 18.5~24
    final double idealMin =
        double.parse((18.5 * heightM * heightM).toStringAsFixed(1));
    final double idealMax =
        double.parse((24.0 * heightM * heightM).toStringAsFixed(1));
    // BMR：Mifflin-St Jeor
    final int bmr = (10 * w + 6.25 * h - 5 * age + (male ? 5 : -161))
        .round()
        .clamp(1000, 5000);
    return BodyStats(
      bmi: bmi,
      bodyFatPct: bfPct,
      leanMassKg: leanKg,
      skeletalMuscleKg: skmKg,
      ffmi: ffmi,
      visceralFatLevel: viscLvl,
      bmrKcal: bmr,
      idealWeightRangeMinKg: idealMin,
      idealWeightRangeMaxKg: idealMax,
    );
  }

  Future<void> load() async {
    try {
      final SharedPreferences sp = await SharedPreferences.getInstance();
      final String nickname = sp.getString(_kNickname) ?? defaultNickname;
      final int avatarIndex = sp.getInt(_kAvatarIndex) ?? defaultAvatarIndex;
      final String goal = sp.getString(_kGoal) ?? defaultGoal;
      final String? avatarPath = sp.getString(_kAvatarPath);
      final double heightCm = sp.getDouble(_kHeightCm) ?? defaultHeightCm;
      final double weightKg = sp.getDouble(_kWeightKg) ?? defaultWeightKg;
      final int ageYears = sp.getInt(_kAgeYears) ?? defaultAgeYears;
      final String biologicalSex = sexes.contains(sp.getString(_kBiologicalSex))
          ? (sp.getString(_kBiologicalSex) ?? defaultBiologicalSex)
          : defaultBiologicalSex;
      final bool onboardingDone = sp.getBool(_kOnboardingDone) ?? false;
      final bool loggedIn = sp.getBool(_kLoggedIn) ?? false;
      _profile = SettingsProfile(
        nickname: nickname.isEmpty ? defaultNickname : nickname,
        avatarIndex: avatarIndex,
        goal: goals.contains(goal) ? goal : defaultGoal,
        avatarPath:
            (avatarPath != null && avatarPath.isNotEmpty) ? avatarPath : null,
        heightCm: heightCm.clamp(100.0, 250.0),
        weightKg: weightKg.clamp(30.0, 300.0),
        ageYears: ageYears.clamp(10, 100),
        biologicalSex: biologicalSex,
      );
      _onboardingCompleted = onboardingDone;
      _loggedIn = loggedIn;
      notifyListeners();
    } catch (e) {
      debugPrint('SettingsStore load error: $e');
      _profile = const SettingsProfile(
        nickname: defaultNickname,
        avatarIndex: defaultAvatarIndex,
        goal: defaultGoal,
        avatarPath: null,
        heightCm: defaultHeightCm,
        weightKg: defaultWeightKg,
        ageYears: defaultAgeYears,
        biologicalSex: defaultBiologicalSex,
      );
      _onboardingCompleted = false;
      _loggedIn = false;
    }
  }

  Future<void> update({
    String? nickname,
    int? avatarIndex,
    String? goal,
    Object? avatarPath = const _Sentinel(),
    double? heightCm,
    double? weightKg,
    int? ageYears,
    String? biologicalSex,
  }) async {
    final SettingsProfile next = _profile.copyWith(
      nickname: nickname,
      avatarIndex: avatarIndex,
      goal: goal,
      avatarPath: avatarPath,
      heightCm: heightCm,
      weightKg: weightKg,
      ageYears: ageYears,
      biologicalSex: biologicalSex,
    );
    final String? finalPath = next.avatarPath;
    final String sex = sexes.contains(next.biologicalSex)
        ? next.biologicalSex
        : defaultBiologicalSex;
    _profile = SettingsProfile(
      nickname: next.nickname.isEmpty ? defaultNickname : next.nickname,
      avatarIndex: next.avatarIndex.clamp(0, 5),
      goal: goals.contains(next.goal) ? next.goal : defaultGoal,
      avatarPath:
          (finalPath != null && finalPath.isNotEmpty) ? finalPath : null,
      heightCm: next.heightCm.clamp(100.0, 250.0),
      weightKg: next.weightKg.clamp(30.0, 300.0),
      ageYears: next.ageYears.clamp(10, 100),
      biologicalSex: sex,
    );
    notifyListeners();
    try {
      final SharedPreferences sp = await SharedPreferences.getInstance();
      await sp.setString(_kNickname, _profile.nickname);
      await sp.setInt(_kAvatarIndex, _profile.avatarIndex);
      await sp.setString(_kGoal, _profile.goal);
      if (_profile.avatarPath != null && _profile.avatarPath!.isNotEmpty) {
        await sp.setString(_kAvatarPath, _profile.avatarPath!);
      } else {
        await sp.remove(_kAvatarPath);
      }
      await sp.setDouble(_kHeightCm, _profile.heightCm);
      await sp.setDouble(_kWeightKg, _profile.weightKg);
      await sp.setInt(_kAgeYears, _profile.ageYears);
      await sp.setString(_kBiologicalSex, _profile.biologicalSex);
    } catch (e) {
      debugPrint('SettingsStore save error: $e');
    }
  }

  Future<void> markOnboardingCompleted() async {
    _onboardingCompleted = true;
    notifyListeners();
    try {
      final SharedPreferences sp = await SharedPreferences.getInstance();
      await sp.setBool(_kOnboardingDone, true);
    } catch (e) {
      debugPrint('mark onboarding save error: $e');
    }
  }

  Future<void> markLoggedIn() async {
    _loggedIn = true;
    notifyListeners();
    try {
      final SharedPreferences sp = await SharedPreferences.getInstance();
      await sp.setBool(_kLoggedIn, true);
    } catch (e) {
      debugPrint('mark logged in save error: $e');
    }
  }

  Future<void> markLoggedOut() async {
    _loggedIn = false;
    notifyListeners();
    try {
      final SharedPreferences sp = await SharedPreferences.getInstance();
      await sp.remove(_kLoggedIn);
    } catch (e) {
      debugPrint('mark logged out save error: $e');
    }
  }
}
