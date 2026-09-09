import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/routes/app_routes.dart';
// import 'package:flutter_application_1/routes/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // ============================================================
  // API
  // ============================================================

  static const String baseUrl = 'https://sijala.biz.id/api/v1';
  static const String profileEndpoint = '$baseUrl/profile';

  // Endpoint gambar
  static const String imageEndpoint =
      'https://sijala.biz.id/api/image';

  // ============================================================
  // STATE
  // ============================================================

  Map<String, dynamic>? profile;
  Future<Uint8List?>? profileImageFuture;

  bool isLoading = true;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    getProfile();
  }

  // ============================================================
  // GET PROFILE
  // ============================================================

  Future<void> getProfile() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Ambil token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        throw Exception(
          'Token tidak ditemukan. Silakan login kembali.',
        );
      }

      // Request API
      final response = await http.get(
        Uri.parse(profileEndpoint),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // Decode JSON
      final data = jsonDecode(response.body);

      // Cek response
      if (response.statusCode == 200 && data['status'] == true) {
        final profileData =
            Map<String, dynamic>.from(data['data']);

        final photo = profileData['photo']?.toString();

        debugPrint('PROFILE PHOTO: $photo');

        setState(() {
          profile = profileData;

          if (photo != null && photo.isNotEmpty) {
            profileImageFuture = fetchProfileImage(photo);
          } else {
            profileImageFuture = null;
          }

          isLoading = false;
        });
      } else {
        throw Exception(
          data['message'] ?? 'Gagal mengambil data profile.',
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll('Exception: ', ''),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // GET PROFILE IMAGE
  // ============================================================

  Future<Uint8List?> fetchProfileImage(String fileName) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse('$imageEndpoint/$fileName'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      debugPrint('IMAGE URL: ${response.request?.url}');
      debugPrint('IMAGE STATUS: ${response.statusCode}');
      debugPrint(
        'IMAGE CONTENT TYPE: ${response.headers['content-type']}',
      );
      debugPrint(
        'IMAGE SIZE: ${response.bodyBytes.length}',
      );

      if (response.statusCode == 200 &&
          response.bodyBytes.isNotEmpty) {
        return response.bodyBytes;
      }

      return null;
    } catch (e) {
      debugPrint('IMAGE ERROR: $e');

      return null;
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    // 1. Tampilkan Dialog Konfirmasi
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text(
            'Apakah Anda yakin ingin keluar dari akun?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Keluar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (result != true) return;

    try {
      // 2. Ambil token dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // Jika token tidak ditemukan di lokal,
      // langsung hapus session dan ke halaman login
      if (token == null || token.isEmpty) {
        await prefs.remove('token');
        await prefs.remove('user');

        if (!mounted) return;

        context.go(AppRoutes.login);
        return;
      }

      // 3. Kirim Request POST ke API Backend
      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // 4. Periksa Status Response
      // 200 = Sukses
      // 401 = Token Expired/Revoked
      if (response.statusCode == 200 ||
          response.statusCode == 401) {

        // 5. Hapus Session Lokal
        await prefs.remove('token');
        await prefs.remove('user');

        if (!mounted) return;

        // Tampilkan snackbar sukses
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logout berhasil'),
            backgroundColor: Colors.green,
          ),
        );

        // 6. Navigasi kembali ke halaman Login
        context.go(AppRoutes.login);
      } else {
        // Tangani jika terjadi error di server
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logout gagal. Silakan coba lagi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Tangani jika tidak ada koneksi internet
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat terhubung ke server.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> handleRefresh() async {
    await getProfile();
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PROFILE CARD
  // ============================================================

  Widget profileCard() {
    if (profile == null) {
      return const Center(
        child: Text('Data profile tidak ditemukan.'),
      );
    }

    final name =
        profile!['name']?.toString() ?? '-';

    final username =
        profile!['username']?.toString() ?? '-';

    final photo =
        profile!['photo']?.toString();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: cardDecoration(),
      child: Column(
        children: [

          // ======================================================
          // FOTO
          // ======================================================

          CircleAvatar(
            radius: 42,
            backgroundColor: Colors.blue.shade50,
            child: photo != null && photo.isNotEmpty
                ? FutureBuilder<Uint8List?>(
                    future: profileImageFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        );
                      }

                      if (snapshot.hasData) {
                        return ClipOval(
                          child: Image.memory(
                            snapshot.data!,
                            width: 84,
                            height: 84,
                            fit: BoxFit.cover,
                          ),
                        );
                      }

                      return const Icon(
                        Icons.person,
                        size: 45,
                        color: Colors.blue,
                      );
                    },
                  )
                : const Icon(
                    Icons.person,
                    size: 45,
                    color: Colors.blue,
                  ),
          ),

          const SizedBox(height: 14),

          // ======================================================
          // NAMA
          // ======================================================

          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            '@$username',
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),

          const Divider(height: 30),

          // ======================================================
          // INFORMASI PROFILE
          // ======================================================

          infoRow(
            'Username',
            username,
          ),

          infoRow(
            'Email',
            profile!['email']?.toString() ?? '-',
          ),

          infoRow(
            'Nomor HP',
            profile!['phone']?.toString() ?? '-',
          ),

          infoRow(
            'Jenis Kelamin',
            profile!['gender']?.toString() ?? '-',
          ),

          infoRow(
            'Tempat Lahir',
            profile!['birth_place']?.toString() ?? '-',
          ),

          infoRow(
            'Tanggal Lahir',
            profile!['birth_date']?.toString() ?? '-',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACTION CARD
  // ============================================================

  Widget actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: cardDecoration(),
      child: ListTile(
        leading: Icon(
          icon,
          color: isLogout ? Colors.red : Colors.blue,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isLogout
                ? Colors.red
                : Colors.black87,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  // ============================================================
  // CARD DECORATION
  // ============================================================

  static BoxDecoration cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: handleRefresh,
          child: SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [

                // PROFILE
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  )
                else
                  profileCard(),

                const SizedBox(height: 16),

                // EDIT PROFILE
                actionCard(
                  icon: Icons.edit,
                  title: 'Edit Profil',
                  subtitle: 'Perbarui data diri',
                  onTap: () async {
                    final result = await context.push(
                      AppRoutes.editProfilPage,
                      extra: profile,
                    );

                    if (result == true) {
                      getProfile();
                    }
                  },
                ),

                // LOGOUT
                actionCard(
                  icon: Icons.logout,
                  title: 'Keluar',
                  subtitle: 'Logout dari akun',
                  isLogout: true,
                  onTap: logout,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}