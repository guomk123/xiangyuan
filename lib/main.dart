import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/train_screen.dart';
import 'screens/data_screen.dart';
import 'screens/diet_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/login_screen.dart';
import 'app_state.dart';
import 'settings_store.dart';
import 'screens/body_metrics_edit_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SettingsStore store = SettingsStore();
  try {
    await store.load();
  } catch (e) {
    debugPrint('init settings store error: $e');
  }
  FlutterError.onError = (FlutterErrorDetails d) {
    FlutterError.presentError(d);
  };
  runApp(AuraFitApp(store: store));
}

class AuraFitApp extends StatelessWidget {
  final SettingsStore store;
  const AuraFitApp({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return SettingsStoreScope(
      store: store,
      child: MaterialApp(
        title: 'AURA FIT',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        builder: (BuildContext ctx, Widget? child) {
          ErrorWidget.builder = (FlutterErrorDetails details) {
            return _ErrorFallback(details: details);
          };
          return child ?? const SizedBox.shrink();
        },
        home: const AnnotatedRegionWrapper(),
      ),
    );
  }
}

class _ErrorFallback extends StatelessWidget {
  final FlutterErrorDetails details;
  const _ErrorFallback({required this.details});

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
              const Text(
                '页面加载中',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '请尝试左右切换 Tab 或重新打开 App',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 24),
              if (details.exceptionAsString().isNotEmpty)
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.06),
                        ),
                      ),
                      child: Text(
                        details.exceptionAsString(),
                        style: const TextStyle(
                          color: AppColors.amber,
                          fontSize: 10.5,
                          height: 1.4,
                        ),
                      ),
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

class AnnotatedRegionWrapper extends StatelessWidget {
  const AnnotatedRegionWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsStore store = SettingsStoreScope.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.darkBase,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: AnimatedBuilder(
        animation: store,
        builder: (BuildContext ctx, Widget? _) {
          if (store.isLoggedIn) {
            return const MainShell();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  int _shellRev = 0;
  bool _showingOnboarding = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        AppState().recomputeDerivedFromVolume();
      } catch (_) {}
      if (!mounted) return;
      final SettingsStore store = SettingsStoreScope.of(context);
      try {
        if (!store.isOnboardingCompleted) {
          // 同步初始化 AppState 的默认 Profile，避免首次 build 不一致
          AppState().syncFromProfile(
            weightKg: store.weightKg,
            heightCm: store.heightCm,
            ageYears: store.ageYears,
            biologicalSex: store.biologicalSex,
            goal: store.goal,
          );
        }
      } catch (_) {}
      await _maybeShowOnboarding();
    });
  }

  Future<void> _maybeShowOnboarding() async {
    if (!mounted) return;
    final SettingsStore store = SettingsStoreScope.of(context);
    if (store.isOnboardingCompleted) return;
    setState(() => _showingOnboarding = true);
    try {
      HapticFeedback.selectionClick();
    } catch (_) {}
    bool done = false;
    while (!done && mounted) {
      final bool? saved = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          fullscreenDialog: true,
          builder: (_) => PopScope(
            canPop: false,
            child: BodyMetricsEditPage(store: store),
          ),
        ),
      );
      if (saved == true && mounted) {
        try {
          AppState().syncFromProfile(
            weightKg: store.weightKg,
            heightCm: store.heightCm,
            ageYears: store.ageYears,
            biologicalSex: store.biologicalSex,
            goal: store.goal,
          );
        } catch (_) {}
        await store.markOnboardingCompleted();
        if (mounted) {
          setState(() {
            _shellRev += 1;
            _currentIndex = 1;
          });
        }
        done = true;
      } else {
        // 用户强制 dismiss：不让走，循环直到填完
        await Future<void>.delayed(const Duration(milliseconds: 150));
      }
    }
    if (mounted) setState(() => _showingOnboarding = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBase,
      body: Stack(
        children: [
          _buildBackgroundGlow(),
          Positioned.fill(
            child: IndexedStack(
              index: _currentIndex,
              children: <Widget>[
                KeyedSubtree(
                  key: ValueKey<int>(_shellRev * 10 + 0),
                  child: _SafePage(
                    builder: (_) => const TrainScreen(),
                    fallbackTitle: '训练',
                  ),
                ),
                KeyedSubtree(
                  key: ValueKey<int>(_shellRev * 10 + 1),
                  child: _SafePage(
                    builder: (_) => const DataScreen(),
                    fallbackTitle: '数据',
                  ),
                ),
                KeyedSubtree(
                  key: ValueKey<int>(_shellRev * 10 + 2),
                  child: _SafePage(
                    builder: (_) => const DietScreen(),
                    fallbackTitle: '饮食',
                  ),
                ),
                KeyedSubtree(
                  key: ValueKey<int>(_shellRev * 10 + 3),
                  child: _SafePage(
                    builder: (_) => const SettingsScreen(),
                    fallbackTitle: '设置',
                  ),
                ),
              ],
            ),
          ),
          if (_showingOnboarding)
            Positioned.fill(
              child: Container(
                color: AppColors.darkBase.withOpacity(0.4),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBackgroundGlow() {
    return Positioned(
      top: -100,
      right: -100,
      child: IgnorePointer(
        child: Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            color: AppColors.brand500.withOpacity(0.08),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.brand500.withOpacity(0.08),
                blurRadius: 100,
                spreadRadius: 50,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.08),
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildTab(0, Icons.bolt, '训练'),
              _buildTab(1, Icons.pie_chart, '数据'),
              _buildTab(2, Icons.restaurant_menu, '饮食'),
              _buildTab(3, Icons.settings, '设置'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(int index, IconData icon, String label) {
    final bool selected = _currentIndex == index;
    final Color active = AppColors.brand400;
    final Color inactive = AppColors.textTertiary;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          try {
            HapticFeedback.selectionClick();
          } catch (_) {}
          if (mounted) {
            setState(() => _currentIndex = index);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                padding: EdgeInsets.symmetric(
                  horizontal: selected ? 12 : 6,
                  vertical: selected ? 5 : 3,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color:
                      selected ? active.withOpacity(0.14) : Colors.transparent,
                  gradient: selected
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: <Color>[
                            active.withOpacity(0.2),
                            active.withOpacity(0.08),
                          ],
                        )
                      : null,
                ),
                child: Icon(
                  icon,
                  color: selected ? active : inactive,
                  size: selected ? 24 : 20,
                ),
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                style: TextStyle(
                  color: selected ? active : inactive,
                  fontSize: 10.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 0.2,
                  height: 1.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SafePage extends StatelessWidget {
  final WidgetBuilder builder;
  final String fallbackTitle;

  const _SafePage({
    required this.builder,
    required this.fallbackTitle,
  });

  @override
  Widget build(BuildContext context) {
    try {
      return Material(
        color: Colors.transparent,
        child: builder(context),
      );
    } catch (e, s) {
      debugPrint('$fallbackTitle page error: $e\n$s');
      return Material(
        color: AppColors.darkBase,
        child: _PageFallback(title: fallbackTitle),
      );
    }
  }
}

class _PageFallback extends StatelessWidget {
  final String title;
  const _PageFallback({required this.title});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.darkBase,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const <Widget>[
                    Text(
                      '页面加载中',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '请尝试重新打开此 Tab，内容会在后台自动恢复。',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
