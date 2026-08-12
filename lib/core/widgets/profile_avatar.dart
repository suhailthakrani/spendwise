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
    final hasFile = path != null &&
        path!.trim().isNotEmpty &&
        File(path!).existsSync();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: hasFile
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withValues(alpha: 0.2),
                  AppColors.primaryLight.withValues(alpha: 0.25),
                ],
              ),
        image: hasFile
            ? DecorationImage(
                image: FileImage(File(path!)),
                fit: BoxFit.cover,
              )
            : null,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.18),
          width: 1.5,
        ),
      ),
      child: hasFile
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
