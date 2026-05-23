import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:vaulto/core/theme/app_colors.dart';
import 'package:vaulto/core/theme/app_text_styles.dart';
import 'package:vaulto/core/utils/currency_formatter.dart';
import 'package:vaulto/providers/finance_provider.dart';
import 'package:vaulto/providers/auth_provider.dart';
import 'package:vaulto/data/services/firestore_service.dart';
import 'history_screen.dart';
import 'admin_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 24),
            _buildProfileHeader(context, provider),
            const SizedBox(height: 32),
            _buildStatGrid(provider),
            const SizedBox(height: 16),
            if (provider.email == 'heldinusha13@gmail.com') ...[
              _buildAdminButton(context),
              const SizedBox(height: 16),
            ],
            _buildHistoryButton(context),
            const SizedBox(height: 16),
            _buildObligationsCard(provider),
            const SizedBox(height: 32),
            _buildLogoutButton(context),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, FinanceProvider provider) {
    Widget avatarChild;
    if (provider.profileImageBase64 != null && provider.profileImageBase64!.isNotEmpty) {
      avatarChild = ClipOval(
        child: Image.memory(
          base64Decode(provider.profileImageBase64!),
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
      );
    } else {
      avatarChild = Center(
        child: Text(
          provider.firstName.isNotEmpty ? provider.firstName[0].toUpperCase() : 'V', 
          style: AppTextStyles.amountLarge.copyWith(color: AppColors.goldAccent)
        ),
      );
    }

    return Column(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            try {
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(
                source: ImageSource.gallery,
                imageQuality: 25, // Compress image to save space
              );
              if (image != null) {
                final bytes = await image.readAsBytes();
                final base64String = base64Encode(bytes);
                if (context.mounted) {
                  context.read<FinanceProvider>().saveProfileImage(base64String);
                }
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error picking image: $e\nPlease tell Antigravity this error.'),
                    backgroundColor: AppColors.neonRed,
                    duration: const Duration(seconds: 10),
                  ),
                );
              }
            }
          },
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.goldAccent, width: 2),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(child: avatarChild),
                Positioned(
                  bottom: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.goldAccent, width: 2),
                    ),
                    child: const Icon(LucideIcons.edit2, size: 14, color: AppColors.goldAccent),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${provider.firstName} ${provider.lastName}'.trim(), style: AppTextStyles.h2),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _showEditProfileModal(context, provider),
              child: const Icon(LucideIcons.edit2, size: 16, color: AppColors.goldAccent),
            ),
          ],
        ),
        if (provider.email.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(provider.email, style: AppTextStyles.bodySecondary),
        ],
      ],
    );
  }

  void _showEditProfileModal(BuildContext context, FinanceProvider provider) {
    final firstNameCtrl = TextEditingController(text: provider.firstName);
    final lastNameCtrl = TextEditingController(text: provider.lastName);
    final emailCtrl = TextEditingController(text: provider.email);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20,
            left: 20,
            right: 20,
          ),
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Edit Profile', style: AppTextStyles.h2),
              const SizedBox(height: 24),
              TextField(
                controller: firstNameCtrl,
                style: AppTextStyles.bodyPrimary,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  labelStyle: AppTextStyles.bodySecondary,
                  filled: true,
                  fillColor: AppColors.cardDark,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: lastNameCtrl,
                style: AppTextStyles.bodyPrimary,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  labelStyle: AppTextStyles.bodySecondary,
                  filled: true,
                  fillColor: AppColors.cardDark,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailCtrl,
                style: AppTextStyles.bodyPrimary,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  labelStyle: AppTextStyles.bodySecondary,
                  filled: true,
                  fillColor: AppColors.cardDark,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  try {
                    // Update in Firestore
                    final uid = context.read<AuthProvider>().user!.uid;
                    final fs = FirestoreService(uid);
                    await fs.updateUserProfile(firstNameCtrl.text, lastNameCtrl.text, emailCtrl.text);
                    if (context.mounted) Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldAccent,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Save Changes', style: AppTextStyles.h3.copyWith(color: AppColors.background)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatGrid(FinanceProvider provider) {
    final now = DateTime.now();
    final currentMonthExpensesCount = provider.transactions
        .where((t) => t.isExpense && t.date.month == now.month && t.date.year == now.year)
        .length;

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildTextStatCard('Net Balance', CurrencyFormatter.formatCompact(provider.totalBalance), AppColors.goldAccent)),
            const SizedBox(width: 12),
            Expanded(child: _buildTextStatCard('Total Spent', CurrencyFormatter.formatCompact(provider.totalExpenses), AppColors.neonRed)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildTextStatCard('Savings Rate', '${provider.savingsRate}%', AppColors.neonGreen)),
            const SizedBox(width: 12),
            Expanded(child: _buildTextStatCard('Transactions', currentMonthExpensesCount.toString(), AppColors.textPrimary)),
          ],
        ),
      ],
    );
  }

  Widget _buildHistoryButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.goldAccent.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.goldAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(LucideIcons.history, color: AppColors.goldAccent),
                ),
                const SizedBox(width: 16),
                Text('Transaction History', style: AppTextStyles.h3),
              ],
            ),
            const Icon(LucideIcons.chevronRight, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<AuthProvider>().signOut();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.neonRed.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.logOut, color: AppColors.neonRed),
            const SizedBox(width: 12),
            Text('Sign Out', style: AppTextStyles.h3.copyWith(color: AppColors.neonRed)),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminScreen()));
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.goldAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.goldAccent),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.users, color: AppColors.goldAccent),
            const SizedBox(width: 12),
            Text('Admin Panel', style: AppTextStyles.h3.copyWith(color: AppColors.goldAccent)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextStatCard(String title, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: AppTextStyles.h2.copyWith(color: valueColor)),
          const SizedBox(height: 8),
          Text(title, style: AppTextStyles.label),
        ],
      ),
    );
  }


  Widget _buildObligationsCard(FinanceProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Monthly Dues', style: AppTextStyles.h3),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.goldAccent.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      const Icon(LucideIcons.refreshCw, color: AppColors.goldAccent, size: 20),
                      const SizedBox(height: 8),
                      Text('Subscriptions', style: AppTextStyles.label),
                      const SizedBox(height: 4),
                      Text(CurrencyFormatter.format(provider.totalSub), style: AppTextStyles.h3.copyWith(color: AppColors.goldAccent)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      const Icon(LucideIcons.creditCard, color: Colors.blue, size: 20),
                      const SizedBox(height: 8),
                      Text('EMIs', style: AppTextStyles.label),
                      const SizedBox(height: 4),
                      Text(CurrencyFormatter.format(provider.totalEmi), style: AppTextStyles.h3.copyWith(color: Colors.blue)),
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
