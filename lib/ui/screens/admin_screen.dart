import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:vaulto/core/theme/app_colors.dart';
import 'package:vaulto/core/theme/app_text_styles.dart';
import 'package:vaulto/data/services/firestore_service.dart';
import 'package:vaulto/providers/auth_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().user!.uid;
    final fs = FirestoreService(uid);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Admin Dashboard', style: AppTextStyles.h2),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: fs.streamAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.goldAccent));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading users: ${snapshot.error}', style: AppTextStyles.bodyPrimary));
          }

          final users = snapshot.data ?? [];

          if (users.isEmpty) {
            return Center(child: Text('No users found.', style: AppTextStyles.bodyPrimary));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final firstName = user['firstName'] ?? 'Vault';
              final lastName = user['lastName'] ?? 'User';
              final email = user['email'] ?? 'No Email';
              final profileImageBase64 = user['profileImageBase64'];

              Widget avatar;
              if (profileImageBase64 != null && profileImageBase64.isNotEmpty) {
                avatar = ClipOval(
                  child: Image.memory(
                    base64Decode(profileImageBase64),
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                );
              } else {
                avatar = Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.goldAccent),
                  ),
                  child: Center(
                    child: Text(
                      firstName.isNotEmpty ? firstName[0].toUpperCase() : 'V',
                      style: AppTextStyles.h3.copyWith(color: AppColors.goldAccent),
                    ),
                  ),
                );
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.goldAccent.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    avatar,
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$firstName $lastName', style: AppTextStyles.h3),
                          const SizedBox(height: 4),
                          Text(email, style: AppTextStyles.bodySecondary),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
