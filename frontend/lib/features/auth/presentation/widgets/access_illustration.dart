import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_icon.dart';
import '../auth_strings.dart';

class FrameRect {
  const FrameRect(this.left, this.top, this.width, this.height);
  final double left;
  final double top;
  final double width;
  final double height;
}

class Spark {
  const Spark(this.left, this.top, this.size, this.color);
  final double left;
  final double top;
  final double size;
  final Color color;
}

const _gold = Color(0xFFF0BC4E);
const _frameCenter = 195.0;
const stepHeaderBottom = 122.0;
const plainHeaderBottom = 108.0;

class AccessScene {
  const AccessScene({
    required this.headerBottom,
    required this.contentTop,
    required this.halo,
    required this.haloColor,
    required this.orbit,
    required this.orbitAsset,
    required this.shadow,
    required this.image,
    required this.imageAsset,
    required this.accent,
    this.messageCard = false,
  });
  final double headerBottom;
  final double contentTop;
  final FrameRect halo;
  final Color haloColor;
  final FrameRect orbit;
  final String orbitAsset;
  final FrameRect shadow;
  final FrameRect image;
  final String imageAsset;
  final Color accent;
  final bool messageCard;

  double get height => contentTop - headerBottom;
  double get top => halo.top;

  List<Spark> get sparks => [
    Spark(300, top + 50, 14, accent),
    Spark(76, top + 150, 11, _gold),
    Spark(96, top + 34, 8, accent),
  ];

  static const phone = AccessScene(
    headerBottom: stepHeaderBottom,
    contentTop: 344,
    halo: FrameRect(65, 106, 260, 240),
    haloColor: Color(0xD9B5EDCF),
    orbit: FrameRect(77, 122, 228, 222),
    orbitAsset: 'orbit-phone',
    shadow: FrameRect(146.38, 310, 97.24, 12),
    image: FrameRect(102, 142, 187, 176),
    imageAsset: 'phone',
    accent: AppColors.borderSuccess,
  );
  static const verify = AccessScene(
    headerBottom: stepHeaderBottom,
    contentTop: 344,
    halo: FrameRect(65, 118, 260, 240),
    haloColor: Color(0xD9B5EDCF),
    orbit: FrameRect(77, 120, 236, 236),
    orbitAsset: 'orbit-mint',
    shadow: FrameRect(151.84, 322, 86.32, 12),
    image: FrameRect(112, 174, 166, 156),
    imageAsset: 'phone',
    accent: AppColors.borderSuccess,
    messageCard: true,
  );
  static const password = AccessScene(
    headerBottom: stepHeaderBottom,
    contentTop: 318,
    halo: FrameRect(65, 94, 260, 240),
    haloColor: Color(0xD9FBE3A4),
    orbit: FrameRect(77, 96, 236, 236),
    orbitAsset: 'orbit-butter',
    shadow: FrameRect(149.5, 298, 91, 12),
    image: FrameRect(108, 146, 175, 160),
    imageAsset: 'lock',
    accent: Color(0xFFE09A1B),
  );
  static const name = AccessScene(
    headerBottom: stepHeaderBottom,
    contentTop: 344,
    halo: FrameRect(65, 106, 260, 240),
    haloColor: Color(0xD9FBCDB3),
    orbit: FrameRect(77, 108, 236, 236),
    orbitAsset: 'orbit-peach',
    shadow: FrameRect(147.42, 310, 95.16, 12),
    image: FrameRect(104, 142, 183, 176),
    imageAsset: 'name-tag',
    accent: Color(0xFFE2701F),
  );
  static const login = AccessScene(
    headerBottom: plainHeaderBottom,
    contentTop: 312,
    halo: FrameRect(65, 80, 260, 240),
    haloColor: Color(0xD9CBC6FB),
    orbit: FrameRect(77, 82, 236, 236),
    orbitAsset: 'orbit-lilac',
    shadow: FrameRect(150.02, 284, 89.96, 12),
    image: FrameRect(109, 128, 173, 164),
    imageAsset: 'wave',
    accent: AppColors.focus,
  );
  static const recover = AccessScene(
    headerBottom: stepHeaderBottom,
    contentTop: 344,
    halo: FrameRect(65, 106, 260, 240),
    haloColor: Color(0xD9CBC6FB),
    orbit: FrameRect(77, 108, 236, 236),
    orbitAsset: 'orbit-violet',
    shadow: FrameRect(144.56, 310, 100.88, 12),
    image: FrameRect(98, 142, 194, 176),
    imageAsset: 'search-key',
    accent: AppColors.focus,
  );
}

class FramePositioned extends StatelessWidget {
  const FramePositioned({
    required this.rect,
    required this.origin,
    required this.child,
    super.key,
  });
  final FrameRect rect;
  final Offset origin;
  final Widget child;
  @override
  Widget build(BuildContext context) => Positioned(
    left: rect.left - origin.dx,
    top: rect.top - origin.dy,
    width: rect.width,
    height: rect.height,
    child: child,
  );
}

class FrameCanvas extends StatelessWidget {
  const FrameCanvas({
    required this.height,
    required this.originY,
    required this.builder,
    super.key,
  });
  final double height;
  final double originY;
  final List<Widget> Function(Offset origin) builder;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) => Stack(
          clipBehavior: Clip.none,
          children: builder(
            Offset(_frameCenter - constraints.maxWidth / 2, originY),
          ),
        ),
      ),
    ),
  );
}

class BlurredEllipse extends StatelessWidget {
  const BlurredEllipse({required this.color, required this.blur, super.key});
  final Color color;
  final double blur;
  @override
  Widget build(BuildContext context) => ImageFiltered(
    imageFilter: ImageFilter.blur(
      sigmaX: blur,
      sigmaY: blur,
      tileMode: TileMode.decal,
    ),
    child: DecoratedBox(
      decoration: ShapeDecoration(color: color, shape: const OvalBorder()),
    ),
  );
}

class GlowDisc extends StatelessWidget {
  const GlowDisc({
    this.middleStop = 0.65,
    this.middleOpacity = 0.55,
    super.key,
  });
  final double middleStop;
  final double middleOpacity;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.95),
          Colors.white.withValues(alpha: middleOpacity),
          Colors.white.withValues(alpha: 0),
        ],
        stops: [0, middleStop, 1],
      ),
    ),
  );
}

class Sparkle extends StatelessWidget {
  const Sparkle({required this.color, super.key});
  final Color color;
  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    'assets/illustrations/sparkle.svg',
    fit: BoxFit.fill,
    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
  );
}

class AccessIllustration extends StatelessWidget {
  const AccessIllustration({required this.scene, super.key});
  final AccessScene scene;
  @override
  Widget build(BuildContext context) => FrameCanvas(
    height: scene.height,
    originY: scene.headerBottom,
    builder: (origin) => [
      FramePositioned(
        rect: scene.halo,
        origin: origin,
        child: BlurredEllipse(color: scene.haloColor, blur: 30),
      ),
      FramePositioned(
        rect: FrameRect(83, scene.top + 8, 224, 224),
        origin: origin,
        child: const GlowDisc(),
      ),
      FramePositioned(
        rect: scene.orbit,
        origin: origin,
        child: Image.asset(
          'assets/images/access/${scene.orbitAsset}.png',
          fit: BoxFit.fill,
        ),
      ),
      FramePositioned(
        rect: scene.shadow,
        origin: origin,
        child: BlurredEllipse(
          color: scene.accent.withValues(alpha: 0.3),
          blur: 3.5,
        ),
      ),
      FramePositioned(
        rect: scene.image,
        origin: origin,
        child: Image.asset(
          'assets/images/access/${scene.imageAsset}.png',
          fit: BoxFit.cover,
        ),
      ),
      for (final spark in scene.sparks)
        FramePositioned(
          rect: FrameRect(spark.left, spark.top, spark.size, spark.size),
          origin: origin,
          child: Sparkle(color: spark.color),
        ),
      if (scene.messageCard)
        FramePositioned(
          rect: FrameRect(44, scene.top + 14, 300, 66),
          origin: origin,
          child: Transform.rotate(
            angle: 2 * pi / 180,
            child: const _MessageCard(),
          ),
        ),
    ],
  );
}

class _MessageCard extends StatelessWidget {
  const _MessageCard();
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          offset: Offset(0, 12),
          blurRadius: 28,
          color: Color(0x1F1E1A5E),
        ),
        BoxShadow(
          offset: Offset(0, 2),
          blurRadius: 4,
          color: Color(0x0D1E1A5E),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 14, 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.86),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF34C759),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const AppIcon(
                  AppIcons.message,
                  size: 20,
                  color: AppColors.inverse,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          AuthStrings.messagesApp,
                          textScaler: TextScaler.noScaling,
                          style: AppTypography.caption.copyWith(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.42,
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          AuthStrings.messageNow,
                          textScaler: TextScaler.noScaling,
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text.rich(
                      const TextSpan(
                        children: [
                          TextSpan(text: AuthStrings.messageBody),
                          TextSpan(
                            text: AuthStrings.messageCode,
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      textScaler: TextScaler.noScaling,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall.copyWith(
                        height: 17 / 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
