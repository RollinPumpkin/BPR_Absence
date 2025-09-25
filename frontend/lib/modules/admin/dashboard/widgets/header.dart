import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'stat_card.dart';
import 'package:frontend/core/constants/colors.dart';

class DashboardHeader extends StatelessWidget {
  final String name; // ditampilkan di sapaan
  final String profileRoute;
  final String avatarUrl;

  const DashboardHeader({
    super.key,
    this.name = "Admin",
    this.profileRoute = '/admin/profile',
    this.avatarUrl = "https://i.pravatar.cc/150?img=3",
  });

  String _greeting(int hour) {
    if (hour >= 5 && hour < 12) return "Good Morning";
    if (hour >= 12 && hour < 16) return "Good Afternoon";
    if (hour >= 16 && hour < 19) return "Good Evening";
    return "Good Night";
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEEE, d MMMM y', 'id_ID').format(DateTime.now());

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.gradientBlue, AppColors.gradientLightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateStr,
                    style: const TextStyle(
                      color: AppColors.pureWhite,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const _LiveClock(),
                ],
              ),
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: AppColors.pureWhite,
                    child: Icon(Icons.notifications, color: AppColors.accentBlue),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pushReplacementNamed(profileRoute),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.pureWhite,
                      backgroundImage: NetworkImage(avatarUrl),
                      onBackgroundImageError: (_, __) {},
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          StreamBuilder<int>(
            stream: Stream.periodic(const Duration(seconds: 1), (i) => i),
            builder: (context, _) {
              final h = DateTime.now().hour;
              final greet = _greeting(h);
              return Text(
                "$greet, $name\nHave a Great Day!",
                style: const TextStyle(
                  color: AppColors.pureWhite,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                ),
              );
            },
          ),

          const SizedBox(height: 20),
          const _StatsResponsive(),
        ],
      ),
    );
  }
}

class _LiveClock extends StatelessWidget {
  const _LiveClock();

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('HH:mm:ss').format(DateTime.now());
    return Text(
      timeStr,
      style: const TextStyle(
        color: AppColors.pureWhite,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _StatsResponsive extends StatelessWidget {
  const _StatsResponsive();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final narrow = w < 370;

        if (!narrow) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Expanded(child: StatCard(title: "Total",  value: "160", color: AppColors.primaryBlue)),
              SizedBox(width: 10),
              Expanded(child: StatCard(title: "Active", value: "150", color: AppColors.primaryYellow)),
              SizedBox(width: 10),
              Expanded(child: StatCard(title: "New",    value: "15",  color: AppColors.primaryGreen)),
              SizedBox(width: 10),
              Expanded(child: StatCard(title: "Resign", value: "10",  color: AppColors.primaryRed)),
            ],
          );
        }

        final gap = 10.0;
        final itemWidth = (w - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: const [SizedBox(width: double.nan)],
        )._withStats(itemWidth);
      },
    );
  }
}

extension on Wrap {
  Widget _withStats(double itemWidth) {
    return Wrap(
      spacing: spacing ?? 0,
      runSpacing: runSpacing ?? 0,
      alignment: alignment,
      crossAxisAlignment: crossAxisAlignment ?? WrapCrossAlignment.start,
      children: [
        SizedBox(width: itemWidth, child: const StatCard(title: "Total",  value: "160", color: AppColors.primaryBlue)),
        SizedBox(width: itemWidth, child: const StatCard(title: "Active", value: "150", color: AppColors.primaryYellow)),
        SizedBox(width: itemWidth, child: const StatCard(title: "New",    value: "15",  color: AppColors.primaryGreen)),
        SizedBox(width: itemWidth, child: const StatCard(title: "Resign", value: "10",  color: AppColors.primaryRed)),
      ],
    );
  }
}
