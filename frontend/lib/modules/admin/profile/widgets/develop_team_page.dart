import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/info_card.dart';

class DevelopTeamPage extends StatelessWidget {
  const DevelopTeamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Develop Team"),
      body: ListView(
        children: const [
          InfoCard(
            title: "Septa Puma Surya",
            subtitle: "Indonesia - May 22, 2004",
            description:
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
            borderColor: Colors.red,
          ),
          InfoCard(
            title: "Septa Puma Surya",
            subtitle: "Indonesia - May 22, 2004",
            description:
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
            borderColor: Colors.yellow,
          ),
          InfoCard(
            title: "Septa Puma Surya",
            subtitle: "Indonesia - May 22, 2004",
            description:
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
            borderColor: Colors.green,
          ),
          InfoCard(
            title: "Septa Puma Surya",
            subtitle: "Indonesia - May 22, 2004",
            description:
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
            borderColor: Colors.blue,
          ),
        ],
      ),
    );
  }
}
