import 'package:flutter/material.dart';
import '../constants/colors.dart';

class NavItem {
  final IconData icon;
  final String routeName;
  const NavItem(this.icon, this.routeName);
}

class SimpleNavStyle {
  final double barHeight;
  final double topRadius;
  final Color backgroundColor;
  final Color shadowColor;
  final double shadowBlur;
  final Offset shadowOffset;
  final Color indicatorColor;
  final double indicatorWidth;
  final double indicatorHeight;
  final double indicatorTop;
  final BorderRadius indicatorRadius;
  final double iconSize;
  final double iconBoxSize;
  final BorderRadius iconBoxRadius;
  final Color inactiveIconColor;
  final Color activeIconColor;
  final Color outlineColor;
  final double outlineWidth;
  final double activeIconTop;
  final Duration duration;
  final Curve curve;

  const SimpleNavStyle({
    this.barHeight = 60,
    this.topRadius = 22,
    this.backgroundColor = AppColors.pureWhite,
    this.shadowColor = const Color(0x33000000),
    this.shadowBlur = 16,
    this.shadowOffset = const Offset(0, -6),
    this.indicatorColor = AppColors.primaryRed,
    this.indicatorWidth = 56,
    this.indicatorHeight = 44,
    this.indicatorTop = -10,
    this.indicatorRadius = const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
    this.iconSize = 20,
    this.iconBoxSize = 38,
    this.iconBoxRadius = const BorderRadius.all(Radius.circular(10)),
    this.inactiveIconColor = AppColors.black,
    this.activeIconColor = AppColors.pureWhite,
    this.outlineColor = AppColors.black,
    this.outlineWidth = 1,
    this.activeIconTop = 2,
    this.duration = Duration.zero,
    this.curve = Curves.linear,
  });

  factory SimpleNavStyle.preset() => const SimpleNavStyle();
}

class CustomBottomNavRouter extends StatelessWidget {
  final int currentIndex;
  final List<NavItem> items;
  final SimpleNavStyle style;

  const CustomBottomNavRouter({
    super.key,
    required this.currentIndex,
    required this.items,
    this.style = const SimpleNavStyle(),
  });

  void _go(BuildContext context, int index) {
    if (index == currentIndex) return;
    if (index < 0 || index >= items.length) return;
    Navigator.of(context).pushReplacementNamed(items[index].routeName);
  }

  @override
  Widget build(BuildContext context) {
    final int safeLen = items.isEmpty ? 1 : items.length;
    final int idx = currentIndex.clamp(0, safeLen - 1);

    return SafeArea(
      top: false,
      child: SizedBox(
        height: style.barHeight,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final totalW = constraints.maxWidth;
            final cellW = totalW / items.length;
            final centerX = (cellW * idx) + (cellW / 2);
            final double indicatorLeft = (centerX - style.indicatorWidth / 2).clamp(0, constraints.maxWidth - style.indicatorWidth);
            final double activeIconLeft = (centerX - style.iconSize / 2).clamp(0, constraints.maxWidth - style.iconSize);

            return Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: style.backgroundColor,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(style.topRadius)),
                    boxShadow: [BoxShadow(color: style.shadowColor, blurRadius: style.shadowBlur, offset: style.shadowOffset)],
                  ),
                ),
                Positioned(
                  left: indicatorLeft,
                  top: style.indicatorTop,
                  width: style.indicatorWidth,
                  height: style.indicatorHeight,
                  child: Container(
                    decoration: BoxDecoration(color: style.indicatorColor, borderRadius: style.indicatorRadius),
                  ),
                ),
                Row(
                  children: List.generate(items.length, (i) {
                    final selected = i == idx;
                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _go(context, i),
                        child: SizedBox(
                          height: style.barHeight,
                          child: Center(
                            child: selected
                                ? SizedBox(width: style.iconBoxSize, height: style.iconBoxSize)
                                : Container(
                                    width: style.iconBoxSize,
                                    height: style.iconBoxSize,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: style.outlineColor, width: style.outlineWidth),
                                      borderRadius: style.iconBoxRadius,
                                    ),
                                    child: Icon(items[i].icon, size: style.iconSize, color: style.inactiveIconColor),
                                  ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                Positioned(
                  left: activeIconLeft,
                  top: style.activeIconTop,
                  child: Icon(items[idx].icon, size: style.iconSize, color: style.activeIconColor),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
