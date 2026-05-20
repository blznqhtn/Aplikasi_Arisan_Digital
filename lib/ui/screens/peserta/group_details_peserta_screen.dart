import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:arisan_digitalv2/services/api_service.dart';
import 'package:arisan_digitalv2/core/api_config.dart';
import 'package:arisan_digitalv2/main.dart';

class GroupDetailsPesertaScreen extends StatefulWidget {
  final int groupId;
  final String groupName;
  final int contributionAmount;
  final String startMonth;
  final int totalParticipants;
  final int currentMonth;
  final String username;
  final int participantId;

  const GroupDetailsPesertaScreen({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.contributionAmount,
    required this.startMonth,
    required this.totalParticipants,
    required this.currentMonth,
    required this.username,
    required this.participantId,
  });

  @override
  State<GroupDetailsPesertaScreen> createState() =>
      _GroupDetailsPesertaScreenState();
}

class _GroupDetailsPesertaScreenState extends State<GroupDetailsPesertaScreen> {
  late String _userInitial;
  bool _isLoading = true;
  List<Map<String, dynamic>> _monthlyPayments = [];
  List<Map<String, dynamic>> _winnersHistory = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _userInitial =
        widget.username.isNotEmpty ? widget.username[0].toUpperCase() : 'U';

    // Load payment data and winners history
    _loadPaymentData();
    _loadWinnersHistory();
  }

  Future<void> _loadPaymentData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final data = await ApiService.getParticipantPayments(
          widget.groupId, widget.participantId);

      if (data['status'] == 'error' && data.containsKey('message')) {
        setState(() {
          _errorMessage = data['message'];
          _isLoading = false;
        });
        return;
      }

      if (data.containsKey('error')) {
        setState(() {
          _errorMessage = data['error'];
          _isLoading = false;
        });
        return;
      }

      // Process payment data
      if (data.containsKey('payments')) {
        final List<dynamic> payments = data['payments'];

        // Create monthly payments list
        setState(() {
          _monthlyPayments = List.generate(
            widget.currentMonth,
            (index) {
              final monthNumber = index + 1;
              // Find payment for this month if it exists
              final payment = payments.firstWhere(
                (p) => p['month'] == monthNumber,
                orElse: () => null,
              );

              return {
                'month': monthNumber,
                'paid': payment != null,
                'paymentTime': payment != null ? payment['payment_date'] : null,
              };
            },
          );
        });
      } else {
        // Create empty payment data if none returned
        setState(() {
          _monthlyPayments = List.generate(
            widget.currentMonth,
            (index) => {
              'month': index + 1,
              'paid': false,
              'paymentTime': null,
            },
          );
        });
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });

      // Create demo data if API fails
      _createDemoData();
    }
  }

  Future<void> _loadWinnersHistory() async {
    try {
      final data = await ApiService.getWinnersHistory(widget.groupId);

      if (data.containsKey('winners')) {
        final List<dynamic> winners = data['winners'];
        setState(() {
          _winnersHistory = winners
              .map((winner) => Map<String, dynamic>.from(winner))
              .toList();
        });
      }
    } catch (e) {
      print('Error loading winners history: $e');

      // Create demo winner data if API fails
      _createDemoWinnerData();
    }
  }

  void _createDemoData() {
    // Create demo payment data matching the screenshot
    setState(() {
      _monthlyPayments = [
        {
          'month': 1,
          'paid': true,
          'paymentTime': '12/05/2025 14:23',
        },
        {
          'month': 2,
          'paid': true,
          'paymentTime': '13/05/2025 14:23',
        },
        {
          'month': 3,
          'paid': false,
          'paymentTime': null,
        },
      ];
    });
  }

  void _createDemoWinnerData() {
    // Create demo winner data matching the screenshot
    setState(() {
      _winnersHistory = [
        {
          'month': 1,
          'winner_name': 'Linda',
          'participant_id': 2,
          'win_date': '2025-05-12 14:23',
        },
      ];
    });
  }

  void _refreshData() {
    _loadPaymentData();
    _loadWinnersHistory();
  }

  Future<bool> _isArisanCompleted() async {
    try {
      final data = await ApiService.checkArisanStatus(widget.groupId);
      return data['is_completed'] == true;
    } catch (e) {
      return false;
    }
  }

  String _formatWinDate(String dateStr) {
    try {
      // Coba format yyyy-MM-dd HH:mm
      final dt = DateFormat('yyyy-MM-dd HH:mm').parse(dateStr);
      return DateFormat('d MMM yyyy HH:mm').format(dt);
    } catch (_) {
      try {
        // Coba format lain jika ada
        final dt = DateFormat('dd/MM/yyyy HH:mm').parse(dateStr);
        return DateFormat('d MMM yyyy HH:mm').format(dt);
      } catch (_) {
        return dateStr;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00B2FF),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: const Color(0xFF00B2FF),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Logo
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: const Padding(
                                  padding: EdgeInsets.only(right: 12.0),
                                  child: Icon(Icons.arrow_back_ios,
                                      color: Colors.white, size: 24),
                                ),
                              ),
                              Image.asset(
                                'assets/logo.png',
                                width: 63,
                                height: 36,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Text(
                                    'ARISAN DIGITAL',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'FjallaOne',
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        // User profile
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: PopupMenuButton<String>(
                            offset: const Offset(0, 40),
                            onSelected: (value) {
                              if (value == 'logout') {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const WelcomeScreen(),
                                  ),
                                );
                              } else if (value == 'refresh') {
                                _refreshData();
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'refresh',
                                child: Row(
                                  children: [
                                    Icon(Icons.refresh,
                                        color: Color(0xFF00B2FF)),
                                    SizedBox(width: 8),
                                    Text(
                                      'Refresh',
                                      style: TextStyle(
                                        fontFamily: 'FjallaOne',
                                        color: Color(0xFF00B2FF),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'logout',
                                child: Row(
                                  children: [
                                    Icon(Icons.logout,
                                        color: Color(0xFF00B2FF)),
                                    SizedBox(width: 8),
                                    Text(
                                      'Logout',
                                      style: TextStyle(
                                        fontFamily: 'FjallaOne',
                                        color: Color(0xFF00B2FF),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  _userInitial,
                                  style: const TextStyle(
                                    color: Color(0xFF00B2FF),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'FjallaOne',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // White divider
            Container(
              width: double.infinity,
              height: 3,
              color: Colors.white,
            ),

            // Main content
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.white,
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF00B2FF)),
                        ),
                      )
                    : _errorMessage.isNotEmpty
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32),
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
                                  onPressed: _refreshData,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00B2FF),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
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
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Group info
                                Text(
                                  widget.groupName,
                                  style: const TextStyle(
                                    color: Color(0xFF00B2FF),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'FjallaOne',
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Iuran: Rp${NumberFormat('#,###').format(widget.contributionAmount)}",
                                      style: const TextStyle(
                                        color: Color(0xFF00B2FF),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'FjallaOne',
                                      ),
                                    ),
                                    FutureBuilder<bool>(
                                      future: _isArisanCompleted(),
                                      builder: (context, snapshot) {
                                        final bool isCompleted =
                                            snapshot.data ?? false;
                                        return Text(
                                          isCompleted
                                              ? "Arisan Selesai"
                                              : "Bulan ke - ${widget.currentMonth}",
                                          style: TextStyle(
                                            color: isCompleted
                                                ? Colors.green
                                                : const Color(0xFF00B2FF),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'FjallaOne',
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "Peserta: ${widget.totalParticipants}",
                                  style: const TextStyle(
                                    color: Color(0xFF00B2FF),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'FjallaOne',
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Winners history section
                                const Text(
                                  "Histori Pemenang",
                                  style: TextStyle(
                                    color: Color(0xFF00B2FF),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'FjallaOne',
                                  ),
                                ),
                                const SizedBox(height: 10),

                                // Winners list
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: const Color(0xFF00B2FF)),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: _winnersHistory.isEmpty
                                      ? Container(
                                          padding: const EdgeInsets.all(16),
                                          width: double.infinity,
                                          child: const Center(
                                            child: Text(
                                              "Belum ada pemenang",
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontFamily: 'FjallaOne',
                                              ),
                                            ),
                                          ),
                                        )
                                      : ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: _winnersHistory.length,
                                          itemBuilder: (context, index) {
                                            final winner =
                                                _winnersHistory[index];
                                            final isCurrentUser =
                                                winner['participant_id'] ==
                                                    widget.participantId;

                                            return Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: isCurrentUser
                                                    ? Colors.yellow[50]
                                                    : null,
                                                border: index <
                                                        _winnersHistory.length -
                                                            1
                                                    ? Border(
                                                        bottom: BorderSide(
                                                          color: Colors
                                                              .grey.shade300,
                                                          width: 1,
                                                        ),
                                                      )
                                                    : null,
                                              ),
                                              child: Row(
                                                children: [
                                                  // Month indicator
                                                  Container(
                                                    width: 30,
                                                    height: 30,
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: Color(0xFF00B2FF),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        "${winner['month']}",
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily:
                                                              'FjallaOne',
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),

                                                  // Winner name
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          winner['winner_name'],
                                                          style: TextStyle(
                                                            color: isCurrentUser
                                                                ? Colors.green
                                                                : Colors
                                                                    .black87,
                                                            fontWeight:
                                                                isCurrentUser
                                                                    ? FontWeight
                                                                        .bold
                                                                    : FontWeight
                                                                        .normal,
                                                            fontFamily:
                                                                'FjallaOne',
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        if (winner['win_date'] !=
                                                                null &&
                                                            winner['win_date']
                                                                .toString()
                                                                .isNotEmpty)
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 2.0),
                                                            child: Text(
                                                              _formatWinDate(
                                                                  winner[
                                                                      'win_date']),
                                                              style:
                                                                  const TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontSize: 12,
                                                                fontFamily:
                                                                    'FjallaOne',
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),

                                                  // Trophy icon
                                                  const Icon(
                                                    Icons.emoji_events,
                                                    color: Colors.amber,
                                                    size: 24,
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                ),
                                const SizedBox(height: 20),

                                // Payment history table
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00B2FF),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10.0),
                                    child: Row(
                                      children: [
                                        // Bulan ke- column
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            alignment: Alignment.center,
                                            child: const Text(
                                              "Bulan ke-",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'FjallaOne',
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Status column
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            alignment: Alignment.center,
                                            child: const Text(
                                              "Status",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'FjallaOne',
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Waktu Pembayaran column
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            alignment: Alignment.center,
                                            child: const Text(
                                              "Waktu Pembayaran",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'FjallaOne',
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Payment rows
                                FutureBuilder<bool>(
                                  future: _isArisanCompleted(),
                                  builder: (context, snapshot) {
                                    final bool isCompleted =
                                        snapshot.data ?? false;
                                    // Jika arisan selesai, batasi hanya sampai total peserta
                                    final int maxMonth = isCompleted
                                        ? widget.totalParticipants
                                        : _monthlyPayments.length;

                                    return Column(
                                      children: List.generate(
                                        maxMonth,
                                        (index) {
                                          final payment =
                                              _monthlyPayments[index];
                                          return Container(
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: Colors.grey.shade300,
                                                  width: 1,
                                                ),
                                              ),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12.0),
                                              child: Row(
                                                children: [
                                                  // Bulan ke- column
                                                  Expanded(
                                                    flex: 1,
                                                    child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        "${payment['month']}",
                                                        style: const TextStyle(
                                                          color: Colors.black87,
                                                          fontFamily:
                                                              'FjallaOne',
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  // Status column
                                                  Expanded(
                                                    flex: 1,
                                                    child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 12,
                                                          vertical: 6,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: payment['paid']
                                                              ? Colors.green
                                                                  .shade100
                                                              : Colors
                                                                  .red.shade100,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                        ),
                                                        child: Text(
                                                          payment['paid']
                                                              ? "Sudah Bayar"
                                                              : "Belum Bayar",
                                                          style: TextStyle(
                                                            color: payment[
                                                                    'paid']
                                                                ? Colors.green
                                                                : Colors.red,
                                                            fontFamily:
                                                                'FjallaOne',
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  // Waktu Pembayaran column
                                                  Expanded(
                                                    flex: 2,
                                                    child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        payment['paid']
                                                            ? (payment[
                                                                    'paymentTime'] ??
                                                                '-')
                                                            : '-',
                                                        style: TextStyle(
                                                          color: payment['paid']
                                                              ? Colors.black87
                                                              : Colors.grey,
                                                          fontFamily:
                                                              'FjallaOne',
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ],
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
