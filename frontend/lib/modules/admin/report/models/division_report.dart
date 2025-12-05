class DivisionReport {
  final String divisionName;
  final List<double> points; // nilai per label (mis. per minggu)
  final List<String> labels; // label sumbu X
  final double minY;
  final double maxY;
  final double yInterval;
  final int? highlightStart;
  final int? highlightEnd;
  final String? subtitle; // Optional subtitle for additional info
  final int? totalRecords; // Total attendance records
  final int? presentCount; // Present count
  final int? uniqueEmployees; // Unique employees count

  DivisionReport({
    required this.divisionName,
    required this.points,
    required this.labels,
    required this.minY,
    required this.maxY,
    required this.yInterval,
    this.highlightStart,
    this.highlightEnd,
    this.subtitle,
    this.totalRecords,
    this.presentCount,
    this.uniqueEmployees,
  });
}
