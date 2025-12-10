import 'package:esx/features/bids/view/bids_tab_page.dart';
import 'package:esx/features/home/view/home_screen.dart';
import 'package:esx/features/order/view/user_order_page.dart';
import 'package:esx/features/profile/view/profile_screen.dart';
import 'package:flutter/material.dart';

class RootView extends StatefulWidget {
  const RootView({Key? key}) : super(key: key);

  @override
  State<RootView> createState() => _RootViewState();
}

class _RootViewState extends State<RootView> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<Widget> _pages = [
    Center(child: HomeScreen()),
    Center(child: BidsTabPage()),
    Center(child: Text('')),
    Center(child: UserOrdersPage()),
    Center(child: ProfileScreen()),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200), // Made faster
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack, // Changed to a snappier curve
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 100),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: SizedBox(
        height: 80 + bottomPadding,
        child: Stack(
          children: [
            // Main navigation bar container
            Positioned(
              bottom: 2,
              left: 0,
              right: 0,
              child: Container(
                height: 65 + bottomPadding,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2C),
                  borderRadius: BorderRadius.circular(35),
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 8,
                    bottom: bottomPadding + 8,
                    left: 20,
                    right: 20,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(_navIcons.length, (index) {
                      final isSelected = index == _selectedIndex;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => _onItemTapped(index),
                          behavior: HitTestBehavior.translucent,
                          child: Container(
                            height: 40,
                            child: Center(
                              child: Icon(
                                _navIcons[index],
                                color: isSelected
                                    ? Colors.transparent
                                    : Colors.grey[400],
                                size: 26,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),

            // Floating selected item - simplified and faster
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                final itemWidth = (screenWidth - 80) / _navIcons.length;
                final selectedPosition =
                    40 + (itemWidth * _selectedIndex) + (itemWidth / 2) - 30;

                return AnimatedPositioned(
                  duration: const Duration(
                      milliseconds: 150), // Faster position animation
                  curve: Curves.easeOutCubic,
                  left: selectedPosition,
                  bottom:
                      15 + bottomPadding, // Fixed position, no sliding up/down
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00695C),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00695C).withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        _navIcons[_selectedIndex],
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

final List<IconData> _navIcons = [
  Icons.home_outlined,
  Icons.access_time_outlined,
  Icons.search,
  Icons.shopping_cart_outlined,
  Icons.person_outline,
];
