import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/data/services/employee_stats_service.dart';
import 'stat_card.dart';

class DatabaseStatsWidget extends StatefulWidget {
  const DatabaseStatsWidget({super.key});

  @override
  State<DatabaseStatsWidget> createState() => _DatabaseStatsWidgetState();
}

class _DatabaseStatsWidgetState extends State<DatabaseStatsWidget> {
  final EmployeeStatsService _statsService = EmployeeStatsService();
  
  Map<String, int> _stats = {
    'total': 0,
    'active': 0,
    'new': 0,
    'resign': 0,
  };
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      setState(() {
        _isLoading = true;
      });

      print('📊 Loading employee statistics from database...');
      
      final response = await _statsService.getEmployeeStats();
      
      if (response.success && response.data != null) {
        setState(() {
          _stats = {
            'total': response.data!['total'] ?? 0,
            'active': response.data!['active'] ?? 0,
            'new': response.data!['new'] ?? 0,
            'resign': response.data!['resign'] ?? 0,
          };
          _isLoading = false;
        });
        
        print('✅ Stats loaded: $_stats');
      } else {
        print('❌ Failed to load stats, using defaults');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading stats: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final narrow = width < 370;

        if (_isLoading) {
          return _buildLoadingWidget(narrow);
        }

        if (!narrow) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatCard(
                title: "Total",
                value: "${_stats['total']}",
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: 10),
              StatCard(
                title: "Active",
                value: "${_stats['active']}",
                color: AppColors.primaryYellow,
              ),
              const SizedBox(width: 10),
              StatCard(
                title: "New",
                value: "${_stats['new']}",
                color: AppColors.primaryGreen,
              ),
              const SizedBox(width: 10),
              StatCard(
                title: "Resign",
                value: "${_stats['resign']}",
                color: AppColors.primaryRed,
              ),
            ],
          );
        }

        // Narrow layout
        final gap = 10.0;
        final itemWidth = (width - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            SizedBox(
              width: itemWidth,
              child: StatCard(
                title: "Total",
                value: "${_stats['total']}",
                color: AppColors.primaryBlue,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: StatCard(
                title: "Active",
                value: "${_stats['active']}",
                color: AppColors.primaryYellow,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: StatCard(
                title: "New",
                value: "${_stats['new']}",
                color: AppColors.primaryGreen,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: StatCard(
                title: "Resign",
                value: "${_stats['resign']}",
                color: AppColors.primaryRed,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingWidget(bool narrow) {
    final loadingCard = Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Loading...",
            style: TextStyle(
              fontSize: 12,
              color: AppColors.neutral500,
            ),
          ),
        ],
      ),
    );

    if (!narrow) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: loadingCard),
          const SizedBox(width: 10),
          Expanded(child: loadingCard),
          const SizedBox(width: 10),
          Expanded(child: loadingCard),
          const SizedBox(width: 10),
          Expanded(child: loadingCard),
        ],
      );
    }

    return Wrap(
      spacing: 10.0,
      runSpacing: 10.0,
      children: [
        loadingCard,
        loadingCard,
        loadingCard,
        loadingCard,
      ],
    );
  }
}