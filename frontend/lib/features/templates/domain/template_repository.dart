import '../../../core/result/result.dart';
import 'template_entities.dart';

abstract interface class TemplateRepository {
  Future<Result<List<TemplateSummary>>> list();
  Future<Result<TemplateDetail>> detail(String key);
  Future<Result<TemplateApplication>> application(String id);
  Future<Result<TemplateApplication>> apply(
    String id,
    List<String> keys,
    String actionKey,
  );
}
