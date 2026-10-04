import 'package:dio/dio.dart';

import '../errors/app_exception.dart';
import '../network/error_mapper.dart';

sealed class Result<T> {
  const Result();

  R fold<R>(
    R Function(T value) success,
    R Function(AppException error) failure,
  ) => switch (this) {
    Success<T>(:final value) => success(value),
    Failure<T>(:final error) => failure(error),
  };
}

final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

final class Failure<T> extends Result<T> {
  const Failure(this.error);
  final AppException error;
}

Future<Result<T>> capture<T>(Future<T> Function() operation) async {
  try {
    return Success(await operation());
  } on AppException catch (error) {
    return Failure(error);
  } on DioException catch (error) {
    return Failure(ErrorMapper.map(error));
  } on Object {
    return const Failure(UnexpectedException());
  }
}
