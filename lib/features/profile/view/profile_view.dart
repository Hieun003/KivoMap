import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/responsive/kivo_scale.dart';
import '../../../app/theme/kivo_theme_tokens.dart';
import '../view_model/profile_view_model.dart';
import '../view_model/profile_view_state.dart';

class ProfileView extends GetView<ProfileViewModel> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(gradient: KivoGradients.lightBackground),
    child: SafeArea(
      bottom: false,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: KivoColors.kivoTeal),
          );
        }
        final error = controller.errorMessage.value;
        if (error != null) {
          return _MessageState(message: error, onRetry: controller.load);
        }
        final state = controller.state.value;
        if (state == null) {
          return _MessageState(
            message: 'Chưa có dữ liệu Hồ sơ.',
            onRetry: controller.load,
          );
        }
        return RefreshIndicator(
          color: KivoColors.kivoTeal,
          onRefresh: controller.load,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              KivoScale.w(24),
              KivoScale.h(18),
              KivoScale.w(24),
              KivoScale.h(56),
            ),
            child: Column(
              children: [
                _ProfileHeader(
                  state: state,
                  onSettings: controller.openSettings,
                  onAvatarTap: controller.openPersonalProfile,
                ),
                SizedBox(height: KivoScale.h(16)),
                _LearningSnapshot(state: state),
                SizedBox(height: KivoScale.h(16)),
                _NextActionCard(
                  state: state,
                  onPressed: controller.startNextAction,
                ),
                SizedBox(height: KivoScale.h(16)),
                _ProgressCards(
                  state: state,
                  onTreasureTap: controller.openTreasure,
                  onDiscoveryTap: controller.openDiscovery,
                ),
                SizedBox(height: KivoScale.h(16)),
                _RecentActivityCard(activities: state.recentActivities),
              ],
            ),
          ),
        );
      }),
    ),
  );
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.state,
    required this.onSettings,
    required this.onAvatarTap,
  });
  final ProfileViewState state;
  final VoidCallback onSettings;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(KivoScale.w(16)),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: KivoRadii.largeCard,
      boxShadow: KivoShadows.soft,
    ),
    child: Stack(
      alignment: Alignment.topCenter,
      children: [
        Padding(
          padding: EdgeInsets.only(top: KivoScale.h(4)),
          child: Column(
            children: [
              Container(
                width: KivoScale.w(164),
                height: KivoScale.w(164),
                padding: EdgeInsets.all(KivoScale.w(5)),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: KivoColors.kivoTeal.withAlpha(42)),
                  boxShadow: KivoShadows.soft,
                ),
                child: ClipOval(
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFC8FFF2), Color(0xFF91EBD9)],
                      ),
                    ),
                    child: Image.asset(state.avatarPath, fit: BoxFit.contain),
                  ),
                ),
              ),
              SizedBox(height: KivoScale.h(10)),
              Text(
                state.displayName,
                textAlign: TextAlign.center,
                style: KivoTextStyles.display.copyWith(
                  color: const Color(0xFF29303C),
                  fontSize: KivoScale.sp(29, min: 23),
                ),
              ),
              SizedBox(height: KivoScale.h(4)),
              Text(
                state.profileDescription,
                textAlign: TextAlign.center,
                style: KivoTextStyles.body.copyWith(
                  color: KivoColors.secondaryText,
                  fontSize: KivoScale.sp(15, min: 12),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            onPressed: onSettings,
            tooltip: 'Cài đặt tài khoản',
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.settings_outlined),
          ),
        ),
      ],
    ),
  );
}

class _LearningSnapshot extends StatelessWidget {
  const _LearningSnapshot({required this.state});
  final ProfileViewState state;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: _EnergyCard(state: state)),
      SizedBox(width: KivoScale.w(14)),
      Expanded(child: _StreakCard(days: state.streakDays)),
    ],
  );
}

class _EnergyCard extends StatelessWidget {
  const _EnergyCard({required this.state});
  final ProfileViewState state;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: KivoScale.w(15),
      vertical: KivoScale.h(14),
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: KivoRadii.largeCard,
      border: Border.all(color: KivoColors.lightBorder),
      boxShadow: KivoShadows.soft,
    ),
    child: Row(
      children: [
        Container(
          width: KivoScale.w(48),
          height: KivoScale.w(48),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: KivoColors.softOrangeCard,
          ),
          child: const Icon(Icons.bolt_rounded, color: KivoColors.actionOrange),
        ),
        SizedBox(width: KivoScale.w(12)),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${state.energy}/${state.maxEnergy}',
                style: KivoTextStyles.cardTitle.copyWith(
                  fontSize: KivoScale.sp(20, min: 16),
                ),
              ),
              SizedBox(height: KivoScale.h(2)),
              Text(
                'Năng lượng',
                style: KivoTextStyles.caption.copyWith(
                  fontSize: KivoScale.sp(12, min: 10),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.days});
  final int days;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: KivoScale.w(15),
      vertical: KivoScale.h(14),
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: KivoRadii.largeCard,
      border: Border.all(color: KivoColors.lightBorder),
      boxShadow: KivoShadows.soft,
    ),
    child: Row(
      children: [
        Container(
          width: KivoScale.w(48),
          height: KivoScale.w(48),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: KivoColors.softOrangeCard,
          ),
          child: const Icon(
            Icons.local_fire_department_rounded,
            color: KivoColors.actionOrange,
          ),
        ),
        SizedBox(width: KivoScale.w(12)),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$days ngày',
                style: KivoTextStyles.cardTitle.copyWith(
                  fontSize: KivoScale.sp(20, min: 16),
                ),
              ),
              SizedBox(height: KivoScale.h(2)),
              Text(
                'Chuỗi học',
                style: KivoTextStyles.caption.copyWith(
                  fontSize: KivoScale.sp(12, min: 10),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _NextActionCard extends StatelessWidget {
  const _NextActionCard({required this.state, required this.onPressed});
  final ProfileViewState state;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isReview = state.nextAction == ProfileNextAction.review;
    final title = isReview
        ? '${state.dueReviewCount} từ đang đến hạn ôn'
        : 'Khám phá một bối cảnh mới';
    final description = isReview
        ? 'Ôn đúng lúc để ghi nhớ lâu hơn.'
        : 'Tiếp tục học từ vựng trong tình huống thực tế.';
    final button = isReview ? 'Ôn ngay' : 'Khám phá ngay';
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(KivoScale.w(20)),
      decoration: BoxDecoration(
        color: KivoColors.softMintCard,
        borderRadius: KivoRadii.largeCard,
        border: Border.all(color: KivoColors.kivoTeal.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TIẾP TỤC HÀNH TRÌNH',
            style: KivoTextStyles.caption.copyWith(
              color: KivoColors.kivoTeal,
              fontSize: KivoScale.sp(12, min: 10),
            ),
          ),
          SizedBox(height: KivoScale.h(7)),
          Text(
            title,
            style: KivoTextStyles.cardTitle.copyWith(
              fontSize: KivoScale.sp(20, min: 16),
            ),
          ),
          SizedBox(height: KivoScale.h(4)),
          Text(
            description,
            style: KivoTextStyles.body.copyWith(
              color: KivoColors.secondaryText,
              fontSize: KivoScale.sp(14, min: 12),
            ),
          ),
          SizedBox(height: KivoScale.h(16)),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onPressed,
              icon: Icon(
                isReview ? Icons.refresh_rounded : Icons.explore_rounded,
                size: KivoScale.w(26),
              ),
              label: Text(button),
              style: FilledButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: KivoScale.h(12)),
                textStyle: KivoTextStyles.cardTitle.copyWith(
                  color: Colors.white,
                  fontSize: KivoScale.sp(18, min: 15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressCards extends StatelessWidget {
  const _ProgressCards({
    required this.state,
    required this.onTreasureTap,
    required this.onDiscoveryTap,
  });
  final ProfileViewState state;
  final VoidCallback onTreasureTap;
  final VoidCallback onDiscoveryTap;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        children: [
          Expanded(
            child: _TapStatCard(
              icon: Icons.workspace_premium_rounded,
              color: const Color(0xFF147CF5),
              value: '${state.unlockedWordCount} từ',
              label: 'Đã mở khóa',
              onTap: onTreasureTap,
            ),
          ),
          SizedBox(width: KivoScale.w(14)),
          Expanded(
            child: _TapStatCard(
              icon: Icons.map_rounded,
              color: KivoColors.kivoTeal,
              value: '${state.discoveredContextCount}',
              label: 'Bối cảnh đã khám phá',
              onTap: onDiscoveryTap,
            ),
          ),
        ],
      ),
    ],
  );
}

class _TapStatCard extends StatelessWidget {
  const _TapStatCard({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    child: Material(
      color: Colors.white,
      borderRadius: KivoRadii.largeCard,
      child: InkWell(
        onTap: onTap,
        borderRadius: KivoRadii.largeCard,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: KivoScale.w(14),
            vertical: KivoScale.h(14),
          ),
          decoration: BoxDecoration(
            borderRadius: KivoRadii.largeCard,
            border: Border.all(color: KivoColors.lightBorder),
          ),
          child: Row(
            children: [
              Container(
                width: KivoScale.w(48),
                height: KivoScale.w(48),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withAlpha(22),
                ),
                child: Icon(icon, color: color),
              ),
              SizedBox(width: KivoScale.w(11)),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: KivoTextStyles.cardTitle.copyWith(
                        fontSize: KivoScale.sp(20, min: 16),
                      ),
                    ),
                    SizedBox(height: KivoScale.h(2)),
                    Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: KivoTextStyles.caption.copyWith(
                        fontSize: KivoScale.sp(11.5, min: 9.5),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: KivoScale.w(26),
                color: KivoColors.secondaryText,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard({required this.activities});
  final List<ProfileRecentActivity> activities;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(KivoScale.w(18)),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: KivoRadii.largeCard,
      border: Border.all(color: KivoColors.lightBorder),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gần đây', style: KivoTextStyles.cardTitle),
        SizedBox(height: KivoScale.h(10)),
        if (activities.isEmpty)
          Text(
            'Hoàn thành một từ để bắt đầu hành trình của bạn nhé.',
            style: KivoTextStyles.body.copyWith(
              color: KivoColors.secondaryText,
              fontSize: KivoScale.sp(14, min: 12),
            ),
          )
        else
          for (final activity in activities) _ActivityRow(activity: activity),
      ],
    ),
  );
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.activity});
  final ProfileRecentActivity activity;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: KivoScale.h(8)),
    child: Row(
      children: [
        Icon(
          activity.type == ProfileActivityType.reviewed
              ? Icons.refresh_rounded
              : Icons.check_circle_outline_rounded,
          color: KivoColors.kivoTeal,
        ),
        SizedBox(width: KivoScale.w(10)),
        Expanded(
          child: Text(
            activity.title,
            style: KivoTextStyles.body.copyWith(
              fontSize: KivoScale.sp(14, min: 12),
            ),
          ),
        ),
        Text(
          _timeLabel(activity.occurredAt),
          style: KivoTextStyles.caption.copyWith(
            fontSize: KivoScale.sp(11, min: 9),
          ),
        ),
      ],
    ),
  );
  String _timeLabel(DateTime date) {
    final days = DateTime.now()
        .difference(DateTime(date.year, date.month, date.day))
        .inDays;
    if (days == 0) return 'Hôm nay';
    if (days == 1) return 'Hôm qua';
    return '$days ngày trước';
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.message, required this.onRetry});
  final String message;
  final Future<void> Function() onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(message, textAlign: TextAlign.center, style: KivoTextStyles.body),
        SizedBox(height: KivoScale.h(12)),
        FilledButton(onPressed: onRetry, child: const Text('Thử lại')),
      ],
    ),
  );
}
