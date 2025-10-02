import '../models/division_report.dart';

final mockDivisionReports = <DivisionReport>[
  DivisionReport(
    divisionName: 'IT Divisi',
    points: [42, 44, 45, 43, 47, 48, 46],
    labels: ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
    minY: 40,
    maxY: 50,
    yInterval: 2,
    highlightStart: 2,
    highlightEnd: 4,
  ),
  DivisionReport(
    divisionName: 'HR Divisi',
    points: [41, 43, 46, 44, 45, 49, 47],
    labels: ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
    minY: 40,
    maxY: 50,
    yInterval: 2,
    highlightStart: 3,
    highlightEnd: 5,
  ),
  DivisionReport(
    divisionName: 'Finance',
    points: [43, 44, 44, 46, 48, 47, 45],
    labels: ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
    minY: 40,
    maxY: 50,
    yInterval: 2,
  ),
];
