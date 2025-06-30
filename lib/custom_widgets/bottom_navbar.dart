import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.light
              ? Color.fromARGB(111, 56, 52, 44)
              : Color(0xFF38342C),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavBarItem(
              isActive: selectedIndex == 0,
              splashColor: Colors.amberAccent,
              activeColor: const Color.fromARGB(68, 255, 214, 64),
              onTap: () => onTap(0),
              icon: Image.asset("assets/Home.png"),
            ),
            _NavBarItem(
              isActive: selectedIndex == 1,
              splashColor: Colors.amberAccent,
              activeColor: const Color.fromARGB(68, 255, 214, 64),
              onTap: () => onTap(1),
              icon: Image.asset("assets/Group 6.png"),
            ),
            _NavBarItem(
              isActive: selectedIndex == 2,
              splashColor: Colors.amberAccent,
              activeColor: const Color.fromARGB(68, 255, 214, 64),
              onTap: () => onTap(2),
              icon: Image.asset("assets/Sparkling.png"),
            ),
            _NavBarItem(
              isActive: selectedIndex == 3,
              splashColor: Colors.amberAccent,
              activeColor: const Color.fromARGB(68, 255, 214, 64),
              onTap: () => onTap(3),
              icon: Image.asset("assets/User.png"),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final bool isActive;
  final Color splashColor;
  final Color activeColor;
  final VoidCallback onTap;
  final Widget icon;

  const _NavBarItem({
    required this.isActive,
    required this.splashColor,
    required this.activeColor,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color.fromARGB(0, 255, 250, 250),
      shape: const CircleBorder(),
      child: InkWell(
        splashColor: splashColor,
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isActive ? activeColor : Color.fromARGB(82, 56, 52, 44),
            shape: BoxShape.circle,
          ),
          child: Center(child: icon),
        ),
      ),
    );
  }
}
