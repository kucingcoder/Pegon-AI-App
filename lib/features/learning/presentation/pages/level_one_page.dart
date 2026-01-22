import 'package:flutter/material.dart';
import '../../data/learning_service.dart';

class LevelOnePage extends StatefulWidget {
  const LevelOnePage({super.key});

  @override
  State<LevelOnePage> createState() => _LevelOnePageState();
}

class _LevelOnePageState extends State<LevelOnePage> {
  final LearningService _service = LearningService();
  bool _isUpdating = false;

  Future<void> _handleNext() async {
    setState(() {
      _isUpdating = true;
    });

    final result = await _service.updateLevelStage();

    if (mounted) {
      setState(() {
        _isUpdating = false;
      });

      if (result != null && result.success) {
        // Success, go back (LevelListPage will be refreshed)
        Navigator.pop(context, true);
      } else {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal update level'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Level 1'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor:
          Colors.white, // As per image background primarily content
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Container for the image with background color (cream/beige)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFFFDF1DC,
                        ), // Beige color like in screenshot
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'AKSARA PEGON',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A237E), // Dark blue
                            ),
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              'assets/images/pegon.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Lorem Ipsum text
                    const Text(
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus eu tincidunt arcu. Cras eu rutrum magna, a varius erat. Morbi urna urna, placerat id vehicula et, blandit eget sem. Proin vitae erat sodales, fringilla dolor et, euismod nisl. Etiam vel erat rutrum, tincidunt sem id, egestas nibh.',
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom Button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isUpdating ? null : _handleNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan[400],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isUpdating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Berikutnya',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
