import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/songs_data.dart';
import '../models/song.dart';
import '../theme/theme_manager.dart';
import '../widgets/bottom_nav_bar.dart';
import 'song_detail_page.dart';
import 'song_swipe_page.dart';
import 'alphabetical_page.dart';
import 'numerical_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  final TextEditingController searchController = TextEditingController();
  final GlobalKey<BottomNavBarState> _bottomNavKey = GlobalKey<BottomNavBarState>();
  List<Song> searchResults = [];

  void performSearch(String query) {
    if (query.isEmpty) {
      setState(() => searchResults = []);
      return;
    }

    final results = songs.where((song) {
      return song.title.toLowerCase().contains(query.toLowerCase()) ||
          song.content.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() => searchResults = results);
  }

  void _navigateToSongWithSwipe(BuildContext context, Song song) {
    // Créer une liste de tous les chants triés par numéro (comme dans NumericalPage)
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

  int _currentNavIndex = 1; // Search est l'index 1

  void _onNavItemTapped(int index) {
    setState(() {
      _currentNavIndex = index;
    });

    if (index == 0) {
      Navigator.pop(context); // Retour à Home
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AlphabeticalPage()),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const NumericalPage()),
      );
    }
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
                    child: _buildResultsList(isTablet, themeManager),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
          key: _bottomNavKey,
          currentIndex: _currentNavIndex,
          onTap: _onNavItemTapped,
          currentSongNumber: null,
          totalSongs: songs.length,
          currentPosition: 1,
        ),
    );
  }

  Widget _buildAppBar(bool isTablet, ThemeManager themeManager) {
    return AppBar(
      backgroundColor: themeManager.appBarColor,
      title: Container(
        height: isTablet ? 50 : 40,
        decoration: BoxDecoration(
          color: themeManager.isDarkMode
              ? const Color(0xE6333333)
              : const Color(0xE6FFFFFF),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: themeManager.primaryColor, width: 1),
        ),
        child: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Search in songs...',
            hintStyle: TextStyle(color: themeManager.secondaryColor),
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: themeManager.primaryColor),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          ),
          style: TextStyle(
            color: themeManager.textColor,
            fontSize: isTablet ? 18 : 16,
          ),
          onChanged: performSearch,
        ),
      ),
      leading: IconButton(
        icon: Icon(
          themeManager.isDarkMode ? Icons.light_mode : Icons.dark_mode,
          color: themeManager.primaryColor,
        ),
        onPressed: themeManager.toggleTheme,
      ),
      iconTheme: IconThemeData(color: themeManager.primaryColor),
      elevation: 0,
    );
  }

  Widget _buildResultsList(bool isTablet, ThemeManager themeManager) {
    if (searchResults.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            searchController.text.isEmpty
                ? 'Type to search for a song...'
                : 'No results found for "${searchController.text}"',
            style: TextStyle(
              color: themeManager.textColor,
              fontSize: isTablet ? 18 : 16,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(isTablet ? 16 : 8),
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final song = searchResults[index];
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
                  color: themeManager.primaryColor,
                  width: 2), // Bordure plus épaisse
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(
                horizontal: isTablet ? 20 : 16,
                vertical: isTablet ? 12 : 8,
              ),
              leading: song.number != null
                  ? Container(
                      width: isTablet ? 50 : 40,
                      height: isTablet ? 50 : 40,
                      decoration: BoxDecoration(
                        color: themeManager.isDarkMode
                            ? const Color(0x40D4AF37)
                            : const Color(0x40DEB887),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: themeManager.primaryColor),
                      ),
                      child: Center(
                        child: Text(
                          '${song.number}',
                          style: TextStyle(
                            fontSize: isTablet ? 16 : 14,
                            fontWeight: FontWeight.bold,
                            color: themeManager.primaryColor,
                          ),
                        ),
                      ),
                    )
                  : Container(
                      width: isTablet ? 50 : 40,
                      height: isTablet ? 50 : 40,
                      decoration: BoxDecoration(
                        color: themeManager.isDarkMode
                            ? const Color(0x40D4AF37)
                            : const Color(0x40DEB887),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: themeManager.primaryColor),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.music_note,
                          color: themeManager.isDarkMode
                              ? Colors.white
                              : themeManager.primaryColor,
                          size: isTablet ? 20 : 16,
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
    );
  }
}

