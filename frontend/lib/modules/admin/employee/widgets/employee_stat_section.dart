import 'package:flutter/material.dart';

class EmployeeStatSection extends StatelessWidget {
  const EmployeeStatSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFFF7F8FA), // mirip abu-abu soft di desain
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dropdown Year - Month
          Row(
            children: [
              _RoundedDropdown(
                value: "2025",
                items: const ["2025", "2024"],
                onChanged: (val) {},
              ),
              const SizedBox(width: 8),
              const Text("-", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              _RoundedDropdown(
                value: "Januari",
                items: const ["Januari", "Februari", "Maret", "April"],
                onChanged: (val) {},
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Statistik dengan garis pembatas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              Expanded(
                child: StatBox(
                  title: "Total Employee",
                  value: "208",
                  showDivider: true,
                ),
              ),
              Expanded(
                child: StatBox(
                  title: "Total New Hire",
                  value: "15",
                  showDivider: true,
                ),
              ),
              Expanded(
                child: StatBox(
                  title: "Full Time Employee",
                  value: "15",
                  showDivider: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoundedDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _RoundedDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        borderRadius: BorderRadius.circular(12),
        items: items
            .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class StatBox extends StatelessWidget {
  final String title;
  final String value;
  final bool showDivider;

  const StatBox({
    super.key,
    required this.title,
    required this.value,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Konten
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(0xFF2C2C2C),
                ),
              ),
            ],
          ),
        ),
        // Divider vertical
        if (showDivider)
          Container(
            height: 40,
            width: 1,
            color: Colors.grey.shade400,
          ),
      ],
    );
  }
}
