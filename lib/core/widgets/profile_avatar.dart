import 'dart:io';

import 'package:flutter/material.dart';

import '../constants/app_icons.dart';
import '../constants/preset_avatars.dart';
import '../theme/app_colors.dart';
import 'app_icon.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    this.path,
    this.size = 64,
    this.iconSize,
  });

  final String? path;
  final double size;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final resolvedIconSize = iconSize ?? size * 0.47;
    final value = path?.trim() ?? '';
    final emoji = PresetAvatars.decode(value);
    final isNetwork =
        value.startsWith('http://') || value.startsWith('https://');
    final hasFile = value.isNotEmpty &&
        !isNetwork &&
        emoji == null &&
        !value.startsWith('asset:') &&
        File(value).existsSync();
    final hasImage = hasFile || isNetwork;
    final hasEmoji = emoji != null;

    Widget? child;
    DecorationImage? decorationImage;

    if (hasEmoji) {
      child = Center(
        child: Text(
          emoji,
          style: TextStyle(fontSize: size * 0.52, height: 1.1),
        ),
      );
    } else if (hasFile || isNetwork) {
      final pixels = (size * MediaQuery.devicePixelRatioOf(context)).ceil();
      final image = isNetwork
          ? ResizeImage(
              NetworkImage(value),
              width: pixels,
              height: pixels,
              policy: ResizeImagePolicy.fit,
            )
          : ResizeImage(
              FileImage(File(value)),
              width: pixels,
              height: pixels,
              policy: ResizeImagePolicy.fit,
            );
      decorationImage = DecorationImage(image: image, fit: BoxFit.cover);
    } else {
      child = Center(
        child: AppIcon(
          AppIcons.profile,
          size: resolvedIconSize,
          color: AppColors.primary,
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: hasEmoji
            ? AppColors.primary.withValues(alpha: 0.08)
            : null,
        gradient: (hasImage || hasEmoji)
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withValues(alpha: 0.2),
                  AppColors.primaryLight.withValues(alpha: 0.25),
                ],
              ),
        image: decorationImage,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.18),
          width: 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
