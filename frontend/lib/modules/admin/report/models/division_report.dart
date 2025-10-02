class DivisionReport {
  final String divisionName;
  final List<double> points; // nilai per label (mis. per minggu)
  final List<String> labels; // label sumbu X
  final double minY;
  final double maxY;
  final double yInterval;
  final int? highlightStart;
  final int? highlightEnd;

  DivisionReport({
    required this.divisionName,
    required this.points,
    required this.labels,
    required this.minY,
    required this.maxY,
    required this.yInterval,
    this.highlightStart,
    this.highlightEnd,
  });
}
