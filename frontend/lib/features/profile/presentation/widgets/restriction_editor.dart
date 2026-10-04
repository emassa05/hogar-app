import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/error_messages.dart';
import '../../../../core/motion/app_haptics.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/error_banner.dart';
import '../../../../core/widgets/field_message.dart';
import '../../../../core/widgets/selectable_chip.dart';
import '../../../catalog/presentation/catalog_providers.dart';
import '../../../households/presentation/household_strings.dart';
import '../../../households/presentation/widgets/household_layout.dart';
import '../../domain/profile_entities.dart';
import '../../domain/profile_repository.dart';
import '../profile_controller.dart';
import 'restriction_tile.dart';

String isoDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

Future<void> showRestrictionEditor(
  BuildContext context, {
  required String householdId,
  Restriction? initial,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: true,
  backgroundColor: AppColors.surface,
  builder: (context) =>
      RestrictionEditor(householdId: householdId, initial: initial),
);

class RestrictionEditor extends ConsumerStatefulWidget {
  const RestrictionEditor({required this.householdId, this.initial, super.key});
  final String householdId;
  final Restriction? initial;
  @override
  ConsumerState<RestrictionEditor> createState() => _RestrictionEditorState();
}

class _RestrictionEditorState extends ConsumerState<RestrictionEditor> {
  late RestrictionTargetType _type =
      widget.initial?.target.type ?? RestrictionTargetType.category;
  late String? _key = widget.initial?.target.key;
  late RestrictionKind _kind =
      widget.initial?.kind ?? RestrictionKind.permanent;
  late String? _endsOn = widget.initial?.endsOn;
  bool _attempted = false;

  bool get _valid =>
      _key != null && (_kind == RestrictionKind.permanent || _endsOn != null);

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _endsOn == null
        ? now.add(const Duration(days: 7))
        : DateTime.parse(_endsOn!);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(now) ? now : initial,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 5),
      helpText: HouseholdStrings.endDate,
    );
    if (picked != null) setState(() => _endsOn = isoDate(picked));
  }

  Future<void> _save() async {
    setState(() => _attempted = true);
    if (!_valid) return;
    final input = RestrictionInput(
      target: RestrictionTarget(type: _type, key: _key!),
      kind: _kind,
      startsOn: widget.initial?.startsOn,
      endsOn: _kind == RestrictionKind.temporary ? _endsOn : null,
    );
    final controller = ref.read(
      profileControllerProvider(widget.householdId).notifier,
    );
    final saved = widget.initial == null
        ? await controller.addRestriction(input)
        : await controller.editRestriction(widget.initial!.id, input);
    if (!saved || !mounted) return;
    unawaited(AppHaptics.commit());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final view = ref
        .watch(profileControllerProvider(widget.householdId))
        .valueOrNull;
    final busy = view?.busy ?? false;
    final error = view?.error;
    final options = _type == RestrictionTargetType.category
        ? ref
              .watch(taskCategoriesProvider)
              .whenData(
                (items) => [for (final item in items) (item.key, item.name)],
              )
        : ref
              .watch(activitiesProvider)
              .whenData(
                (items) => [for (final item in items) (item.key, item.name)],
              );
    final endError = ErrorMessages.field(error, 'ends_on');
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                widget.initial == null
                    ? HouseholdStrings.addRestriction
                    : HouseholdStrings.editRestriction,
                style: AppTypography.titleLarge,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              HouseholdStrings.restrictionHelp,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                for (final (type, label) in const [
                  (RestrictionTargetType.category, HouseholdStrings.category),
                  (RestrictionTargetType.activity, HouseholdStrings.activity),
                ])
                  SelectableChip(
                    label: label,
                    selected: _type == type,
                    onSelected: busy
                        ? null
                        : (_) => setState(() {
                            _type = type;
                            _key = null;
                          }),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            options.when(
              skipLoadingOnRefresh: false,
              loading: () => const LoadPlaceholder(error: null, onRetry: _noop),
              error: (error, _) => ErrorBanner(
                error: asAppException(error),
                onRetry: () => ref.invalidate(
                  _type == RestrictionTargetType.category
                      ? taskCategoriesProvider
                      : activitiesProvider,
                ),
              ),
              data: (items) => items.isEmpty
                  ? const FieldMessage.helper(HouseholdStrings.emptyCatalog)
                  : Wrap(
                      spacing: 8,
                      children: [
                        for (final (key, name) in items)
                          SelectableChip(
                            label: name,
                            selected: _key == key,
                            tone: ChipTone.danger,
                            onSelected: busy
                                ? null
                                : (_) => setState(() => _key = key),
                          ),
                      ],
                    ),
            ),
            if (_attempted && _key == null)
              const FieldMessage.error(HouseholdStrings.chooseTarget),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                for (final (kind, label) in const [
                  (RestrictionKind.permanent, HouseholdStrings.permanent),
                  (RestrictionKind.temporary, HouseholdStrings.temporary),
                ])
                  SelectableChip(
                    label: label,
                    selected: _kind == kind,
                    onSelected: busy
                        ? null
                        : (_) => setState(() => _kind = kind),
                  ),
              ],
            ),
            if (_kind == RestrictionKind.temporary) ...[
              const SizedBox(height: 8),
              SecondaryButton(
                label: _endsOn == null
                    ? HouseholdStrings.chooseEndDate
                    : HouseholdStrings.endsOn(displayDate(_endsOn!)),
                onPressed: busy ? null : () => unawaited(_pickDate()),
              ),
              if (endError != null || (_attempted && _endsOn == null)) ...[
                const SizedBox(height: 6),
                FieldMessage.error(endError ?? HouseholdStrings.endDateNeeded),
              ],
            ],
            if (error != null && endError == null) ...[
              const SizedBox(height: 16),
              ErrorBanner(error: error),
            ],
            const SizedBox(height: 20),
            PrimaryButton(
              label: HouseholdStrings.save,
              compact: true,
              loading: busy,
              onPressed: () => unawaited(_save()),
            ),
          ],
        ),
      ),
    );
  }
}

void _noop() {}
