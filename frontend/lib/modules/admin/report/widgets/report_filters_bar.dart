import 'package:flutter/material.dart';

class ReportFiltersBar extends StatelessWidget {
  const ReportFiltersBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Export button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: const Color(0xFFE53935), // merah seperti screenshot
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            onPressed: () {
              // TODO: implement export
            },
            child: const Text('Export'),
          ),
          const SizedBox(width: 8),
          // search
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE6E8F0)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              height: 44,
              child: const Row(
                children: [
                  Icon(Icons.search, size: 20, color: Color(0xFF8E96A4)),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search Employee',
                        border: InputBorder.none,
                        isCollapsed: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // filter
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black87,
              side: const BorderSide(color: Color(0xFFE6E8F0)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            onPressed: () {
              // TODO: show filters
            },
            icon: const Icon(Icons.tune, size: 18),
            label: const Text('Filter'),
          ),
        ],
      ),
    );
  }
}
