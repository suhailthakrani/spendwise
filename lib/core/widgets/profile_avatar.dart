import 'dart:io';

import 'package:flutter/material.dart';

import '../constants/app_icons.dart';
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
    final isNetwork =
        value.startsWith('http://') || value.startsWith('https://');
    final hasFile = value.isNotEmpty && !isNetwork && File(value).existsSync();
    final hasImage = hasFile || isNetwork;

    ImageProvider? image;
    if (isNetwork) {
      image = NetworkImage(value);
    } else if (hasFile) {
      image = FileImage(File(value));
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: hasImage
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withValues(alpha: 0.2),
                  AppColors.primaryLight.withValues(alpha: 0.25),
                ],
              ),
        image: image == null
            ? null
            : DecorationImage(
                image: image,
                fit: BoxFit.cover,
              ),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.18),
          width: 1.5,
        ),
      ),
      child: hasImage
          ? null
          : Center(
              child: AppIcon(
                AppIcons.profile,
                size: resolvedIconSize,
                color: AppColors.primary,
              ),
            ),
    );
  }
}
