import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../settings_store.dart';
import '../theme/app_theme.dart';

class ProfileEditPage extends StatefulWidget {
  final SettingsStore store;

  const ProfileEditPage({
    super.key,
    required this.store,
  });

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  late TextEditingController _nicknameCtrl;
  late int _avatarIndex;
  late int _goalIndex;
  String? _avatarPath;
  bool _saving = false;
  bool _picking = false;

  @override
  void initState() {
    super.initState();
    final SettingsStore s = widget.store;
    _nicknameCtrl = TextEditingController(text: s.nickname);
    _avatarIndex = s.avatarIndex.clamp(0, 5);
    _goalIndex = s.allGoals.indexOf(s.goal).clamp(0, s.allGoals.length - 1);
    _avatarPath = s.avatarPath;
  }

  @override
  void dispose() {
    _nicknameCtrl.dispose();
    super.dispose();
  }

  List<LinearGradient> get _avatarGradients {
    return const <LinearGradient>[
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFF4F7CFF), Color(0xFF8B5CF6)],
      ),
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFF22D3EE), Color(0xFF4F7CFF)],
      ),
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFFFBBF24), Color(0xFFF97316)],
      ),
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFF34D399), Color(0xFF06B6D4)],
      ),
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFFEC4899), Color(0xFF8B5CF6)],
      ),
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFFA855F7), Color(0xFF6366F1)],
      ),
    ];
  }

  String _avatarLetter() {
    final String name =
        _nicknameCtrl.text.trim().isEmpty ? 'A' : _nicknameCtrl.text.trim();
    return name.characters.first;
  }

  Future<void> _onSave() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      HapticFeedback.selectionClick();
    } catch (_) {}
    final SettingsStore s = widget.store;
    final String nickname = _nicknameCtrl.text.trim();
    final String goal = s.allGoals[_goalIndex.clamp(0, s.allGoals.length - 1)];
    await s.update(
      nickname: nickname,
      avatarIndex: _avatarIndex.clamp(0, 5),
      goal: goal,
      avatarPath: _avatarPath,
    );
    if (mounted) Navigator.of(context).pop<bool>(true);
  }

  Future<void> _onPickImage(ImageSource source) async {
    if (_picking) return;
    setState(() => _picking = true);
    try {
      final XFile? file = await ImagePicker().pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 90,
      );
      if (file != null && mounted) {
        setState(() => _avatarPath = file.path);
        try {
          HapticFeedback.selectionClick();
        } catch (_) {}
      }
    } catch (e, s) {
      debugPrint('pick image error: $e\n$s');
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<LinearGradient> gradients = _avatarGradients;
    final SettingsStore s = widget.store;
    return Scaffold(
      backgroundColor: AppColors.darkBase,
      appBar: AppBar(
        backgroundColor: AppColors.darkBase,
        elevation: 0,
        title: const Text(
          '编辑个人资料',
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
            if (mounted) Navigator.of(context).pop<bool>(false);
          },
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _buildSectionTitle('头像'),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAvatarPreview(gradients),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPickButton(
                    icon: Icons.photo_library_outlined,
                    label: '从相册选择',
                    color: AppColors.brand400,
                    onTap: () => _onPickImage(ImageSource.gallery),
                  ),
                  const SizedBox(width: 12),
                  _buildPickButton(
                    icon: Icons.photo_camera_outlined,
                    label: '拍照',
                    color: AppColors.cyan,
                    onTap: () => _onPickImage(ImageSource.camera),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (_avatarPath != null && _avatarPath!.isNotEmpty)
                Center(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      try {
                        HapticFeedback.selectionClick();
                      } catch (_) {}
                      if (mounted) setState(() => _avatarPath = null);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                      child: const Text(
                        '使用渐变风格头像',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: <Widget>[
                  for (int i = 0; i < gradients.length; i++)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        try {
                          HapticFeedback.selectionClick();
                        } catch (_) {}
                        if (mounted) {
                          setState(() {
                            _avatarIndex = i;
                            _avatarPath = null;
                          });
                        }
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: gradients[i],
                          border: Border.all(
                            color: _avatarIndex == i &&
                                    (_avatarPath == null ||
                                        _avatarPath!.isEmpty)
                                ? Colors.white
                                : Colors.white.withOpacity(0.1),
                            width: _avatarIndex == i &&
                                    (_avatarPath == null ||
                                        _avatarPath!.isEmpty)
                                ? 2.5
                                : 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 28),
              _buildSectionTitle('昵称'),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _nicknameCtrl,
                hint: '请输入昵称',
                maxLength: 16,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('训练目标'),
              const SizedBox(height: 10),
              Column(
                children: <Widget>[
                  for (int i = 0; i < s.allGoals.length; i++) ...[
                    _buildGoalOption(
                      index: i,
                      title: s.allGoals[i],
                    ),
                    if (i != s.allGoals.length - 1) const SizedBox(height: 10),
                  ],
                ],
              ),
              const SizedBox(height: 32),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarPreview(List<LinearGradient> gradients) {
    final int idx = _avatarIndex.clamp(0, gradients.length - 1);
    final bool useFile = _avatarPath != null && _avatarPath!.isNotEmpty;
    final DecorationImage? img;
    if (useFile) {
      img = DecorationImage(
        image: FileImage(File(_avatarPath!)),
        fit: BoxFit.cover,
      );
    } else {
      img = null;
    }
    return Stack(
      alignment: Alignment.bottomRight,
      children: <Widget>[
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: useFile ? null : gradients[idx],
            image: img,
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.brandGlow,
                blurRadius: 22,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: useFile
              ? null
              : Text(
                  _avatarLetter(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                  ),
                ),
        ),
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.brand500,
            border: Border.all(
              color: AppColors.darkBase,
              width: 2.5,
            ),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.edit_outlined,
            color: Colors.white,
            size: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildPickButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _picking ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textTertiary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required int maxLength,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.person,
            color: AppColors.textTertiary,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              maxLength: maxLength,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              cursorColor: AppColors.brand400,
              decoration: InputDecoration(
                counterText: '',
                hintText: hint,
                hintStyle: const TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalOption({
    required int index,
    required String title,
  }) {
    final bool selected = _goalIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (_goalIndex == index) return;
        try {
          HapticFeedback.selectionClick();
        } catch (_) {}
        if (mounted) setState(() => _goalIndex = index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.brand500.withOpacity(0.18)
              : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.brand500.withOpacity(0.55)
                : Colors.white.withOpacity(0.08),
            width: selected ? 1.2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.brand500 : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? AppColors.brand500
                      : Colors.white.withOpacity(0.25),
                  width: 1.6,
                ),
              ),
              alignment: Alignment.center,
              child: selected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 12,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _saving ? null : _onSave,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xFF4F7CFF), Color(0xFF8B5CF6)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.brandGlow,
              blurRadius: 25,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: _saving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  backgroundColor: Colors.transparent,
                ),
              )
            : const Text(
                '保存修改',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
