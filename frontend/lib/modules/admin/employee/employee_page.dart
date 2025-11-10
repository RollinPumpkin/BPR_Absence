  import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/data/providers/user_provider.dart';
import 'package:frontend/data/providers/auth_provider.dart';

import 'widgets/employee_stat_section.dart';
import 'widgets/employee_action_buttons.dart';
import 'widgets/employee_search.dart';
import 'widgets/employee_card.dart';

class EmployeePage extends StatefulWidget {
  const EmployeePage({super.key});

  @override
  State<EmployeePage> createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check current user role first
      final authProvider = context.read<AuthProvider>();
      final currentUser = authProvider.currentUser;
      print('👤 Current User Info:');
      print('   - Name: ${currentUser?.fullName}');
      print('   - Email: ${currentUser?.email}');
      print('   - Role: ${currentUser?.role}');
      print('   - Employee ID: ${currentUser?.employeeId}');
      print('   - Is Authenticated: ${authProvider.isAuthenticated}');
      
      if (currentUser?.role == 'admin' || currentUser?.role == 'super_admin') {
        print('✅ User has admin access - proceeding to fetch users');
        context.read<UserProvider>().initialize();
      } else {
        print('❌ User does not have admin access - role: ${currentUser?.role}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Same as user dashboard

      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.neutral800),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          splashRadius: 20,
        ),
        title: const Text(
          'Employee Database', // Debug reload
          style: TextStyle(
            color: AppColors.neutral800,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () {
              Navigator.pushNamed(context, '/admin/employees/sync');
            },
            splashRadius: 20,
            tooltip: 'Sync Users to Employee DB',
          ),
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              Navigator.pushNamed(context, '/admin/employees/test');
            },
            splashRadius: 20,
            tooltip: 'Test Fetch Data',
          ),
          IconButton(
            icon: const Icon(Icons.science),
            onPressed: () {
              Navigator.pushNamed(context, '/admin/employees/unit-test');
            },
            splashRadius: 20,
            tooltip: 'Unit Tests',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<UserProvider>().refreshUsers();
            },
            splashRadius: 20,
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: () => context.read<UserProvider>().refreshUsers(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const EmployeeStatSection(),
              const SizedBox(height: 16),
              const EmployeeActionButtons(),
              const SizedBox(height: 12),
              const EmployeeSearch(),
              const SizedBox(height: 16),

              // Employee List
              Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  if (userProvider.isLoading && userProvider.users.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (userProvider.errorMessage != null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red[400],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              userProvider.errorMessage!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.red[700],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => userProvider.refreshUsers(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (userProvider.users.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'No employees found',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      // Employee list
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: userProvider.users.length,
                        itemBuilder: (context, index) {
                          final user = userProvider.users[index];
                          return EmployeeCard(
                            key: ValueKey(user.id), // Add key for proper widget tracking
                            user: user,
                            onDeleted: () async {
                              // Refresh the list after deletion
                              print('🔄 Refreshing employee list after deletion...');
                              await userProvider.refreshUsers();
                              print('✅ Employee list refreshed');
                            },
                          );
                        },
                      ),
                      
                      // Load more button
                      if (userProvider.hasMore)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: userProvider.isLoading
                              ? const CircularProgressIndicator()
                              : ElevatedButton(
                                  onPressed: () => userProvider.loadMoreUsers(),
                                  child: const Text('Load More'),
                                ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
