import 'package:dio/dio.dart';
import '../../../core/network/api_response.dart';
import 'template_dtos.dart';

class TemplateRemoteDataSource {
  const TemplateRemoteDataSource(this.dio);
  final Dio dio;
  Future<List<TemplateSummaryDto>> list() async => ApiResponse.objects(
    (await dio.get<Object?>('/household-templates')).data,
  ).map(TemplateSummaryDto.fromJson).toList();
  Future<TemplateDetailDto> detail(String key) async =>
      TemplateDetailDto.fromJson(
        ApiResponse.object(
          (await dio.get<Object?>('/household-templates/$key')).data,
        ),
      );
  Future<TemplateApplicationDto> application(String id) async =>
      TemplateApplicationDto.fromJson(
        ApiResponse.object(
          (await dio.get<Object?>('/households/$id/template-application')).data,
        ),
      );
  Future<TemplateApplicationDto> apply(
    String id,
    List<String> keys,
    String actionKey,
  ) async => TemplateApplicationDto.fromJson(
    ApiResponse.object(
      (await dio.post<Object?>(
        '/households/$id/template-application',
        data: {'template_keys': keys},
        options: Options(headers: {'Idempotency-Key': actionKey}),
      )).data,
    ),
  );
}
