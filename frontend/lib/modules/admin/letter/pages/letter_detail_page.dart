import 'package:flutter/material.dart';

class LetterDetailPage extends StatelessWidget {
  final String name;
  final String date;
  final String type;
  final String status;
  final Color statusColor;
  final String absence;
  final Color absenceColor;
  final String description;
  final String fileName;

  const LetterDetailPage({
    super.key,
    required this.name,
    required this.date,
    required this.type,
    required this.status,
    required this.statusColor,
    required this.absence,
    required this.absenceColor,
    required this.description,
    required this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Letter Acceptance"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date + Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      date,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Name
                Text(
                  name,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(type, style: const TextStyle(color: Colors.grey)),

                const SizedBox(height: 12),

                // Description
                Text(description, style: const TextStyle(fontSize: 14)),

                const SizedBox(height: 12),

                // File section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade100,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(fileName,
                          style: const TextStyle(
                              fontSize: 13, color: Colors.black54)),
                      Row(
                        children: const [
                          Icon(Icons.remove_red_eye, size: 20),
                          SizedBox(width: 12),
                          Icon(Icons.download, size: 20),
                        ],
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Approve / Reject
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(14)),
                      onPressed: () {},
                      child: const Icon(Icons.check, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(14)),
                      onPressed: () {},
                      child: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
