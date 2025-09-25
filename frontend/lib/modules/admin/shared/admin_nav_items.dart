import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/custom_bottom_nav_router.dart';

class AdminNavItems {
  static const items = <NavItem>[
    NavItem(Icons.dashboard_outlined, '/admin/dashboard'),
    NavItem(Icons.calendar_today,     '/admin/attendance'),
    NavItem(Icons.task_alt_outlined,  '/admin/assignment'),
    NavItem(Icons.description,        '/admin/letter'),
    NavItem(Icons.person_outline,     '/admin/profile'),
  ];
}
