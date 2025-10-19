import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';

class ProfileActionCard extends StatelessWidget {
  final String title;
  final List<ProfileAction> actions;

  const ProfileActionCard({
    super.key,
    required this.title,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.neutral800,
            ),
          ),
          const SizedBox(height: 16),
          
          // Actions List
          ...actions.map((action) => _buildActionItem(action)).toList(),
        ],
      ),
    );
  }

  Widget _buildActionItem(ProfileAction action) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: action.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: action.color.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: action.color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  action.icon,
                  color: AppColors.pureWhite,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral800,
                      ),
                    ),
                    if (action.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        action.subtitle!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade400,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileAction {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  ProfileAction({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}