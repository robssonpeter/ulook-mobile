import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'providers/auth_provider.dart';
import 'providers/data_provider.dart';
import 'screens/login_screen.dart';
import 'screens/main_wrapper.dart';
import 'screens/onboarding_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final apiService = ApiService();
  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>.value(value: apiService),
        ChangeNotifierProvider(create: (_) => AuthProvider(apiService)),
        ChangeNotifierProxyProvider<AuthProvider, DataProvider>(
          create: (_) => DataProvider(apiService),
          update: (_, auth, data) => data ?? DataProvider(apiService),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

const kPrimary = Color(0xFF2E1B2E); // deep plum / aubergine
const kSecondary = Color(0xFFC99A3F); // gold
const kBackground = Color(0xFFFBF7F2); // warm cream
// A darker plum used for large surfaces (splash, profile hero).
const kPlumDark = Color(0xFF241322);
// Soft brand tints for avatar backgrounds, chips and subtle fills.
const kPrimarySoft = Color(0xFFEDE6EC); // soft plum tint
const kSecondarySoft = Color(0xFFF6ECD8); // soft gold tint
// Neutral text tones for a consistent hierarchy.
const kTextMuted = Color(0xFF8A7F88);
const kTextDark = Color(0xFF2A222A); // near-black plum for headings on cream

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ULOOK',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: const AppRoot(),
    );
  }

  ThemeData _buildTheme() {
    final base = ThemeData.light(useMaterial3: true);
    final cs = ColorScheme.fromSeed(
      seedColor: kPrimary,
      primary: kPrimary,
      onPrimary: Colors.white,
      secondary: kSecondary,
      onSecondary: kPlumDark,
      surface: Colors.white,
      brightness: Brightness.light,
    );
    return base.copyWith(
      colorScheme: cs,
      scaffoldBackgroundColor: kBackground,
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),
      primaryTextTheme: GoogleFonts.poppinsTextTheme(base.primaryTextTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: kBackground,
        foregroundColor: kTextDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.poppins(
          color: kTextDark,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: kTextDark),
        actionsIconTheme: const IconThemeData(color: kTextDark),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFEDE6DF)),
        ),
        color: Colors.white,
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF2ECE4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: Color(0xFFB0B5C4)),
        prefixIconColor: const Color(0xFFB0B5C4),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: kPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: const BorderSide(color: kPrimary),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: kPrimary,
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: kPrimary,
        unselectedItemColor: Color(0xFFB0B5C4),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        labelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFFEDE6DF), space: 1),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: kPrimary),
    );
  }
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  bool _initializing = true;
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final seen = await hasSeenOnboarding();
    await context.read<AuthProvider>().tryAutoLogin();
    setState(() {
      _showOnboarding = !seen;
      _initializing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) return const _SplashScreen();
    if (_showOnboarding) {
      return OnboardingScreen(
        onDone: () => setState(() => _showOnboarding = false),
      );
    }
    final auth = context.watch<AuthProvider>();
    return auth.isAuthenticated ? const MainWrapper() : const LoginScreen();
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPlumDark,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: kSecondary.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: kSecondary, width: 1.5),
              ),
              child: const Icon(Icons.spa_rounded, color: kSecondary, size: 42),
            ),
            const SizedBox(height: 22),
            Text(
              'ULOOK',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 6,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Discover. Connect. Book.',
              style: GoogleFonts.poppins(
                color: kSecondary,
                fontSize: 13,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(kSecondary),
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
