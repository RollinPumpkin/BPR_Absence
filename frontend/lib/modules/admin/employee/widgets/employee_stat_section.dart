import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/data/providers/user_provider.dart';

class EmployeeStatSection extends StatelessWidget {
  const EmployeeStatSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
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
          // Tahun & Bulan (responsif pakai Wrap biar nggak kepotong di layar kecil)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _RoundedDropdown(
                value: "2025",
                items: const ["2025", "2024"],
                onChanged: (val) {},
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  "-",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral100,
                  ),
                ),
              ),
              _RoundedDropdown(
                value: "Januari",
                items: const ["Januari", "Februari", "Maret", "April"],
                onChanged: (val) {},
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Statistik (3 kolom) dengan divider tipis
          Row(
            children: [
              Expanded(
                child: Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    return StatBox(
                      title: "Total Employee",
                      value: userProvider.statistics?.totalUsers.toString() ?? "0",
                      showDivider: true,
                    );
                  },
                ),
              ),
              Expanded(
                child: Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    return StatBox(
                      title: "Active Employee",
                      value: userProvider.statistics?.activeUsers.toString() ?? "0",
                      showDivider: true,
                    );
                  },
                ),
              ),
              Expanded(
                child: Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    return StatBox(
                      title: "Roles Count",
                      value: userProvider.statistics?.roleDistribution.length.toString() ?? "0",
                      showDivider: false,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoundedDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _RoundedDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.dividerGray),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          borderRadius: BorderRadius.circular(12),
          icon: const Icon(Icons.expand_more, color: AppColors.neutral800),
          style: const TextStyle(
            color: AppColors.neutral800,
            fontWeight: FontWeight.w600,
          ),
          items: items
              .map((e) => DropdownMenuItem<String>(
                    value: e,
                    child: Text(e),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class StatBox extends StatelessWidget {
  final String title;
  final String value;
  final bool showDivider;

  const StatBox({
    super.key,
    required this.title,
    required this.value,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Konten
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.neutral500,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: AppColors.neutral800,
                ),
              ),
            ],
          ),
        ),
        // Divider kanan (optional)
        if (showDivider)
          Container(
            height: 42,
            width: 1,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            color: AppColors.dividerGray,
          ),
      ],
    );
  }
}
