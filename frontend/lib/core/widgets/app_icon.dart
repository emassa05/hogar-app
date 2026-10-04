import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum AppIcons {
  alertCircle('alert-circle', 16),
  arrowRight('arrow-right', 20),
  baby('baby', 18),
  ban('ban', 18),
  building('building', 18),
  check('check', 12),
  checkCircle('check-circle', 16),
  checkCircleLarge('check-circle-22', 22),
  checkBox('check-box', 15),
  checkSmall('check-small', 14),
  chevronDown('chevron-down', 14),
  chevronLeft('chevron-left', 20),
  chevronRight('chevron-right', 20),
  clock('clock', 16),
  clockLarge('clock-large', 18),
  cook('cook', 16, tinted: false),
  copy('copy', 18),
  eye('eye', 22),
  eyeOff('eye-off', 22),
  flagChile('flag-chile', 24, height: 16, tinted: false),
  handHeart('hand-heart', 18),
  heart('heart', 18),
  home('home', 24),
  info('info', 20),
  key('key', 24),
  logo('logo', 24, height: 22, tinted: false),
  message('message', 21),
  more('more', 20),
  paw('paw', 16, tinted: false),
  pawOutline('paw-outline', 18),
  plus('plus', 18),
  refresh('refresh', 18),
  share('share', 20),
  shield('shield', 14),
  shieldCheck('shield-check', 16),
  shieldLarge('shield-large', 20),
  template('template', 20);

  const AppIcons(this.file, this.size, {double? height, this.tinted = true})
    : height = height ?? size;
  final String file;
  final double size;
  final double height;
  final bool tinted;
  String get asset => 'assets/icons/$file.svg';
}

class AppIcon extends StatelessWidget {
  const AppIcon(this.icon, {this.color, this.size, super.key});
  final AppIcons icon;
  final Color? color;
  final double? size;
  @override
  Widget build(BuildContext context) {
    final width = size ?? icon.size;
    final tint = icon.tinted
        ? color ?? IconTheme.of(context).color ?? Colors.black
        : null;
    return ExcludeSemantics(
      child: SvgPicture.asset(
        icon.asset,
        width: width,
        height: width * icon.height / icon.size,
        colorFilter: tint == null
            ? null
            : ColorFilter.mode(tint, BlendMode.srcIn),
      ),
    );
  }
}
