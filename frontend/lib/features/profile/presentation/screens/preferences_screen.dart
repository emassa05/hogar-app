import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/error_messages.dart';
import '../../../../core/motion/app_haptics.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/deadline_builder.dart';
import '../../../../core/widgets/field_message.dart';
import '../../../../core/widgets/selectable_chip.dart';
import '../../../catalog/domain/catalog_entities.dart';
import '../../../catalog/presentation/catalog_providers.dart';
import '../../../households/domain/household_entities.dart';
import '../../../households/presentation/household_controller.dart';
import '../../../households/presentation/household_strings.dart';
import '../../../households/presentation/widgets/household_layout.dart';
import '../../domain/profile_entities.dart';
import '../profile_controller.dart';

Set<String> unableKeys(MemberProfile profile) => {
  for (final restriction in profile.restrictions)
    if (restriction.isActive &&
        restriction.kind == RestrictionKind.permanent &&
        restriction.target.type == RestrictionTargetType.activity)
      restriction.target.key,
};

Set<String> blockedKeys(MemberProfile profile, List<Activity> activities) {
  final categories = {
    for (final restriction in profile.restrictions)
      if (restriction.isActive &&
          restriction.target.type == RestrictionTargetType.category)
        restriction.target.key,
  };
  final temporary = {
    for (final restriction in profile.restrictions)
      if (restriction.isActive &&
          restriction.kind == RestrictionKind.temporary &&
          restriction.target.type == RestrictionTargetType.activity)
        restriction.target.key,
  };
  return {
    for (final activity in activities)
      if (categories.contains(activity.categoryKey) ||
          temporary.contains(activity.key))
        activity.key,
  };
}

class PreferencesScreen extends ConsumerStatefulWidget {
  const PreferencesScreen({required this.householdId, super.key});
  final String householdId;
  @override
  ConsumerState<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends ConsumerState<PreferencesScreen> {
  List<String>? _preferred;
  Set<String>? _unable;

  ProfileControllerProvider get _provider =>
      profileControllerProvider(widget.householdId);

  void _seed(MemberProfile profile) {
    _preferred ??= [...profile.preferences.preferredActivityKeys];
    _unable ??= unableKeys(profile);
  }

  void _togglePreferred(String key) => setState(() {
    if (!_preferred!.remove(key)) {
      _preferred!.add(key);
      _unable!.remove(key);
    }
  });

  void _toggleUnable(String key) => setState(() {
    if (!_unable!.remove(key)) {
      _unable!.add(key);
      _preferred!.remove(key);
    }
  });

  Future<void> _save() async {
    final saved = await ref
        .read(_provider.notifier)
        .savePreferences(_preferred!, _unable!);
    if (!saved || !mounted) return;
    unawaited(AppHaptics.commit());
    final household = await ref.read(activeHouseholdProvider.future);
    if (!mounted) return;
    final needsTemplates =
        household != null &&
        household.id == widget.householdId &&
        household.myRole == MemberRole.admin &&
        !household.templatesApplied;
    if (needsTemplates) {
      unawaited(
        context.pushNamed(
          RouteNames.householdTemplates,
          pathParameters: {'householdId': widget.householdId},
        ),
      );
    } else {
      context.goNamed(RouteNames.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_provider);
    final catalog = ref.watch(activitiesProvider);
    final view = async.valueOrNull;
    final activities = catalog.valueOrNull;
    if (view != null) _seed(view.profile);
    final busy = view?.busy ?? false;
    final ready = view != null && activities != null;
    final loadError = async.hasError && !async.isLoading
        ? async.error
        : catalog.hasError && !catalog.isLoading
        ? catalog.error
        : null;
    final fieldError = ErrorMessages.field(
      view?.error,
      'preferred_activity_keys',
    );
    return HouseholdLayout(
      title: HouseholdStrings.preferences,
      busy: busy,
      footer: DeadlineBuilder(
        deadline: view?.blockedUntil,
        builder: (context, seconds) => PrimaryButton(
          label: HouseholdStrings.savePreferences,
          compact: true,
          loading: busy,
          onPressed: !ready || seconds > 0 ? null : () => unawaited(_save()),
        ),
      ),
      child: !ready
          ? LoadPlaceholder(
              error: loadError == null ? null : asAppException(loadError),
              onRetry: () {
                ref
                  ..invalidate(_provider)
                  ..invalidate(activitiesProvider);
              },
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const ScreenIntro(
                  title: HouseholdStrings.preferencesTitle,
                  body: HouseholdStrings.preferencesBody,
                ),
                const SizedBox(height: 18),
                if (activities.isEmpty)
                  const FieldMessage.helper(HouseholdStrings.emptyCatalog)
                else ...[
                  _PreferenceGroup(
                    icon: AppIcons.heart,
                    tone: ChipTone.success,
                    title: HouseholdStrings.preferred,
                    subtitle: HouseholdStrings.preferredHelp,
                    activities: activities,
                    selected: _preferred!.toSet(),
                    disabled: blockedKeys(view.profile, activities),
                    enabled: !busy,
                    onToggle: _togglePreferred,
                  ),
                  if (fieldError != null) ...[
                    const SizedBox(height: 8),
                    FieldMessage.error(fieldError),
                  ],
                  const SizedBox(height: 18),
                  _PreferenceGroup(
                    icon: AppIcons.ban,
                    tone: ChipTone.danger,
                    title: HouseholdStrings.unable,
                    subtitle: HouseholdStrings.unableHelp,
                    activities: activities,
                    selected: _unable!,
                    disabled: const {},
                    enabled: !busy,
                    onToggle: _toggleUnable,
                  ),
                ],
                if ((view.error != null && fieldError == null) ||
                    view.savedPart.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  SaveFeedback(
                    error: fieldError == null ? view.error : null,
                    savedPart: view.savedPart,
                    onRetry: busy ? null : () => unawaited(_save()),
                  ),
                ],
              ],
            ),
    );
  }
}

class _PreferenceGroup extends StatelessWidget {
  const _PreferenceGroup({
    required this.icon,
    required this.tone,
    required this.title,
    required this.subtitle,
    required this.activities,
    required this.selected,
    required this.disabled,
    required this.enabled,
    required this.onToggle,
  });
  final AppIcons icon;
  final ChipTone tone;
  final String title;
  final String subtitle;
  final List<Activity> activities;
  final Set<String> selected;
  final Set<String> disabled;
  final bool enabled;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final success = tone == ChipTone.success;
    return AppCard(
      radius: AppRadius.large,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconTile(
                icon: icon,
                background: success
                    ? AppColors.successSubtle
                    : AppColors.dangerSubtle,
                color: success ? AppColors.iconSuccess : AppColors.iconDanger,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.titleSmall.copyWith(
                          color: success ? AppColors.success : AppColors.danger,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(subtitle, style: AppTypography.caption),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            children: [
              for (final activity in activities)
                SelectableChip(
                  label: activity.name,
                  tone: tone,
                  selected: selected.contains(activity.key),
                  onSelected:
                      enabled &&
                          (!disabled.contains(activity.key) ||
                              selected.contains(activity.key))
                      ? (_) => onToggle(activity.key)
                      : null,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
