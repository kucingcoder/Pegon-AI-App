import 'package:flutter/material.dart';
import '../../data/learning_service.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class LevelTwoPage extends StatefulWidget {
  const LevelTwoPage({super.key});

  @override
  State<LevelTwoPage> createState() => _LevelTwoPageState();
}

class _LevelTwoPageState extends State<LevelTwoPage> {
  final LearningService _service = LearningService();
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _isListening = false;
  String _text = 'Tekan mikrofon untuk mulai bicara';
  String _recognizedText = '';
  bool _isChecking = false;

  Future<void> _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          print('onStatus: $val');
          if (val == 'done' || val == 'notListening') {
            setState(() => _isListening = false);
          }
        },
        onError: (val) {
          print('onError: $val');
          setState(() => _isListening = false);
        },
      );

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            _recognizedText = val.recognizedWords;
          }),
          listenMode: stt.ListenMode.dictation,
          localeId: 'id_ID', // Assume Indonesian
        );
      } else {
        setState(() => _text = 'Speech recognition not available');
        // Request permission explicitly if initialize fails?
        var status = await Permission.microphone.status;
        if (!status.isGranted) {
          await Permission.microphone.request();
        }
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _checkAnswer() async {
    if (_recognizedText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan ucapkan jawaban terlebih dahulu'),
        ),
      );
      return;
    }

    setState(() => _isChecking = true);

    // Real answer hardcoded as per instructions
    const real = "selamat pagi";

    final result = await _service.checkRead(_recognizedText, real);

    if (mounted) {
      setState(() => _isChecking = false);

      if (result != null && result.success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Jawaban Benar!')));
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result?.message ?? 'Jawaban Salah, coba lagi'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Level 2'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image/Text for Pegon
              // "سۤلَمَتْ ڤَاڮِي"
              // No image asset mentioned, but user says "level 2 seperti di gambar"
              // And text is "سۤلَمَتْ ڤَاڮِي"
              // I will display the text prominently.
              const Spacer(),
              const Text(
                'Bacalah tulisan berikut:',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF1DC), // Beige
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: const Text(
                  'سۤلَمَتْ ڤَاڮِي',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                    fontFamily:
                        'Amiri', // Assuming an arabic font might be available or default
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Microphone Button
              GestureDetector(
                onTap: _listen,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: _isListening ? Colors.red : Colors.teal,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (_isListening ? Colors.red : Colors.teal)
                            .withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isListening ? Icons.stop : Icons.mic,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _text,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: Colors.black87),
              ),
              const Spacer(),

              // "Periksa" Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isChecking ? null : _checkAnswer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan[400],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isChecking
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Periksa',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
