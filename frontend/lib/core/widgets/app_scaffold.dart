import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_gradients.dart';
import '../theme/app_spacing.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.child,
    this.header,
    this.footer,
    this.household = false,
    this.sky = false,
    super.key,
  });
  final Widget child;
  final Widget? header;
  final Widget? footer;
  final bool household;
  final bool sky;

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
    child: Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: household ? AppGradients.household : AppGradients.canvas,
        ),
        child: Stack(
          children: [
            if (!household) ...[
              const Positioned(
                top: -100,
                left: -140,
                width: 380,
                height: 380,
                child: DecoratedBox(
                  decoration: BoxDecoration(gradient: AppGradients.violetHalo),
                ),
              ),
              Positioned(
                top: -80,
                right: -90,
                width: 360,
                height: 360,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: sky
                        ? AppGradients.skyHalo
                        : AppGradients.warmHalo,
                  ),
                ),
              ),
            ],
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                        maxWidth: 520,
                      ),
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xxl,
                        8,
                        AppSpacing.xxl,
                        AppSpacing.xxl,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (header != null) ...[
                                header!,
                                const SizedBox(height: 24),
                              ],
                              child,
                            ],
                          ),
                          if (footer != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 32),
                              child: footer!,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
