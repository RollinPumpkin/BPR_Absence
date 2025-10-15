import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/data/providers/user_provider.dart';

class EmployeeSearch extends StatefulWidget {
  const EmployeeSearch({super.key});

  @override
  State<EmployeeSearch> createState() => _EmployeeSearchState();
}

class _EmployeeSearchState extends State<EmployeeSearch> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: "Search Employee",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  context.read<UserProvider>().searchUsers('');
                },
              )
            : null,
      ),
      onChanged: (value) {
        context.read<UserProvider>().searchUsers(value);
      },
    );
  }
}
