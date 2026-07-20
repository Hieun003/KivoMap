import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/user_profile_service.dart';
import '../../../app/responsive/kivo_scale.dart';
import '../../../app/theme/kivo_theme_tokens.dart';
import '../view_model/settings_view_model.dart';

class SettingsView extends GetView<SettingsViewModel> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: KivoGradients.lightBackground,
        ),
        child: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: KivoColors.kivoTeal),
              );
            }
            return ListView(
              padding: EdgeInsets.fromLTRB(
                KivoScale.w(24),
                KivoScale.h(14),
                KivoScale.w(24),
                KivoScale.h(32),
              ),
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: Get.back,
                      icon: const Icon(Icons.arrow_back_rounded),
                      tooltip: 'Quay lại Hồ sơ',
                    ),
                    SizedBox(width: KivoScale.w(8)),
                    Text(
                      'Cài đặt tài khoản',
                      style: KivoTextStyles.screenTitle.copyWith(
                        fontSize: KivoScale.sp(28, min: 22),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: KivoScale.h(22)),
                _AccountCard(
                  profile: controller.profile.value,
                  onTap: controller.openPersonalProfile,
                ),
                SizedBox(height: KivoScale.h(24)),
                _SectionTitle(title: 'Học tập'),
                SizedBox(height: KivoScale.h(8)),
                _SettingsGroup(
                  children: [
                    _AudioSettingTile(
                      enabled: controller.audioEnabled.value,
                      onChanged: controller.setAudioEnabled,
                    ),
                  ],
                ),
                SizedBox(height: KivoScale.h(24)),
                _SectionTitle(title: 'Ứng dụng'),
                SizedBox(height: KivoScale.h(8)),
                const _SettingsGroup(
                  children: [
                    _StaticSettingTile(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Quyền riêng tư',
                      subtitle: 'Thông tin học tập được lưu trên thiết bị.',
                    ),
                    _StaticSettingTile(
                      icon: Icons.info_outline_rounded,
                      title: 'Về Kivo',
                      subtitle: 'Học tiếng Anh từ bối cảnh thực tế.',
                    ),
                  ],
                ),
                SizedBox(height: KivoScale.h(28)),
                OutlinedButton.icon(
                  onPressed:
                      controller.canSignOut && !controller.isSigningOut.value
                      ? () => _confirmLogout(context)
                      : null,
                  icon: controller.isSigningOut.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.logout_rounded),
                  label: Text(
                    controller.isSigningOut.value
                        ? 'Đang đăng xuất...'
                        : 'Đăng xuất',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: KivoColors.errorCoral,
                    side: const BorderSide(color: KivoColors.errorCoral),
                    padding: EdgeInsets.symmetric(vertical: KivoScale.h(15)),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Đăng xuất khỏi Kivo?'),
        content: const Text(
          'Bạn sẽ cần xác thực lại để tiếp tục hành trình học.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Ở lại'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: KivoColors.errorCoral),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
    if (shouldSignOut == true) await controller.signOut();
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.profile, required this.onTap});
  final UserProfileData profile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: KivoRadii.largeCard,
      child: Container(
        padding: EdgeInsets.all(KivoScale.w(18)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: KivoRadii.largeCard,
          border: Border.all(color: KivoColors.lightBorder),
          boxShadow: KivoShadows.soft,
        ),
        child: Row(
          children: [
            Container(
              width: KivoScale.w(64),
              height: KivoScale.w(64),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE7FFF8),
              ),
              child: ClipOval(
                child: Image.asset(
                  UserProfileService().avatarFor(profile.avatarKey).assetPath,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(width: KivoScale.w(14)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(profile.displayName, style: KivoTextStyles.cardTitle),
                  SizedBox(height: KivoScale.h(3)),
                  Text(
                    profile.email,
                    style: KivoTextStyles.caption.copyWith(
                      fontSize: KivoScale.sp(13, min: 11),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: KivoColors.secondaryText,
            ),
          ],
        ),
      ),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: KivoTextStyles.cardTitle.copyWith(
      color: KivoColors.secondaryText,
      fontSize: KivoScale.sp(16, min: 13),
    ),
  );
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: KivoRadii.largeCard,
      border: Border.all(color: KivoColors.lightBorder),
    ),
    child: Column(children: children),
  );
}

class _AudioSettingTile extends StatelessWidget {
  const _AudioSettingTile({required this.enabled, required this.onChanged});
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: const Icon(Icons.volume_up_outlined, color: KivoColors.kivoTeal),
    title: const Text('Giọng đọc tiếng Anh'),
    subtitle: const Text('Phát âm ví dụ và hội thoại.'),
    trailing: Switch(value: enabled, onChanged: onChanged),
  );
}

class _StaticSettingTile extends StatelessWidget {
  const _StaticSettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: KivoColors.kivoTeal),
    title: Text(title),
    subtitle: Text(subtitle),
  );
}
