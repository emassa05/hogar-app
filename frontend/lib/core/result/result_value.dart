import 'result.dart';

extension ResultValue<T> on Result<T> {
  T get valueOrThrow => switch (this) {
    Success<T>(:final value) => value,
    Failure<T>(:final error) => throw error,
  };
}
