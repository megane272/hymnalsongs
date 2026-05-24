import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/songs_data.dart';
import '../models/song.dart';
import '../theme/theme_manager.dart';
import '../widgets/bottom_nav_bar.dart';
import 'song_swipe_page.dart';
import 'search_page.dart';
import 'numerical_page.dart';
import 'home_page.dart';

class AlphabeticalPage extends StatefulWidget {
  const AlphabeticalPage({super.key});

  @override
  AlphabeticalPageState createState() => AlphabeticalPageState();
}

class AlphabeticalPageState extends State<AlphabeticalPage> {
  int _currentNavIndex = 2;
  final GlobalKey<BottomNavBarState> _bottomNavKey = GlobalKey<BottomNavBarState>();

  void _onNavItemTapped(int index) {
    setState(() {
      _currentNavIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SearchPage()),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const NumericalPage()),
      );
    }
  }

  void _navigateToSongWithSwipe(BuildContext context, Song song) {
    // Utiliser la liste complète triée par numéro pour le swipe
    final List<Song> allSongsSorted = _getAllSongsSortedByNumber();
    final initialIndex = allSongsSorted.indexOf(song);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SongSwipePage(
          songs: allSongsSorted,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  // Méthode pour obtenir tous les chants triés par numéro
  List<Song> _getAllSongsSortedByNumber() {
    final specialSongs = songs.where((s) => s.number == null).toList();
    final numberedSongs = songs.where((s) => s.number != null).toList()
      ..sort((a, b) => a.number!.compareTo(b.number!));

    return [...specialSongs, ...numberedSongs];
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final isTablet = MediaQuery.of(context).size.width > 600;

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
              _buildAppBar(isTablet, themeManager),
              Expanded(
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaleFactor: themeManager.textScale,
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.all(isTablet ? 16 : 8),
                    itemCount: songsAlphabetical.length,
                    itemBuilder: (context, index) {
                      final song = songsAlphabetical[index];
                      return Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: isTablet ? 8 : 4,
                          vertical: 4,
                        ),
                        child: Card(
                          color: themeManager.backgroundColor.withOpacity(0.9),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                                color: themeManager.primaryColor, width: 2),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 20 : 16,
                              vertical: isTablet ? 12 : 8,
                            ),
                            leading: Container(
                              width: isTablet ? 50 : 40,
                              height: isTablet ? 50 : 40,
                              decoration: BoxDecoration(
                                color: themeManager.backgroundColor.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                    color: themeManager.primaryColor),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.music_note,
                                  color: themeManager.primaryColor,
                                  size: isTablet ? 22 : 18,
                                ),
                              ),
                            ),
                            title: Text(
                              song.title,
                              style: TextStyle(
                                fontSize: isTablet ? 18 : 16,
                                fontWeight: FontWeight.w500,
                                color: themeManager.textColor,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              song.number != null
                                  ? 'Song number ${song.number}'
                                  : 'Special Song',
                              style: TextStyle(
                                fontSize: isTablet ? 14 : 12,
                                color: themeManager.secondaryColor,
                              ),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: isTablet ? 20 : 16,
                              color: themeManager.primaryColor,
                            ),
                            onTap: () => _navigateToSongWithSwipe(context, song),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      )
      ),
      bottomNavigationBar: BottomNavBar(
        key: _bottomNavKey,
        currentIndex: _currentNavIndex,
        onTap: _onNavItemTapped,
        currentSongNumber: null,
        totalSongs: songsAlphabetical.length,
        currentPosition: 1,
      ),
    );
  }

  Widget _buildAppBar(bool isTablet, ThemeManager themeManager) {
    return AppBar(
      backgroundColor: themeManager.appBarColor,
      title: Text(
        'Songs by Alphabetical Order',
        style: TextStyle(
          color: themeManager.primaryColor,
          fontSize: isTablet ? 20 : 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: themeManager.primaryColor,
          size: isTablet ? 28 : 24,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(
            themeManager.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            color: themeManager.primaryColor,
          ),
          onPressed: themeManager.toggleTheme,
        ),
      ],
      iconTheme: IconThemeData(color: themeManager.primaryColor),
      elevation: 0,
      centerTitle: true,
    );
  }
}