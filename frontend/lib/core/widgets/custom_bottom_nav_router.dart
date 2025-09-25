// frontend/lib/core/widgets/custom_bottom_nav_router.dart
import 'package:flutter/material.dart';
import '../constants/colors.dart';

class NavItem {
  final IconData icon;
  final String routeName;
  const NavItem(this.icon, this.routeName);
}

/// Gaya sederhana yang mudah di-tweak (tanpa strip merah belakang)
class SimpleNavStyle {
  // Bar
  final double barHeight;
  final double topRadius;
  final Color backgroundColor;
  final Color shadowColor;
  final double shadowBlur;
  final Offset shadowOffset;

  // Indicator (bump merah)
  final Color indicatorColor;
  final double indicatorWidth;
  final double indicatorHeight;
  /// negatif agar naik keluar bar
  final double indicatorTop;
  final BorderRadius indicatorRadius;

  // Icon
  final double iconSize;
  final double iconBoxSize; // ukuran kotak outline icon non-aktif
  final BorderRadius iconBoxRadius;
  final Color inactiveIconColor;
  final Color activeIconColor;
  final Color outlineColor;
  final double outlineWidth;
  /// posisi ikon aktif terhadap top bar
  final double activeIconTop;

  // Animasi
  final Duration duration;
  final Curve curve;

  const SimpleNavStyle({
    // bar
    this.barHeight = 60,
    this.topRadius = 22,
    this.backgroundColor = AppColors.pureWhite,
    this.shadowColor = const Color(0x33000000),
    this.shadowBlur = 16,
    this.shadowOffset = const Offset(0, -6),

    // indicator
    this.indicatorColor = AppColors.primaryRed,
    this.indicatorWidth = 56,
    this.indicatorHeight = 44,
    this.indicatorTop = -10,
    this.indicatorRadius = const BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16),
      bottomLeft: Radius.circular(10),
      bottomRight: Radius.circular(10),
    ),

    // icons
    this.iconSize = 20,
    this.iconBoxSize = 38,
    this.iconBoxRadius = const BorderRadius.all(Radius.circular(10)),
    this.inactiveIconColor = AppColors.black,
    this.activeIconColor = AppColors.pureWhite,
    this.outlineColor = AppColors.black,
    this.outlineWidth = 1,

    this.activeIconTop = 2,

    // anim
    this.duration = const Duration(milliseconds: 220),
    this.curve = Curves.easeOutCubic,
  });

  SimpleNavStyle copyWith({
    double? barHeight,
    double? topRadius,
    Color? backgroundColor,
    Color? shadowColor,
    double? shadowBlur,
    Offset? shadowOffset,
    Color? indicatorColor,
    double? indicatorWidth,
    double? indicatorHeight,
    double? indicatorTop,
    BorderRadius? indicatorRadius,
    double? iconSize,
    double? iconBoxSize,
    BorderRadius? iconBoxRadius,
    Color? inactiveIconColor,
    Color? activeIconColor,
    Color? outlineColor,
    double? outlineWidth,
    double? activeIconTop,
    Duration? duration,
    Curve? curve,
  }) {
    return SimpleNavStyle(
      barHeight: barHeight ?? this.barHeight,
      topRadius: topRadius ?? this.topRadius,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      shadowColor: shadowColor ?? this.shadowColor,
      shadowBlur: shadowBlur ?? this.shadowBlur,
      shadowOffset: shadowOffset ?? this.shadowOffset,
      indicatorColor: indicatorColor ?? this.indicatorColor,
      indicatorWidth: indicatorWidth ?? this.indicatorWidth,
      indicatorHeight: indicatorHeight ?? this.indicatorHeight,
      indicatorTop: indicatorTop ?? this.indicatorTop,
      indicatorRadius: indicatorRadius ?? this.indicatorRadius,
      iconSize: iconSize ?? this.iconSize,
      iconBoxSize: iconBoxSize ?? this.iconBoxSize,
      iconBoxRadius: iconBoxRadius ?? this.iconBoxRadius,
      inactiveIconColor: inactiveIconColor ?? this.inactiveIconColor,
      activeIconColor: activeIconColor ?? this.activeIconColor,
      outlineColor: outlineColor ?? this.outlineColor,
      outlineWidth: outlineWidth ?? this.outlineWidth,
      activeIconTop: activeIconTop ?? this.activeIconTop,
      duration: duration ?? this.duration,
      curve: curve ?? this.curve,
    );
  }

  /// preset mirip mockup-mu
  factory SimpleNavStyle.preset() => const SimpleNavStyle();
}

/// BottomNav berbasis ROUTE dengan indikator “bump” merah (tanpa strip belakang).
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
    final idx = currentIndex.clamp(0, (items.length - 1).clamp(0, items.length - 1));

    return SafeArea(
      top: false,
      child: SizedBox(
        height: style.barHeight,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final totalW = constraints.maxWidth;
            final cellW = totalW / items.length;
            final centerX = (cellW * idx) + (cellW / 2);

            final indicatorLeft = (centerX - style.indicatorWidth / 2)
                .clamp(0, constraints.maxWidth - style.indicatorWidth);
            final activeIconLeft = (centerX - style.iconSize / 2)
                .clamp(0, constraints.maxWidth - style.iconSize);

            return Stack(
              clipBehavior: Clip.none,
              children: [
                // BAR putih dengan rounded + shadow
                Container(
                  decoration: BoxDecoration(
                    color: style.backgroundColor,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(style.topRadius)),
                    boxShadow: [
                      BoxShadow(
                        color: style.shadowColor,
                        blurRadius: style.shadowBlur,
                        offset: style.shadowOffset,
                      ),
                    ],
                  ),
                ),

                // BUMP merah yang align tepat di tengah sel aktif
                AnimatedPositioned(
                  duration: style.duration,
                  curve: style.curve,
                  left: indicatorLeft.toDouble(),
                  top: style.indicatorTop,
                  width: style.indicatorWidth,
                  height: style.indicatorHeight,
                  child: Container(
                    decoration: BoxDecoration(
                      color: style.indicatorColor,
                      borderRadius: style.indicatorRadius,
                    ),
                  ),
                ),

                // Tap target + ikon non-aktif (kotak outline)
                Row(
                  children: List.generate(items.length, (i) {
                    final selected = i == idx;
                    return Expanded(
                      child: InkResponse(
                        onTap: () => _go(context, i),
                        highlightShape: BoxShape.rectangle,
                        radius: style.iconBoxSize,
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

                // Ikon aktif (di atas bump)
                AnimatedPositioned(
                  duration: style.duration,
                  curve: style.curve,
                  left: activeIconLeft.toDouble(),
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
