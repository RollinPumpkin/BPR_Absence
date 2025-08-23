import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'stat_card.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3A7BD5), Color(0xFF00D2FF)],
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
          // Date + Profile
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEEE, d MMMM y', 'id_ID').format(DateTime.now()),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  StreamBuilder(
                    stream: Stream.periodic(const Duration(seconds: 1)),
                    builder: (context, snapshot) {
                      return Text(
                        DateFormat('HH:mm:ss').format(DateTime.now()),
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      );
                    },
                  ),
                ],
              ),

              Row(
                children: const [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.notifications, color: Colors.blue),
                  ),
                  SizedBox(width: 8),
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=3"),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Greeting
          const Text(
            "Good Morning, Admin\nHave a Great Day!",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              StatCard(title: "Total", value: "160", color: Colors.blue),
              StatCard(title: "Active", value: "150", color: Colors.green),
              StatCard(title: "New", value: "15", color: Colors.lightGreen),
              StatCard(title: "Resign", value: "10", color: Colors.red),
            ],
          ),
        ],
      ),
    );
  }
}
