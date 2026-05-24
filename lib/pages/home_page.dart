import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/songs_data.dart';
import '../models/song.dart';
import '../theme/theme_manager.dart';
import '../widgets/bottom_nav_bar.dart';
import 'search_page.dart';
import 'alphabetical_page.dart';
import 'numerical_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  final GlobalKey<BottomNavBarState> _bottomNavKey = GlobalKey<BottomNavBarState>();
  int _currentPage = 0;
  int _currentNavIndex = 0;

  // Obtenir la liste des chants pour le swipe (non numérotés d'abord, puis numérotés)
  List<Song> get _swipeSongs {
    final unnumberedSongs = songs.where((s) => s.number == null).toList();
    final numberedSongs = songs.where((s) => s.number != null).toList()
      ..sort((a, b) => a.number!.compareTo(b.number!));

    return [...unnumberedSongs, ...numberedSongs];
  }

  @override
  void initState() {
    super.initState();
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

  void _onNavItemTapped(int index) {
    setState(() {
      _currentNavIndex = index;
    });

    switch (index) {
      case 0: // Home - Retour au chant actuel
        break;
      case 1: // Search
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SearchPage()),
        );
        break;
      case 2: // Alphabetical
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AlphabeticalPage()),
        );
        break;
      case 3: // Numerical
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NumericalPage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

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
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _swipeSongs.length,
                      itemBuilder: (context, index) {
                        final song = _swipeSongs[index];
                        return _buildSongPage(song, isTablet, themeManager);
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
        currentIndex: _currentNavIndex,
        onTap: _onNavItemTapped,
        currentSongNumber: _swipeSongs[_currentPage].number,
        totalSongs: _swipeSongs.length,
        currentPosition: _currentPage + 1,
      ),
    );
  }

  Widget _buildAppBar(bool isTablet, ThemeManager themeManager) {
    final currentSong = _swipeSongs[_currentPage];

    return AppBar(
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
          if (currentSong.number != null)
            Text(
              'Song ${currentSong.number}',
              style: TextStyle(
                color: themeManager.secondaryColor,
                fontSize: isTablet ? 14 : 12,
              ),
            )
          else
            Text(
              'Special Song',
              style: TextStyle(
                color: themeManager.secondaryColor,
                fontSize: isTablet ? 14 : 12,
              ),
            ),
        ],
      ),
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: themeManager.primaryColor),
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
          onPressed: () {
            _showSongInfo(context, _swipeSongs[_currentPage], themeManager);
          },
        ),
      ],
    );
  }

  void _showSongInfo(
      BuildContext context, Song song, ThemeManager themeManager) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeManager.isDarkMode
            ? const Color(0xCC1A1A1A)
            : const Color(0xCCFAF0E6),
        title: Text(
          song.title,
          style: TextStyle(color: themeManager.primaryColor),
        ),
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

  Widget _buildSongPage(Song song, bool isTablet, ThemeManager themeManager) {
    final padding = isTablet ? 24.0 : 16.0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec numéro ou indication - STYLE RECTANGLE BORDURE DORÉE
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            decoration: BoxDecoration(
              color: themeManager.backgroundColor, // ← MÊME COULEUR QUE LE FOND
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
                      color: themeManager.primaryColor, // Texte doré
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
                      color: themeManager.primaryColor, // Texte doré
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Serif',
                    ),
                    textAlign: TextAlign.center,
                  ),

                const SizedBox(height: 12),

                // Titre du chant
                Text(
                  song.title,
                  style: TextStyle(
                    fontSize: isTablet ? 24 : 20,
                    color: themeManager.primaryColor, // Texte doré
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Contenu du chant
          ...song.sections.map((section) {
            return _buildSongSection(section, isTablet, themeManager);
          }),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSongSection(
      SongSection section, bool isTablet, ThemeManager themeManager) {
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
