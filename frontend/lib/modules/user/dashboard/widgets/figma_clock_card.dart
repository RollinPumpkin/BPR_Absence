import 'package:flutter/material.dart';

class FigmaClockCard extends StatefulWidget {
  const FigmaClockCard({super.key});

  @override
  State<FigmaClockCard> createState() => _FigmaClockCardState();
}

class _FigmaClockCardState extends State<FigmaClockCard> {
  bool isClockedIn = true;
  String clockInTime = "07:88:55";
  String clockOutTime = "--:--:--";

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          /// Clock In/Out Header
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      "Clock In",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 1,
                      color: Colors.grey.shade300,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 40),
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      "Clock out",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 1,
                      color: Colors.grey.shade300,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// Clock Times
          Row(
            children: [
              Expanded(
                child: Text(
                  clockInTime,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 40),
              Expanded(
                child: Text(
                  clockOutTime,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: clockOutTime == "--:--:--" ? Colors.grey.shade400 : Colors.black,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          /// Clock In/Out Buttons
          Row(
            children: [
              // Clock In Button
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (!isClockedIn) {
                      setState(() {
                        isClockedIn = true;
                        clockInTime = DateTime.now().toString().substring(11, 19);
                        clockOutTime = "--:--:--";
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isClockedIn ? Colors.green.shade300 : Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.meeting_room,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "In",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Clock Out Button
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (isClockedIn) {
                      setState(() {
                        isClockedIn = false;
                        clockOutTime = DateTime.now().toString().substring(11, 19);
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: !isClockedIn ? Colors.red.shade300 : Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Out",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.meeting_room,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}