import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../custom_widgets/bottom_navbar.dart';
import '../services/navigation_service.dart';

class ShellScreen extends StatelessWidget {
  final Widget child;

  const ShellScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final selectedIndex = NavigationService.getCurrentTabIndex(location);

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Colors.white
          : Colors.black,
      body: child,
      bottomNavigationBar: BottomNavBar(
        selectedIndex: selectedIndex,
        onTap: (index) => NavigationService.navigateToTab(context, index),
      ),
    );
  }
}
