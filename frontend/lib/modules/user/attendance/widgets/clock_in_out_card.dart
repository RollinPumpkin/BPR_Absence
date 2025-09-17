import 'package:flutter/material.dart';

class ClockInOutCard extends StatefulWidget {
  const ClockInOutCard({super.key});

  @override
  State<ClockInOutCard> createState() => _ClockInOutCardState();
}

class _ClockInOutCardState extends State<ClockInOutCard> {
  bool isClockedIn = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3A7BD5), Color(0xFF00D2FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Current Time
          Text(
            DateTime.now().toString().substring(11, 16),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            DateTime.now().toString().substring(0, 10),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),

          // Clock In/Out Button
          GestureDetector(
            onTap: () {
              setState(() {
                isClockedIn = !isClockedIn;
              });
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isClockedIn ? "Successfully Clocked In!" : "Successfully Clocked Out!",
                  ),
                  backgroundColor: isClockedIn ? Colors.green : Colors.orange,
                ),
              );
            },
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isClockedIn ? Icons.logout : Icons.login,
                    color: isClockedIn ? Colors.red : Colors.green,
                    size: 32,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isClockedIn ? "Clock Out" : "Clock In",
                    style: TextStyle(
                      color: isClockedIn ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isClockedIn ? "Currently Working" : "Not Clocked In",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
