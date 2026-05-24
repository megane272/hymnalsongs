import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song.dart';
import '../theme/theme_manager.dart';

class SongDetailPage extends StatelessWidget {
  final Song song;

  const SongDetailPage({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return _buildSongContent(song, themeManager, isTablet);
  }

  Widget _buildSongContent(Song song, ThemeManager themeManager, bool isTablet) {
    final padding = isTablet ? 24.0 : 16.0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            decoration: BoxDecoration(
              color: themeManager.backgroundColor,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: themeManager.primaryColor,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: themeManager.primaryColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                if (song.number != null)
                  Text(
                    'No. ${song.number}',
                    style: TextStyle(
                      fontSize: isTablet ? 32 : 28,
                      color: themeManager.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Serif',
                    ),
                    textAlign: TextAlign.center,
                  )
                else
                  Text(
                    'Special Song',
                    style: TextStyle(
                      fontSize: isTablet ? 32 : 28,
                      color: themeManager.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Serif',
                    ),
                    textAlign: TextAlign.center,
                  ),

                const SizedBox(height: 12),

                Text(
                  song.title,
                  style: TextStyle(
                    fontSize: isTablet ? 24 : 20,
                    color: themeManager.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          ...song.sections.map((section) {
            return _buildSongSection(section, themeManager, isTablet);
          }),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSongSection(SongSection section, ThemeManager themeManager, bool isTablet) {
    final bool isChorus = section.type == 'chorus';

    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 24 : 20),
      child: Column(
        crossAxisAlignment:
        isChorus ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          if (isChorus)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 12),
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 24 : 16,
                vertical: isTablet ? 24 : 20,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: themeManager.primaryColor, width: 3),
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: themeManager.isDarkMode
                      ? [
                    const Color(0x20D4AF37),
                    const Color(0x40B8860B),
                  ]
                      : [
                    const Color(0x20F5F5DC),
                    const Color(0x40DEB887),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: themeManager.isDarkMode
                        ? const Color(0x60D4AF37)
                        : const Color(0x60DEB887),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'CHORUS',
                    style: TextStyle(
                      color: themeManager.primaryColor,
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    section.content,
                    style: TextStyle(
                      color: themeManager.textColor,
                      fontSize: isTablet ? 20 : 18,
                      fontStyle: FontStyle.italic,
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            Container(
              padding: EdgeInsets.symmetric(horizontal: isTablet ? 12 : 8),
              child: Text(
                section.content,
                style: TextStyle(
                  color: themeManager.textColor,
                  fontSize: isTablet ? 20 : 18,
                  height: 1.6,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
        ],
      ),
    );
  }
}