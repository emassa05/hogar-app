import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/motion/app_haptics.dart';
import '../../../../core/motion/motion_reveal.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/deadline_builder.dart';
import '../../../../core/widgets/field_message.dart';
import '../../../../core/widgets/section_label.dart';
import '../../../households/presentation/household_strings.dart';
import '../../../households/presentation/widgets/household_layout.dart';
import '../../domain/template_entities.dart';
import '../template_controller.dart';
import '../template_selection_state.dart';
import '../widgets/template_card.dart';

class TemplatesScreen extends ConsumerWidget {
  const TemplatesScreen({required this.householdId, super.key});
  final String householdId;

  Future<void> _apply(WidgetRef ref, {bool empty = false}) async {
    final applied = await ref
        .read(templateControllerProvider(householdId).notifier)
        .apply(empty: empty);
    if (applied) unawaited(AppHaptics.success());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(templateControllerProvider(householdId));
    final view = async.valueOrNull;
    final busy = view?.busy ?? false;
    final application = view?.application;
    return HouseholdLayout(
      title: HouseholdStrings.templates,
      busy: busy,
      showBack: application == null,
      footer: view == null
          ? null
          : application != null
          ? PrimaryButton(
              label: HouseholdStrings.enterHome,
              compact: true,
              onPressed: () => context.goNamed(RouteNames.home),
            )
          : DeadlineBuilder(
              deadline: view.blockedUntil,
              builder: (context, seconds) => FooterActions(
                children: [
                  SecondaryButton(
                    label: HouseholdStrings.startEmpty,
                    loading: busy && view.selected.isEmpty,
                    onPressed: busy || seconds > 0
                        ? null
                        : () => unawaited(_apply(ref, empty: true)),
                  ),
                  PrimaryButton(
                    label: HouseholdStrings.addTasks(view.taskTotal),
                    compact: true,
                    loading: busy && view.selected.isNotEmpty,
                    onPressed: view.selected.isEmpty || busy || seconds > 0
                        ? null
                        : () => unawaited(_apply(ref)),
                  ),
                ],
              ),
            ),
      child: view == null
          ? LoadPlaceholder(
              error: async.hasError && !async.isLoading
                  ? asAppException(async.error)
                  : null,
              onRetry: () =>
                  ref.invalidate(templateControllerProvider(householdId)),
            )
          : application != null
          ? _Applied(application: application)
          : _Selection(
              view: view,
              onToggle: (key) => ref
                  .read(templateControllerProvider(householdId).notifier)
                  .toggle(key),
              onRetry: () => unawaited(_apply(ref)),
            ),
    );
  }
}

class _Selection extends StatelessWidget {
  const _Selection({
    required this.view,
    required this.onToggle,
    required this.onRetry,
  });
  final TemplateSelectionState view;
  final ValueChanged<String> onToggle;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = {
      for (final (index, template) in view.templates.indexed)
        template.key: templateTone(template.key, index).$2,
    };
    final tasks = [
      for (final key in view.selected)
        for (final task in view.details[key]?.tasks ?? const <TemplateTask>[])
          (task, colors[key] ?? AppColors.categoryOne),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ScreenIntro(
          title: HouseholdStrings.templatesTitle,
          body: HouseholdStrings.templatesBody,
        ),
        const SizedBox(height: 18),
        if (view.templates.isEmpty)
          const FieldMessage.helper(HouseholdStrings.emptyTemplates)
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = MediaQuery.textScalerOf(context).scale(10) >= 15
                  ? 1
                  : 2;
              final width =
                  (constraints.maxWidth - 12 * (columns - 1)) / columns;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final (index, template) in view.templates.indexed)
                    SizedBox(
                      width: width,
                      child: TemplateCard(
                        template: template,
                        index: index,
                        selected: view.selected.contains(template.key),
                        onToggle: view.busy
                            ? null
                            : () => onToggle(template.key),
                      ),
                    ),
                ],
              );
            },
          ),
        const SizedBox(height: 18),
        Semantics(
          liveRegion: true,
          child: SectionLabel(
            label: HouseholdStrings.willAdd(view.taskTotal),
            trailing: HouseholdStrings.templateCount(view.selected.length),
          ),
        ),
        for (final (index, (task, color)) in tasks.indexed) ...[
          const SizedBox(height: 18),
          MotionReveal(
            key: ValueKey('${task.activityKey}-$index'),
            index: index,
            child: TemplateTaskRow(task: task, color: color),
          ),
        ],
        if (view.error != null) ...[
          const SizedBox(height: 18),
          SaveFeedback(
            error: view.error,
            savedPart: '',
            onRetry: view.busy ? null : onRetry,
          ),
        ],
      ],
    );
  }
}

class _Applied extends StatelessWidget {
  const _Applied({required this.application});
  final TemplateApplication application;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 40),
    child: Column(
      children: [
        MotionReveal(
          delight: true,
          child: Container(
            width: 88,
            height: 88,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.successSurface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.surface, width: 4),
              boxShadow: AppShadows.badge,
            ),
            child: const AppIcon(
              AppIcons.check,
              size: 40,
              color: AppColors.inverse,
            ),
          ),
        ),
        const SizedBox(height: 24),
        MotionReveal(
          index: 2,
          child: Semantics(
            liveRegion: true,
            header: true,
            child: const Text(
              HouseholdStrings.applied,
              textAlign: TextAlign.center,
              style: AppTypography.display,
            ),
          ),
        ),
        const SizedBox(height: 12),
        MotionReveal(
          index: 3,
          child: Text(
            application.taskCount == 0
                ? HouseholdStrings.appliedEmpty
                : HouseholdStrings.appliedTasks(application.taskCount),
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium,
          ),
        ),
      ],
    ),
  );
}
