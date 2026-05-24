class Song {
  final int? number;
  final String title;
  final String content;
  final List<SongSection> sections;

  Song({
    this.number,
    required this.title,
    required this.content,
    required this.sections,
  });

  @override
  String toString() {
    return 'Song{number: $number, title: $title}';
  }
}

class SongSection {
  final String type; // 'verse', 'chorus', 'bridge'
  final String content;

  SongSection({required this.type, required this.content});
}
