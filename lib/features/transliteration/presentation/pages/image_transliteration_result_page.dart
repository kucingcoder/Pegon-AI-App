import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/image_transliteration_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../dashboard/data/dashboard_service.dart';
import '../../../dashboard/data/models/dashboard_model.dart';
import '../../../../core/presentation/widgets/app_image.dart';

class ImageTransliterationResultPage extends StatefulWidget {
  final String id;
  final String? initialTitle;
  final String? initialImage;
  final String? initialResult;
  final String? initialDate;

  const ImageTransliterationResultPage({
    super.key,
    required this.id,
    this.initialTitle,
    this.initialImage,
    this.initialResult,
    this.initialDate,
  });

  @override
  State<ImageTransliterationResultPage> createState() =>
      _ImageTransliterationResultPageState();
}

class _ImageTransliterationResultPageState
    extends State<ImageTransliterationResultPage> {
  final ImageTransliterationService _service = ImageTransliterationService();
  final DashboardService _dashboardService = DashboardService();
  late TextEditingController _titleController;

  bool _isLoading = true;
  bool _isSavingTitle = false;

  // Data holders
  String? _image;
  String? _result;
  String? _date;

  // AdMob
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;
  User? _user;

  @override
  void initState() {
    super.initState();
    // Initialize with passed data if available for immediate display
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _image = widget.initialImage;
    _result = widget.initialResult;
    _date = widget.initialDate;

    // Fetch fresh details (and user for ads)
    _fetchDetail();
    _fetchUser();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-1144248073011584/6668460405',
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );

    _bannerAd?.load();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _fetchUser() async {
    try {
      final data = await _dashboardService.getDashboardData();
      if (mounted && data != null) {
        setState(() => _user = data.user);
        if (!_user!.isPremium) {
          _loadBannerAd();
        }
      }
    } catch (e) {
      print("Error fetching user for ads: $e");
    }
  }

  Future<void> _fetchDetail() async {
    try {
      final data = await _service.getDetail(widget.id);
      if (mounted) {
        setState(() {
          _image = data['image'];
          _result = data['result'];
          _date = data['created_at'];
          _titleController.text = data['title'] ?? _titleController.text;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveTitle() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Judul tidak boleh kosong!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() => _isSavingTitle = true);
    try {
      await _service.updateTitle(widget.id, _titleController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Judul berhasil disimpan'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan judul: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingTitle = false);
    }
  }

  String _formatDateDisplay(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      // Assuming input is ISO string like "2026-01-19T12:44:55Z" or similar
      // If it's already formatted from dashboard, we might need to parse differently
      // For now, let's just try to parse ISO.
      final DateTime date = DateTime.parse(dateStr).toLocal();
      // Simple format: "November 5, 2025" or "19 Jan 2026"
      // Manual formatting for simplicity without external intl package if not present,
      // or just standard string manip.

      const months = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
      ];

      return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Hasil Transliterasi Gambar',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: _isLoading && _image == null
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // 1. Image Card
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(12),
                                child: InkWell(
                                  onTap: () {
                                    if (_image != null) {
                                      _showFullScreenImage(context, _image!);
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: AspectRatio(
                                      aspectRatio: 1.0,
                                      child: _image != null
                                          ? AppImage(
                                              imageUrl: _image!,
                                              fit: BoxFit.cover,
                                            )
                                          : const SizedBox(
                                              child: Center(
                                                child: Text("No Image"),
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // 2. Title Input
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.05),
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: _titleController,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Judul Transliterasi',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.8),
                                    suffixIcon: IconButton(
                                      icon: _isSavingTitle
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.save,
                                              color: Colors.teal,
                                            ),
                                      onPressed: _saveTitle,
                                      tooltip: 'Simpan Judul',
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // 3. Date Card
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.teal[400]!,
                                      Colors.cyan[400]!,
                                    ], // Soft Teal/Cyan
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.teal.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.calendar_today,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Dibuat pada',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.9,
                                            ),
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          _formatDateDisplay(_date),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // 4. Result Section
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFFFF8E1,
                                  ).withOpacity(0.9), // Very light amber/cream
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.amber.withOpacity(0.3),
                                  ),
                                ),
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Colors.orange,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Hasil',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const Spacer(),
                                        TextButton.icon(
                                          onPressed: () {
                                            if (_result != null) {
                                              Clipboard.setData(
                                                ClipboardData(text: _result!),
                                              );
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Teks disalin!',
                                                  ),
                                                  backgroundColor: Colors.blue,
                                                ),
                                              );
                                            }
                                          },
                                          icon: const Icon(
                                            Icons.copy,
                                            size: 16,
                                            color: Colors.brown,
                                          ),
                                          label: const Text(
                                            'Salin',
                                            style: TextStyle(
                                              color: Colors.brown,
                                            ),
                                          ),
                                          style: TextButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              side: BorderSide(
                                                color: Colors.brown.withOpacity(
                                                  0.2,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Sentuh & tahan untuk menyeleksi teks',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 10,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.all(16),
                                      child: SelectableText(
                                        _result ?? '',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          height: 1.5,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      _result != null
                                          ? '${_result!.length} karakter'
                                          : '',
                                      style: TextStyle(
                                        color: Colors.brown.withOpacity(0.6),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                if (_user != null &&
                    !_user!.isPremium &&
                    _isBannerAdReady &&
                    _bannerAd != null)
                  Container(
                    alignment: Alignment.center,
                    width: _bannerAd!.size.width.toDouble(),
                    height: _bannerAd!.size.height.toDouble(),
                    child: AdWidget(ad: _bannerAd!),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        // Base Gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.amber[50]!, Colors.white, Colors.teal[50]!],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
        // Abstract Shapes
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.amber[100]!.withOpacity(0.3),
            ),
          ),
        ),
        Positioned(
          bottom: -50,
          left: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.teal[100]!.withOpacity(0.3),
            ),
          ),
        ),
      ],
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,

              child: AppImage(imageUrl: imageUrl, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }
}
