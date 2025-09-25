import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/custom_bottom_nav_router.dart';

class UserNavItems {
  static const items = <NavItem>[
    NavItem(Icons.home,            '/user/dashboard'),
    NavItem(Icons.calendar_today,  '/user/attendance'),
    NavItem(Icons.check_box,       '/user/assignment'),
    NavItem(Icons.description,     '/user/letter'),
    NavItem(Icons.person_outline,  '/user/profile'),
  ];
}
