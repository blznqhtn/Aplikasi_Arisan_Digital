import 'dart:convert';
import 'package:arisan_digitalv2/ui/screens/pengelola/group_details_pengelola_screen.dart';
import 'package:flutter/material.dart';
import 'package:arisan_digitalv2/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:arisan_digitalv2/core/api_config.dart';
import 'package:arisan_digitalv2/ui/screens/auth/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:arisan_digitalv2/providers/user_provider.dart';
import 'package:arisan_digitalv2/providers/group_provider.dart';

class HomePengelolaScreen extends StatefulWidget {
  const HomePengelolaScreen({super.key});

  @override
  State<HomePengelolaScreen> createState() => _HomePengelolaScreenState();
}

class _HomePengelolaScreenState extends State<HomePengelolaScreen> {
  late String _userInitial;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final userProvider = context.read<UserProvider>();
    _userInitial = _getUserInitial(userProvider.username ?? 'U');
    
    // Fetch groups using GroupProvider after layout is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (userProvider.userId != null) {
        context.read<GroupProvider>().fetchGroups(userProvider.userId!);
      }
    });
  }

  // Method to get the first letter of username
  String _getUserInitial(String username) {
    if (username.isNotEmpty) {
      return username[0].toUpperCase();
    }
    return 'U'; // Default if username is empty
  }

  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
    });

    // Navigate to login screen and remove all previous routes
    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false, // Remove all previous routes
      );
    }
  }

  void _showAddGroupDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController contributionController =
        TextEditingController();
    final TextEditingController startMonthController = TextEditingController();
    final TextEditingController participantsController =
        TextEditingController();

    // Validate form inputs
    bool _validateInputs() {
      if (nameController.text.isEmpty ||
          contributionController.text.isEmpty ||
          startMonthController.text.isEmpty ||
          participantsController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mohon lengkapi semua data'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }

      // Validate contribution is a number
      try {
        int.parse(contributionController.text);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jumlah iuran harus berupa angka'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }

      // Validate participants is a number
      try {
        int.parse(participantsController.text);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jumlah peserta harus berupa angka'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }

      return true;
    }

    // Function to show the month picker
    Future<void> _selectMonthYear(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
        initialDatePickerMode: DatePickerMode.year,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF00B2FF),
                onPrimary: Colors.white,
                onSurface: Color(0xFF00B2FF),
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF00B2FF),
                ),
              ),
            ),
            child: child!,
          );
        },
      );

      if (picked != null) {
        String formattedDate = DateFormat('MMMM yyyy').format(picked);
        setState(() {
          startMonthController.text = formattedDate;
        });
      }
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
            height: 400,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: SingleChildScrollView(
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
                        "Tambah Grup Arisan",
                        style: TextStyle(
                          color: Color(0xFF00B2FF),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'FjallaOne',
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 8),
                    const Text(
                      "Jumlah Iuran",
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'FjallaOne',
                        color: Color(0xFF00B2FF),
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextField(
                      controller: contributionController,
                      style: const TextStyle(
                        color: Color(0xFF00B2FF),
                        fontFamily: 'FjallaOne',
                      ),
                      keyboardType: TextInputType.number,
                      decoration:
                          _inputDecoration("Masukkan jumlah iuran (angka)"),
                    ),
                    const SizedBox(height: 8),

                    // Side-by-side fields for "Mulai Bulan" and "Jumlah Peserta"
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left column - Mulai Bulan
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Mulai Bulan",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'FjallaOne',
                                  color: Color(0xFF00B2FF),
                                ),
                              ),
                              const SizedBox(height: 5),
                              TextField(
                                controller: startMonthController,
                                style: const TextStyle(
                                  color: Color(0xFF00B2FF),
                                  fontFamily: 'FjallaOne',
                                ),
                                readOnly: true, // Make the text field read-only
                                decoration:
                                    _inputDecoration("Bulan mulai").copyWith(
                                  suffixIcon: const Icon(
                                    Icons.calendar_today,
                                    color: Color(0xFF00B2FF),
                                    size: 20,
                                  ),
                                ),
                                onTap: () {
                                  _selectMonthYear(
                                      context); // Show date picker on tap
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Right column - Jumlah Peserta
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Jumlah Peserta",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'FjallaOne',
                                  color: Color(0xFF00B2FF),
                                ),
                              ),
                              const SizedBox(height: 5),
                              TextField(
                                controller: participantsController,
                                style: const TextStyle(
                                  color: Color(0xFF00B2FF),
                                  fontFamily: 'FjallaOne',
                                ),
                                keyboardType: TextInputType.number,
                                decoration:
                                    _inputDecoration("Jumlah peserta (angka)"),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    // Full-width button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          // Validate and submit form data
                          if (_validateInputs()) {
                            // Add group through API
                            await _createGroup(
                              nameController.text,
                              int.parse(contributionController.text),
                              startMonthController.text,
                              int.parse(participantsController.text),
                            );
                            Navigator.pop(context); // Close the bottom sheet
                          }
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
          ),
        );
      },
    );
  }

  // Create a new group via API
  Future<void> _createGroup(String name, int contribution, String startMonth,
      int participants) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = context.read<UserProvider>();
      final data = await ApiService.createGroup(
        userProvider.userId ?? 0,
        name,
        contribution,
        startMonth,
        participants,
      );

      if (mounted) {
        if (data['status'] == 'success') {
          await context.read<GroupProvider>().refreshGroupsSilent(context.read<UserProvider>().userId ?? 0); // Reload groups after successful creation

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? "Grup berhasil ditambahkan"),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? "Gagal menambahkan grup"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
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

  // Delete a group via API
  Future<void> _deleteGroup(int groupId) async {
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
          'Apakah Anda yakin ingin menghapus grup ini?',
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
    ).then((confirmed) async {
      if (confirmed == true) {
        setState(() {
          _isLoading = true;
        });

        try {
          final userProvider = context.read<UserProvider>();
          final data = await ApiService.deleteGroup(userProvider.userId ?? 0, groupId);

          if (data['status'] == 'success') {
            // Refresh the groups list via provider
            await context.read<GroupProvider>().refreshGroupsSilent(userProvider.userId ?? 0);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(data['message'] ?? "Grup berhasil dihapus"),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(data['message'] ?? "Gagal menghapus grup"),
                backgroundColor: Colors.red,
              ),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error: $e"),
              backgroundColor: Colors.red,
            ),
          );
          print('Error in deleteGroup: $e');
        } finally {
          setState(() {
            _isLoading = false;
          });
        }
      }
    });
  }

  // Update group name via API
  Future<void> _updateGroupName(int groupId, String newName) async {
    setState(() {
      _isLoading = true;
    });

    try {
      print(
          'Sending update request - Group ID: $groupId, New Name: $newName'); // Debug log

      final userProvider = context.read<UserProvider>();
      final data =
          await ApiService.updateGroup(userProvider.userId ?? 0, groupId, newName);

      if (mounted) {
        if (data['status'] == 'success') {
          // Reload groups to get fresh data instead of updating locally
          await context.read<GroupProvider>().refreshGroupsSilent(context.read<UserProvider>().userId ?? 0);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? "Nama grup berhasil diperbarui"),
              backgroundColor: Colors.green,
            ),
          );
        } else {
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
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('Error updating group name: $e'); // Debug log
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Add this method to check if arisan is completed
  Future<bool> _isArisanCompleted(int groupId) async {
    try {
      final data = await ApiService.checkArisanStatus(groupId);
      return data['is_completed'] == true;
    } catch (e) {
      print('Error checking arisan status: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = context.watch<GroupProvider>();
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
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: PopupMenuButton<String>(
                                    offset: const Offset(0, 40),
                                    onSelected: (value) {
                                      if (value == 'logout') {
                                        _logout(); // Call the logout method
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
                                "Buat Grup Arisan",
                                style: TextStyle(
                                  color: Color(0xFF00B2FF),
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'FjallaOne',
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  _showAddGroupDialog(context);
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

                          // Display loading indicator, error message, or list of groups
                          Expanded(
                            child: groupProvider.isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Color(0xFF00B2FF)),
                                    ),
                                  )
                                : groupProvider.errorMessage.isNotEmpty &&
                                        groupProvider.groups.isEmpty
                                    ? Center(
                                        child: Text(
                                          groupProvider.errorMessage,
                                          style: const TextStyle(
                                            color: Color(0xFF00B2FF),
                                            fontSize: 16,
                                            fontFamily: 'FjallaOne',
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      )
                                    : groupProvider.groups.isEmpty
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
                                                  "Buat grup arisan baru dengan menekan tombol + di atas",
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
                                                    _showAddGroupDialog(
                                                        context);
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color(0xFF00B2FF),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    "Buat Grup",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontFamily: 'FjallaOne',
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : RefreshIndicator(
                                            onRefresh: () async {
                                              await context.read<GroupProvider>().refreshGroupsSilent(context.read<UserProvider>().userId ?? 0);
                                              // Show a confirmation snackbar
                                              if (mounted) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'Data berhasil diperbarui'),
                                                    backgroundColor:
                                                        Colors.green,
                                                    duration:
                                                        Duration(seconds: 2),
                                                  ),
                                                );
                                              }
                                            },
                                            color: const Color(0xFF00B2FF),
                                            child: ListView.builder(
                                              itemCount: groupProvider.groups.length,
                                              itemBuilder: (context, index) {
                                                final group =
                                                    groupProvider.groups[index];
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 16.0),
                                                  child: Container(
                                                    height: 135,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      border: Border.all(
                                                        color: const Color(
                                                            0xFF00B2FF),
                                                        width: 2,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                    child: Material(
                                                      color: Colors.transparent,
                                                      child: InkWell(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  GroupDetailsPengelolaScreen(
                                                                groupId:
                                                                    group['id'],
                                                                groupName: group[
                                                                    'group_name'],
                                                                contributionAmount:
                                                                    group[
                                                                        'contribution_amount'],
                                                                startMonth: group[
                                                                    'start_month'],
                                                                totalParticipants:
                                                                    group[
                                                                        'total_participants'],
                                                                currentMonth: group[
                                                                    'current_month'],
                                                                username: context.read<UserProvider>().username ?? '',
                                                                userId: context.read<UserProvider>().userId ?? 0,
                                                              ),
                                                            ),
                                                          ).then((_) {
                                                            // Always refresh data when returning from group details
                                                            context.read<GroupProvider>().refreshGroupsSilent(context.read<UserProvider>().userId ?? 0);
                                                          });
                                                        },
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      12.0,
                                                                  vertical:
                                                                      6.0),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
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
                                                                      fontSize:
                                                                          20,
                                                                      fontFamily:
                                                                          'FjallaOne',
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                    ),
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    maxLines: 1,
                                                                  ),
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      _deleteGroup(
                                                                          group[
                                                                              'id']);
                                                                    },
                                                                    behavior:
                                                                        HitTestBehavior
                                                                            .opaque,
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                      child: Image
                                                                          .asset(
                                                                        'assets/delete.png',
                                                                        width:
                                                                            20,
                                                                        height:
                                                                            20,
                                                                        fit: BoxFit
                                                                            .contain,
                                                                        errorBuilder: (context,
                                                                            error,
                                                                            stackTrace) {
                                                                          return const Icon(
                                                                              Icons.delete,
                                                                              color: Color(0xFF00B2FF),
                                                                              size: 20);
                                                                        },
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                  height: 6),
                                                              // Group details - first row
                                                              // In homepengelola.dart Row section
                                                              Row(
                                                                children: [
                                                                  Expanded(
                                                                    child:
                                                                        FutureBuilder<
                                                                            bool>(
                                                                      future: _isArisanCompleted(
                                                                          group[
                                                                              'id']),
                                                                      builder:
                                                                          (context,
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
                                                                                ? Colors.green
                                                                                : const Color(0xFF00B2FF),
                                                                            fontSize:
                                                                                14,
                                                                            fontFamily:
                                                                                'FjallaOne',
                                                                            fontWeight:
                                                                                FontWeight.w500,
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
                                                                        fontSize:
                                                                            14,
                                                                        fontFamily:
                                                                            'FjallaOne',
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                  height: 4),
                                                              Text(
                                                                "Iuran: Rp${NumberFormat('#,###').format(group['contribution_amount'])}",
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
                          )
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
}
