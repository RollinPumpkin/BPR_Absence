import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';

class AttendanceDetailSheet extends StatelessWidget {
  final String title;
  final Widget chart;
  final int? present;
  final int? absent;
  final int? lateCount;

  const AttendanceDetailSheet({
    super.key,
    required this.title,
    required this.chart,
    this.present,
    this.absent,
    this.lateCount,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 34, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.neutral800,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close',
                        style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.neutral800),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),
              const Divider(color: AppColors.dividerGray, height: 1),

              Expanded(
                child: SingleChildScrollView(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SummaryChips(present: present, absent: absent, lateCount: lateCount),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
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
                        child: AspectRatio(aspectRatio: 1.9, child: chart),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Insights',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.neutral800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const _InsightBullet(text: 'Peak attendance on Wednesday & Friday.'),
                      const _InsightBullet(text: 'Late spikes after long holidays.'),
                      const _InsightBullet(text: 'Consider flexible check-in for early shift.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryChips extends StatelessWidget {
  final int? present;
  final int? absent;
  final int? lateCount;

  const _SummaryChips({this.present, this.absent, this.lateCount});

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    if (present != null) {
      items.add(_Chip(color: AppColors.primaryGreen, label: 'Present', value: present!));
    }
    if (absent != null) {
      items.add(_Chip(color: AppColors.errorRed, label: 'Absent', value: absent!));
    }
    if (lateCount != null) {
      items.add(_Chip(color: AppColors.primaryYellow, label: 'Late', value: lateCount!));
    }
    if (items.isEmpty) return const SizedBox.shrink();
    return Wrap(spacing: 10, runSpacing: 8, children: items);
  }
}

class _Chip extends StatelessWidget {
  final Color color;
  final String label;
  final int value;

  const _Chip({required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(
            '$label: $value',
            style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _InsightBullet extends StatelessWidget {
  final String text;
  const _InsightBullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Icon(Icons.circle, size: 6, color: AppColors.neutral500),
        SizedBox(width: 8),
      ],
    )._with(text);
  }
}

extension on Row {
  Widget _with(String text) {
    return Row(
      children: [
        ...children,
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13.5,
              color: AppColors.neutral800,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
