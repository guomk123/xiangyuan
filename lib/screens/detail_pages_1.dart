import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_widgets.dart';
import '../widgets/ui_components.dart';
import '../widgets/common_widgets.dart';
import '../widgets/detail_page_template.dart';

class ProfileDetailPage extends StatelessWidget {
  const ProfileDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GenericDetailPage(
      title: '个人资料',
      subtitle: 'PRO 高级会员 · ID A2049817',
      leadingIcon: Icons.person,
      accentColor: AppColors.brand400,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.brand500.withOpacity(0.2),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.brand500.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.brand500,
                      width: 2.5,
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
                        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
                    width: 66,
                    height: 66,
                    borderRadius: 33,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alex Morgan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '加入 218 天 · 已训练 142 次',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 6),
                      BadgeTag(
                        text: '目标：增肌强化',
                        backgroundColor: Color.fromRGBO(118, 88, 254, 0.18),
                        textColor: Color.fromRGBO(148, 120, 255, 1),
                        borderColor: Color.fromRGBO(118, 88, 254, 0.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SectionCard(
            title: '身体基础数据',
            description: '最近更新：2 小时前 (手动记录 · 训练日志估算)',
            icon: Icons.line_weight,
            child: Column(
              children: [
                InfoTile(
                  icon: Icons.height,
                  label: '身高',
                  value: '182 cm',
                  iconColor: AppColors.cyan,
                  trailingIcon: Icons.edit,
                ),
                DividerGap(),
                InfoTile(
                  icon: Icons.scale,
                  label: '当前体重',
                  value: '76.4 kg',
                  iconColor: AppColors.brand400,
                  valueColor: AppColors.brand300,
                  trailingIcon: Icons.show_chart,
                ),
                DividerGap(),
                InfoTile(
                  icon: Icons.percent,
                  label: '体脂率',
                  value: '12.8%',
                  iconColor: AppColors.amber,
                  trailingIcon: Icons.trending_down,
                ),
                DividerGap(),
                InfoTile(
                  icon: Icons.fitness_center,
                  label: '瘦体重 (LBM)',
                  value: '66.6 kg',
                  iconColor: AppColors.emerald,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SectionCard(
            title: '训练里程碑',
            icon: Icons.emoji_events,
            accentColor: AppColors.amber,
            child: Column(
              children: [
                InfoTile(
                  icon: Icons.local_fire_department,
                  label: '累计消耗',
                  value: '86,420 kcal',
                  iconColor: AppColors.danger,
                ),
                DividerGap(),
                InfoTile(
                  icon: Icons.timer_outlined,
                  label: '累计训练时长',
                  value: '182 小时 44 分',
                  iconColor: AppColors.purple,
                ),
                DividerGap(),
                InfoTile(
                  icon: Icons.workspace_premium,
                  label: '最高连续打卡',
                  value: '34 天',
                  iconColor: AppColors.amber,
                  valueColor: AppColors.amber,
                ),
                DividerGap(),
                InfoTile(
                  icon: Icons.star,
                  label: 'PR 突破次数',
                  value: '12 项',
                  iconColor: AppColors.brand400,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          GradientButton(
            text: '编辑个人资料',
            icon: Icons.edit_note,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class PROMembershipPage extends StatelessWidget {
  const PROMembershipPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GenericDetailPage(
      title: 'AURA PRO 会员',
      subtitle: '解锁完整 AI 教练与饮食数据库',
      leadingIcon: Icons.workspace_premium,
      accentColor: AppColors.amber,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF7658FE),
                  Color(0xFFB984FF),
                  Color(0xFFFFC76B),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7658FE).withOpacity(0.35),
                  blurRadius: 40,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '当前已激活',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Text(
                      '剩余 362 天',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'AURA FIT PRO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'AI 教练 + 营养数据库 + 训练日志备份',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: const [
                    Text(
                      '¥388',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '/ 年',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      '省 40%',
                      style: TextStyle(
                        color: Color(0xFFFFF8C4),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SectionCard(
            title: 'PRO 会员专属特权',
            description: '共 12 项高级功能全部解锁',
            icon: Icons.verified,
            accentColor: AppColors.amber,
            child: Column(
              children: [
                InfoTile(
                  icon: Icons.auto_awesome,
                  label: 'AI 个性化训练计划',
                  value: '已解锁',
                  iconColor: AppColors.purple,
                  valueColor: AppColors.emerald,
                ),
                DividerGap(),
                InfoTile(
                  icon: Icons.restaurant,
                  label: 'AI 拍照食物识别',
                  value: '无限次/日',
                  iconColor: AppColors.cyan,
                  valueColor: AppColors.cyan,
                ),
                DividerGap(),
                InfoTile(
                  icon: Icons.assessment,
                  label: '深度训练分析报告',
                  value: '已解锁',
                  iconColor: AppColors.brand400,
                  valueColor: AppColors.emerald,
                ),
                DividerGap(),
                InfoTile(
                  icon: Icons.thermostat,
                  label: '肌肉疲劳热力图',
                  value: '全肌肉群',
                  iconColor: AppColors.danger,
                  valueColor: AppColors.danger,
                ),
                DividerGap(),
                InfoTile(
                  icon: Icons.sd_card_outlined,
                  label: '训练日志云备份',
                  value: '最近备份 2 小时前',
                  iconColor: AppColors.emerald,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlineButton(
                  text: '管理订阅',
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: GradientButton(
                  text: '续费 365 天',
                  icon: Icons.card_membership,
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const OutlineButton({
    super.key,
    required this.text,
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
          color: Colors.transparent,
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.brand300,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class CircleBadge extends StatelessWidget {
  final String text;
  final Color color;

  const CircleBadge({
    super.key,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
