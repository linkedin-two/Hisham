import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../../utils/session_manager.dart';
import '../../../screens/login/sign_in.dart';

/// Reusable Mobile Header containing Brand Logo, Page Title, Subtitle, Teacher Profile Avatar, and Logout action.
class MobileHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onProfileTap;
  final VoidCallback? onLogoutTap;

  const MobileHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.onProfileTap,
    this.onLogoutTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // App Brand Logo
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                'assets/images/app_logo.jpg',
                height: 36,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  width: 36,
                  height: 36,
                  color: AppColors.primary,
                  child: const Icon(Icons.school, color: Colors.white, size: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Title and Subtitle
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),

            // Teacher Profile Avatar
            GestureDetector(
              onTap: onProfileTap ?? () {},
              child: ClipOval(
                child: Image.asset(
                  'assets/images/profile.png',
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 36,
                    height: 36,
                    color: AppColors.secondary,
                    child: const Icon(Icons.person, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Logout Button
            IconButton(
              icon: const Icon(Icons.logout, color: AppColors.danger, size: 22),
              tooltip: 'Logout',
              onPressed: onLogoutTap ?? () async {
                await SessionManager.clearSession();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const SignIn()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
