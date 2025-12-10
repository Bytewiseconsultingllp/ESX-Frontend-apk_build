import 'package:esx/features/auth/provider/auth_provider.dart';
import 'package:esx/features/auth/view/login_screen.dart';
import 'package:esx/features/auth/view/registration_page.dart';
import 'package:esx/features/root/view/root_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Buy, Sell & Bid on Electronics',
      'description':
          'Join the ultimate marketplace for pre-owned electronics. List your gadgets, place bids, and get the best deals effortlessly.',
      'image': 'assets/intro_images/exchange.png',
    },
    {
      'title': 'Easy & Secure Transactions',
      'description':
          'Every transaction is secure, and all listings are verified to ensure a hassle-free experience.',
      'image': 'assets/intro_images/card.png',
    },
    {
      'title': 'Smart Bidding System',
      'description':
          'Place your bid, and if no one outbids you in 180 seconds, the gadget is yours! Stay ahead and grab the best offers.',
      'image': 'assets/intro_images/shopping.png',
    },
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _completeIntro();
    }
  }

  Future<void> _completeIntro() async {
    final authProvider = context.read<AuthProvider>();
    final isAuthenticated = await authProvider.checkAuthStatus();
    debugPrint('Is Authenticated: $isAuthenticated');

    if (isAuthenticated && authProvider.user != null) {
      final user = authProvider.user!;
      final isNewUser = user.isNewUser ?? false;
      debugPrint('Is New User: $isNewUser');

      if (!isNewUser) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RootView()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => RegistrationPage(phoneNumber: user.phoneNumber)),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF005C45),
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedScale(
                      duration: const Duration(milliseconds: 500),
                      scale: _currentPage == index ? 1 : 0.9,
                      child: Image.asset(
                        _pages[index]['image']!,
                        fit: BoxFit.cover,
                        height: 280,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          Text(
                            _pages[index]['title']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _pages[index]['description']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            Positioned(
              bottom: 40,
              left: 24,
              right: 24,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => _completeIntro(),
                    child: const Text('Skip',
                        style: TextStyle(color: Colors.white)),
                  ),
                  Row(
                    children: List.generate(
                      _pages.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _nextPage,
                    child: const Text('Next',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
