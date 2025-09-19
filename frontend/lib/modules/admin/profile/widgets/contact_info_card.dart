import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';

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
        border: Border.all(color: AppColors.mediumGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("Contact info",
              style: TextStyle(fontSize: 14, color: AppColors.mediumGray)),
          SizedBox(height: 8),
          Text("Email", style: TextStyle(fontSize: 12, color: AppColors.mediumGray)),
          Text(
            "Anin.pulupulu@dahbbDSAS",
            style: TextStyle(
                fontSize: 14, color: Colors.black, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),
          Text("Phone Number",
              style: TextStyle(fontSize: 12, color: AppColors.mediumGray)),
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
