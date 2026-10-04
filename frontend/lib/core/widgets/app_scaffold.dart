import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import '../theme/app_shadows.dart';
import 'app_halo.dart';

enum ScaffoldVariant { access, household }

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.child,
    this.header,
    this.footer,
    this.variant = ScaffoldVariant.access,
    this.halos,
    this.background,
    this.bodyPadding,
    super.key,
  });
  final Widget child;
  final Widget? header;
  final Widget? footer;
  final ScaffoldVariant variant;
  final List<Halo>? halos;
  final Gradient? background;
  final EdgeInsets? bodyPadding;

  bool get _household => variant == ScaffoldVariant.household;

  EdgeInsets get _defaultBodyPadding => _household
      ? const EdgeInsets.fromLTRB(20, 12, 20, 28)
      : const EdgeInsets.fromLTRB(24, 8, 24, 24);

  Widget _constrained(Widget child) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: child,
    ),
  );

  Widget _footer(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    if (!_household) {
      return Padding(
        padding: EdgeInsets.fromLTRB(24, 12, 24, 16 + bottom),
        child: _constrained(footer!),
      );
    }
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppShadows.bottomBar,
        border: Border(top: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 14, 20, 10 + bottom),
        child: _constrained(footer!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
    child: Scaffold(
      backgroundColor: AppColors.surface,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient:
              background ??
              (_household ? AppGradients.household : AppGradients.canvas),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: HaloLayer(
                halos:
                    halos ??
                    (_household
                        ? AppHalos.household
                        : AppHalos.access(AppHalos.mint)),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_household)
                  SafeArea(
                    bottom: false,
                    child: header == null
                        ? const SizedBox.shrink()
                        : _constrained(header!),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!_household)
                          SafeArea(
                            bottom: false,
                            child: header == null
                                ? const SizedBox.shrink()
                                : _constrained(header!),
                          ),
                        Padding(
                          padding: bodyPadding ?? _defaultBodyPadding,
                          child: _constrained(child),
                        ),
                      ],
                    ),
                  ),
                ),
                if (footer != null) _footer(context),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
