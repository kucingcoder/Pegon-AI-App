import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/transaction_service.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';

class PaymentPage extends StatefulWidget {
  final String transactionId;

  const PaymentPage({super.key, required this.transactionId});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final TransactionService _service = TransactionService();
  Map<String, dynamic>? _transactionInfo;
  bool _isLoading = true;
  String? _error;
  Timer? _timer;
  Duration _timeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadTransactionInfo();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadTransactionInfo() async {
    try {
      final data = await _service.getTransactionInfo(widget.transactionId);
      if (mounted) {
        setState(() {
          _transactionInfo = data;
          _isLoading = false;
        });
        _startTimer();
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  void _startTimer() {
    if (_transactionInfo == null) return;
    final expiredAt = DateTime.parse(_transactionInfo!['expired_at']).toLocal();
    final now = DateTime.now();

    if (expiredAt.isAfter(now)) {
      _timeLeft = expiredAt.difference(now);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            if (_timeLeft.inSeconds > 0) {
              _timeLeft = _timeLeft - const Duration(seconds: 1);
            } else {
              _timer?.cancel();
              // Refresh status or show expired
              _loadTransactionInfo();
            }
          });

          // Poll status every 5 seconds
          if (timer.tick % 5 == 0) {
            _checkStatus();
          }
        }
      });
    }
  }

  Future<void> _checkStatus() async {
    try {
      final status = await _service.getTransactionStatus(widget.transactionId);
      if (mounted && status != _transactionInfo?['status']) {
        setState(() {
          _transactionInfo!['status'] = status;
        });
        if (status != 'Pending') {
          _timer?.cancel(); // Stop polling if final state reached
        }
      }
    } catch (e) {
      debugPrint('Error checking status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(body: Center(child: Text('Error: $_error')));
    }

    final status = _transactionInfo!['status'];
    final isPending = status == 'Pending';
    final isSuccess = status == 'Success';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Pembayaran QRIS',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (isSuccess || status == 'Canceled') {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const DashboardPage()),
                (route) => false,
              );
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Timer Card
            if (isPending)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1), // Light Orange/Yellow
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.access_time,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Menunggu Pembayaran',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Segera selesaikan pembayaran Anda',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.brown[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Pembayaran',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            NumberFormat.currency(
                              locale: 'id',
                              symbol: 'Rp ',
                              decimalDigits: 0,
                            ).format(_transactionInfo!['value']),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 16,
                          color: Colors.brown[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Bayar sebelum: ${DateFormat('d MMM yyyy, HH.mm').format(DateTime.parse(_transactionInfo!['expired_at']).toLocal())}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange[50], // Lighter orange
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _formatDuration(_timeLeft),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),

            // QR Code Section
            if (isPending)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.purpleAccent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.qr_code,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Scan Kode QR',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.network(
                        _transactionInfo!['qr_code'],
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const SizedBox(
                            height: 200,
                            width: 200,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox(
                              height: 200,
                              width: 200,
                              child: Center(child: Text("Failed to load QR")),
                            ),
                      ),
                    ),
                  ],
                ),
              ),

            if (!isPending)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(
                      isSuccess ? Icons.check_circle : Icons.cancel,
                      color: isSuccess ? Colors.green : Colors.red,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isSuccess
                          ? 'Pembayaran Berhasil!'
                          : 'Transaksi Dibatalkan',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const DashboardPage(),
                            ),
                            (route) => false,
                          );
                        },
                        child: const Text('Kembali ke Dashboard'),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Instructions
            if (isPending)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    leading: const Icon(Icons.menu_book, color: Colors.teal),
                    title: const Text(
                      'Cara Bayar',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: [
                      _buildInstructionStep(
                        1,
                        'Buka aplikasi e-wallet Anda (GoPay, OVO, DANA, ShopeePay, dll)',
                      ),
                      _buildInstructionStep(
                        2,
                        'Pilih menu "Scan QR" atau "Bayar"',
                      ),
                      _buildInstructionStep(
                        3,
                        'Scan kode QR di atas atau download dan upload gambar QR',
                      ),
                      _buildInstructionStep(4, 'Periksa detail pembayaran'),
                      _buildInstructionStep(5, 'Konfirmasi pembayaran'),
                      _buildInstructionStep(6, 'Simpan bukti transaksi Anda'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.teal,
              shape: BoxShape.circle,
            ),
            child: Text(
              number.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: TextStyle(color: Colors.grey[700])),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String houses = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$houses:$minutes:$seconds";
  }
}
