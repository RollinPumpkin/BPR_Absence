class UserStatistics {
  final int totalUsers;
  final int activeUsers;
  final int inactiveUsers;
  final Map<String, int> roleDistribution;
  final Map<String, int> departmentDistribution;

  UserStatistics({
    required this.totalUsers,
    required this.activeUsers,
    required this.inactiveUsers,
    required this.roleDistribution,
    required this.departmentDistribution,
  });

  factory UserStatistics.fromJson(Map<String, dynamic> json) {
    return UserStatistics(
      totalUsers: json['totalUsers'] ?? 0,
      activeUsers: json['activeUsers'] ?? 0,
      inactiveUsers: json['inactiveUsers'] ?? 0,
      roleDistribution: Map<String, int>.from(json['roleDistribution'] ?? {}),
      departmentDistribution: Map<String, int>.from(json['departmentDistribution'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalUsers': totalUsers,
      'activeUsers': activeUsers,
      'inactiveUsers': inactiveUsers,
      'roleDistribution': roleDistribution,
      'departmentDistribution': departmentDistribution,
    };
  }
}