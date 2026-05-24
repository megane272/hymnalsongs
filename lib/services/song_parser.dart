import '../models/song_model.dart';

class SongParser {
  static Song parseSong(String title, String content, int? number) {
    final lines = content.split('\n');
    final sections = <SongSection>[];
    String currentSection = 'verse';
    List<String> currentLines = [];

    for (final line in lines) {
      final trimmedLine = line.trim();

      if (trimmedLine.isEmpty) {
        if (currentLines.isNotEmpty) {
          sections.add(
            SongSection(type: currentSection, content: currentLines.join('\n')),
          );
          currentLines = [];
        }
        continue;
      }

      final lowerLine = trimmedLine.toLowerCase();
      if (lowerLine.contains('chorus') || lowerLine.contains('refrain')) {
        if (currentLines.isNotEmpty) {
          sections.add(
            SongSection(type: currentSection, content: currentLines.join('\n')),
          );
          currentLines = [];
        }
        currentSection = 'chorus';
      } else if (lowerLine.contains('verse') ||
          RegExp(r'^\d+\.').hasMatch(trimmedLine)) {
        if (currentLines.isNotEmpty) {
          sections.add(
            SongSection(type: currentSection, content: currentLines.join('\n')),
          );
          currentLines = [];
        }
        currentSection = 'verse';
      } else {
        currentLines.add(trimmedLine);
      }
    }

    if (currentLines.isNotEmpty) {
      sections.add(
        SongSection(type: currentSection, content: currentLines.join('\n')),
      );
    }

    return Song(
      number: number,
      title: title,
      content: content,
      sections: sections,
    );
  }
}
