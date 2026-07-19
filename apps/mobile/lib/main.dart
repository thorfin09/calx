import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const CalxApp());
}

class CalxApp extends StatefulWidget {
  const CalxApp({super.key});

  @override
  State<CalxApp> createState() => _CalxAppState();
}

class _CalxAppState extends State<CalxApp> {
  ThemeMode _themeMode = ThemeMode.light;
  String _lang = 'en';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('calx_theme') ?? 'light';
    final savedLang = prefs.getString('calx_lang') ?? 'en';
    setState(() {
      _themeMode = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
      _lang = savedLang;
    });
  }

  void toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_themeMode == ThemeMode.light) {
        _themeMode = ThemeMode.dark;
        prefs.setString('calx_theme', 'dark');
      } else {
        _themeMode = ThemeMode.light;
        prefs.setString('calx_theme', 'light');
      }
    });
  }

  void setLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lang = lang;
      prefs.setString('calx_lang', lang);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calx — Math Trainer',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        primaryColor: const Color(0xFF171717),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF171717),
          secondary: Color(0xFF4D4D4D),
          surface: Color(0xFFFFFFFF),
          error: Color(0xFFEF4444),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFFFFFFFF),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFEBEBEB), width: 1),
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        primaryColor: const Color(0xFFEDEDED),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFEDEDED),
          secondary: Color(0xFFA0A0A0),
          surface: Color(0xFF000000),
          error: Color(0xFFEF4444),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF000000),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFF222222), width: 1),
          ),
        ),
      ),
      home: DashboardScreen(
        lang: _lang,
        themeMode: _themeMode,
        onToggleTheme: toggleTheme,
        onSetLanguage: setLanguage,
      ),
    );
  }
}

// Translations map matching web translations
final Map<String, Map<String, String>> _translations = {
  'en': {
    'workout': 'Mental Math Workout',
    'workoutDesc': 'Sharpen your quantitative calculations with timed daily drills.',
    'topicLabel': 'Arithmetic Topic',
    'levelLabel': 'Difficulty Tier',
    'durationLabel': 'Session Duration',
    'startBtn': 'Start Practice Run',
    'exitBtn': 'Exit Drill',
    'reportCard': 'Drill Report Card',
    'correctAnswers': 'Correct Answers',
    'accuracy': 'Calculation Accuracy',
    'pace': 'Pace per Problem',
    'apm': 'Answers per Minute',
    'review': 'Detailed Problem Review',
    'saveScore': 'Save My Score',
    'leaderboard': 'Global Speed Leaderboard',
    'leaderboardDesc': 'Top speed calculations practitioners, ranked by highest Calculations per Minute (APM).',
    'streak': 'Daily Streak',
    'streakDays': 'Days',
    'streakTip': 'Practise 10 minutes daily to make calculations 100x faster.',
    'practiceTab': 'Practice Workout',
    'leaderboardTab': 'Leaderboard',
    'guestMode': 'Guest Mode',
    'offlinePractice': 'Offline Practice',
    'signIn': 'Sign In',
    'signUp': 'Sign Up',
    'confirmExit': 'Are you sure you want to exit the current math drill?',
    'username': 'Username',
    'password': 'Password',
    'fullName': 'Full Name',
    'phoneNumber': 'Phone Number',
    'email': 'Email Address',
    'register': 'Register',
    'cancel': 'Cancel',
    'welcomeBack': 'Welcome Back',
    'createAccount': 'Create Account',
    'apiConfig': 'API Config',
    'serverBaseUrl': 'Server Base URL',
    'save': 'Save',
    'incorrectMsg': 'Incorrect. It was ',
    'correctMsg': 'Correct!',
    'fetchingLeaderboard': 'Fetching rankings from Neon DB...',
    'noLeaderboardRecords': 'No records logged yet. Start a practice drill!',
    'wrong': 'Wrong',
    'correct': 'Correct',
    'calculation': 'Calculation',
    'yourInput': 'Your Input',
    'correctValue': 'Correct Value',
    'status': 'Status',
    'practiceAgain': 'Practice Again',
    'backToMenu': 'Back to Menu',
  },
  'hi': {
    'workout': 'मानसिक गणित कसरत',
    'workoutDesc': 'समयबद्ध दैनिक अभ्यासों के साथ अपनी गणनाओं को तेज करें।',
    'topicLabel': 'अंकगणित विषय',
    'levelLabel': 'कठिनाई स्तर',
    'durationLabel': 'सत्र की अवधि',
    'startBtn': 'अभ्यास शुरू करें',
    'exitBtn': 'बाहर निकलें',
    'reportCard': 'ड्रिल रिपोर्ट कार्ड',
    'correctAnswers': 'सही उत्तर',
    'accuracy': 'गणना सटीकता',
    'pace': 'प्रति प्रश्न गति',
    'apm': 'प्रति मिनट उत्तर',
    'review': 'विस्तृत प्रश्न समीक्षा',
    'saveScore': 'मेरा स्कोर सहेजें',
    'leaderboard': 'ग्लोबल स्पीड लीडरबोर्ड',
    'leaderboardDesc': 'शीर्ष गति गणना उपयोगकर्ता, प्रति मिनट उच्चतम गणना (APM) के आधार पर स्थान।',
    'streak': 'दैनिक निरंतरता',
    'streakDays': 'दिन',
    'streakTip': 'गणना को 100 गुना तेज करने के लिए प्रतिदिन 10 मिनट अभ्यास करें।',
    'practiceTab': 'अभ्यास कसरत',
    'leaderboardTab': 'लीडरबोर्ड',
    'guestMode': 'अतिथि मोड',
    'offlinePractice': 'ऑफ़लाइन अभ्यास',
    'signIn': 'लॉग इन करें',
    'signUp': 'साइन अप करें',
    'confirmExit': 'क्या आप वाकई वर्तमान गणित अभ्यास से बाहर निकलना चाहते हैं?',
    'username': 'उपयोगकर्ता नाम',
    'password': 'पासवर्ड',
    'fullName': 'पूरा नाम',
    'phoneNumber': 'फ़ोन नंबर',
    'email': 'ईमेल पता',
    'register': 'रजिस्टर करें',
    'cancel': 'रद्द करें',
    'welcomeBack': 'स्वागत हे',
    'createAccount': 'खाता बनाएं',
    'apiConfig': 'API विन्यास',
    'serverBaseUrl': 'सर्वर बेस URL',
    'save': 'सहेजें',
    'incorrectMsg': 'गलत उत्तर। सही उत्तर था ',
    'correctMsg': 'सही उत्तर!',
    'fetchingLeaderboard': 'डेटाबेस से रैंकिंग लोड हो रही है...',
    'noLeaderboardRecords': 'अभी तक कोई रिकॉर्ड नहीं है। अभ्यास शुरू करें!',
    'wrong': 'गलत',
    'correct': 'सही',
    'calculation': 'गणना',
    'yourInput': 'आपका उत्तर',
    'correctValue': 'सही मूल्य',
    'status': 'स्थिति',
    'practiceAgain': 'फिर से अभ्यास करें',
    'backToMenu': 'मुख्य मेनू',
  }
};

class DashboardScreen extends StatefulWidget {
  final String lang;
  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;
  final Function(String) onSetLanguage;

  const DashboardScreen({
    super.key,
    required this.lang,
    required this.themeMode,
    required this.onToggleTheme,
    required this.onSetLanguage,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _baseUrl = 'http://localhost:5000';
  List<dynamic> _recentScores = [];
  bool _isLoading = false;
  int _streak = 5;
  int _avgScore = 0;
  Map<String, dynamic>? _currentUser;

  // Selected Configurations
  List<String> _selectedTopics = ['add'];
  String _selectedLevel = 'easy';
  dynamic _selectedDuration = 60; // 30, 60, 120, 300, or 'custom'
  int _customDurationVal = 90;

  int _currentIndex = 0;

  final Map<String, String> _topics = {
    'add': 'Addition (+)',
    'sub': 'Subtraction (-)',
    'mul': 'Multiplication (×)',
    'div': 'Division (÷)',
    'sqrt': 'Square Root (√)',
    'cbrt': 'Cube Root (∛)',
    'sq': 'Squares (x²)',
    'cb': 'Cubes (x³)',
  };

  final Map<String, String> _levels = {
    'easy': 'Easy',
    'medium': 'Medium',
    'hard': 'Hard',
    'advanced': 'Advanced',
  };

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final savedBaseUrl = prefs.getString('calx_base_url') ?? 'http://10.0.2.2:5000';
    final savedUserStr = prefs.getString('calx_user');

    setState(() {
      _baseUrl = savedBaseUrl;
      if (savedUserStr != null) {
        try {
          _currentUser = json.decode(savedUserStr);
        } catch (e) {
          prefs.remove('calx_user');
        }
      }
    });

    _loadScores();
  }

  Future<void> _loadScores() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/scores')).timeout(
        const Duration(seconds: 3),
      );
      if (response.statusCode == 200) {
        final res = json.decode(response.body);
        if (res['success'] == true) {
          final list = res['data'] as List;
          setState(() {
            _recentScores = list;
            if (list.isNotEmpty) {
              final total = list.map((e) => e['score'] as int).reduce((a, b) => a + b);
              _avgScore = (total / list.length).round();
            }
          });
        }
      }

      final statsResponse = await http.get(Uri.parse('$_baseUrl/api/status')).timeout(
        const Duration(seconds: 3),
      );
      if (statsResponse.statusCode == 200) {
        final res = json.decode(statsResponse.body);
        if (res['success'] == true) {
          setState(() {
            _streak = res['data']['dailyActiveStreaks'] ?? 5;
          });
        }
      }
    } catch (e) {
      debugPrint("API offline.");
      setState(() {
        _recentScores = [
          { 'id': 1, 'player': 'guest_mobile_user', 'score': 18, 'totalQuestions': 20, 'timestamp': DateTime.now().toIso8601String() },
          { 'id': 2, 'player': 'guest_mobile_user', 'score': 14, 'totalQuestions': 15, 'timestamp': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String() }
        ];
        _avgScore = 16;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _saveUserSession(Map<String, dynamic>? user) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUser = user;
    });
    if (user != null) {
      prefs.setString('calx_user', json.encode(user));
    } else {
      prefs.remove('calx_user');
    }
    _loadScores();
  }

  void _openSettings() {
    final controller = TextEditingController(text: _baseUrl);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_translations[widget.lang]!['apiConfig']!, style: const TextStyle(fontWeight: FontWeight.w700)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: _translations[widget.lang]!['serverBaseUrl']!,
            hintText: 'http://10.0.2.2:5000',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_translations[widget.lang]!['cancel']!),
          ),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              prefs.setString('calx_base_url', controller.text);
              setState(() => _baseUrl = controller.text);
              if (context.mounted) Navigator.pop(context);
              _loadScores();
            },
            child: Text(_translations[widget.lang]!['save']!),
          )
        ],
      ),
    );
  }

  void _showAuthModal(String mode) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AuthBottomSheet(
        mode: mode,
        baseUrl: _baseUrl,
        lang: widget.lang,
        onSuccess: (user) {
          _saveUserSession(user);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = _translations[widget.lang]!;
    final isDark = widget.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calx',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -0.8),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(onPressed: _openSettings, icon: const Icon(Icons.settings_outlined)),
        ],
        backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
        foregroundColor: isDark ? const Color(0xFFEDEDED) : const Color(0xFF171717),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: isDark ? const Color(0xFF222222) : const Color(0xFFEBEBEB),
            height: 1.0,
          ),
        ),
      ),
      drawer: Drawer(
        backgroundColor: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFFAFADA),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo brand matching collapsible web brand
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0F172A),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            left: 4,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white, width: 2),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          const Positioned(
                            right: 4,
                            child: Icon(Icons.chevron_right, color: Color(0xFF06B6D4), size: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Calx',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // User Profile Box
                if (_currentUser != null) ...[
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: isDark ? const Color(0xFFEDEDED) : const Color(0xFF171717),
                        foregroundColor: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFFAFADA),
                        child: Text(
                          _currentUser!['full_name'] != null && _currentUser!['full_name'].toString().isNotEmpty
                              ? _currentUser!['full_name'][0].toString().toUpperCase()
                              : _currentUser!['username'][0].toString().toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentUser!['full_name'] ?? _currentUser!['username'],
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '@${_currentUser!['username']}',
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, size: 18, color: Colors.redAccent),
                        onPressed: () => _saveUserSession(null),
                      )
                    ],
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: isDark ? const Color(0xFF222222) : const Color(0xFFEBEBEB)),
                      borderRadius: BorderRadius.circular(8),
                      color: isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.grey.shade400,
                              child: const Text('G', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(t['guestMode']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                Text(t['offlinePractice']!, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => _showAuthModal('login'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? const Color(0xFFEDEDED) : const Color(0xFF171717),
                            foregroundColor: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFFAFADA),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            elevation: 0,
                          ),
                          child: Text(t['signIn']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                // Streak and Average APM Row Widget
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
                          border: Border.all(color: isDark ? const Color(0xFF222222) : const Color(0xFFEBEBEB)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t['streak']!, style: const TextStyle(fontFamily: 'monospace', fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text('$_streak ${t['streakDays']!}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900), overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
                          border: Border.all(color: isDark ? const Color(0xFF222222) : const Color(0xFFEBEBEB)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.lang == 'en' ? 'AVG APM' : 'औसत APM', style: const TextStyle(fontFamily: 'monospace', fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text('$_avgScore/m', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900), overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Settings Row
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: widget.onToggleTheme,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: isDark ? const Color(0xFF222222) : const Color(0xFFEBEBEB)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        child: Text(isDark ? '☀️ Light' : '🌙 Dark', style: const TextStyle(fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          widget.onSetLanguage(widget.lang == 'en' ? 'hi' : 'en');
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: isDark ? const Color(0xFF222222) : const Color(0xFFEBEBEB)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        child: Text(widget.lang == 'en' ? '🌐 HI' : '🌐 EN', style: const TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildPracticeConfigView(),
          LeaderboardView(baseUrl: _baseUrl, lang: widget.lang),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
        selectedItemColor: isDark ? const Color(0xFFEDEDED) : const Color(0xFF171717),
        unselectedItemColor: Colors.grey,
        elevation: 0,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.play_circle_fill), label: t['practiceTab']!),
          BottomNavigationBarItem(icon: const Icon(Icons.emoji_events), label: t['leaderboardTab']!),
        ],
      ),
    );
  }

  Widget _buildPracticeConfigView() {
    final t = _translations[widget.lang]!;
    final isDark = widget.themeMode == ThemeMode.dark;

    return RefreshIndicator(
      onRefresh: _loadScores,
      child: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isDark ? const Color(0xFF222222) : const Color(0xFFEBEBEB)),
            ),
            child: Row(
              children: [
                Icon(Icons.flash_on, size: 20, color: isDark ? Colors.cyan : Colors.black87),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t['workout']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 2),
                      Text(t['workoutDesc']!, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Workout configuration selectors card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(t['topicLabel']!, style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  
                  // Multi Topic Select Wrap
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      ..._topics.entries.map((entry) {
                        final isSelected = _selectedTopics.contains(entry.key);
                        return ChoiceChip(
                          label: Text(entry.value, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : (isDark ? Colors.grey : Colors.black))),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedTopics.add(entry.key);
                              } else {
                                if (_selectedTopics.length > 1) {
                                  _selectedTopics.remove(entry.key);
                                }
                              }
                            });
                          },
                          selectedColor: isDark ? const Color(0xFFEDEDED) : const Color(0xFF171717),
                          backgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        );
                      }),
                      ChoiceChip(
                        label: Text(widget.lang == 'en' ? 'Select All' : 'सभी चुनें', style: TextStyle(fontSize: 11, color: _selectedTopics.length == 8 ? Colors.white : (isDark ? Colors.grey : Colors.black))),
                        selected: _selectedTopics.length == 8,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedTopics = ['add', 'sub', 'mul', 'div', 'sqrt', 'cbrt', 'sq', 'cb'];
                            } else {
                              _selectedTopics = ['add'];
                            }
                          });
                        },
                        selectedColor: isDark ? const Color(0xFFEDEDED) : const Color(0xFF171717),
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Level select Wrap
                  Text(t['levelLabel']!, style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    children: _levels.entries.map((entry) {
                      final isSelected = _selectedLevel == entry.key;
                      Color activeColor = const Color(0xFF171717);
                      if (entry.key == 'easy') activeColor = const Color(0xFF10B981);
                      if (entry.key == 'medium') activeColor = const Color(0xFFEAB308);
                      if (entry.key == 'hard') activeColor = const Color(0xFFF97316);
                      if (entry.key == 'advanced') activeColor = const Color(0xFFEF4444);

                      return ChoiceChip(
                        label: Text(entry.value, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : (isDark ? Colors.grey : Colors.black))),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedLevel = entry.key);
                        },
                        selectedColor: activeColor,
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Duration Selector
                  Text(t['durationLabel']!, style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    children: [
                      _buildDurationChip(30, '30s'),
                      _buildDurationChip(60, '1m'),
                      _buildDurationChip(120, '2m'),
                      _buildDurationChip(300, '5m'),
                      _buildDurationChip('custom', widget.lang == 'en' ? 'Custom' : 'कस्टम'),
                    ],
                  ),
                  if (_selectedDuration == 'custom') ...[
                    const SizedBox(height: 12),
                    TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: widget.lang == 'en' ? 'Duration (seconds)' : 'अवधि (सेकंड)',
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onChanged: (val) {
                        final parsed = int.tryParse(val);
                        if (parsed != null && parsed > 0) {
                          setState(() {
                            _customDurationVal = parsed;
                          });
                        }
                      },
                    )
                  ]
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Start elevation button
          ElevatedButton(
            onPressed: () async {
              int sessionDuration = _selectedDuration == 'custom' ? _customDurationVal : _selectedDuration;
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PracticeSessionScreen(
                    baseUrl: _baseUrl,
                    topics: _selectedTopics,
                    level: _selectedLevel,
                    duration: sessionDuration,
                    lang: widget.lang,
                    currentUser: _currentUser,
                  ),
                ),
              );
              _loadScores();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? const Color(0xFFEDEDED) : const Color(0xFF171717),
              foregroundColor: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFFAFADA),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), // Web CTA styling pill shape
              elevation: 0,
            ),
            child: Text(t['startBtn']!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 24),

          // Recent Scores Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.lang == 'en' ? 'Recent Score Logs' : 'हाल के स्कोर लॉग', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              if (_isLoading)
                const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 1.5))
            ],
          ),
          const SizedBox(height: 10),

          _recentScores.isEmpty
              ? Container(
                  height: 100,
                  alignment: Alignment.center,
                  child: Text(
                    _isLoading ? 'Syncing...' : 'No sessions recorded yet. Start training!',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _recentScores.length > 5 ? 5 : _recentScores.length,
                  itemBuilder: (context, index) {
                    final score = _recentScores[index];
                    final date = DateTime.tryParse(score['timestamp'] ?? '');
                    final dateStr = date != null
                        ? '${date.hour}:${date.minute.toString().padLeft(2, '0')} - ${date.day}/${date.month}'
                        : '';
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text('${score['score']} correct answers', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        subtitle: Text('Context: ${score['player']}', style: const TextStyle(fontSize: 11)),
                        trailing: Text(dateStr, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        dense: true,
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildDurationChip(dynamic value, String label) {
    final isDark = widget.themeMode == ThemeMode.dark;
    final isSelected = _selectedDuration == value;
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : (isDark ? Colors.grey : Colors.black))),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _selectedDuration = value);
      },
      selectedColor: isDark ? const Color(0xFFEDEDED) : const Color(0xFF171717),
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    );
  }
}

class LeaderboardView extends StatefulWidget {
  final String baseUrl;
  final String lang;

  const LeaderboardView({super.key, required this.baseUrl, required this.lang});

  @override
  State<LeaderboardView> createState() => _LeaderboardViewState();
}

class _LeaderboardViewState extends State<LeaderboardView> {
  List<dynamic> _rankings = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
  }

  Future<void> _fetchLeaderboard() async {
    setState(() => _loading = true);
    try {
      final res = await http.get(Uri.parse('${widget.baseUrl}/api/leaderboard')).timeout(
        const Duration(seconds: 3),
      );
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        if (body['success'] == true) {
          setState(() {
            _rankings = body['data'];
          });
        }
      }
    } catch (e) {
      debugPrint("API offline. Mocking leaderboard.");
      setState(() {
        _rankings = [
          { 'username': 'speedmathpro', 'fullName': 'Speed Math Pro', 'maxSpeed': 48 },
          { 'username': 'quant_wizard', 'fullName': 'Quant Wizard', 'maxSpeed': 42 },
          { 'username': 'mathgenius', 'fullName': 'Math Genius', 'maxSpeed': 38 },
          { 'username': 'john.doe', 'fullName': 'John Doe', 'maxSpeed': 32 },
        ];
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = _translations[widget.lang]!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(t['leaderboard']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
          const SizedBox(height: 4),
          Text(t['leaderboardDesc']!, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 20),

          Expanded(
            child: _loading
                ? Center(child: Text(t['fetchingLeaderboard']!))
                : _rankings.isEmpty
                    ? Center(child: Text(t['noLeaderboardRecords']!))
                    : RefreshIndicator(
                        onRefresh: _fetchLeaderboard,
                        child: ListView.builder(
                          itemCount: _rankings.length,
                          itemBuilder: (context, index) {
                            final player = _rankings[index];
                            final rank = index + 1;
                            
                            // Colors and podium medals style mimicking webapp
                            String rankMedal = '#$rank';
                            Color cardBg = Colors.transparent;
                            if (rank == 1) {
                              rankMedal = '🥇';
                              cardBg = isDark ? const Color(0xFF1C1917) : const Color(0xFFFEF3C7);
                            } else if (rank == 2) {
                              rankMedal = '🥈';
                              cardBg = isDark ? const Color(0xFF18181B) : const Color(0xFFF3F4F6);
                            } else if (rank == 3) {
                              rankMedal = '🥉';
                              cardBg = isDark ? const Color(0xFF1C1610) : const Color(0xFFFFEDD5);
                            }

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: isDark ? const Color(0xFF222222) : const Color(0xFFEBEBEB)),
                              ),
                              child: ListTile(
                                leading: Container(
                                  width: 32,
                                  alignment: Alignment.center,
                                  child: Text(rankMedal, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                ),
                                title: Text(player['fullName'] ?? player['username'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                subtitle: Text('@${player['username']}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('${player['maxSpeed']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                                    const Text('APM', style: TextStyle(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          )
        ],
      ),
    );
  }
}

class AuthBottomSheet extends StatefulWidget {
  final String mode;
  final String baseUrl;
  final String lang;
  final Function(Map<String, dynamic>) onSuccess;

  const AuthBottomSheet({
    super.key,
    required this.mode,
    required this.baseUrl,
    required this.lang,
    required this.onSuccess,
  });

  @override
  State<AuthBottomSheet> createState() => _AuthBottomSheetState();
}

class _AuthBottomSheetState extends State<AuthBottomSheet> {
  late String _authMode;
  bool _loading = false;
  String _errorMsg = '';

  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _fullNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _authMode = widget.mode;
  }

  void _submitAuth() async {
    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (username.isEmpty || password.isEmpty) return;

    setState(() {
      _loading = true;
      _errorMsg = '';
    });

    try {
      if (_authMode == 'login') {
        final res = await http.post(
          Uri.parse('${widget.baseUrl}/api/auth/signin'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'username': username, 'password': password}),
        );
        final body = json.decode(res.body);
        if (body['success'] == true) {
          widget.onSuccess(body['user']);
          if (mounted) Navigator.pop(context);
        } else {
          setState(() => _errorMsg = body['error'] ?? 'Sign In failed.');
        }
      } else {
        final fullName = _fullNameCtrl.text.trim();
        final phone = _phoneCtrl.text.trim();
        final email = _emailCtrl.text.trim();
        if (fullName.isEmpty || phone.isEmpty || email.isEmpty) {
          setState(() => _errorMsg = 'Please fill in all register fields.');
          setState(() => _loading = false);
          return;
        }

        final res = await http.post(
          Uri.parse('${widget.baseUrl}/api/auth/signup'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'full_name': fullName,
            'username': username,
            'password': password,
            'phone_number': phone,
            'email': email
          }),
        );
        final body = json.decode(res.body);
        if (body['success'] == true) {
          widget.onSuccess(body['user']);
          if (mounted) Navigator.pop(context);
        } else {
          setState(() => _errorMsg = body['error'] ?? 'Sign Up failed.');
        }
      }
    } catch (e) {
      setState(() => _errorMsg = 'Failed to reach database server.');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = _translations[widget.lang]!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFFAFADA),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border.all(color: isDark ? const Color(0xFF222222) : const Color(0xFFEBEBEB)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _authMode == 'login' ? t['welcomeBack']! : t['createAccount']!,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 12),
            if (_errorMsg.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border(left: BorderSide(color: Colors.red.shade400, width: 3)),
                ),
                child: Text(_errorMsg, style: TextStyle(color: Colors.red.shade900, fontSize: 12)),
              ),
              const SizedBox(height: 12),
            ],

            if (_authMode == 'signup') ...[
              TextField(
                controller: _fullNameCtrl,
                decoration: InputDecoration(labelText: t['fullName']!, border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
            ],
            TextField(
              controller: _usernameCtrl,
              decoration: InputDecoration(labelText: t['username']!, border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordCtrl,
              obscureText: true,
              decoration: InputDecoration(labelText: t['password']!, border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 10),

            if (_authMode == 'signup') ...[
              TextField(
                controller: _phoneCtrl,
                decoration: InputDecoration(labelText: t['phoneNumber']!, border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _emailCtrl,
                decoration: InputDecoration(labelText: t['email']!, border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
            ],

            ElevatedButton(
              onPressed: _loading ? null : _submitAuth,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? const Color(0xFFEDEDED) : const Color(0xFF171717),
                foregroundColor: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFFAFADA),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                _loading
                    ? 'Processing...'
                    : (_authMode == 'login' ? t['signIn']! : t['register']!),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),

            TextButton(
              onPressed: () {
                setState(() {
                  _authMode = _authMode == 'login' ? 'signup' : 'login';
                  _errorMsg = '';
                });
              },
              child: Text(
                _authMode == 'login'
                    ? "New to Calx? Create Account"
                    : "Have an account? Sign In",
                style: const TextStyle(decoration: TextDecoration.underline),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class PracticeSessionScreen extends StatefulWidget {
  final String baseUrl;
  final List<String> topics;
  final String level;
  final int duration;
  final String lang;
  final Map<String, dynamic>? currentUser;

  const PracticeSessionScreen({
    super.key,
    required this.baseUrl,
    required this.topics,
    required this.level,
    required this.duration,
    required this.lang,
    this.currentUser,
  });

  @override
  State<PracticeSessionScreen> createState() => _PracticeSessionScreenState();
}

class _PracticeSessionScreenState extends State<PracticeSessionScreen> {
  int _score = 0;
  int _totalQuestions = 0;
  late int _timeLeft;
  Timer? _timer;

  String _questionText = '';
  int _correctAnswer = 0;
  String _inputBuffer = '';
  bool _gameEnded = false;

  final List<Map<String, dynamic>> _sessionHistory = [];
  String _feedbackText = '';
  Color _feedbackColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.duration;
    _generateNextQuestion();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 1) {
        setState(() => _timeLeft--);
      } else {
        _endGame();
      }
    });
  }

  void _generateNextQuestion() {
    final rand = Random();
    String currentTopic = widget.topics[rand.nextInt(widget.topics.length)];

    int n1, n2, ans;
    String text;

    int randomRange(int min, int max) => min + rand.nextInt(max - min + 1);

    switch (widget.level) {
      case 'easy':
        if (currentTopic == 'add') {
          n1 = randomRange(1, 20); n2 = randomRange(1, 20); ans = n1 + n2; text = '$n1 + $n2';
        } else if (currentTopic == 'sub') {
          n1 = randomRange(5, 20); n2 = randomRange(1, n1 - 1); ans = n1 - n2; text = '$n1 - $n2';
        } else if (currentTopic == 'mul') {
          n1 = randomRange(1, 10); n2 = randomRange(1, 10); ans = n1 * n2; text = '$n1 × $n2';
        } else if (currentTopic == 'div') {
          n2 = randomRange(1, 10); ans = randomRange(1, 10); n1 = n2 * ans; text = '$n1 ÷ $n2';
        } else if (currentTopic == 'sqrt') {
          ans = randomRange(2, 10); n1 = ans * ans; text = '√$n1';
        } else if (currentTopic == 'cbrt') {
          ans = randomRange(2, 5); n1 = ans * ans * ans; text = '∛$n1';
        } else if (currentTopic == 'sq') {
          ans = randomRange(2, 12); n1 = ans; text = '$n1²';
        } else { // cb
          ans = randomRange(2, 5); n1 = ans; text = '$n1³';
        }
        break;

      case 'medium':
        if (currentTopic == 'add') {
          n1 = randomRange(10, 100); n2 = randomRange(10, 100); ans = n1 + n2; text = '$n1 + $n2';
        } else if (currentTopic == 'sub') {
          n1 = randomRange(20, 100); n2 = randomRange(10, n1 - 5); ans = n1 - n2; text = '$n1 - $n2';
        } else if (currentTopic == 'mul') {
          n1 = randomRange(2, 15); n2 = randomRange(2, 15); ans = n1 * n2; text = '$n1 × $n2';
        } else if (currentTopic == 'div') {
          n2 = randomRange(2, 12); ans = randomRange(2, 12); n1 = n2 * ans; text = '$n1 ÷ $n2';
        } else if (currentTopic == 'sqrt') {
          ans = randomRange(11, 20); n1 = ans * ans; text = '√$n1';
        } else if (currentTopic == 'cbrt') {
          ans = randomRange(6, 10); n1 = ans * ans * ans; text = '∛$n1';
        } else if (currentTopic == 'sq') {
          ans = randomRange(13, 25); n1 = ans; text = '$n1²';
        } else { // cb
          ans = randomRange(6, 10); n1 = ans; text = '$n1³';
        }
        break;

      case 'hard':
        if (currentTopic == 'add') {
          n1 = randomRange(100, 1000); n2 = randomRange(100, 1000); ans = n1 + n2; text = '$n1 + $n2';
        } else if (currentTopic == 'sub') {
          n1 = randomRange(200, 1000); n2 = randomRange(100, n1 - 10); ans = n1 - n2; text = '$n1 - $n2';
        } else if (currentTopic == 'mul') {
          n1 = randomRange(10, 40); n2 = randomRange(5, 20); ans = n1 * n2; text = '$n1 × $n2';
        } else if (currentTopic == 'div') {
          n2 = randomRange(5, 20); ans = randomRange(10, 40); n1 = n2 * ans; text = '$n1 ÷ $n2';
        } else if (currentTopic == 'sqrt') {
          ans = randomRange(21, 50); n1 = ans * ans; text = '√$n1';
        } else if (currentTopic == 'cbrt') {
          ans = randomRange(11, 15); n1 = ans * ans * ans; text = '∛$n1';
        } else if (currentTopic == 'sq') {
          ans = randomRange(26, 50); n1 = ans; text = '$n1²';
        } else { // cb
          ans = randomRange(11, 15); n1 = ans; text = '$n1³';
        }
        break;

      case 'advanced':
      default:
        if (currentTopic == 'add') {
          n1 = randomRange(500, 5000); n2 = randomRange(500, 5000); ans = n1 + n2; text = '$n1 + $n2';
        } else if (currentTopic == 'sub') {
          n1 = randomRange(1000, 5000); n2 = randomRange(500, n1 - 100); ans = n1 - n2; text = '$n1 - $n2';
        } else if (currentTopic == 'mul') {
          n1 = randomRange(12, 100); n2 = randomRange(12, 100); ans = n1 * n2; text = '$n1 × $n2';
        } else if (currentTopic == 'div') {
          n2 = randomRange(12, 100); ans = randomRange(12, 100); n1 = n2 * ans; text = '$n1 ÷ $n2';
        } else if (currentTopic == 'sqrt') {
          ans = randomRange(51, 100); n1 = ans * ans; text = '√$n1';
        } else if (currentTopic == 'cbrt') {
          ans = randomRange(16, 25); n1 = ans * ans * ans; text = '∛$n1';
        } else if (currentTopic == 'sq') {
          ans = randomRange(51, 100); n1 = ans; text = '$n1²';
        } else { // cb
          ans = randomRange(16, 25); n1 = ans; text = '$n1³';
        }
        break;
    }

    setState(() {
      _questionText = text;
      _correctAnswer = ans;
      _inputBuffer = '';
      _feedbackText = '';
      _feedbackColor = Colors.transparent;
    });
  }

  // Auto check inputs on key press matching web logic
  void _handleNumberInput(String value) {
    if (_gameEnded) return;
    setState(() {
      _inputBuffer += value;
    });

    final valNum = int.tryParse(_inputBuffer);
    if (valNum == null) return;

    if (valNum == _correctAnswer) {
      setState(() {
        _score++;
        _totalQuestions++;
        _feedbackText = _translations[widget.lang]!['correctMsg']!;
        _feedbackColor = const Color(0xFF10B981);
        _sessionHistory.add({
          'question': _questionText,
          'userAnswer': _inputBuffer,
          'correctAnswer': _correctAnswer,
          'isCorrect': true,
        });
      });
      Future.delayed(const Duration(milliseconds: 250), () {
        if (mounted) _generateNextQuestion();
      });
    }
  }

  void _handleBackspace() {
    if (_inputBuffer.isEmpty) return;
    setState(() {
      _inputBuffer = _inputBuffer.substring(0, _inputBuffer.length - 1);
    });
  }

  void _submitAnswer() {
    if (_gameEnded) return;

    final ansNum = int.tryParse(_inputBuffer);
    final isCorrect = ansNum != null && ansNum == _correctAnswer;

    setState(() {
      _totalQuestions++;
      if (isCorrect) {
        _score++;
        _feedbackText = _translations[widget.lang]!['correctMsg']!;
        _feedbackColor = const Color(0xFF10B981);
      } else {
        _feedbackText = '${_translations[widget.lang]!['incorrectMsg']!}$_correctAnswer';
        _feedbackColor = const Color(0xFFEF4444);
      }

      _sessionHistory.add({
        'question': _questionText,
        'userAnswer': _inputBuffer,
        'correctAnswer': _correctAnswer,
        'isCorrect': isCorrect,
      });
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _generateNextQuestion();
    });
  }

  void _exitDrill() async {
    final msg = _translations[widget.lang]!['confirmExit']!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(_translations[widget.lang]!['cancel']!)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(_translations[widget.lang]!['exitBtn']!)),
        ],
      ),
    );

    if (confirm == true && mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _endGame() async {
    _timer?.cancel();
    setState(() {
      _gameEnded = true;
      _timeLeft = 0;
    });

    try {
      final topicLabels = { 'add': 'Add', 'sub': 'Sub', 'mul': 'Mul', 'div': 'Div', 'sqrt': 'Sqrt', 'cbrt': 'Cbrt', 'sq': 'Square', 'cb': 'Cube' };
      final levelLabels = { 'easy': 'Easy', 'medium': 'Medium', 'hard': 'Hard', 'advanced': 'Adv' };
      final activeTopicsStr = widget.topics.map((t) => topicLabels[t] ?? t).join(', ');

      final playerLabel = widget.currentUser != null
          ? 'Mobile (${widget.currentUser!['username']}) ($activeTopicsStr - ${levelLabels[widget.level]})'
          : 'Guest Mobile ($activeTopicsStr - ${levelLabels[widget.level]})';

      await http.post(
        Uri.parse('${widget.baseUrl}/api/scores'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': widget.currentUser != null ? widget.currentUser!['username'] : 'guest_mobile_user',
          'score': _score,
          'totalQuestions': _totalQuestions,
          'duration': widget.duration,
          'player': playerLabel,
        }),
      ).timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint("API offline.");
    }
  }

  void _saveScoreDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AuthBottomSheet(
        mode: 'signup',
        baseUrl: widget.baseUrl,
        lang: widget.lang,
        onSuccess: (user) async {
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('calx_user', json.encode(user));
          // Save and Sync score after auth
          try {
            final topicLabels = { 'add': 'Add', 'sub': 'Sub', 'mul': 'Mul', 'div': 'Div', 'sqrt': 'Sqrt', 'cbrt': 'Cbrt', 'sq': 'Square', 'cb': 'Cube' };
            final levelLabels = { 'easy': 'Easy', 'medium': 'Medium', 'hard': 'Hard', 'advanced': 'Adv' };
            final activeTopicsStr = widget.topics.map((t) => topicLabels[t] ?? t).join(', ');
            final playerLabel = 'Mobile (${user['username']}) ($activeTopicsStr - ${levelLabels[widget.level]})';

            await http.post(
              Uri.parse('${widget.baseUrl}/api/scores'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                'username': user['username'],
                'score': _score,
                'totalQuestions': _totalQuestions,
                'duration': widget.duration,
                'player': playerLabel,
              }),
            ).timeout(const Duration(seconds: 3));
          } catch (e) {
            debugPrint("Sync offline.");
          }
          if (context.mounted) Navigator.pop(context); // Pop Results and reload Dashboard
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(_translations[widget.lang]!['workout']!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          if (!_gameEnded)
            TextButton(
              onPressed: _exitDrill,
              child: Text(
                _translations[widget.lang]!['exitBtn']!,
                style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
            )
        ],
      ),
      body: SafeArea(
        child: _gameEnded ? _buildResultsScreen() : _buildGamePlayScreen(),
      ),
    );
  }

  Widget _buildGamePlayScreen() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_translations[widget.lang]!['durationLabel']!}: $_timeLeft s',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                'Score: $_score / $_totalQuestions',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const Spacer(),
        Center(
          child: Text(
            _questionText,
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, fontFamily: 'monospace', letterSpacing: -1.5),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Container(
            height: 60,
            alignment: Alignment.center,
            child: Text(
              _inputBuffer.isEmpty ? '?' : _inputBuffer,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: _inputBuffer.isEmpty ? Colors.grey : (isDark ? Colors.white : Colors.black),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Text(
            _feedbackText,
            style: TextStyle(color: _feedbackColor, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        const Spacer(),
        _buildCupertinoKeyboard(),
      ],
    );
  }

  Widget _buildResultsScreen() {
    final t = _translations[widget.lang]!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final int accuracy = _totalQuestions > 0 ? ((_score / _totalQuestions) * 100).round() : 0;
    final String solvePace = _totalQuestions > 0 ? (widget.duration / _totalQuestions).toStringAsFixed(1) : '0';
    final int apm = widget.duration > 0 ? ((_score / widget.duration) * 60).round() : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: ListView(
        children: [
          const SizedBox(height: 10),
          Text(t['reportCard']!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
          const SizedBox(height: 20),

          // Core Metrics Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.4,
            children: [
              _buildMetricCard('$_score', t['correctAnswers']!, 'Out of $_totalQuestions questions'),
              _buildMetricCard('$accuracy%', t['accuracy']!, 'Aim for >90% accuracy'),
              _buildMetricCard('${solvePace}s', t['pace']!, 'Average solving speed'),
              _buildMetricCard('$apm/m', t['apm']!, 'Calculated solving rate'),
            ],
          ),
          const SizedBox(height: 24),

          // Problem review section
          Text(t['review']!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: isDark ? const Color(0xFF222222) : const Color(0xFFEBEBEB)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1.5),
                2: FlexColumnWidth(1.5),
                3: FlexColumnWidth(1.8),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF171717) : const Color(0xFFEBEBEB),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                  ),
                  children: [
                    _buildTableCell(t['calculation']!, isHeader: true),
                    _buildTableCell(t['yourInput']!, isHeader: true),
                    _buildTableCell(t['correctValue']!, isHeader: true),
                    _buildTableCell(t['status']!, isHeader: true),
                  ]
                ),
                ..._sessionHistory.map((item) {
                  final isCorrect = item['isCorrect'] == true;
                  final rowColor = isCorrect
                      ? (isDark ? const Color(0xFF042F1A) : const Color(0xFFECFDF5))
                      : (isDark ? const Color(0xFF450A0A) : const Color(0xFFFEF2F2));
                  return TableRow(
                    decoration: BoxDecoration(color: rowColor),
                    children: [
                      _buildTableCell(item['question'], isMono: true),
                      _buildTableCell(item['userAnswer'].toString().isEmpty ? '(skip)' : item['userAnswer'], isMono: true),
                      _buildTableCell(item['correctAnswer'].toString(), isMono: true),
                      _buildTableCell(
                        isCorrect ? '✅ ${t['correct']!}' : '❌ ${t['wrong']!}',
                        textColor: isCorrect ? Colors.green : Colors.red,
                        isBold: true,
                      ),
                    ]
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Footer actions matching web
          if (widget.currentUser == null) ...[
            ElevatedButton(
              onPressed: _saveScoreDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(t['saveScore']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
          ],

          ElevatedButton(
            onPressed: () {
              setState(() {
                _score = 0;
                _totalQuestions = 0;
                _timeLeft = widget.duration;
                _gameEnded = false;
                _sessionHistory.clear();
              });
              _generateNextQuestion();
              _startTimer();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? const Color(0xFFEDEDED) : const Color(0xFF171717),
              foregroundColor: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFFAFADA),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(t['practiceAgain']!, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 10),

          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: isDark ? const Color(0xFF222222) : const Color(0xFFEBEBEB)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(t['backToMenu']!, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false, bool isMono = false, bool isBold = false, Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader || isBold ? FontWeight.bold : FontWeight.normal,
          fontSize: isHeader ? 10 : 12,
          fontFamily: isMono ? 'monospace' : null,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildMetricCard(String value, String label, String sub) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
        border: Border.all(color: isDark ? const Color(0xFF222222) : const Color(0xFFEBEBEB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 2),
          Text(sub, style: const TextStyle(fontSize: 8, color: Colors.grey), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildCupertinoKeyboard() {
    return Container(
      color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF171717) : const Color(0xFFF3F4F6),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        children: [
          Row(
            children: [
              _buildKey('1'),
              _buildKey('2'),
              _buildKey('3'),
            ],
          ),
          Row(
            children: [
              _buildKey('4'),
              _buildKey('5'),
              _buildKey('6'),
            ],
          ),
          Row(
            children: [
              _buildKey('7'),
              _buildKey('8'),
              _buildKey('9'),
            ],
          ),
          Row(
            children: [
              _buildKey('⌫', action: _handleBackspace),
              _buildKey('0'),
              _buildKey('Submit', action: _submitAnswer, isAction: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String label, {VoidCallback? action, bool isAction = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: InkWell(
          onTap: action ?? () => _handleNumberInput(label),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: isAction
                  ? const Color(0xFF10B981)
                  : (isDark ? const Color(0xFF000000) : Colors.white),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: isDark ? const Color(0xFF222222) : const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  offset: const Offset(0, 1),
                  blurRadius: 1,
                )
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontSize: isAction ? 14 : 20,
                fontWeight: FontWeight.bold,
                color: isAction ? Colors.white : (isDark ? Colors.white : Colors.black),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
