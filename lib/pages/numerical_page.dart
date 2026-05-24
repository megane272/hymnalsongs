import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/songs_data.dart';
import '../models/song.dart';
import '../theme/theme_manager.dart';
import '../widgets/bottom_nav_bar.dart';
import 'song_swipe_page.dart'; // Import de la nouvelle page de swipe
import 'search_page.dart';
import 'alphabetical_page.dart';
import 'home_page.dart';

class NumericalPage extends StatefulWidget {
  const NumericalPage({super.key});

  @override
  NumericalPageState createState() => NumericalPageState();
}

class NumericalPageState extends State<NumericalPage> {
  int _currentNavIndex = 3;
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
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AlphabeticalPage()),
      );
    }
  }

  void _navigateToSongWithSwipe(BuildContext context, Song song, List<Song> songList) {
    final initialIndex = songList.indexOf(song);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SongSwipePage(
          songs: songList,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  // Liste combinée: chants spéciaux d'abord, puis chants numérotés
  List<Song> get _combinedSongs {
    final specialSongs = songs.where((s) => s.number == null).toList();
    final numberedSongs = songs.where((s) => s.number != null).toList()
      ..sort((a, b) => a.number!.compareTo(b.number!));

    return [...specialSongs, ...numberedSongs];
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isLargeTablet = screenWidth > 900;

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
                  child: _buildContent(
                      context, isTablet, isLargeTablet, themeManager),
                ),
              ),
            ],
          )
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        key: _bottomNavKey,
        currentIndex: _currentNavIndex,
        onTap: _onNavItemTapped,
        currentSongNumber: null,
        totalSongs: _combinedSongs.length,
        currentPosition: 1,
      ),
    );
  }

  Widget _buildAppBar(bool isTablet, ThemeManager themeManager) {
    return AppBar(
      backgroundColor: themeManager.appBarColor,
      title: Text(
        'Songs by Number',
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

  Widget _buildContent(BuildContext context, bool isTablet, bool isLargeTablet,
      ThemeManager themeManager) {
    if (_combinedSongs.isEmpty) {
      return Center(
        child: Text(
          'No songs found',
          style: TextStyle(
            color: themeManager.textColor,
            fontSize: isTablet ? 18 : 16,
          ),
        ),
      );
    }

    if (isLargeTablet) {
      return _buildGridLayout(context, 4, isTablet, themeManager);
    } else if (isTablet) {
      return _buildGridLayout(context, 3, isTablet, themeManager);
    } else {
      return _buildListLayout(context, isTablet, themeManager);
    }
  }

  Widget _buildGridLayout(BuildContext context, int crossAxisCount,
      bool isTablet, ThemeManager themeManager) {
    return GridView.builder(
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: isTablet ? 16 : 12,
        mainAxisSpacing: isTablet ? 16 : 12,
        childAspectRatio: 1.2,
      ),
      itemCount: _combinedSongs.length,
      itemBuilder: (context, index) {
        final song = _combinedSongs[index];
        return _buildSongCard(song, context, isTablet, true, themeManager);
      },
    );
  }

  Widget _buildListLayout(
      BuildContext context, bool isTablet, ThemeManager themeManager) {
    return ListView.builder(
      padding: EdgeInsets.all(isTablet ? 16 : 8),
      itemCount: _combinedSongs.length,
      itemBuilder: (context, index) {
        final song = _combinedSongs[index];
        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: isTablet ? 8 : 4,
            vertical: 4,
          ),
          child: _buildSongCard(song, context, isTablet, false, themeManager),
        );
      },
    );
  }

  Widget _buildSongCard(Song song, BuildContext context, bool isTablet,
      bool isGrid, ThemeManager themeManager) {
    return Card(
      color: themeManager.backgroundColor.withOpacity(0.9),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: themeManager.primaryColor, width: 2),
      ),
      child: InkWell(
        onTap: () => _navigateToSongWithSwipe(context, song, _combinedSongs),
        borderRadius: BorderRadius.circular(12),
        child: isGrid
            ? _buildGridContent(song, isTablet, themeManager)
            : _buildListContent(song, isTablet, themeManager),
      ),
    );
  }

  Widget _buildGridContent(
      Song song, bool isTablet, ThemeManager themeManager) {
    final bool isSpecialSong = song.number == null;

    return Padding(
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: isTablet ? 60 : 50,
            height: isTablet ? 60 : 50,
            decoration: BoxDecoration(
              color: themeManager.backgroundColor.withOpacity(0.8),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: themeManager.primaryColor, width: 2),
            ),
            child: Center(
              child: isSpecialSong
                  ? Icon(
                Icons.star,
                color: themeManager.primaryColor,
                size: isTablet ? 24 : 20,
              )
                  : Text(
                '${song.number}',
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.bold,
                  color: themeManager.primaryColor,
                ),
              ),
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            song.title,
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.w500,
              color: themeManager.textColor,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: isTablet ? 8 : 4),
          Icon(
            Icons.arrow_forward,
            size: isTablet ? 20 : 16,
            color: themeManager.secondaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildListContent(
      Song song, bool isTablet, ThemeManager themeManager) {
    final bool isSpecialSong = song.number == null;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 20 : 16,
        vertical: isTablet ? 16 : 12,
      ),
      child: Row(
        children: [
          Container(
            width: isTablet ? 50 : 40,
            height: isTablet ? 50 : 40,
            decoration: BoxDecoration(
              color: themeManager.backgroundColor.withOpacity(0.8),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: themeManager.primaryColor),
            ),
            child: Center(
              child: isSpecialSong
                  ? Icon(
                Icons.star,
                color: themeManager.primaryColor,
                size: isTablet ? 20 : 16,
              )
                  : Text(
                '${song.number}',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.bold,
                  color: themeManager.primaryColor,
                ),
              ),
            ),
          ),
          SizedBox(width: isTablet ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.title,
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.w500,
                    color: themeManager.textColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  isSpecialSong ? 'Special Song' : 'Song number ${song.number}',
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    color: themeManager.secondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: isTablet ? 20 : 16,
            color: themeManager.primaryColor,
          ),
        ],
      ),
    );
  }
}