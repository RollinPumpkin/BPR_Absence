import 'package:flutter/material.dart';

class ContactInfoCard extends StatelessWidget {
  const ContactInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("Contact info",
              style: TextStyle(fontSize: 14, color: Colors.grey)),
          SizedBox(height: 8),
          Text("Email", style: TextStyle(fontSize: 12, color: Colors.grey)),
          Text(
            "Anin.pulupulu@dahbbDSAS",
            style: TextStyle(
                fontSize: 14, color: Colors.black, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),
          Text("Phone Number",
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          Text(
            "+62 8888881111",
            style: TextStyle(
                fontSize: 14, color: Colors.black, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
