import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song.dart';
import '../theme/theme_manager.dart';
import '../widgets/bottom_nav_bar.dart';
import 'song_detail_page.dart';

class SongSwipePage extends StatefulWidget {
  final List<Song> songs;
  final int initialIndex;

  const SongSwipePage({
    super.key,
    required this.songs,
    required this.initialIndex,
  });

  @override
  SongSwipePageState createState() => SongSwipePageState();
}

class SongSwipePageState extends State<SongSwipePage> {
  late PageController _pageController;
  int _currentPage = 0;
  final GlobalKey<BottomNavBarState> _bottomNavKey = GlobalKey<BottomNavBarState>();

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showSongInfo(BuildContext context, Song song, ThemeManager themeManager) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeManager.isDarkMode
            ? const Color(0xCC1A1A1A)
            : const Color(0xCCFAF0E6),
        title: Text(song.title,
            style: TextStyle(color: themeManager.primaryColor)),
        content: Text(
          song.number != null
              ? 'Song Number: ${song.number}\nTotal Sections: ${song.sections.length}'
              : 'Special Song\nTotal Sections: ${song.sections.length}',
          style: TextStyle(color: themeManager.secondaryColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close',
                style: TextStyle(color: themeManager.primaryColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final isTablet = MediaQuery.of(context).size.width > 600;
    final currentSong = widget.songs[_currentPage];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => _bottomNavKey.currentState?.showAndResetTimer(),
        onPanDown: (_) => _bottomNavKey.currentState?.showAndResetTimer(),
        child: Container(
          decoration: BoxDecoration(
            gradient: themeManager.backgroundGradient,
          ),
          child: SafeArea(
            child: Column(
              children: [
                AppBar(
                  backgroundColor: themeManager.appBarColor,
                  title: Column(
                    children: [
                      Text(
                        'Hymnal Songs',
                        style: TextStyle(
                          color: themeManager.primaryColor,
                          fontSize: isTablet ? 22 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        currentSong.number != null
                            ? 'Song ${currentSong.number}'
                            : 'Special Song',
                        style: TextStyle(
                          color: themeManager.secondaryColor,
                          fontSize: isTablet ? 14 : 12,
                        ),
                      ),
                    ],
                  ),
                  leading: IconButton(
                    icon: Icon(
                      themeManager.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                      color: themeManager.primaryColor,
                    ),
                    onPressed: themeManager.toggleTheme,
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.info_outline),
                      color: themeManager.primaryColor,
                      onPressed: () => _showSongInfo(context, currentSong, themeManager),
                    ),
                  ],
                  elevation: 0,
                  centerTitle: true,
                ),
                Expanded(
                  child: MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaleFactor: themeManager.textScale,
                    ),
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: widget.songs.length,
                      itemBuilder: (context, index) {
                        return SongDetailPage(song: widget.songs[index]);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        key: _bottomNavKey,
        currentIndex: -1,
        onTap: (index) => Navigator.pop(context),
        currentSongNumber: currentSong.number,
        totalSongs: widget.songs.length,
        currentPosition: _currentPage + 1,
      ),
    );
  }
}