import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/transaction_service.dart';
import 'payment_page.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  final TransactionService _service = TransactionService();
  final ScrollController _scrollController = ScrollController();
  List<dynamic> _history = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoading &&
        _hasMore) {
      _loadHistory();
    }
  }

  Future<void> _loadHistory() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final data = await _service.getTransactionHistory(page: _currentPage);
      final List<dynamic> newItems = data['data'];
      final meta = data['meta'];

      setState(() {
        _history.addAll(newItems);
        _currentPage = meta['current_page'] + 1;
        _hasMore = _currentPage <= meta['total_pages'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'canceled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return 'Berhasil';
      case 'pending':
        return 'Menunggu';
      case 'canceled':
        return 'Batal';
      default:
        return status;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return Icons.check;
      case 'pending':
        return Icons.access_time;
      case 'canceled':
        return Icons.close;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background
      appBar: AppBar(
        title: const Text(
          'Riwayat Pembayaran',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _history.clear();
            _currentPage = 1;
            _hasMore = true;
          });
          await _loadHistory();
        },
        child: _history.isEmpty && !_isLoading
            ? const Center(child: Text('Belum ada riwayat transaksi'))
            : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                itemCount: _history.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _history.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final item = _history[index];
                  final status = item['status'] ?? 'unknown';
                  final isPending = status.toLowerCase() == 'pending';
                  final statusColor = _getStatusColor(status);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
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
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: isPending
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PaymentPage(transactionId: item['id']),
                                  ),
                                );
                              }
                            : null,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item['title'] ?? 'Upgrade Premium',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: statusColor.withOpacity(0.5),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _getStatusIcon(status),
                                          size: 14,
                                          color: statusColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _getStatusText(status),
                                          style: TextStyle(
                                            color: statusColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Total Pembayaran',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                NumberFormat.currency(
                                  locale: 'id',
                                  symbol: 'Rp ',
                                  decimalDigits: 0,
                                ).format(item['value'] ?? 0),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildDateRow(
                                Icons.calendar_today_outlined,
                                'Dibuat: ${_formatDate(item['created_at'])}',
                              ),
                              const SizedBox(height: 8),
                              _buildDateRow(
                                Icons.access_time,
                                'Kadaluwarsa: ${_formatDate(item['expired_at'])}',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildDateRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return DateFormat('DD/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}
