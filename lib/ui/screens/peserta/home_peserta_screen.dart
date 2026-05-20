import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:arisan_digitalv2/ui/screens/peserta/group_details_peserta_screen.dart';
import 'package:arisan_digitalv2/services/api_service.dart';
import 'package:arisan_digitalv2/core/api_config.dart';

class HomePesertaScreen extends StatefulWidget {
  final String username;
  final int userId;

  const HomePesertaScreen({
    super.key,
    this.username = 'Tamu',
    this.userId = 0,
  });

  @override
  State<HomePesertaScreen> createState() => _HomePesertaScreenState();
}

class _HomePesertaScreenState extends State<HomePesertaScreen> {
  late String _userInitial;
  bool _isLoading = false;
  List<Map<String, dynamic>> _userGroups = [];

  @override
  void initState() {
    super.initState();
    _userInitial = _getUserInitial(widget.username);
    // Initialize empty groups list
    _userGroups = [];
  }

  // Method to get the first letter of username
  String _getUserInitial(String username) {
    if (username.isNotEmpty) {
      return username[0].toUpperCase();
    }
    return 'U'; // Default if username is empty
  }

  void _logout() {
    setState(() {
      _isLoading = true;
    });

    // Simulate logout process
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Navigate back to main screen
        Navigator.pop(context);
      }
    });
  }

  void _showLoginDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    // Validate input fields
    bool _validateInput() {
      if (nameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mohon masukkan nama peserta'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
      if (passwordController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mohon masukkan password'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
      return true;
    }

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
            height: 320, // Height for the bottom sheet
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
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
                      "Masuk ke Grup Arisan",
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
                  const SizedBox(height: 12),
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
                  const SizedBox(height: 16),
                  // Full-width button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Validate and submit form data
                        if (_validateInput()) {
                          _loginAsParticipant(
                            nameController.text.trim(),
                            passwordController.text.trim(),
                          );
                          Navigator.pop(context); // Close the bottom sheet
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B2FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        minimumSize: const Size(double.infinity, 45),
                      ),
                      child: const Text(
                        "Masuk",
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

  // Method to verify participant login
  Future<void> _loginAsParticipant(String name, String password) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await ApiService.loginParticipant(name, password);

      if (data['status'] == 'success') {
        // Extract group data
        final groupData = data['data'];

        // Add to user's groups if not already present
        setState(() {
          // Check if the group is already in the list
          if (!_userGroups
              .any((group) => group['id'] == groupData['group_id'])) {
            _userGroups.add({
              'id': groupData['group_id'],
              'group_name': groupData['group_name'],
              'contribution_amount': groupData['contribution_amount'],
              'start_month': groupData['start_month'],
              'total_participants': groupData['total_participants'],
              'current_month': groupData['current_month'],
              'participant_name': name,
              'participant_id': groupData['participant_id'],
            });
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Berhasil masuk ke grup arisan'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to the group details
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GroupDetailsPesertaScreen(
              groupId: groupData['group_id'],
              groupName: groupData['group_name'],
              contributionAmount: groupData['contribution_amount'],
              startMonth: groupData['start_month'] ?? 'Januari 2024',
              totalParticipants: groupData['total_participants'],
              currentMonth: groupData['current_month'],
              username: name,
              participantId: groupData['participant_id'],
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(data['message'] ?? 'Nama peserta atau password salah'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Delete a group from user's list
  void _deleteGroup(int groupId) {
    // Show a confirmation dialog
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Hapus Grup',
          style: TextStyle(
            color: Color(0xFF00B2FF),
            fontFamily: 'FjallaOne',
          ),
        ),
        content: const Text(
          'Apakah Anda yakin ingin menghapus grup ini dari daftar Anda?',
          style: TextStyle(
            fontFamily: 'FjallaOne',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Batal',
              style: TextStyle(
                color: Color(0xFF00B2FF),
                fontFamily: 'FjallaOne',
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Hapus',
              style: TextStyle(
                color: Colors.red,
                fontFamily: 'FjallaOne',
              ),
            ),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        setState(() {
          _userGroups.removeWhere((group) => group['id'] == groupId);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Grup berhasil dihapus dari daftar"),
              backgroundColor: Colors.green,
            ),
          );
        });
      }
    });
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
                Container(
                  color: const Color(0xFF00B2FF),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Image.asset(
                                'assets/logo.png',
                                width: 63,
                                height: 36,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Text(
                                    'Logo not found',
                                    style: TextStyle(color: Colors.white),
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: PopupMenuButton<String>(
                                offset: const Offset(0, 40),
                                onSelected: (value) {
                                  if (value == 'logout') {
                                    _logout();
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
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 28),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Gabung Grup Arisan",
                                style: TextStyle(
                                  color: Color(0xFF00B2FF),
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'FjallaOne',
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  _showLoginDialog(context);
                                },
                                child: const Icon(
                                  Icons.add,
                                  color: Color(0xFF00B2FF),
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Display groups
                          Expanded(
                            child: _userGroups.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.group_off,
                                          color: Color(0xFF00B2FF),
                                          size: 48,
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          "Anda belum memiliki grup arisan",
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
                                          "Masuk ke grup arisan dengan menekan tombol + di atas",
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                            fontFamily: 'FjallaOne',
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 16),
                                        ElevatedButton(
                                          onPressed: () {
                                            _showLoginDialog(context);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF00B2FF),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                          ),
                                          child: const Text(
                                            "Masuk ke Grup",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'FjallaOne',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: _userGroups.length,
                                    itemBuilder: (context, index) {
                                      final group = _userGroups[index];
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 16.0),
                                        child: Container(
                                          height: 125,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(
                                              color: const Color(0xFF00B2FF),
                                              width: 2,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        GroupDetailsPesertaScreen(
                                                      groupId: group['id'],
                                                      groupName:
                                                          group['group_name'],
                                                      contributionAmount: group[
                                                          'contribution_amount'],
                                                      startMonth: group[
                                                              'start_month'] ??
                                                          '',
                                                      totalParticipants: group[
                                                          'total_participants'],
                                                      currentMonth: group[
                                                          'current_month'],
                                                      username: group[
                                                              'participant_name'] ??
                                                          widget.username,
                                                      participantId: group[
                                                          'participant_id'],
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12.0,
                                                        vertical: 6.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          group['group_name'] ??
                                                              "Nama Grup Arisan",
                                                          style:
                                                              const TextStyle(
                                                            color: Color(
                                                                0xFF00B2FF),
                                                            fontSize: 20,
                                                            fontFamily:
                                                                'FjallaOne',
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 1,
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            _deleteGroup(
                                                                group['id']);
                                                          },
                                                          behavior:
                                                              HitTestBehavior
                                                                  .opaque,
                                                          child: const Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    8.0),
                                                            child: Icon(
                                                              Icons.delete,
                                                              color: Color(
                                                                  0xFF00B2FF),
                                                              size: 20,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 6),
                                                    // Group details
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: FutureBuilder<
                                                              bool>(
                                                            future:
                                                                _isArisanCompleted(
                                                                    group[
                                                                        'id']),
                                                            builder: (context,
                                                                snapshot) {
                                                              final bool
                                                                  isCompleted =
                                                                  snapshot.data ??
                                                                      false;
                                                              return Text(
                                                                isCompleted
                                                                    ? "Arisan Selesai"
                                                                    : "Bulan ke - ${group['current_month'] ?? 1}",
                                                                style:
                                                                    TextStyle(
                                                                  color: isCompleted
                                                                      ? Colors
                                                                          .green
                                                                      : const Color(
                                                                          0xFF00B2FF),
                                                                  fontSize: 14,
                                                                  fontFamily:
                                                                      'FjallaOne',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            "Peserta: ${group['total_participants'] ?? 0}",
                                                            style:
                                                                const TextStyle(
                                                              color: Color(
                                                                  0xFF00B2FF),
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'FjallaOne',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      "Iuran: Rp${NumberFormat('#,###').format(group['contribution_amount'])}",
                                                      style: const TextStyle(
                                                        color:
                                                            Color(0xFF00B2FF),
                                                        fontSize: 14,
                                                        fontFamily: 'FjallaOne',
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    // Add participant name below the contribution
                                                    Text(
                                                      "Nama Peserta: ${group['participant_name'] ?? 'Tidak Diketahui'}",
                                                      style: const TextStyle(
                                                        color:
                                                            Color(0xFF00B2FF),
                                                        fontSize: 14,
                                                        fontFamily: 'FjallaOne',
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
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
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: const Color(0xFF00B2FF).withOpacity(0.4),
        fontFamily: 'FjallaOne',
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Color(0xFF00B2FF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Color(0xFF00B2FF), width: 2),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Color(0xFF00B2FF)),
      ),
    );
  }

  Future<bool> _isArisanCompleted(int groupId) async {
    try {
      final data = await ApiService.checkArisanStatus(groupId);
      return data['is_completed'] == true;
    } catch (e) {
      print('Error checking arisan status: $e');
      return false;
    }
  }
}
