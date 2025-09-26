import 'package:flutter/material.dart';
import '../pages/settings_page.dart';
import 'package:frontend/core/constants/colors.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Profile card (tetap, hanya tambah shadow halus)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryRed,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  const CircleAvatar(radius: 30, backgroundColor: Colors.grey),
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Material(
                      color: AppColors.pureWhite,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {}, // TODO: action edit avatar
                        child: const SizedBox(
                          width: 22,
                          height: 22,
                          child: Icon(Icons.edit, size: 14, color: AppColors.neutral800),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: _NameSubtitle(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NameSubtitle extends StatelessWidget {
  const _NameSubtitle();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Anindya Nurhaliza Putri',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.pureWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Last update 1 day ago',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, color: AppColors.pureWhite),
        ),
      ],
    );
  }
}
