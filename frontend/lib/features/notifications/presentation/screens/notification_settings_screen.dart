import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/session/session_controller.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/error_banner.dart';
import '../../../../core/widgets/info_banner.dart';
import '../../../../core/widgets/selectable_chip.dart';
import '../../../households/presentation/widgets/household_layout.dart';
import '../../domain/notification_settings.dart';
import '../notification_settings_controller.dart';
import '../notification_strings.dart';

String? _dependencyMessage(AppException error) =>
    error is ApiException && error.statusCode == 404
    ? NotificationStrings.dependency
    : null;

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);
    final user = session.user;
    if (!session.isAuthenticated || user == null) {
      return const HouseholdLayout(
        title: NotificationStrings.title,
        child: SizedBox.shrink(),
      );
    }
    final actor = (
      userId: user.id,
      epoch: ref.read(sessionControllerProvider.notifier).epoch,
    );
    final provider = notificationSettingsControllerProvider(actor);
    final settings = ref.watch(provider);
    return HouseholdLayout(
      title: NotificationStrings.title,
      busy: settings.valueOrNull?.busy ?? false,
      onBack: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.goNamed(RouteNames.householdSettings);
        }
      },
      child: settings.when(
        skipLoadingOnRefresh: false,
        skipLoadingOnReload: false,
        loading: () => LoadPlaceholder(
          error: null,
          onRetry: () => ref.invalidate(provider),
        ),
        error: (error, _) => ErrorBanner(
          error: asAppException(error),
          message: _dependencyMessage(asAppException(error)),
          onRetry: () => ref.invalidate(provider),
        ),
        data: (value) =>
            _SettingsForm(key: ValueKey(actor), actor: actor, value: value),
      ),
    );
  }
}

class _SettingsForm extends ConsumerStatefulWidget {
  const _SettingsForm({required this.actor, required this.value, super.key});
  final NotificationActor actor;
  final NotificationSettingsState value;
  @override
  ConsumerState<_SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends ConsumerState<_SettingsForm> {
  final _form = GlobalKey<FormState>();
  late bool _muted;
  late Set<String> _mutedTypes;
  late bool _quietEnabled;
  late final TextEditingController _lead;
  late final TextEditingController _start;
  late final TextEditingController _end;
  bool _dirty = false;
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    final settings = widget.value.settings;
    _muted = settings.muted;
    _mutedTypes = settings.mutedTypes.toSet();
    _quietEnabled = settings.quietHours != null;
    _lead = TextEditingController(
      text: settings.reminderLeadMinutes?.toString() ?? '',
    );
    _start = TextEditingController(text: settings.quietHours?.start ?? '');
    _end = TextEditingController(text: settings.quietHours?.end ?? '');
  }

  @override
  void didUpdateWidget(covariant _SettingsForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value.blockedUntil != widget.value.blockedUntil) {
      _retryTimer?.cancel();
      final deadline = widget.value.blockedUntil;
      if (deadline != null) {
        final remaining = deadline.difference(DateTime.now().toUtc());
        _retryTimer = Timer(
          remaining.isNegative ? Duration.zero : remaining,
          () {
            if (mounted) setState(() {});
          },
        );
      }
    }
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _lead.dispose();
    _start.dispose();
    _end.dispose();
    super.dispose();
  }

  void _edit(VoidCallback change) => setState(() {
    change();
    _dirty = true;
  });

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final draft = NotificationSettings(
      muted: _muted,
      mutedTypes: _mutedTypes.toList(),
      quietHours: _quietEnabled ? QuietHours(_start.text, _end.text) : null,
      reminderLeadMinutes: _lead.text.isEmpty ? null : int.parse(_lead.text),
    );
    final settings = await ref
        .read(notificationSettingsControllerProvider(widget.actor).notifier)
        .save(draft);
    if (!mounted || settings == null) return;
    setState(() {
      _muted = settings.muted;
      _mutedTypes = settings.mutedTypes.toSet();
      _quietEnabled = settings.quietHours != null;
      _lead.text = settings.reminderLeadMinutes?.toString() ?? '';
      _start.text = settings.quietHours?.start ?? '';
      _end.text = settings.quietHours?.end ?? '';
      _dirty = false;
    });
  }

  Widget _toggle(
    String label,
    bool value,
    ValueChanged<bool> change, {
    String? id,
  }) => Material(
    type: MaterialType.transparency,
    child: SwitchListTile(
      key: ValueKey(id ?? label),
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: AppTypography.bodyMedium),
      value: value,
      onChanged: widget.value.busy
          ? null
          : (value) => _edit(() => change(value)),
    ),
  );

  Widget _types(
    String heading,
    List<String> types, {
    List<Widget> extra = const [],
  }) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(heading, style: AppTypography.titleMedium),
        ),
        for (final type in types)
          _toggle(
            NotificationStrings.labels[type]!,
            !_mutedTypes.contains(type),
            (enabled) =>
                enabled ? _mutedTypes.remove(type) : _mutedTypes.add(type),
            id: type,
          ),
        ...extra,
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final value = widget.value;
    return Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ScreenIntro(
            title: NotificationStrings.heading,
            body: NotificationStrings.help,
          ),
          const SizedBox(height: 24),
          AppCard(
            child: _toggle(
              NotificationStrings.muted,
              _muted,
              (value) => _muted = value,
              id: 'muted',
            ),
          ),
          const SizedBox(height: 16),
          _types(
            NotificationStrings.tasks,
            ['task_reminder', 'task_due', 'routine_without_candidate'],
            extra: [
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final option in {
                    10: '10 min',
                    30: '30 min',
                    60: '1 h',
                    1440: '1 día',
                  }.entries)
                    SelectableChip(
                      label: option.value,
                      selected: int.tryParse(_lead.text) == option.key,
                      onSelected: value.busy
                          ? null
                          : (_) => _edit(() => _lead.text = '${option.key}'),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: NotificationStrings.lead,
                controller: _lead,
                enabled: !value.busy,
                keyboardType: TextInputType.number,
                helperText: NotificationStrings.leadHelp,
                onChanged: (_) => _edit(() {}),
                validator: (text) {
                  if (text == null || text.isEmpty) return null;
                  final minutes = int.tryParse(text);
                  return RegExp(r'^[0-9]+$').hasMatch(text) &&
                          minutes != null &&
                          minutes >= 5 &&
                          minutes <= 10080
                      ? null
                      : NotificationStrings.leadError;
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _types(NotificationStrings.sharing, [
            'suggestion_pending',
            'suggestion_resolved',
            'swap_request',
            'swap_resolved',
          ]),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _toggle(
                  NotificationStrings.quiet,
                  _quietEnabled,
                  (value) => _quietEnabled = value,
                  id: 'quiet',
                ),
                const Text(
                  NotificationStrings.quietHelp,
                  style: AppTypography.bodySmall,
                ),
                if (_quietEnabled) ...[
                  const SizedBox(height: 16),
                  for (final field in [
                    (_start, NotificationStrings.start),
                    (_end, NotificationStrings.end),
                  ]) ...[
                    AppTextField(
                      label: field.$2,
                      controller: field.$1,
                      enabled: !value.busy,
                      hintText: 'HH:MM',
                      onChanged: (_) => _edit(() {}),
                      validator: (text) =>
                          text != null && QuietHours.validTime(text)
                          ? null
                          : NotificationStrings.timeError,
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (value.error != null) ...[
            ErrorBanner(
              error: value.error!,
              message: _dependencyMessage(value.error!),
              onRetry: value.busy || value.blocked ? null : _save,
            ),
            const SizedBox(height: 12),
          ],
          if (value.uncertain) ...[
            const InfoBanner(
              message: NotificationStrings.uncertain,
              tone: BannerTone.warning,
            ),
            const SizedBox(height: 12),
          ],
          if (value.saved && !_dirty) ...[
            const InfoBanner(message: NotificationStrings.saved),
            const SizedBox(height: 12),
          ],
          PrimaryButton(
            label: NotificationStrings.save,
            loading: value.busy,
            onPressed: value.busy || value.blocked ? null : _save,
          ),
        ],
      ),
    );
  }
}
