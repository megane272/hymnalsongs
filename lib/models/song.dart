// lib/models/song.dart
class Song {
  final int? number;
  final String title;
  final String content;
  final List<SongSection> sections;

  Song({
    this.number,
    required this.title,
    required this.content,
    List<SongSection>? sections,
  }) : sections = sections ?? [];
}

class SongSection {
  final String type; // 'verse', 'chorus', 'bridge', etc.
  final String content;

  SongSection({required this.type, required this.content});
}
