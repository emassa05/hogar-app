import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/errors/app_exception.dart';
import '../domain/template_entities.dart';
part 'template_selection_state.freezed.dart';

@freezed
class TemplateSelectionState with _$TemplateSelectionState {
  const TemplateSelectionState._();
  const factory TemplateSelectionState({
    required List<TemplateSummary> templates,
    required Map<String, TemplateDetail> details,
    @Default(<String>{}) Set<String> selected,
    @Default(false) bool busy,
    TemplateApplication? application,
    AppException? error,
    DateTime? blockedUntil,
  }) = _TemplateSelectionState;
  int get taskTotal => templates
      .where((template) => selected.contains(template.key))
      .fold(0, (total, template) => total + template.taskCount);
  List<TemplateTask> get previewTasks => selected
      .expand((key) => details[key]?.tasks ?? const <TemplateTask>[])
      .toList(growable: false);
}
