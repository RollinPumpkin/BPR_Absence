import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'stat_card.dart';
import 'package:frontend/core/constants/colors.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
          /// Top bar (Date + Profile)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Date + Time
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEEE, d MMMM y', 'id_ID').format(DateTime.now()),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  StreamBuilder(
                    stream: Stream.periodic(const Duration(seconds: 1)),
                    builder: (context, snapshot) {
                      return Text(
                        DateFormat('HH:mm:ss').format(DateTime.now()),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      );
                    },
                  ),
                ],
              ),

              // Notification + Avatar
              Row(
                children: const [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.notifications, color: AppColors.accentBlue),
                  ),
                  SizedBox(width: 10),
                  CircleAvatar(
                    radius: 22,
                    backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=3"),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// Greeting
          const Text(
            "Good Morning, Admin\nHave a Great Day!",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 20),

          /// Stats Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Expanded(child: StatCard(title: "Total", value: "160", color: AppColors.primaryBlue)),
              SizedBox(width: 10),
              Expanded(child: StatCard(title: "Active", value: "150", color: AppColors.primaryYellow)),
              SizedBox(width: 10),
              Expanded(child: StatCard(title: "New", value: "15", color: AppColors.primaryGreen)),
              SizedBox(width: 10),
              Expanded(child: StatCard(title: "Resign", value: "10", color: AppColors.primaryRed)),
            ],
          ),
        ],
      ),
    );
  }
}
