import 'package:arisan_digitalv2/ui/screens/pengelola/gacha_pengelola_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:arisan_digitalv2/ui/screens/auth/login_screen.dart';
import 'package:arisan_digitalv2/ui/screens/pengelola/history_pengelola_screen.dart';
import 'package:arisan_digitalv2/services/api_service.dart';
import 'dart:convert';
import 'package:arisan_digitalv2/core/api_config.dart';

class GroupDetailsPengelolaScreen extends StatefulWidget {
  final int groupId;
  final String groupName;
  final int contributionAmount;
  final String startMonth;
  final int totalParticipants;
  final int currentMonth;
  final String username;
  final int userId;

  const GroupDetailsPengelolaScreen({
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
  State<GroupDetailsPengelolaScreen> createState() =>
      _GroupDetailsPengelolaScreenState();
}

class _GroupDetailsPengelolaScreenState
    extends State<GroupDetailsPengelolaScreen> {
  late String _userInitial;
  late String _currentGroupName;
  bool _isLoading = false;
  List<Map<String, dynamic>> _participants = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _userInitial =
        widget.username.isNotEmpty ? widget.username[0].toUpperCase() : 'U';
    _currentGroupName = widget.groupName;

    // Load group details and participants
    _loadGroupDetails();
    _loadParticipants();
  }

  void _loadGroupDetails() {
    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _currentGroupName = widget.groupName;
        _isLoading = false;
      });
    });
  }

  Future<void> _loadParticipants() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await ApiService.getParticipants(widget.groupId);

      if (data['status'] == 'success') {
        setState(() {
          _participants = List<Map<String, dynamic>>.from(data['data']);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = data['message'] ?? 'Gagal memuat data peserta';
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Navigate to payment history screen
  void _navigateToPaymentHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentHistoryScreen(
          groupId: widget.groupId,
          groupName: widget.groupName,
          contributionAmount: widget.contributionAmount,
          startMonth: widget.startMonth,
          totalParticipants: widget.totalParticipants,
          currentMonth: widget.currentMonth,
          username: widget.username,
          userId: widget.userId,
        ),
      ),
    ).then((_) {
      // Refresh data when returning from payment history
      _loadGroupDetails();
      _loadParticipants();
    });
  }

  // UI for showing add participant bottom sheet
  void _showAddParticipantDialog() {
    // Check if participant limit is reached
    if (_participants.length >= widget.totalParticipants) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jumlah peserta sudah mencapai batas maksimal'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final TextEditingController nameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SizedBox(
            height: 350, // Tinggi disesuaikan
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const Center(
                    child: Text(
                      "Tambah Peserta",
                      style: TextStyle(
                        color: Color(0xFF00B2FF),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'FjallaOne',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Nama Peserta",
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'FjallaOne',
                      color: Color(0xFF00B2FF),
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextField(
                    controller: nameController,
                    style: const TextStyle(
                      color: Color(0xFF00B2FF),
                      fontFamily: 'FjallaOne',
                    ),
                    decoration: _inputDecoration("Masukkan nama peserta"),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Password",
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'FjallaOne',
                      color: Color(0xFF00B2FF),
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    style: const TextStyle(
                      color: Color(0xFF00B2FF),
                      fontFamily: 'FjallaOne',
                    ),
                    decoration: _inputDecoration("Masukkan password"),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (nameController.text.trim().isEmpty ||
                            passwordController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Mohon lengkapi semua data'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        _addParticipant(
                          nameController.text.trim(),
                          passwordController.text.trim(),
                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B2FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        "Tambah",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'FjallaOne',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _addParticipant(String name, String password) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data =
          await ApiService.addParticipant(widget.groupId, name, password);

      if (data['status'] == 'success') {
        await _loadParticipants(); // Reload participants list

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? "Peserta berhasil ditambahkan"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? "Gagal menambahkan peserta"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // UI for showing edit group name bottom sheet
  void _showEditGroupNameDialog() {
    final TextEditingController nameController =
        TextEditingController(text: _currentGroupName);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SizedBox(
            height: 250,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const Center(
                    child: Text(
                      "Edit Nama Grup",
                      style: TextStyle(
                        color: Color(0xFF00B2FF),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'FjallaOne',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Nama Grup Arisan",
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'FjallaOne',
                      color: Color(0xFF00B2FF),
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextField(
                    controller: nameController,
                    style: const TextStyle(
                      color: Color(0xFF00B2FF),
                      fontFamily: 'FjallaOne',
                    ),
                    decoration: _inputDecoration("Masukkan nama grup"),
                  ),
                  const SizedBox(height: 20),
                  // Full-width button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (nameController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Nama grup tidak boleh kosong'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        _updateGroupName(nameController.text.trim());
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B2FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        "Simpan",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'FjallaOne',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _updateGroupName(String newName) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data =
          await ApiService.updateGroup(widget.userId, widget.groupId, newName);

      if (data['status'] == 'success') {
        setState(() {
          _currentGroupName = newName;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? "Nama grup berhasil diperbarui"),
              backgroundColor: Colors.green,
            ),
          );

          // Pop back to previous screen to refresh
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? "Gagal memperbarui nama grup"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // UI for showing group code dialog

  void _updatePaymentStatus(int participantId, bool paid) {
    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          for (var i = 0; i < _participants.length; i++) {
            if (_participants[i]['id'] == participantId) {
              _participants[i]['paid'] = paid;
              break;
            }
          }
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _deleteParticipant(int participantId) async {
    try {
      final data =
          await ApiService.deleteParticipant(widget.groupId, participantId);

      if (data['status'] == 'success') {
        await _loadParticipants(); // Reload participants list

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? "Peserta berhasil dihapus"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? "Gagal menghapus peserta"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Helper UI calculation functions for display
  int _calculateTotalCollected() {
    int paidCount =
        _participants.where((p) => p['payment_confirmed'] == true).length;
    return paidCount * widget.contributionAmount;
  }

  int _calculateTotalExpected() {
    return widget.totalParticipants * widget.contributionAmount;
  }

// Add the "Arisan Selesai" indicator to the group details screen
// Add this method to check if arisan is completed
  Future<bool> _checkArisanStatus() async {
    try {
      final data = await ApiService.checkArisanStatus(widget.groupId);
      return data['is_completed'] == true;
    } catch (e) {
      print('Error checking arisan status: $e');
      return false;
    }
  }

  // Add this method to check if the draw date has been set and reached
  Future<Map<String, dynamic>> _checkDrawDate() async {
    try {
      final data = await ApiService.checkDrawDate(widget.groupId);

      if (data['status'] != 'error') {
        return {
          'can_draw': data['can_draw'] == true,
          'draw_date': data['draw_date'] ?? 'Belum ditetapkan',
          'is_date_set': data['is_date_set'] == true
        };
      }
      return {
        'can_draw': false,
        'draw_date': 'Belum ditetapkan',
        'is_date_set': false
      };
    } catch (e) {
      print('Error checking draw date: $e');
      return {
        'can_draw': false,
        'draw_date': 'Error: $e',
        'is_date_set': false
      };
    }
  }

  // Add this method to set the draw date
  Future<bool> _setDrawDate(DateTime selectedDate) async {
    try {
      final data = await ApiService.setDrawDate(
          widget.groupId, selectedDate.toIso8601String(), widget.currentMonth);
      return data['status'] == 'success';
    } catch (e) {
      print('Error setting draw date: $e');
      return false;
    }
  }

  // Add this method to show the date picker dialog
  void _showDatePickerDialog() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1, now.month, now.day),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00B2FF),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF00B2FF),
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Show time picker after date is selected
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF00B2FF),
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Color(0xFF00B2FF),
              ),
              dialogBackgroundColor: Colors.white,
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        // Combine date and time
        final DateTime selectedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          _isLoading = true;
        });

        // Save the draw date
        final success = await _setDrawDate(selectedDateTime);

        setState(() {
          _isLoading = false;
        });

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tanggal pengundian berhasil ditetapkan'),
              backgroundColor: Colors.green,
            ),
          );
          // Refresh the page
          _loadGroupDetails();
          _loadParticipants();
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal menetapkan tanggal pengundian'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFF00B2FF),
          body: SafeArea(
            child: Column(
              children: [
                Column(
                  children: [
                    Container(
                      color: const Color(0xFF00B2FF),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          children: [
                            // Corrected Row in the header section of GroupDetailsPengelolaScreen
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
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
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Text(
                                            'Logo not found',
                                            style:
                                                TextStyle(color: Colors.white),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    // Add refresh button
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 16.0, right: 10.0),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.refresh,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isLoading = true;
                                          });

                                          // Refresh all data
                                          _loadGroupDetails();
                                          _loadParticipants().then((_) {
                                            if (mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Data berhasil diperbarui'),
                                                  backgroundColor: Colors.green,
                                                  duration:
                                                      Duration(seconds: 2),
                                                ),
                                              );
                                            }
                                          });
                                        },
                                        tooltip: 'Refresh Data',
                                      ),
                                    ),
                                    // User profile popup menu - align with the refresh button
                                    Padding(
                                      padding: const EdgeInsets.only(top: 16.0),
                                      child: PopupMenuButton<String>(
                                        offset: const Offset(0, 40),
                                        onSelected: (value) {
                                          if (value == 'logout') {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const LoginScreen()),
                                            );
                                          }
                                        },
                                        itemBuilder: (context) => [
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
                                        child: Row(
                                          children: [
                                            Container(
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
                                            const Icon(
                                              Icons.arrow_drop_down,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 3,
                      color: Colors.white,
                    ),
                  ],
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          // Group Name with Edit Icon and History Icon
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Left side - Group Name with Edit Icon
                              Expanded(
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        _currentGroupName,
                                        style: const TextStyle(
                                          color: Color(0xFF00B2FF),
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'FjallaOne',
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    GestureDetector(
                                      onTap: _showEditGroupNameDialog,
                                      child: const Icon(
                                        Icons.edit,
                                        color: Color(0xFF00B2FF),
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Right side - Icons (History and Share)
                              Row(
                                children: [
                                  // History Icon Button
                                  IconButton(
                                    icon: const Icon(
                                      Icons.history,
                                      color: Color(0xFF00B2FF),
                                      size: 20,
                                    ),
                                    onPressed: _navigateToPaymentHistory,
                                    tooltip: 'Histori Pembayaran',
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          // Jumlah Iuran and Bulan ke-x in the same row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Left side - Jumlah Iuran
                              Text(
                                "Iuran: Rp${NumberFormat('#,###').format(widget.contributionAmount)}",
                                style: const TextStyle(
                                  color: Color(0xFF00B2FF),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'FjallaOne',
                                ),
                              ),

                              // Right side - Month indicator or Arisan Selesai status
                              FutureBuilder<bool>(
                                  future: _checkArisanStatus(),
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
                                  }),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Jumlah Peserta and Add Participant
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Peserta: ${_participants.length} dari ${widget.totalParticipants}",
                                style: const TextStyle(
                                  color: Color(0xFF00B2FF),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'FjallaOne',
                                ),
                              ),
                              GestureDetector(
                                onTap: _showAddParticipantDialog,
                                behavior: HitTestBehavior.opaque,
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Row(
                                    children: [
                                      const Text(
                                        "Tambah Peserta",
                                        style: TextStyle(
                                          color: Color(0xFF00B2FF),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'FjallaOne',
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF00B2FF),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        padding: const EdgeInsets.all(2),
                                        child: const Icon(
                                          Icons.add,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Participant list section
                          Expanded(
                            child: _participants.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.people_alt_outlined,
                                          color: Color(0xFF00B2FF),
                                          size: 48,
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          "Belum ada peserta",
                                          style: TextStyle(
                                            color: Color(0xFF00B2FF),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'FjallaOne',
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          "Tambahkan peserta untuk mulai mengelola arisan",
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                            fontFamily: 'FjallaOne',
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 16),
                                        ElevatedButton(
                                          onPressed: _showAddParticipantDialog,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF00B2FF),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 10,
                                            ),
                                          ),
                                          child: const Text(
                                            "Tambah Peserta",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'FjallaOne',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Column(
                                    children: [
                                      // Table Header
                                      Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF00B2FF),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10.0),
                                          child: Row(
                                            children: [
                                              // No column
                                              Container(
                                                width: 40,
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  "No",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'FjallaOne',
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                              // Nama Peserta column
                                              Expanded(
                                                flex: 2,
                                                child: Container(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: const Text(
                                                    "Nama Peserta",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: 'FjallaOne',
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // Password column
                                              Expanded(
                                                flex: 2,
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  child: const Text(
                                                    "Password",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: 'FjallaOne',
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // Bayar Iuran column
                                              Expanded(
                                                flex: 2,
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  child: const Text(
                                                    "Bayar Iuran",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: 'FjallaOne',
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // Aksi column
                                              Container(
                                                width: 40,
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  "Aksi",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'FjallaOne',
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      // Table Body
                                      Expanded(
                                        child: ListView.builder(
                                          itemCount: _participants.length,
                                          itemBuilder: (context, index) {
                                            final participant =
                                                _participants[index];
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
                                                        vertical: 8.0),
                                                child: Row(
                                                  children: [
                                                    // No column
                                                    Container(
                                                      width: 40,
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        "${index + 1}",
                                                        style: const TextStyle(
                                                          color: Colors.black87,
                                                          fontFamily:
                                                              'FjallaOne',
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),
                                                    // Nama Peserta column
                                                    Expanded(
                                                      flex: 2,
                                                      child: Container(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          "${participant['name']}",
                                                          style:
                                                              const TextStyle(
                                                            color:
                                                                Colors.black87,
                                                            fontFamily:
                                                                'FjallaOne',
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    // Password column
                                                    Expanded(
                                                      flex: 2,
                                                      child: Container(
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                          "${participant['password']}",
                                                          style:
                                                              const TextStyle(
                                                            color:
                                                                Colors.black87,
                                                            fontFamily:
                                                                'FjallaOne',
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    // Bayar Iuran column
                                                    Expanded(
                                                      flex: 2,
                                                      child: Container(
                                                        alignment:
                                                            Alignment.center,
                                                        child: participant[
                                                                'payment_confirmed']
                                                            ? const Text(
                                                                "Sudah Bayar",
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .green,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontFamily:
                                                                      'FjallaOne',
                                                                  fontSize: 14,
                                                                ),
                                                              )
                                                            : FutureBuilder<
                                                                    bool>(
                                                                future:
                                                                    _checkArisanStatus(),
                                                                builder: (context,
                                                                    snapshot) {
                                                                  final bool
                                                                      isCompleted =
                                                                      snapshot.data ??
                                                                          false;

                                                                  return isCompleted
                                                                      ? const Text(
                                                                          "Belum Bayar",
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.red,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontFamily:
                                                                                'FjallaOne',
                                                                            fontSize:
                                                                                14,
                                                                          ),
                                                                        )
                                                                      : ElevatedButton(
                                                                          onPressed: () =>
                                                                              _showPaymentConfirmationDialog(participant['id']),
                                                                          style:
                                                                              ElevatedButton.styleFrom(
                                                                            backgroundColor:
                                                                                const Color(0xFF00B2FF),
                                                                            padding:
                                                                                const EdgeInsets.symmetric(
                                                                              horizontal: 12,
                                                                              vertical: 8,
                                                                            ),
                                                                            shape:
                                                                                RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(15),
                                                                            ),
                                                                          ),
                                                                          child:
                                                                              const Text(
                                                                            "Konfirmasi",
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize: 12,
                                                                              fontFamily: 'FjallaOne',
                                                                            ),
                                                                          ),
                                                                        );
                                                                }),
                                                      ),
                                                    ),
                                                    // Aksi column
                                                    Container(
                                                      width: 40,
                                                      alignment:
                                                          Alignment.center,
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          _deleteParticipant(
                                                              participant[
                                                                  'id']);
                                                        },
                                                        child: const Icon(
                                                          Icons.delete,
                                                          color:
                                                              Color(0xFF00B2FF),
                                                          size: 20,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                          ),

                          // Bottom section with Total Iuran and Kocok Arisan button
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Left side - Total Iuran
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Total Iuran (Saat Ini):",
                                      style: TextStyle(
                                        color: Color(0xFF00B2FF),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'FjallaOne',
                                      ),
                                    ),
                                    Text(
                                      "Rp${NumberFormat('#,###').format(_calculateTotalCollected())}",
                                      style: const TextStyle(
                                        color: Color(0xFF00B2FF),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'FjallaOne',
                                      ),
                                    ),
                                    Text(
                                      "dari Rp${NumberFormat('#,###').format(_calculateTotalExpected())}",
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                        fontFamily: 'FjallaOne',
                                      ),
                                    ),
                                  ],
                                ),

                                // Right side - Kocok Arisan button
                                // Update the FutureBuilder<bool> in groupdetailspengelola.dart
                                FutureBuilder<Map<String, dynamic>>(
                                  future: _checkDrawDate(),
                                  builder: (context, snapshot) {
                                    final Map<String, dynamic> drawDateData =
                                        snapshot.data ??
                                            {
                                              'can_draw': false,
                                              'draw_date': 'Memuat...',
                                              'is_date_set': false
                                            };

                                    // Debug information - print to console
                                    if (snapshot.hasData) {
                                      print('Draw date data: ${snapshot.data}');
                                      if (snapshot.data!
                                          .containsKey('now_time')) {
                                        print(
                                            'Current time: ${snapshot.data!['now_time']}');
                                        print(
                                            'Draw time: ${snapshot.data!['draw_time']}');
                                        print(
                                            'Current timestamp: ${snapshot.data!['now_timestamp']}');
                                        print(
                                            'Draw timestamp: ${snapshot.data!['draw_timestamp']}');
                                        print(
                                            'Can draw: ${snapshot.data!['can_draw']}');
                                      }
                                    }

                                    final bool isCompleted =
                                        snapshot.data?['is_completed'] ?? false;
                                    final bool canDraw =
                                        drawDateData['can_draw'] ?? false;
                                    final bool isDateSet =
                                        drawDateData['is_date_set'] ?? false;
                                    final String drawDate =
                                        drawDateData['draw_date'] ??
                                            'Memuat...';

                                    // Calculate if all requirements are met for enabling the draw button
                                    final bool hasEnoughParticipants =
                                        _participants.length >=
                                            widget.totalParticipants;
                                    final bool allParticipantsPaid =
                                        _participants.isNotEmpty &&
                                            _participants.every((p) =>
                                                p['payment_confirmed'] == true);

                                    if (isCompleted) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.green, width: 2),
                                          borderRadius:
                                              BorderRadius.circular(25),
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius:
                                                BorderRadius.circular(23),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.emoji_events,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                "Arisan Selesai",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'FjallaOne',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }

                                    // Jika belum selesai, baru tampilkan tombol dan status tanggal
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        ElevatedButton(
                                          onPressed: _showDatePickerDialog,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF00B2FF),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                          ),
                                          child: Text(
                                            isDateSet
                                                ? "Ubah Tanggal"
                                                : "Tetapkan Tanggal",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'FjallaOne',
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.calendar_today,
                                              size: 14,
                                              color: isDateSet
                                                  ? Colors.green
                                                  : Colors.grey.shade600,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              isDateSet
                                                  ? "Pengundian: $drawDate"
                                                  : "Tanggal pengundian belum ditetapkan",
                                              style: TextStyle(
                                                color: isDateSet
                                                    ? Colors.green
                                                    : Colors.grey.shade600,
                                                fontSize: 12,
                                                fontWeight: isDateSet
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                                fontFamily: 'FjallaOne',
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        // Show the "Kocok Arisan" button with appropriate state
                                        if (isDateSet) // Only show this button if date is set
                                          ElevatedButton(
                                            onPressed: (canDraw &&
                                                    hasEnoughParticipants &&
                                                    allParticipantsPaid)
                                                ? () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            GachaPengelolaScreen(
                                                          groupId:
                                                              widget.groupId,
                                                          groupName:
                                                              widget.groupName,
                                                          currentMonth: widget
                                                              .currentMonth,
                                                          userId: widget.userId,
                                                        ),
                                                      ),
                                                    ).then((value) {
                                                      // Always refresh data when returning from gacha screen
                                                      _loadGroupDetails();
                                                      _loadParticipants();
                                                    });
                                                  }
                                                : null,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: (canDraw &&
                                                      hasEnoughParticipants &&
                                                      allParticipantsPaid)
                                                  ? const Color(0xFF00B2FF)
                                                  : Colors.grey,
                                              disabledBackgroundColor:
                                                  Colors.grey,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 20,
                                                vertical: 12,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                            ),
                                            child: Text(
                                              !hasEnoughParticipants
                                                  ? "Kurang Peserta"
                                                  : !allParticipantsPaid
                                                      ? "Belum Lunas"
                                                      : !canDraw
                                                          ? "Menunggu Tanggal"
                                                          : "Kocok Arisan",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'FjallaOne',
                                              ),
                                            ),
                                          ),

                                        // Show status message below the button
                                        if (isDateSet)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4.0),
                                            child: Text(
                                              !hasEnoughParticipants
                                                  ? "Tambahkan ${widget.totalParticipants - _participants.length} peserta lagi"
                                                  : !allParticipantsPaid
                                                      ? "Semua peserta harus membayar"
                                                      : !canDraw
                                                          ? "Pengundian pada $drawDate"
                                                          : "Siap untuk pengundian!",
                                              style: TextStyle(
                                                color: (canDraw &&
                                                        hasEnoughParticipants &&
                                                        allParticipantsPaid)
                                                    ? Colors.green
                                                    : Colors.grey.shade600,
                                                fontSize: 12,
                                                fontFamily: 'FjallaOne',
                                              ),
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Loading overlay
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            width: double.infinity,
            height: double.infinity,
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00B2FF)),
              ),
            ),
          ),
      ],
    );
  }

  // Input decoration helper for consistent text fields
  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey[400], fontFamily: 'FjallaOne'),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF00B2FF)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF00B2FF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF00B2FF), width: 2),
      ),
    );
  }

  // Tambahkan fungsi untuk menampilkan dialog konfirmasi pembayaran
  void _showPaymentConfirmationDialog(int participantId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Konfirmasi Pembayaran',
          style: TextStyle(
            color: Color(0xFF00B2FF),
            fontFamily: 'FjallaOne',
          ),
        ),
        content: const Text(
          'Apakah Anda yakin peserta ini sudah membayar iuran?',
          style: TextStyle(
            fontFamily: 'FjallaOne',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Batal',
              style: TextStyle(
                color: Color(0xFF00B2FF),
                fontFamily: 'FjallaOne',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _confirmPayment(participantId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B2FF),
            ),
            child: const Text(
              'Konfirmasi',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'FjallaOne',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk mengkonfirmasi pembayaran
  Future<void> _confirmPayment(int participantId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await ApiService.updatePayment(
          widget.groupId, participantId, 'update_payment');

      if (data['status'] == 'success') {
        await _loadParticipants(); // Reload participants list

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(data['message'] ?? 'Pembayaran berhasil dikonfirmasi'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(data['message'] ?? 'Gagal mengkonfirmasi pembayaran'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
