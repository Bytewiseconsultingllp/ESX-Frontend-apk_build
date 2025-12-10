import 'package:esx/core/widgets/app_header.dart';
import 'package:esx/features/auth/view/login_screen.dart';
import 'package:esx/features/profile/models/user_model.dart';
import 'package:esx/features/profile/view/address_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:esx/features/auth/provider/auth_provider.dart';
import 'package:esx/features/profile/provider/user_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppHeader(),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50],
      body: const ProfileBody(),
    );
  }
}

class ProfileBody extends StatefulWidget {
  const ProfileBody({Key? key}) : super(key: key);

  @override
  State<ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody>
    with AutomaticKeepAliveClientMixin {
  // Keep the widget alive when switching tabs
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Selector<UserProvider, User?>(
      selector: (context, userProvider) => userProvider.user,
      builder: (context, user, child) {
        return RefreshIndicator(
          onRefresh: _handleRefresh,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.white,
                elevation: 1,
                pinned: true,
                automaticallyImplyLeading:
                    false, // Remove back button for bottom nav
                title: const Text(
                  'Profile',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                centerTitle: true,
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _ProfileHeader(user: user),
                    const SizedBox(height: 2),
                    _ProfileMenuList(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleRefresh() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.fetchUserProfile();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile refreshed successfully')),
        );
      }
      // Add actual refresh logic here if your UserProvider has a refresh method
      // await userProvider.refreshUser();
      await Future.delayed(const Duration(milliseconds: 500)); // Placeholder
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to refresh profile')),
        );
      }
    }
  }
}

class _ProfileHeader extends StatelessWidget {
  final User? user;

  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Hero(
            tag: 'profile_avatar',
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey[200],
              backgroundImage: user?.profileImage != null
                  ? NetworkImage(user!.profileImage!)
                  : null,
              child: user?.profileImage == null
                  ? Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.grey[600],
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user?.displayName ?? 'Guest User',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          if (user?.email.isNotEmpty == true) ...[
            const SizedBox(height: 4),
            Text(
              user!.email,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
          if (user?.phoneNumber.isNotEmpty == true) ...[
            const SizedBox(height: 2),
            Text(
              user!.formattedPhoneNumber,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProfileMenuList extends StatelessWidget {
  static const _menuItems = [
    _MenuItem(
      icon: Icons.edit_outlined,
      title: 'Edit Profile',
      route: '/edit-profile',
    ),
    _MenuItem(
      icon: Icons.shopping_bag_outlined,
      title: 'Order History',
      route: '/order-history',
    ),
    _MenuItem(
      icon: Icons.location_on_outlined,
      title: 'Shipping Details',
      route: '/shipping-details',
    ),
    _MenuItem(
      icon: Icons.notifications_outlined,
      title: 'Notifications',
      route: '/notifications',
    ),
    _MenuItem(
      icon: Icons.help_outline,
      title: 'Help & Support',
      route: '/support',
    ),
    _MenuItem(
      icon: Icons.privacy_tip_outlined,
      title: 'Privacy Policy',
      route: '/privacy',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          ..._menuItems
              .map((item) => [
                    _buildMenuItem(context, item),
                    _buildDivider(),
                  ])
              .expand((e) => e),
          _buildLogoutMenuItem(context),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, _MenuItem item) {
    return InkWell(
      onTap: () => _handleMenuTap(context, item),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(item.icon, color: Colors.grey[600], size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                item.title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutMenuItem(BuildContext context) {
    return InkWell(
      onTap: () => _handleLogout(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(Icons.logout_outlined, color: Colors.red[600], size: 24),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'Log Out',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey[200],
      indent: 60,
    );
  }

  void _handleMenuTap(BuildContext context, _MenuItem item) {
    // Navigate to the appropriate screen
    // Navigator.pushNamed(context, item.route);
    if (item.route == '/shipping-details') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddressListScreen()),
      );
      return;
    }
    // For now, show a placeholder
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item.title} - Coming Soon')),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await _showLogoutConfirmation(context);
    if (!confirmed) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final success = await authProvider.logoutUser();

      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog

        if (success) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Failed to log out. Please try again.')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred during logout')),
        );
      }
    }
  }

  Future<bool> _showLogoutConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String route;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.route,
  });
}
