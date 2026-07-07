import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/responsive/kivo_scale.dart';
import '../../../app/theme/kivo_theme_tokens.dart';
import '../view_model/discovery_view_model.dart';
import '../view_model/discovery_view_state.dart';
import '../widgets/discovery_completion_card.dart';
import '../widgets/discovery_context_bottom_sheet.dart';
import '../widgets/discovery_header.dart';
import '../widgets/discovery_loading_state.dart';
import '../widgets/discovery_matrix_map.dart';
import '../widgets/discovery_message_state.dart';
import '../widgets/discovery_sentence_panel.dart';

class DiscoveryMatrixView extends GetView<DiscoveryViewModel> {
  const DiscoveryMatrixView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: KivoGradients.lightBackground,
        ),
        child: SafeArea(
          bottom: true,
          child: Obx(() {
            if (controller.isLoading.value) {
              return const DiscoveryLoadingState();
            }

            final errorMessage = controller.errorMessage.value;
            if (errorMessage != null) {
              return DiscoveryMessageState(
                title: 'Ch\u01b0a m\u1edf \u0111\u01b0\u1ee3c ma tr\u1eadn',
                message: errorMessage,
                buttonLabel: 'Th\u1eed l\u1ea1i',
                onPressed: controller.refresh,
              );
            }

            final matrixState = controller.state.value;
            if (matrixState == null) {
              return DiscoveryMessageState(
                title: 'Ch\u01b0a c\u00f3 ng\u1eef c\u1ea3nh',
                message:
                    'T\u1eeb n\u00e0y \u0111ang \u0111\u01b0\u1ee3c Kivo chu\u1ea9n b\u1ecb th\u00eam ng\u1eef c\u1ea3nh.',
                buttonLabel: 'Quay l\u1ea1i',
                onPressed: controller.goBack,
              );
            }

            return _DiscoveryMatrixContent(
              state: matrixState,
              selectedContextId: controller.selectedContextId.value,
              discoveredContextIds: controller.discoveredContextIds.toSet(),
              onBack: controller.goBack,
              onContinue: controller.continueLearning,
              onContextSelected: (contextNode) {
                final isDiscovered = controller.discoveredContextIds.contains(
                  contextNode.id,
                );
                if (isDiscovered) {
                  controller.previewContext(contextNode);
                }

                Get.bottomSheet<void>(
                  DiscoveryContextBottomSheet(
                    rootNode: matrixState.root,
                    contextNode: contextNode,
                    actionLabel: isDiscovered ? '\u0110\u00f3ng' : null,
                    onUnderstood: () async {
                      if (!isDiscovered) {
                        await controller.selectContext(contextNode);
                      }
                      Get.back<void>();
                    },
                  ),
                  isScrollControlled: true,
                  backgroundColor: Colors.black.withAlpha(96),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}

class _DiscoveryMatrixContent extends StatelessWidget {
  const _DiscoveryMatrixContent({
    required this.state,
    required this.selectedContextId,
    required this.discoveredContextIds,
    required this.onBack,
    required this.onContinue,
    required this.onContextSelected,
  });

  final DiscoveryMatrixState state;
  final String? selectedContextId;
  final Set<String> discoveredContextIds;
  final VoidCallback onBack;
  final VoidCallback onContinue;
  final ValueChanged<DiscoveryContextNode> onContextSelected;

  @override
  Widget build(BuildContext context) {
    final selectedContext = state.contextFor(selectedContextId);
    final understoodCount = state.contexts
        .where((contextNode) => discoveredContextIds.contains(contextNode.id))
        .length;
    final isComplete =
        state.contexts.isNotEmpty &&
        state.contexts.every(
          (contextNode) => discoveredContextIds.contains(contextNode.id),
        );

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            KivoScale.w(18),
            KivoScale.h(10),
            KivoScale.w(18),
            KivoScale.h(28),
          ),
          sliver: SliverList.list(
            children: [
              DiscoveryHeader(
                title: state.title,
                subtitle: state.subtitle,
                onBack: onBack,
              ),
              SizedBox(height: KivoScale.h(10)),
              TargetWordBanner(root: state.root),
              SizedBox(height: KivoScale.h(10)),
              DiscoveryProgressBadge(
                understoodCount: understoodCount,
                totalCount: state.contexts.length,
              ),
              SizedBox(height: KivoScale.h(14)),
              DiscoveryMatrixMap(
                state: state,
                selectedContextId: selectedContextId,
                discoveredContextIds: discoveredContextIds,
                onContextTap: onContextSelected,
              ),
              SizedBox(height: KivoScale.h(10)),
              if (selectedContext == null)
                const DiscoverySentencePlaceholder()
              else
                DiscoverySentencePanel(
                  englishChunks: selectedContext.englishChunks,
                  vietnameseChunks: selectedContext.vietnameseChunks,
                ),
              if (isComplete) ...[
                SizedBox(height: KivoScale.h(16)),
                DiscoveryCompletionCard(state: state, onContinue: onContinue),
              ] else ...[
                SizedBox(height: KivoScale.h(8)),
                const TapHint(),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
