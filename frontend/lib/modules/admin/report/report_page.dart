import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'widgets/report_filters_bar.dart';
import 'widgets/section_header.dart';
import 'widgets/division_chart_card.dart';
import 'widgets/stat_card.dart';
import '../../../data/dummy/dummy_data.dart';
import 'models/division_report.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Menggunakan data admin dashboard stats sebagai pengganti
    final adminStats = DummyData.adminDashboardStats;
    
    // Convert dummy data ke DivisionReport objects
    final reports = DummyData.divisionReports.map((data) => DivisionReport(
      divisionName: data['divisionName'],
      points: List<double>.from(data['points']),
      labels: List<String>.from(data['labels']),
      minY: data['minY'],
      maxY: data['maxY'],
      yInterval: data['yInterval'],
      highlightStart: data['highlightStart'],
      highlightEnd: data['highlightEnd'],
    )).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,

      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              title: const Text('Report',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  // bar export / search / filter
                  const ReportFiltersBar(),
                  const SizedBox(height: 8),

                  // Section: Clock In - Out
                  const SectionHeader(
                    title: 'Clock In - Out',
                    trailingText: 'view',
                  ),
                  const SizedBox(height: 8),

                  // Grafik per divisi
                  ...reports.map((r) => Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: DivisionChartCard(report: r),
                      )),

                  const SizedBox(height: 12),
                  const SectionHeader(
                    title: 'Letter Assign',
                    trailingText: 'view',
                  ),
                  const SizedBox(height: 8),

                  // contoh kartu statistik
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        StatCard(
                          title: 'Sick',
                          subtitle: 'IT Divisi',
                          rightStatus: 'Clock In',
                          people: 245,
                        ),
                        SizedBox(height: 12),
                        StatCard(
                          title: 'Annual Leave',
                          subtitle: 'IT Divisi',
                          rightStatus: 'Clock In',
                          people: 245,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
