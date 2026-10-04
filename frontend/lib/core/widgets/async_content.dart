import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../errors/app_exception.dart';
import '../l10n/app_strings.dart';
import 'error_banner.dart';

class AsyncContent<T> extends StatelessWidget {
  const AsyncContent({
    required this.value,
    required this.builder,
    required this.onRetry,
    super.key,
  });
  final AsyncValue<T> value;
  final Widget Function(T) builder;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => value.when(
    skipLoadingOnRefresh: false,
    data: builder,
    loading: () => Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Semantics(
          label: AppStrings.loading,
          child: const CircularProgressIndicator(),
        ),
      ),
    ),
    error: (error, stack) => ErrorBanner(
      error: error is AppException ? error : const UnexpectedException(),
      onRetry: onRetry,
    ),
  );
}
