import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final List<IconData> icons;
  final List<Widget> pages;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.icons,
    required this.pages,
  });

  void _onItemTapped(BuildContext context, int index) {
    if (index != currentIndex) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => pages[index],
          transitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (_, anim, __, child) {
            return FadeTransition(opacity: anim, child: child);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 60,
          color: AppColors.primaryRed,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(icons.length, (index) {
              final isSelected = index == currentIndex;
              return GestureDetector(
                onTap: () => _onItemTapped(context, index), // ✅ langsung navigasi
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(8),
                  decoration: isSelected
                      ? BoxDecoration(
                          color: AppColors.primaryRed,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                            bottomLeft: Radius.circular(50),
                            bottomRight: Radius.circular(50),
                          ),
                        )
                      : const BoxDecoration(),
                  child: Icon(
                    icons[index],
                    color: isSelected ? Colors.white : Colors.black,
                    size: 28,
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
