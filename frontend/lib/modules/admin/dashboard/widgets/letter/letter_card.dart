import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'letter_detail_sheet.dart';

class LetterCard extends StatelessWidget {
  final String name;
  final String status;
  final Color statusColor;

  // optional (biar fleksibel, default tetap sama dengan desain awal)
  final String dateText;     // ex: "27 Agustus 2024"
  final String category;     // ex: "Doctor's Note"
  final String summary;      // excerpt
  final String stageText;    // ex: "Waiting Approval"

  /// Override aksi "View" kalau perlu. Kalau null → buka bottom sheet detail.
  final VoidCallback? onViewTap;

  const LetterCard({
    super.key,
    required this.name,
    required this.status,
    required this.statusColor,
    this.dateText = "27 Agustus 2024",
    this.category = "Doctor's Note",
    this.summary =
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt.",
    this.stageText = "Waiting Approval",
    this.onViewTap,
  });

  void _openDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.pureWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => LetterDetailSheet(
        name: name,
        status: status,
        statusColor: statusColor,
        dateText: dateText,
        category: category,
        summary: summary,
        stageText: stageText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.pureWhite,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (onViewTap != null) {
            onViewTap!();
          } else {
            _openDetail(context);
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // name + status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppColors.neutral800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),
              Text(
                dateText,
                style: const TextStyle(
                  color: AppColors.neutral500,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 4),
              Text(
                category,
                style: const TextStyle(
                  color: AppColors.neutral800,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 8),
              Text(
                summary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.neutral800,
                  height: 1.35,
                  fontSize: 13.5,
                ),
              ),

              const SizedBox(height: 12),

              // status bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadowColor,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        stageText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.primaryYellow,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (onViewTap != null) {
                          onViewTap!();
                        } else {
                          _openDetail(context);
                        }
                      },
                      child: const Text(
                        "View",
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
