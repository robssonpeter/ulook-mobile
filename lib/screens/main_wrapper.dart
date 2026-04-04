import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';
import 'my_bookings_screen.dart';
import 'dashboard_screen.dart';
import 'become_professional_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isProfessional = user?.role == 'professional';

    final List<Widget> screens = [
      const HomeScreen(),
      const MyBookingsScreen(),
      if (isProfessional) const DashboardScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Bookings'),
          if (isProfessional)
            const BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isProfessional = user?.role == 'professional';

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
            const SizedBox(height: 16),
            Text(user?.name ?? 'User Name', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(user?.phone ?? '', style: const TextStyle(fontSize: 18, color: Colors.grey)),
            if (user != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Chip(
                  label: Text(user.role.toUpperCase()),
                  backgroundColor: isProfessional ? Colors.green.shade100 : Colors.blue.shade100,
                ),
              ),
            const SizedBox(height: 32),
            if (!isProfessional && user?.role != 'admin')
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const BecomeProfessionalScreen()),
                    );
                  },
                  icon: const Icon(Icons.work),
                  label: const Text('Become a Professional'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                ),
              ),
            ElevatedButton(
              onPressed: () => context.read<AuthProvider>().logout(),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
