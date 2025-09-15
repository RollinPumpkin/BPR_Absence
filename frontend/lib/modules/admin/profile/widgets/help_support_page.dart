import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/info_card.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Help Desk"),
      body: ListView(
        children: const [
          InfoCard(
            title: "Email",
            subtitle: "Admin.bpr@jsdifsn",
            description: "Kontak via email untuk bantuan",
            borderColor: Colors.red,
          ),
          InfoCard(
            title: "Phone",
            subtitle: "+62 aiorY4r8r9",
            description: "Hubungi nomor ini untuk dukungan",
            borderColor: Colors.orange,
          ),
          InfoCard(
            title: "Timezone",
            subtitle: "Indonesia, GMT+7",
            description: "Zona waktu kerja",
            borderColor: Colors.green,
          ),
          InfoCard(
            title: "Location",
            subtitle: "Malang, EastJava",
            description: "Alamat kantor",
            borderColor: Colors.blue,
          ),
        ],
      ),
    );
  }
}
