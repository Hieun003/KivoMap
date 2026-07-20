import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/responsive/kivo_scale.dart';
import '../../../app/theme/kivo_theme_tokens.dart';
import '../../../data/user_profile_service.dart';

class PersonalProfileView extends StatefulWidget {
  const PersonalProfileView({super.key});

  @override
  State<PersonalProfileView> createState() => _PersonalProfileViewState();
}

class _PersonalProfileViewState extends State<PersonalProfileView> {
  final UserProfileService _profileService = Get.find<UserProfileService>();
  late final TextEditingController _nameController;
  late String _avatarKey;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final profile = _profileService.profile.value;
    _nameController = TextEditingController(text: profile.displayName);
    _avatarKey = profile.avatarKey;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profileService.profile.value;
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: KivoGradients.lightBackground,
        ),
        child: SafeArea(
          child: ListView(
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
                  ),
                  SizedBox(width: KivoScale.w(8)),
                  Text(
                    'Thông tin cá nhân',
                    style: KivoTextStyles.screenTitle.copyWith(
                      fontSize: KivoScale.sp(28, min: 22),
                    ),
                  ),
                ],
              ),
              SizedBox(height: KivoScale.h(24)),
              Text('Chọn avatar Kivo', style: KivoTextStyles.cardTitle),
              SizedBox(height: KivoScale.h(12)),
              Wrap(
                spacing: KivoScale.w(12),
                runSpacing: KivoScale.h(12),
                children: [
                  for (final option in UserProfileService.avatarOptions)
                    _AvatarChoice(
                      option: option,
                      isSelected: option.key == _avatarKey,
                      onTap: () => setState(() => _avatarKey = option.key),
                    ),
                ],
              ),
              SizedBox(height: KivoScale.h(28)),
              Text('Tên hiển thị', style: KivoTextStyles.cardTitle),
              SizedBox(height: KivoScale.h(8)),
              TextField(
                controller: _nameController,
                maxLength: 32,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(hintText: 'Nhập tên của bạn'),
              ),
              SizedBox(height: KivoScale.h(18)),
              Text(
                profile.email.startsWith('+') ? 'Số điện thoại' : 'Email',
                style: KivoTextStyles.cardTitle,
              ),
              SizedBox(height: KivoScale.h(8)),
              TextFormField(
                initialValue: profile.email,
                readOnly: true,
                decoration: const InputDecoration(
                  helperText: 'Thông tin đăng nhập được quản lý bởi Firebase.',
                ),
              ),
              SizedBox(height: KivoScale.h(28)),
              FilledButton(
                onPressed: _isSaving ? null : _save,
                child: Text(_isSaving ? 'Đang lưu...' : 'Lưu thay đổi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await _profileService.update(
        displayName: _nameController.text,
        avatarKey: _avatarKey,
      );
      if (mounted) Get.back<void>();
    } on ArgumentError {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tên hiển thị cần có từ 1 đến 32 ký tự.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

class _AvatarChoice extends StatelessWidget {
  const _AvatarChoice({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });
  final ProfileAvatarOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: isSelected,
    label: option.label,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(KivoScale.r(999)),
      child: Container(
        width: KivoScale.w(78),
        height: KivoScale.w(78),
        padding: EdgeInsets.all(KivoScale.w(4)),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? KivoColors.kivoTeal : KivoColors.lightBorder,
            width: isSelected ? 2.5 : 1,
          ),
          color: isSelected ? KivoColors.softMintCard : Colors.white,
        ),
        child: ClipOval(
          child: Image.asset(option.assetPath, fit: BoxFit.contain),
        ),
      ),
    ),
  );
}
