import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:arisan_digitalv2/services/api_service.dart';
import 'package:arisan_digitalv2/core/api_config.dart';

class GachaPengelolaScreen extends StatefulWidget {
  final int groupId;
  final String groupName;
  final int currentMonth;
  final int userId;

  const GachaPengelolaScreen({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.currentMonth,
    required this.userId,
  });

  @override
  State<GachaPengelolaScreen> createState() => _GachaPengelolaScreenState();
}

class _GachaPengelolaScreenState extends State<GachaPengelolaScreen>
    with SingleTickerProviderStateMixin {
  // List of eligible participants
  List<Map<String, dynamic>> _participants = [];
  String _groupName = '';
  int _prizeAmount = 0;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isArisanCompleted = false;

  // Animation controller for spinning the wheel
  late AnimationController _animationController;
  late Animation<double> _animation = const AlwaysStoppedAnimation(0);
  final _random = Random();
  double _finalAngle = 0.0;
  bool _isSpinning = false;
  int _selectedParticipantIndex = -1;
  bool _winnerSubmitted = false;
  bool _submittingWinner = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCirc,
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isSpinning = false;
          // Calculate the winner based on the final angle
          if (_participants.isNotEmpty) {
            final segmentSize = 360.0 / _participants.length;
            final normalizedAngle = ((_finalAngle % 360) + 360) % 360;
            _selectedParticipantIndex =
                _participants.length - 1 - (normalizedAngle ~/ segmentSize);
            _selectedParticipantIndex =
                _selectedParticipantIndex % _participants.length;
          }
        });
      }
    });

    // Load participants
    _loadParticipants();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Load eligible participants from API
  Future<void> _loadParticipants() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      final data = await ApiService.getEligibleParticipants(
          widget.groupId, widget.currentMonth);

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

      // Check if arisan is completed
      if (data.containsKey('is_completed') && data['is_completed'] == true) {
        setState(() {
          _isArisanCompleted = true;
          _isLoading = false;
          _errorMessage = data['message'] ?? 'Arisan Selesai';
        });
        return;
      }

      // Parse participants
      if (data.containsKey('participants')) {
        final List<dynamic> participantsList = data['participants'];
        _participants = participantsList
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }

      // Get prize amount
      if (data.containsKey('prize_amount')) {
        _prizeAmount = data['prize_amount'];
      }

      setState(() {
        _groupName = widget.groupName;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Error loading participants: $e';
        _isLoading = false;
      });
    }
  }

  // Submit winner to API
  Future<bool> _submitWinner(int participantId) async {
    if (_submittingWinner) return false;

    setState(() {
      _submittingWinner = true;
    });

    try {
      final data = await ApiService.recordWinner(
          widget.groupId, participantId, widget.currentMonth);

      // After successfully submitting winner
      if (data['success'] == true) {
        setState(() {
          _submittingWinner = false;
          _winnerSubmitted = true;
          if (data.containsKey('is_completed') &&
              data['is_completed'] == true) {
            _isArisanCompleted = true;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Pemenang berhasil dicatat'),
            backgroundColor: Colors.green,
          ),
        );

        // Always return true when popping back to refresh previous screens
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pop(context, true);
          }
        });

        return true;
      } else {
        setState(() {
          _submittingWinner = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Gagal mencatat pemenang'),
            backgroundColor: Colors.red,
          ),
        );

        return false;
      }
    } catch (e) {
      setState(() {
        _submittingWinner = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );

      return false;
    }
  }

  // Function to start spinning the wheel
  void _spinWheel() {
    if (_isSpinning || _participants.isEmpty || _winnerSubmitted) return;

    setState(() {
      _isSpinning = true;
      _selectedParticipantIndex = -1;
      // Generate a random number of full rotations (3-5) plus a random angle
      final rotations = 3 + _random.nextInt(3);
      _finalAngle = (rotations * 360) + _random.nextDouble() * 360;

      _animation = Tween<double>(
        begin: 0.0,
        end: _finalAngle,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCirc,
      ));

      _animationController.reset();
      _animationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // When user presses back button, return true to indicate refresh needed
        Navigator.pop(context, true);
        return false; // Prevent default back behavior
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF00B2FF),
        appBar: AppBar(
          backgroundColor: const Color(0xFF00B2FF),
          title: const Text(
            'Kocok Arisan',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'FjallaOne',
              fontSize: 18,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            // Add refresh button
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              tooltip: 'Refresh Data',
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _selectedParticipantIndex = -1;
                  _winnerSubmitted = false;
                });
                _loadParticipants().then((_) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Data berhasil diperbarui'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                });
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 3,
                color: Colors.white,
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: Colors.white,
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF00B2FF)),
                          ),
                        )
                      : _isArisanCompleted
                          ? _buildArisanCompletedView()
                          : _hasError
                              ? _buildErrorView()
                              : _participants.isEmpty
                                  ? _buildNoParticipantsView()
                                  : _buildGachaView(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArisanCompletedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.emoji_events,
              color: Color(0xFFFFD700), // Gold color
              size: 80,
            ),
            const SizedBox(height: 24),
            const Text(
              'Arisan Selesai',
              style: TextStyle(
                color: Color(0xFF00B2FF),
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'FjallaOne',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Semua peserta telah mendapatkan giliran sebagai pemenang.',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 16,
                fontFamily: 'FjallaOne',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B2FF),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              icon: const Icon(Icons.history, color: Colors.white),
              label: const Text(
                'Lihat Histori Pemenang',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'FjallaOne',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Color(0xFF00B2FF),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: const TextStyle(
                color: Color(0xFF00B2FF),
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'FjallaOne',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
                fontFamily: 'FjallaOne',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadParticipants,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B2FF),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Coba Lagi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'FjallaOne',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoParticipantsView() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.people_alt_outlined,
              color: Color(0xFF00B2FF),
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Tidak Ada Peserta Eligible',
              style: TextStyle(
                color: Color(0xFF00B2FF),
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'FjallaOne',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Pastikan semua peserta telah membayar untuk bulan ini.',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
                fontFamily: 'FjallaOne',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadParticipants,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B2FF),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Refresh',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'FjallaOne',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGachaView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 30),
          // Nama Grup Arisan text centered at the top
          Text(
            _groupName,
            style: const TextStyle(
              color: Color(0xFF00B2FF),
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'FjallaOne',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // Current month text centered below the group name
          Text(
            "Bulan ke - ${widget.currentMonth}",
            style: const TextStyle(
              color: Color(0xFF00B2FF),
              fontSize: 18,
              fontWeight: FontWeight.w500,
              fontFamily: 'FjallaOne',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "Total Hadiah: Rp${_prizeAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
            style: const TextStyle(
              color: Color(0xFF00B2FF),
              fontSize: 16,
              fontFamily: 'FjallaOne',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Roulette wheel
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Wheel of fortune with pointer
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Spinning wheel
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: (_animation.value * pi / 180),
                          child: Container(
                            width: 280,
                            height: 280,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF00B2FF),
                                width: 3,
                              ),
                            ),
                            child: CustomPaint(
                              painter: RoulettePainter(
                                participants: _participants,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Center decoration
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: const Color(0xFF00B2FF),
                          width: 2,
                        ),
                      ),
                    ),

                    // Pointer
                    Positioned(
                      right: 0,
                      child: Container(
                        width: 40,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFD700),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Display winner
                if (_selectedParticipantIndex >= 0 &&
                    !_isSpinning &&
                    _participants.isNotEmpty)
                  Column(
                    children: [
                      const Text(
                        "Pemenang:",
                        style: TextStyle(
                          color: Color(0xFF00B2FF),
                          fontSize: 18,
                          fontFamily: 'FjallaOne',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${_participants[_selectedParticipantIndex]['name']}",
                        style: const TextStyle(
                          color: Color(0xFF00B2FF),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'FjallaOne',
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Submit winner button
                      if (!_winnerSubmitted)
                        ElevatedButton(
                          onPressed: _submittingWinner
                              ? null
                              : () async {
                                  await _submitWinner(
                                      _participants[_selectedParticipantIndex]
                                          ['id']);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            disabledBackgroundColor: Colors.grey,
                          ),
                          child: Text(
                            _submittingWinner
                                ? "Mengirim..."
                                : "Konfirmasi Pemenang",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'FjallaOne',
                            ),
                          ),
                        ),
                      if (_winnerSubmitted)
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Pemenang Tercatat",
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'FjallaOne',
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),

                const SizedBox(height: 20),

                // Spin button - always visible until a winner is selected
                if (_selectedParticipantIndex < 0 || _isSpinning)
                  ElevatedButton(
                    onPressed: (_isSpinning || _participants.isEmpty)
                        ? null
                        : _spinWheel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B2FF),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      disabledBackgroundColor: Colors.grey,
                    ),
                    child: Text(
                      _isSpinning ? "Memutar..." : "Putar",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'FjallaOne',
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for the roulette wheel
class RoulettePainter extends CustomPainter {
  final List<Map<String, dynamic>> participants;

  RoulettePainter({required this.participants});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final segmentAngle = 2 * pi / participants.length;

    // Define colors for alternating segments
    final colors = [
      const Color(0xFF00B2FF), // Primary blue
      const Color(0xFF80D8FF), // Lighter blue
    ];

    // Draw segments
    for (int i = 0; i < participants.length; i++) {
      final startAngle = i * segmentAngle;
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        segmentAngle,
        true,
        paint,
      );

      // Add participant names
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${participants[i]['name']}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'FjallaOne',
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout(maxWidth: radius);

      // Position the text within the segment
      final textAngle = startAngle + (segmentAngle / 2);
      final textRadius = radius * 0.7; // Position text at 70% of the radius

      canvas.save();
      canvas.translate(
        center.dx + textRadius * cos(textAngle),
        center.dy + textRadius * sin(textAngle),
      );
      canvas.rotate(textAngle + pi / 2); // Rotate text to be readable

      // Center the text
      canvas.translate(-textPainter.width / 2, -textPainter.height / 2);
      textPainter.paint(canvas, Offset.zero);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
