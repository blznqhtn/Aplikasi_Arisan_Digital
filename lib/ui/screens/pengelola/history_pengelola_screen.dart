import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:arisan_digitalv2/services/api_service.dart';
import 'package:arisan_digitalv2/ui/screens/pengelola/group_details_pengelola_screen.dart';
import 'package:arisan_digitalv2/core/api_config.dart';

class PaymentHistoryScreen extends StatefulWidget {
  final int groupId;
  final String groupName;
  final int contributionAmount;
  final String startMonth;
  final int totalParticipants;
  final int currentMonth;
  final String username;
  final int userId;

  const PaymentHistoryScreen({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.contributionAmount,
    required this.startMonth,
    required this.totalParticipants,
    required this.currentMonth,
    required this.username,
    required this.userId,
  });

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _monthlyHistory = [];
  List<Map<String, dynamic>> _winnerHistory = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  int _actualCurrentMonth = 1; // Store the actual current month from the server

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadHistoryData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHistoryData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final data = await ApiService.getHistory(widget.groupId);

      if (data['status'] == 'error' && data.containsKey('message')) {
        setState(() {
          _hasError = true;
          _errorMessage = data['message'];
          _isLoading = false;
        });
        return;
      }

      if (data.containsKey('error')) {
        setState(() {
          _hasError = true;
          _errorMessage = data['error'];
          _isLoading = false;
        });
        return;
      }

      // Get the current month from the response
      if (data.containsKey('current_month')) {
        _actualCurrentMonth = data['current_month'];
      }

      // Parse payment history
      if (data.containsKey('payment_history')) {
        final List<dynamic> paymentHistory = data['payment_history'];
        _monthlyHistory = paymentHistory
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }

      // Parse winner history
      if (data.containsKey('winner_history')) {
        final List<dynamic> winnerHistory = data['winner_history'];
        _winnerHistory = winnerHistory
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  String _calculateMonthDate(int monthIndex) {
    try {
      // Fix: Handle date parsing more safely
      DateTime startDate;
      try {
        startDate = DateFormat('MMMM yyyy').parse(widget.startMonth);
      } catch (e) {
        // Fallback if parsing fails with the first format
        try {
          startDate = DateFormat('MMM yyyy').parse(widget.startMonth);
        } catch (e) {
          // If all parsing fails, use current date as fallback
          startDate = DateTime.now();
        }
      }

      // Calculate the month by adding monthIndex to the start month
      final month = DateTime(startDate.year, startDate.month + monthIndex);

      return DateFormat('MMMM yyyy').format(month);
    } catch (e) {
      // Handle potential date parsing errors gracefully
      return 'Bulan ${monthIndex + 1}';
    }
  }

  void _navigateToGroupDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupDetailsPengelolaScreen(
          groupId: widget.groupId,
          groupName: widget.groupName,
          contributionAmount: widget.contributionAmount,
          startMonth: widget.startMonth,
          totalParticipants: widget.totalParticipants,
          currentMonth:
              _actualCurrentMonth, // Use the actual current month from server
          username: widget.username,
          userId: widget.userId,
        ),
      ),
    ).then((_) {
      // Always refresh data when returning from group details
      _loadHistoryData();
    });
  }

  // Function to record a winner
  Future<bool> _recordWinner(int participantId, int monthNumber) async {
    try {
      final data = await ApiService.recordWinnerFromHistory(
          widget.groupId, participantId, monthNumber);

      if (data['success'] == true) {
        // Refresh data after successful update
        await _loadHistoryData();
        return true;
      }

      return false;
    } catch (e) {
      print('Error recording winner: $e');
      return false;
    }
  }

  // Function to advance the group to the next month
  Future<bool> _advanceToNextMonth() async {
    try {
      final data = await ApiService.advanceMonth(widget.groupId);

      if (data['success'] == true) {
        // Refresh data after successful update
        await _loadHistoryData();
        return true;
      }

      return false;
    } catch (e) {
      print('Error advancing month: $e');
      return false;
    }
  }

  // Add a method to check if arisan is completed
  Future<bool> _checkArisanStatus() async {
    try {
      final data = await ApiService.checkArisanStatus(widget.groupId);
      return data['is_completed'] == true;
    } catch (e) {
      print('Error checking arisan status: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00B2FF),
        title: Text(
          'Histori ${widget.groupName}',
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'FjallaOne',
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh Data',
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _loadHistoryData().then((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Data berhasil diperbarui'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.group, color: Colors.white),
            tooltip: 'Kelola Grup',
            onPressed: _navigateToGroupDetails,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontFamily: 'FjallaOne',
            fontWeight: FontWeight.bold,
          ),
          tabs: const [
            Tab(text: 'Status Pembayaran'),
            Tab(text: 'Pemenang Arisan'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00B2FF)),
              ),
            )
          : _hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Terjadi Kesalahan',
                        style: TextStyle(
                          fontFamily: 'FjallaOne',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'FjallaOne',
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _loadHistoryData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00B2FF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                        icon: const Icon(Icons.refresh),
                        label: const Text(
                          'Coba Lagi',
                          style: TextStyle(
                            fontFamily: 'FjallaOne',
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPaymentStatusTab(),
                    _buildWinnerHistoryTab(),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToGroupDetails,
        backgroundColor: const Color(0xFF00B2FF),
        child: const Icon(Icons.edit, color: Colors.white),
        tooltip: 'Kelola Grup',
      ),
    );
  }

  // Modify _buildPaymentStatusTab to filter out future months if arisan is completed
  Widget _buildPaymentStatusTab() {
    return FutureBuilder<bool>(
      future: _checkArisanStatus(),
      builder: (context, snapshot) {
        final bool isCompleted = snapshot.data ?? false;

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: _monthlyHistory.length,
          itemBuilder: (context, monthIndex) {
            final monthData = _monthlyHistory[monthIndex];
            // Skip this month if it's a future month (after current month) and arisan is completed
            if (isCompleted &&
                int.parse(monthData['month'].toString()) >
                    widget.totalParticipants) {
              return SizedBox.shrink(); // Don't show this month
            }

            // The rest of your existing code for building month cards
            // Fix: Safely cast to List<dynamic> first, then map to List<Map<String, dynamic>>
            final List<dynamic> rawParticipants =
                monthData['participants'] as List<dynamic>;
            final List<Map<String, dynamic>> participants = rawParticipants
                .map((item) => item as Map<String, dynamic>)
                .toList();

            final isCurrentMonth = monthIndex == _monthlyHistory.length - 1;

            // Calculate stats
            final totalPaid =
                participants.where((p) => p['paid'] == true).length;
            final progressPercentage =
                participants.isEmpty ? 0.0 : totalPaid / participants.length;

            return Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isCurrentMonth
                      ? const Color(0xFF00B2FF)
                      : Colors.grey.shade300,
                  width: isCurrentMonth ? 2.0 : 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Month header
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: isCurrentMonth
                          ? const Color(0xFF00B2FF)
                          : Colors.grey.shade100,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_month,
                          color: isCurrentMonth
                              ? Colors.white
                              : const Color(0xFF00B2FF),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Bulan ${monthData['month']} - ${monthData['date']}',
                            style: TextStyle(
                              fontFamily: 'FjallaOne',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isCurrentMonth
                                  ? Colors.white
                                  : const Color(0xFF00B2FF),
                            ),
                          ),
                        ),
                        if (isCurrentMonth)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Bulan Ini',
                              style: TextStyle(
                                fontFamily: 'FjallaOne',
                                fontSize: 12,
                                color: Color(0xFF00B2FF),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Progress bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Status Pembayaran',
                              style: TextStyle(
                                fontFamily: 'FjallaOne',
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            Text(
                              '$totalPaid dari ${participants.length} peserta',
                              style: TextStyle(
                                fontFamily: 'FjallaOne',
                                fontWeight: FontWeight.w500,
                                color: isCurrentMonth
                                    ? const Color(0xFF00B2FF)
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progressPercentage,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              progressPercentage == 1.0
                                  ? Colors.green
                                  : const Color(0xFF00B2FF),
                            ),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          progressPercentage == 1.0
                              ? 'Semua peserta telah membayar'
                              : 'Total terkumpul: Rp${NumberFormat('#,###').format(totalPaid * widget.contributionAmount)}',
                          style: TextStyle(
                            fontFamily: 'FjallaOne',
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Divider
                  Divider(color: Colors.grey.shade300),

                  // Add action button for current month to manage payments
                  if (isCurrentMonth)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 8.0),
                      child: ElevatedButton(
                        onPressed: _navigateToGroupDetails,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00B2FF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Kelola Pembayaran',
                              style: TextStyle(
                                fontFamily: 'FjallaOne',
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Participants list
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: participants.length,
                    itemBuilder: (context, index) {
                      final participant = participants[index];
                      final bool isPaid = participant['paid'] == true;
                      final String? paymentDate = participant['payment_date'];

                      return ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          backgroundColor: isPaid
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                          radius: 16,
                          child: Icon(
                            isPaid ? Icons.check : Icons.close,
                            color: isPaid ? Colors.green : Colors.red,
                            size: 16,
                          ),
                        ),
                        title: Text(
                          participant['name'].toString(),
                          style: const TextStyle(
                            fontFamily: 'FjallaOne',
                            fontSize: 14,
                          ),
                        ),
                        trailing: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              isPaid ? 'Sudah Bayar' : 'Belum Bayar',
                              style: TextStyle(
                                fontFamily: 'FjallaOne',
                                fontSize: 12,
                                color: isPaid ? Colors.green : Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (isPaid && paymentDate != null)
                              Text(
                                DateFormat('dd/MM/yyyy HH:mm')
                                    .format(DateTime.parse(paymentDate)),
                                style: TextStyle(
                                  fontFamily: 'FjallaOne',
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWinnerHistoryTab() {
    // Use the actual winner history from API data
    final monthsWithWinners = _winnerHistory;

    return monthsWithWinners.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.emoji_events_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Belum Ada Pemenang',
                  style: TextStyle(
                    fontFamily: 'FjallaOne',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00B2FF),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pengundian belum dilakukan untuk bulan ini',
                  style: TextStyle(
                    fontFamily: 'FjallaOne',
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                // Add button to navigate to group details to perform draw
                ElevatedButton.icon(
                  onPressed: _navigateToGroupDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B2FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  icon: const Icon(Icons.casino),
                  label: const Text(
                    'Kocok Arisan',
                    style: TextStyle(
                      fontFamily: 'FjallaOne',
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: monthsWithWinners.length,
            itemBuilder: (context, index) {
              final monthData = monthsWithWinners[index];
              final String winnerName =
                  monthData['winner']?.toString() ?? 'Unknown';
              final int prizeAmount = monthData['prize_amount'] ?? 0;

              // --- FIXED: Robust date parsing for winning_date ---
              String formattedWinningDate = "tanggal tidak tersedia";
              if (monthData['winning_date'] != null) {
                try {
                  final dt = DateFormat('d MMMM yyyy')
                      .parse(monthData['winning_date']);
                  formattedWinningDate = DateFormat('dd MMMM yyyy').format(dt);
                } catch (e) {
                  formattedWinningDate = monthData['winning_date'];
                }
              }
              // ---------------------------------------------------

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    // Winner display with trophy
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF00B2FF),
                            const Color(0xFF00B2FF).withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.emoji_events,
                            color: Colors.amber,
                            size: 36,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bulan ${monthData['month']} - ${monthData['date']}',
                                  style: const TextStyle(
                                    fontFamily: 'FjallaOne',
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  winnerName,
                                  style: const TextStyle(
                                    fontFamily: 'FjallaOne',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Prize amount
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Hadiah:',
                                style: TextStyle(
                                  fontFamily: 'FjallaOne',
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Rp${NumberFormat('#,###').format(prizeAmount)}',
                                style: const TextStyle(
                                  fontFamily: 'FjallaOne',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00B2FF),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Divider(),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: Colors.grey,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Pengundian dilakukan pada $formattedWinningDate',
                                  style: TextStyle(
                                    fontFamily: 'FjallaOne',
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
  }
}
