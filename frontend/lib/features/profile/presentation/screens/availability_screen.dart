import 'dart:async';

import 'package:flutter/material.dart' hide DayPeriod;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/motion/app_haptics.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/deadline_builder.dart';
import '../../../../core/widgets/section_label.dart';
import '../../../households/presentation/household_strings.dart';
import '../../../households/presentation/widgets/household_layout.dart';
import '../../domain/profile_entities.dart';
import '../profile_controller.dart';
import '../widgets/availability_grid.dart';
import '../widgets/restriction_editor.dart';
import '../widgets/restriction_tile.dart';

class AvailabilityScreen extends ConsumerStatefulWidget {
  const AvailabilityScreen({required this.householdId, super.key});
  final String householdId;
  @override
  ConsumerState<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends ConsumerState<AvailabilityScreen> {
  Set<String>? _slots;

  ProfileControllerProvider get _provider =>
      profileControllerProvider(widget.householdId);

  void _toggle(int weekday, DayPeriod period) {
    final key = slotKey(weekday, period);
    setState(() {
      final next = {...?_slots};
      if (!next.add(key)) next.remove(key);
      _slots = next;
    });
  }

  Future<void> _save(MemberProfile profile) async {
    final slots = _slots ?? _initial(profile);
    final availability = Availability(
      slots: [
        for (var weekday = 0; weekday < 7; weekday++)
          for (final period in DayPeriod.values)
            if (slots.contains(slotKey(weekday, period)))
              AvailabilitySlot(weekday: weekday, period: period),
      ],
      exceptions: profile.availability.exceptions,
    );
    if (!await ref.read(_provider.notifier).saveAvailability(availability) ||
        !mounted) {
      return;
    }
    unawaited(AppHaptics.commit());
    unawaited(
      context.pushNamed(
        RouteNames.householdPreferences,
        pathParameters: {'householdId': widget.householdId},
      ),
    );
  }

  Set<String> _initial(MemberProfile profile) => {
    for (final slot in profile.availability.slots)
      slotKey(slot.weekday, slot.period),
  };

  Future<void> _restrictionAction(
    Restriction restriction,
    RestrictionAction action,
  ) async {
    switch (action) {
      case RestrictionAction.edit:
        await showRestrictionEditor(
          context,
          householdId: widget.householdId,
          initial: restriction,
        );
      case RestrictionAction.remove:
        await ref.read(_provider.notifier).removeRestriction(restriction.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_provider);
    final view = async.valueOrNull;
    final busy = view?.busy ?? false;
    final slots =
        _slots ?? (view == null ? <String>{} : _initial(view.profile));
    return HouseholdLayout(
      title: HouseholdStrings.availability,
      busy: busy,
      footer: DeadlineBuilder(
        deadline: view?.blockedUntil,
        builder: (context, seconds) => PrimaryButton(
          label: HouseholdStrings.save,
          compact: true,
          loading: busy,
          onPressed: view == null || seconds > 0
              ? null
              : () => unawaited(_save(view.profile)),
        ),
      ),
      child: view == null
          ? LoadPlaceholder(
              error: async.hasError && !async.isLoading
                  ? asAppException(async.error)
                  : null,
              onRetry: () => ref.invalidate(_provider),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const ScreenIntro(
                  title: HouseholdStrings.availabilityTitle,
                  body: HouseholdStrings.availabilityBody,
                ),
                const SizedBox(height: 18),
                AvailabilityGrid(
                  selected: slots,
                  enabled: !busy,
                  onToggle: _toggle,
                ),
                const SizedBox(height: 18),
                const SectionLabel(label: HouseholdStrings.restrictions),
                const SizedBox(height: 18),
                if (view.profile.restrictions.isEmpty)
                  Text(
                    HouseholdStrings.noRestrictions,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                for (final restriction in view.profile.restrictions) ...[
                  RestrictionTile(
                    restriction: restriction,
                    onAction: busy
                        ? null
                        : (action) => unawaited(
                            _restrictionAction(restriction, action),
                          ),
                  ),
                  const SizedBox(height: 18),
                ],
                if (view.profile.restrictions.isEmpty)
                  const SizedBox(height: 18),
                DashedAddButton(
                  label: HouseholdStrings.addRestriction,
                  onPressed: busy
                      ? null
                      : () => unawaited(
                          showRestrictionEditor(
                            context,
                            householdId: widget.householdId,
                          ),
                        ),
                ),
                if (view.error != null || view.savedPart.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  SaveFeedback(
                    error: view.error,
                    savedPart: view.savedPart,
                    onRetry: busy ? null : () => unawaited(_save(view.profile)),
                  ),
                ],
              ],
            ),
    );
  }
}
