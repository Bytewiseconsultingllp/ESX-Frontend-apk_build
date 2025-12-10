import 'package:esx/features/auth/provider/auth_provider.dart';
import 'package:esx/features/auth/view/login_screen.dart';
import 'package:esx/features/profile/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Header with ESX title
          Container(
            height: 100,
            width: double.infinity,
            color: Colors.grey[100],
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'ESX',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
          ),

          // Main section header
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'MAIN',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),

          // Menu items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildMenuItem(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Shop',
                  onTap: () {},
                ),
                _buildMenuItem(
                  icon: Icons.shopping_cart_outlined,
                  title: 'Orders',
                  onTap: () {},
                ),
                _buildMenuItem(
                  icon: Icons.person_outline,
                  title: 'Profile',
                  onTap: () {},
                  children: [
                    _buildSubMenuItem('Address', () {}),
                    _buildSubMenuItem('Bids', () {}),
                    _buildSubMenuItem('Payment Options', () {}),
                  ],
                ),
                _buildMenuItem(
                  icon: Icons.info_outline,
                  title: 'About us',
                  onTap: () {},
                ),
                _buildMenuItem(
                  icon: Icons.card_giftcard_outlined,
                  title: 'Rewards',
                  onTap: () {},
                ),
                _buildMenuItem(
                  icon: Icons.star_outline,
                  title: 'Rate the app',
                  onTap: () {},
                ),
                _buildMenuItem(
                  icon: Icons.notifications_none,
                  title: 'Notifications',
                  onTap: () {},
                  trailing: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      '12',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                _buildMenuItem(
                  icon: Icons.help_outline,
                  title: 'Help',
                  onTap: () {},
                ),
                _buildMenuItem(
                  icon: Icons.logout,
                  title: 'Logout Account',
                  onTap: () {
                    // Handle logout logic here
                    AuthProvider().logoutUser();
                    Navigator.pop(context); // Close the drawer after logout
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // User profile section at bottom
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: user?.profileImage != null
                      ? NetworkImage(user!.profileImage!)
                      : null,
                  backgroundColor: Colors.pink[100],
                  child: user?.profileImage == null
                      ? const Icon(Icons.person, color: Colors.pink)
                      : null,
                ),
                const SizedBox(width: 12),
                Text(
                  '${user?.firstName ?? ''} ${user?.lastName ?? ''}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
    List<Widget>? children,
  }) {
    return ExpansionTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
      ),
      trailing: trailing ?? const Icon(Icons.keyboard_arrow_down),
      children: children ?? [],
      onExpansionChanged: (expanded) {
        if (children == null) {
          onTap();
        }
      },
    );
  }

  Widget _buildSubMenuItem(String title, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 72, right: 16),
      title: Text(
        title,
        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
      ),
      onTap: onTap,
    );
  }
}
