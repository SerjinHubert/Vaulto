import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:vaulto/providers/auth_provider.dart';
import 'package:vaulto/core/theme/app_colors.dart';
import 'package:vaulto/core/theme/app_text_styles.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  bool _isLoading = false;

  Future<void> _resendEmail() async {
    setState(() => _isLoading = true);
    try {
      await context.read<AuthProvider>().sendVerificationEmail();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent!'),
            backgroundColor: AppColors.neonGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.neonRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _checkVerification() async {
    setState(() => _isLoading = true);
    await context.read<AuthProvider>().reloadUser();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(LucideIcons.mail, size: 80, color: AppColors.goldAccent),
              const SizedBox(height: 32),
              Text(
                'Verify Your Email',
                style: AppTextStyles.amountLarge.copyWith(fontSize: 32),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'We\'ve sent a verification link to your email address. Please click the link to verify your account and continue.',
                style: AppTextStyles.bodySecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isLoading ? null : _checkVerification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldAccent,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: AppColors.background, strokeWidth: 2),
                      )
                    : Text(
                        'I\'ve Verified My Email',
                        style: AppTextStyles.h3.copyWith(color: AppColors.background),
                      ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _isLoading ? null : _resendEmail,
                child: Text(
                  'Resend Verification Email',
                  style: AppTextStyles.bodyPrimary.copyWith(color: AppColors.goldAccent),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  context.read<AuthProvider>().signOut();
                },
                child: Text(
                  'Sign Out',
                  style: AppTextStyles.bodySecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
