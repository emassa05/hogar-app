import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/error_messages.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/session/session_controller.dart';
import '../../../../core/validation/validators.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/deadline_builder.dart';
import '../../domain/household_entities.dart';
import '../household_controller.dart';
import '../household_strings.dart';
import '../widgets/household_layout.dart';

class HouseholdEditScreen extends ConsumerStatefulWidget {
  const HouseholdEditScreen({required this.householdId, super.key});
  final String householdId;
  @override
  ConsumerState<HouseholdEditScreen> createState() =>
      _HouseholdEditScreenState();
}

class _HouseholdEditScreenState extends ConsumerState<HouseholdEditScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  bool _ready = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_load()));
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (ref.read(sessionControllerProvider).user?.activeHouseholdId !=
        widget.householdId) {
      return;
    }
    final loaded = await ref
        .read(householdControllerProvider.notifier)
        .load(widget.householdId, includeInvitation: false);
    if (loaded && mounted) {
      _name.text = ref.read(householdControllerProvider).household!.name;
      setState(() => _ready = true);
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    if (ref.read(sessionControllerProvider).user?.activeHouseholdId !=
        widget.householdId) {
      return;
    }
    final household = ref.read(householdControllerProvider).household;
    if (household?.id != widget.householdId ||
        household?.myRole != MemberRole.admin) {
      return;
    }
    final saved = await ref
        .read(householdControllerProvider.notifier)
        .rename(widget.householdId, household!.version, _name.text);
    if (saved && mounted) context.goNamed(RouteNames.householdSettings);
  }

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(householdControllerProvider);
    final activeId = ref.watch(
      sessionControllerProvider.select(
        (value) => value.user?.activeHouseholdId,
      ),
    );
    final household = flow.household?.id == widget.householdId
        ? flow.household
        : null;
    final eligible =
        activeId == widget.householdId &&
        household?.myRole == MemberRole.admin &&
        _ready;
    return HouseholdLayout(
      title: HouseholdStrings.editHousehold,
      onBack: () => context.goNamed(RouteNames.householdSettings),
      busy: flow.busy,
      footer: DeadlineBuilder(
        deadline: flow.blockedUntil,
        builder: (context, seconds) => PrimaryButton(
          label: HouseholdStrings.saveChanges,
          compact: true,
          loading: flow.busy,
          onPressed: eligible && seconds == 0 ? () => unawaited(_save()) : null,
        ),
      ),
      child: activeId != widget.householdId
          ? const Text(HouseholdStrings.inactiveHousehold)
          : !_ready
          ? LoadPlaceholder(
              error: flow.busy ? null : flow.error,
              onRetry: () => unawaited(_load()),
            )
          : !eligible
          ? const Text(HouseholdStrings.adminHelp)
          : Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(
                    label: HouseholdStrings.householdName,
                    controller: _name,
                    enabled: !flow.busy,
                    compact: true,
                    helperText: HouseholdStrings.nameHelp,
                    validator: NameValidator.validate,
                    errorText: ErrorMessages.field(flow.error, 'name'),
                  ),
                  const SizedBox(height: 16),
                  SaveFeedback(error: flow.error, savedPart: flow.savedPart),
                ],
              ),
            ),
    );
  }
}
