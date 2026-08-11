import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stateful Survey UI',
      theme: ThemeData(
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          primary: const Color(0xFF6366F1),
          surface: const Color(0xFFF8FAFC),
        ),
        useMaterial3: true,
      ),
      home: const SurveyPage(),
    );
  }
}

// Model Data Pertanyaan & Opsi
class SurveyQuestion {
  final String id;
  final String question;
  final String subtitle;
  final List<SurveyOption> options;

  SurveyQuestion({
    required this.id,
    required this.question,
    required this.subtitle,
    required this.options,
  });
}

class SurveyOption {
  final String label;
  final IconData icon;

  SurveyOption({required this.label, required this.icon});
}

// 1. Deklarasi StatefulWidget
class SurveyPage extends StatefulWidget {
  const SurveyPage({super.key});

  @override
  State<SurveyPage> createState() => _SurveyPageState();
}

// 2. Class State
class _SurveyPageState extends State<SurveyPage> {
  // Variable State
  int _currentIndex = 0;
  final Map<int, int> _selectedAnswers = {}; // {indexPertanyaan: indexOpsiTerpilih}

  // Data Soal
  final List<SurveyQuestion> _questions = [
    SurveyQuestion(
      id: 'q1',
      question: 'Seberapa sering Anda menggunakan aplikasi kami?',
      subtitle: 'Pilih satu opsi yang paling menggambarkan rutinitas Anda.',
      options: [
        SurveyOption(label: 'Setiap Hari', icon: Icons.bolt_rounded),
        SurveyOption(label: 'Beberapa Kali Seminggu', icon: Icons.calendar_today_rounded),
        SurveyOption(label: 'Jarang (1-2x Sebulan)', icon: Icons.history_toggle_off_rounded),
        SurveyOption(label: 'Baru Pertama Kali', icon: Icons.fiber_new_rounded),
      ],
    ),
    SurveyQuestion(
      id: 'q2',
      question: 'Fitur mana yang paling membantu pekerjaan Anda?',
      subtitle: 'Umpan balik ini membantu kami memprioritaskan pengembangan.',
      options: [
        SurveyOption(label: 'Manajemen Tugas', icon: Icons.task_alt_rounded),
        SurveyOption(label: 'Laporan Lanjutan', icon: Icons.analytics_rounded),
        SurveyOption(label: 'Kolaborasi Tim', icon: Icons.groups_rounded),
        SurveyOption(label: 'Integrasi API', icon: Icons.extension_rounded),
      ],
    ),
    SurveyQuestion(
      id: 'q3',
      question: 'Bagaimana pengalaman antarmuka (UI) kami?',
      subtitle: 'Beri penilaian singkat tentang kemudahan navigasi.',
      options: [
        SurveyOption(label: 'Sangat Nyaman & Elegan', icon: Icons.sentiment_very_satisfied_rounded),
        SurveyOption(label: 'Cukup Baik', icon: Icons.sentiment_satisfied_rounded),
        SurveyOption(label: 'Agak Membingungkan', icon: Icons.sentiment_neutral_rounded),
        SurveyOption(label: 'Perlu Banyak Perbaikan', icon: Icons.sentiment_dissatisfied_rounded),
      ],
    ),
  ];

  // Handler Lanjut / Selesai
  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      _showCompletionModal();
    }
  }

  // Handler Kembali
  void _prevQuestion() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  // Modal Dialog Selesai
  void _showCompletionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 64,
                color: Color(0xFF6366F1),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Terima Kasih!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Jawaban Anda telah tersimpan dan sangat berharga bagi kami.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _currentIndex = 0;
                    _selectedAnswers.clear();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Ulangi Survei',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQ = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;
    final isAnswered = _selectedAnswers.containsKey(_currentIndex);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentIndex > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A)),
                onPressed: _prevQuestion,
              )
            : null,
        title: const Text(
          'Survei Pengguna',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Dynamic Progress Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pertanyaan ${_currentIndex + 1} dari ${_questions.length}',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(
                      color: Color(0xFF6366F1),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: const Color(0xFFE2E8F0),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                ),
              ),

              const SizedBox(height: 28),

              // 2. Dynamic Card Pertanyaan
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.05, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    key: ValueKey<int>(_currentIndex),
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentQ.question,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          currentQ.subtitle,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // List Opsi Pilihan dengan State Aktif
                        Expanded(
                          child: ListView.separated(
                            itemCount: currentQ.options.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final option = currentQ.options[index];
                              final isSelected = _selectedAnswers[_currentIndex] == index;

                              return InkWell(
                                onTap: () {
                                  // Update State saat Opsi Dipilih
                                  setState(() {
                                    _selectedAnswers[_currentIndex] = index;
                                  });
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF6366F1).withOpacity(0.08)
                                        : const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF6366F1)
                                          : const Color(0xFFE2E8F0),
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? const Color(0xFF6366F1)
                                              : Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            if (!isSelected)
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.05),
                                                blurRadius: 6,
                                              ),
                                          ],
                                        ),
                                        child: Icon(
                                          option.icon,
                                          size: 20,
                                          color: isSelected ? Colors.white : const Color(0xFF64748B),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          option.label,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                            color: isSelected
                                                ? const Color(0xFF6366F1)
                                                : const Color(0xFF334155),
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        const Icon(
                                          Icons.check_circle_rounded,
                                          color: Color(0xFF6366F1),
                                          size: 22,
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
                ),
              ),

              const SizedBox(height: 20),

              // 3. Action Button (State Mengontrol Enabled/Disabled)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isAnswered ? _nextQuestion : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    disabledBackgroundColor: const Color(0xFFCBD5E1),
                    foregroundColor: Colors.white,
                    elevation: isAnswered ? 4 : 0,
                    shadowColor: const Color(0xFF6366F1).withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentIndex == _questions.length - 1 ? 'Kirim Survei' : 'Lanjutkan',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _currentIndex == _questions.length - 1
                            ? Icons.send_rounded
                            : Icons.arrow_forward_rounded,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}