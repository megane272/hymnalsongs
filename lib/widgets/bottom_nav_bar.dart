import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_manager.dart';

class BottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final int? currentSongNumber;
  final int totalSongs;
  final int currentPosition;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.currentSongNumber,
    required this.totalSongs,
    required this.currentPosition,
  });

  @override
  BottomNavBarState createState() => BottomNavBarState();
}

class BottomNavBarState extends State<BottomNavBar> {
  bool _isVisible = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _startHideTimer();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isVisible = false);
      }
    });
  }

  void showAndResetTimer() {
    setState(() => _isVisible = true);
    _startHideTimer();
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    final primaryColor = themeManager.primaryColor;
    final secondaryColor = themeManager.secondaryColor;
    final backgroundColor = themeManager.backgroundColor;
    final cardColor = themeManager.cardColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _isVisible ? null : 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: _isVisible ? 1.0 : 0.0,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [backgroundColor, cardColor],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Icon(Icons.text_decrease, color: secondaryColor, size: 20),
                    Expanded(
                      child: Slider(
                        value: themeManager.textScale,
                        min: 0.8,
                        max: 1.5,
                        divisions: 7,
                        onChanged: themeManager.updateTextScale,
                        activeColor: primaryColor,
                        inactiveColor: secondaryColor.withOpacity(0.3),
                      ),
                    ),
                    Icon(Icons.text_increase, color: secondaryColor, size: 20),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 40 : 20,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(icon: Icons.home, label: 'Home', index: 0, isTablet: isTablet, primaryColor: primaryColor, secondaryColor: secondaryColor),
                    _buildNavItem(icon: Icons.search, label: 'Search', index: 1, isTablet: isTablet, primaryColor: primaryColor, secondaryColor: secondaryColor),
                    _buildNavItem(icon: Icons.sort_by_alpha, label: 'A-Z', index: 2, isTablet: isTablet, primaryColor: primaryColor, secondaryColor: secondaryColor),
                    _buildNavItem(icon: Icons.numbers, label: 'Numbers', index: 3, isTablet: isTablet, primaryColor: primaryColor, secondaryColor: secondaryColor),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom > 0 ? 8 : 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isTablet,
    required Color primaryColor,
    required Color secondaryColor,
  }) {
    final isSelected = widget.currentIndex == index;

    return GestureDetector(
      onTap: () => widget.onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 20 : 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    primaryColor.withOpacity(0.2),
                    secondaryColor.withOpacity(0.1),
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(color: primaryColor, width: 2) : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? primaryColor : secondaryColor, size: isTablet ? 28 : 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? primaryColor : secondaryColor,
                fontSize: isTablet ? 14 : 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}