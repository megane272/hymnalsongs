import 'package:flutter/material.dart';
import '../data/songs_data.dart';
import '../pages/song_detail_page.dart';

class QuickAccessDialog extends StatefulWidget {
  const QuickAccessDialog({super.key});

  @override
  QuickAccessDialogState createState() => QuickAccessDialogState();
}

class QuickAccessDialogState extends State<QuickAccessDialog> {
  final TextEditingController numberController = TextEditingController();

  void _onNumberPressed(String number) {
    setState(() {
      numberController.text += number;
    });
  }

  void _onBackspacePressed() {
    if (numberController.text.isNotEmpty) {
      setState(() {
        numberController.text = numberController.text
            .substring(0, numberController.text.length - 1);
      });
    }
  }

  void _onClearPressed() {
    setState(() {
      numberController.text = '';
    });
  }

  void _goToSong() {
    final number = int.tryParse(numberController.text);
    if (number != null) {
      try {
        final song = songs.firstWhere((s) => s.number == number);
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SongDetailPage(song: song),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Song number not found'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid number'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xE6FFFFFF),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Quick Access',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Champ de texte affiché
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Text(
                numberController.text.isEmpty ? '0' : numberController.text,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),

            // Clavier numérique
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.5,
              ),
              itemCount: 12, // 0-9 + backspace + clear
              itemBuilder: (context, index) {
                if (index == 9) {
                  // Bouton Clear
                  return _buildKeyButton('C', _onClearPressed,
                      color: Colors.blueAccent);
                } else if (index == 10) {
                  // Bouton 0
                  return _buildKeyButton('0', () => _onNumberPressed('0'));
                } else if (index == 11) {
                  // Bouton Backspace
                  return _buildKeyButton('⌫', _onBackspacePressed,
                      color: Colors.blueGrey);
                } else {
                  // Boutons 1-9
                  final number = (index + 1).toString();
                  return _buildKeyButton(
                      number, () => _onNumberPressed(number));
                }
              },
            ),
            const SizedBox(height: 16),

            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _goToSong,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                    ),
                    child: const Text(
                      'Go to Song',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyButton(String label, VoidCallback onPressed, {Color? color}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? const Color(0xFFE3F2FD),
        foregroundColor: color != null ? Colors.white : const Color(0xFF1976D2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: color != null ? Colors.white : const Color(0xFF1976D2),
        ),
      ),
    );
  }
}
