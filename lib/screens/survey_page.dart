import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/auth/login_page.dart';
import 'package:flutter_application_1/screens/splash/survey_detail_page.dart';
import 'package:flutter_application_1/screens/survey_detail_page.dart';
import 'package:flutter_application_1/screens/splash/survey_form_page.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SurveyPage extends StatefulWidget {
  const SurveyPage({super.key, Map<String, dynamic>? survey});

  @override
  State<SurveyPage> createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  // 1. STATE VARIABEL
  List<Map<String, dynamic>> surveys = [];
  bool isLoading = true;
  String? errorMessage;

  static const Color primaryColor = Color(0xFF1E40AF);

  // 2. LIFECYCLE
  @override
  void initState() {
    super.initState();
    fetchSurveys();
  }

  // 3. REST API: MENGAMBIL DAFTAR SURVEY (GET)
  Future<void> fetchSurveys() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      if (token.isEmpty) {
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
        return;
      }

      final url = Uri.parse('https://sijala.biz.id/api/v1/surveys');
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 401) {
        await prefs.remove('token');
        await prefs.remove('user');
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
        return;
      }

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['status'] == true && result['data'] is List) {
          final List rawList = result['data'];
          if (!mounted) return;
          setState(() {
            surveys = rawList
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList();
            isLoading = false;
          });
          return;
        }
      }

      throw Exception('Gagal memuat daftar survey (Kode: ${response.statusCode})');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = 'Gagal mengambil data survey. Periksa koneksi Anda.';
      });
    }
  }

  // 4. NAVIGASI
  Future<void> openAddPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SurveyFormPage()),
    );

    if (result == true && mounted) {
      fetchSurveys();
    }
  }

  Future<void> openDetailPage(int surveyId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SurveyDetailPage(surveyId: surveyId),
      ),
    );

    if (result == true && mounted) {
      fetchSurveys();
    }
  }

  // 5. BUILD TAMPILAN WIDGET (UI)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Daftar Survey'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: openAddPage,
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget buildBody() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: primaryColor),
            SizedBox(height: 16),
            Text(
              'Memuat daftar survey...',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Color(0xFFEF4444),
              ),
              const SizedBox(height: 16),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: fetchSurveys,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (surveys.isEmpty) {
      return RefreshIndicator(
        color: primaryColor,
        onRefresh: fetchSurveys,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 120),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 64,
                    color: Color(0xFF94A3B8),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada data survey',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: primaryColor,
      onRefresh: fetchSurveys,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: surveys.length,
        itemBuilder: (context, index) {
          final item = surveys[index];
          final id = int.tryParse(item['id']?.toString() ?? '') ?? 0;
          final title = item['title']?.toString() ?? '-';
          final category = item['category_name']?.toString() ??
              item['category']?['name']?.toString() ??
              'Tanpa Kategori';
          final date = item['created_at']?.toString() ?? '-';

          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 12),
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      category,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: Color(0xFF94A3B8),
              ),
              onTap: () => openDetailPage(id),
            ),
          );
        },
      ),
    );
  }
}