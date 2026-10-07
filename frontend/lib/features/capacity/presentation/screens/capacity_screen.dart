import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/session/session_controller.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/avatar_circle.dart';
import '../../../../core/widgets/error_banner.dart';
import '../../../../core/widgets/info_banner.dart';
import '../../../households/domain/household_entities.dart';
import '../../../households/presentation/widgets/household_layout.dart';
import '../../../profile/presentation/widgets/capacity_card.dart';
import '../capacity_controller.dart';
import '../capacity_state.dart';
import '../capacity_strings.dart';
import '../widgets/capacity_distribution_card.dart';

class CapacityScreen extends ConsumerWidget {
  const CapacityScreen({required this.householdId, super.key});
  final String householdId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionControllerProvider).user;
    if (user?.activeHouseholdId != householdId) {
      return HouseholdLayout(
        title: CapacityStrings.title,
        onBack: () => context.goNamed(RouteNames.householdSettings),
        child: const Text(CapacityStrings.unavailable),
      );
    }
    final epoch = ref.read(sessionControllerProvider.notifier).epoch;
    final value = ref.watch(capacityControllerProvider(householdId));
    return value.when(
      skipLoadingOnReload: false,
      skipLoadingOnRefresh: false,
      loading: () => HouseholdLayout(
        title: CapacityStrings.title,
        onBack: () => context.goNamed(RouteNames.householdSettings),
        child: LoadPlaceholder(
          error: null,
          onRetry: () =>
              ref.invalidate(capacityControllerProvider(householdId)),
        ),
      ),
      error: (error, _) => HouseholdLayout(
        title: CapacityStrings.title,
        onBack: () => context.goNamed(RouteNames.householdSettings),
        child: LoadPlaceholder(
          error: asAppException(error),
          onRetry: () =>
              ref.invalidate(capacityControllerProvider(householdId)),
        ),
      ),
      data: (state) => _CapacityContent(
        key: ValueKey((householdId, user!.id, epoch)),
        householdId: householdId,
        userId: user.id,
        state: state,
      ),
    );
  }
}

class _CapacityContent extends ConsumerStatefulWidget {
  const _CapacityContent({
    required this.householdId,
    required this.userId,
    required this.state,
    super.key,
  });
  final String householdId;
  final String userId;
  final CapacityState state;
  @override
  ConsumerState<_CapacityContent> createState() => _CapacityContentState();
}

class _CapacityContentState extends ConsumerState<_CapacityContent> {
  int? _proposal;
  Map<String, int> _allocations = {};
  String _membershipKey = '';
  String? _upcomingId;
  String? _currentId;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() {
    final overview = widget.state.overview;
    final own = overview.proposals.where(
      (item) => item.member.userId == widget.userId,
    );
    _proposal = own.isEmpty ? null : own.first.proposedCapacityPercent;
    _membershipKey = overview.proposals
        .map((item) => item.member.userId)
        .join(':');
    _upcomingId = overview.upcoming?.id;
    _currentId = overview.current?.id;
    final approved = overview.upcoming ?? overview.current;
    _allocations = {
      for (final proposal in overview.proposals)
        proposal.member.userId:
            approved?.allocations
                .where((item) => item.member.userId == proposal.member.userId)
                .firstOrNull
                ?.percent ??
            proposal.proposedCapacityPercent ??
            0,
    };
  }

  @override
  void didUpdateWidget(_CapacityContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    final key = widget.state.overview.proposals
        .map((item) => item.member.userId)
        .join(':');
    if (key != _membershipKey ||
        _upcomingId != widget.state.overview.upcoming?.id ||
        _currentId != widget.state.overview.current?.id ||
        oldWidget.state.role != widget.state.role) {
      final previous = oldWidget.state.overview.proposals
          .where((item) => item.member.userId == widget.userId)
          .firstOrNull;
      final draft = _proposal;
      final keepDraft =
          previous != null && draft != previous.proposedCapacityPercent;
      _initialize();
      if (keepDraft &&
          widget.state.overview.proposals.any(
            (item) => item.member.userId == widget.userId,
          )) {
        _proposal = draft;
      }
    } else {
      final previous = oldWidget.state.overview.proposals
          .where((item) => item.member.userId == widget.userId)
          .firstOrNull;
      final current = widget.state.overview.proposals
          .where((item) => item.member.userId == widget.userId)
          .firstOrNull;
      if (_proposal == previous?.proposedCapacityPercent) {
        _proposal = current?.proposedCapacityPercent;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final overview = state.overview;
    final controller = ref.read(
      capacityControllerProvider(widget.householdId).notifier,
    );
    final total = _allocations.values.fold(0, (sum, value) => sum + value);
    final own = overview.proposals
        .where((item) => item.member.userId == widget.userId)
        .firstOrNull;
    final proposalChanged =
        _proposal != null && _proposal != own?.proposedCapacityPercent;
    return HouseholdLayout(
      title: CapacityStrings.title,
      busy: state.busy,
      onBack: () => context.goNamed(RouteNames.householdSettings),
      footer: own == null
          ? null
          : PrimaryButton(
              compact: true,
              label: CapacityStrings.saveProposal,
              loading: state.busy,
              onPressed: state.busy || !proposalChanged
                  ? null
                  : () => unawaited(controller.saveProposal(_proposal!)),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ScreenIntro(
            title: CapacityStrings.heading,
            body: CapacityStrings.explanation,
          ),
          const SizedBox(height: 18),
          const Text(
            CapacityStrings.scheduling,
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: 12),
          const Text(
            CapacityStrings.invalidation,
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: 20),
          if (overview.current case final current?)
            CapacityDistributionCard(
              title: CapacityStrings.current,
              distribution: current,
            )
          else
            const InfoBanner(message: CapacityStrings.unconfigured),
          const SizedBox(height: 16),
          if (overview.upcoming case final upcoming?)
            CapacityDistributionCard(
              title: CapacityStrings.upcoming,
              distribution: upcoming,
            )
          else
            const Text(
              CapacityStrings.noUpcoming,
              style: AppTypography.bodySmall,
            ),
          const SizedBox(height: 18),
          Semantics(
            header: true,
            child: const Text(
              CapacityStrings.proposals,
              style: AppTypography.titleMedium,
            ),
          ),
          const SizedBox(height: 16),
          if (overview.proposals.isEmpty) const Text(CapacityStrings.noMembers),
          for (final proposal in overview.proposals) ...[
            if (proposal.member.userId == widget.userId)
              Semantics(
                label:
                    '${proposal.member.displayName}. ${CapacityStrings.ownProposal}',
                child: CapacityCard(
                  key: const ValueKey('own-capacity'),
                  value: _proposal,
                  title: CapacityStrings.ownProposal,
                  helpText: null,
                  divisions: 100,
                  leading: AvatarCircle(
                    avatar: proposal.member.avatar,
                    name: proposal.member.displayName,
                    size: 32,
                  ),
                  enabled: !state.busy,
                  onChanged: (value) => setState(() => _proposal = value),
                ),
              )
            else
              AppCard(
                child: Row(
                  children: [
                    AvatarCircle(
                      avatar: proposal.member.avatar,
                      name: proposal.member.displayName,
                      size: 32,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        proposal.member.displayName,
                        style: AppTypography.titleSmall,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        proposal.proposedCapacityPercent == null
                            ? CapacityStrings.unset
                            : CapacityStrings.percent(
                                proposal.proposedCapacityPercent!,
                              ),
                        style: AppTypography.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 18),
          ],
          if (_proposal == 0 ||
              overview.proposals.any(
                (item) => item.proposedCapacityPercent == 0,
              )) ...[
            const InfoBanner(message: CapacityStrings.zeroHelp),
            const SizedBox(height: 16),
          ],
          if (state.role == MemberRole.admin &&
              overview.proposals.isNotEmpty) ...[
            const Text(
              CapacityStrings.approval,
              style: AppTypography.titleMedium,
            ),
            const SizedBox(height: 12),
            const Text(
              CapacityStrings.approvalHelp,
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: 16),
            for (final proposal in overview.proposals) ...[
              Semantics(
                label:
                    '${CapacityStrings.approval}. ${proposal.member.displayName}',
                child: CapacityCard(
                  key: ValueKey('approval-${proposal.member.userId}'),
                  title: proposal.member.displayName,
                  leading: AvatarCircle(
                    avatar: proposal.member.avatar,
                    name: proposal.member.displayName,
                    size: 32,
                  ),
                  helpText: null,
                  value: _allocations[proposal.member.userId],
                  divisions: 100,
                  enabled: !state.busy,
                  onChanged: (value) => setState(
                    () => _allocations[proposal.member.userId] = value,
                  ),
                ),
              ),
              const SizedBox(height: 18),
            ],
            InfoBanner(
              message: CapacityStrings.total(total),
              tone: total == 100 ? BannerTone.success : BannerTone.warning,
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              compact: true,
              label: CapacityStrings.approve,
              loading: state.busy,
              onPressed: state.busy || total != 100
                  ? null
                  : () => unawaited(controller.approve(Map.of(_allocations))),
            ),
            const SizedBox(height: 18),
          ],
          if (state.savedPart.isNotEmpty || state.error != null) ...[
            SaveFeedback(error: null, savedPart: state.savedPart),
            const SizedBox(height: 12),
          ],
          SecondaryButton(
            label: CapacityStrings.refresh,
            onPressed: state.busy ? null : () => unawaited(controller.reload()),
          ),
          const SizedBox(height: 18),
          if (!state.historyLoaded)
            SecondaryButton(
              label: CapacityStrings.showHistory,
              onPressed: state.busy
                  ? null
                  : () => unawaited(controller.loadHistory()),
            )
          else ...[
            const Text(
              CapacityStrings.history,
              style: AppTypography.titleMedium,
            ),
            const SizedBox(height: 12),
            const Text(
              CapacityStrings.historyHelp,
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: 12),
            if (state.history.isEmpty) const Text(CapacityStrings.emptyHistory),
            for (final distribution in state.history) ...[
              CapacityDistributionCard(
                title: CapacityStrings.history,
                distribution: distribution,
              ),
              const SizedBox(height: 16),
            ],
            if (state.nextCursor != null)
              SecondaryButton(
                label: CapacityStrings.moreHistory,
                onPressed: state.busy
                    ? null
                    : () => unawaited(controller.loadHistory()),
              ),
          ],
          if (state.error != null) ...[
            const SizedBox(height: 16),
            ErrorBanner(
              error: state.error!,
              onRetry: state.busy ? null : () => unawaited(controller.reload()),
            ),
          ],
        ],
      ),
    );
  }
}
