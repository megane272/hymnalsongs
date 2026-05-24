import 'song.dart';

class SongParser {
  static Song parseSong(String title, String content, int? number) {
    final formattedContent = _formatContent(content);
    final sections = _parseSections(content);

    return Song(
      title: title,
      content: formattedContent,
      number: number,
      sections: sections,
    );
  }

  static String _formatContent(String content) {
    final lines = content.split('\n');
    final formattedLines = <String>[];
    bool inChorus = false;

    for (int i = 0; i < lines.length; i++) {
      final trimmedLine = lines[i].trim();

      if (trimmedLine.isEmpty) {
        formattedLines.add('');
        inChorus = false;
        continue;
      }

      // Détecter le début d'un chorus
      if (trimmedLine.toLowerCase().contains('Chorus:')) {
        inChorus = true;
        formattedLines.add(trimmedLine.toUpperCase());
        continue;
      }

      // Si on est dans un chorus ET que la ligne suivante n'est pas vide ET
      // qu'on ne détecte pas un nouveau chorus, on reste dans le chorus
      if (inChorus) {
        formattedLines.add('    $trimmedLine');

        // Vérifier si c'est la fin du chorus (ligne vide suivante ou fin du texte)
        if (i + 1 < lines.length) {
          final nextLine = lines[i + 1].trim();
          if (nextLine.isEmpty) {
            inChorus = false; // Le chorus se termine à la prochaine ligne vide
          }
        }
      } else {
        formattedLines.add(trimmedLine);
      }
    }

    return formattedLines.join('\n');
  }

  static List<SongSection> _parseSections(String content) {
    final sections = <SongSection>[];
    final lines = content.split('\n');
    String currentSectionType = 'verse';
    final currentSectionLines = <String>[];

    for (final line in lines) {
      final trimmedLine = line.trim();

      // Changer de section quand on trouve "chorus"
      if (trimmedLine.toLowerCase().contains('chorus')) {
        // Sauvegarder la section précédente si elle existe
        if (currentSectionLines.isNotEmpty) {
          sections.add(SongSection(
            type: currentSectionType,
            content: currentSectionLines.join('\n'),
          ));
          currentSectionLines.clear();
        }
        currentSectionType = 'chorus';
        continue;
      }

      if (trimmedLine.isEmpty && currentSectionLines.isNotEmpty) {
        // Fin d'une section (ligne vide)
        sections.add(SongSection(
          type: currentSectionType,
          content: currentSectionLines.join('\n'),
        ));
        currentSectionLines.clear();
        currentSectionType = 'verse'; // Retour aux strophes normales
        continue;
      }

      if (trimmedLine.isNotEmpty) {
        currentSectionLines.add(trimmedLine);
      }
    }

    // Ajouter la dernière section
    if (currentSectionLines.isNotEmpty) {
      sections.add(SongSection(
        type: currentSectionType,
        content: currentSectionLines.join('\n'),
      ));
    }

    return sections;
  }
}
