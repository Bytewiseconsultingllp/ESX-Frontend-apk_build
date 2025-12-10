import 'package:esx/core/constants/colors.dart';
import 'package:esx/features/auth/provider/auth_provider.dart';
import 'package:esx/features/bid/provider/bid_provider.dart';
import 'package:esx/features/order/provider/order_provider.dart';
import 'package:esx/features/product/provider/product_provider.dart';
import 'package:esx/features/root/view/intro_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'features/profile/provider/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => BidProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: MaterialApp(
        title: 'ESX',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: ESXColors.primary),
          useMaterial3: true,
          fontFamily: 'Inter',
        ),
        home: const IntroPage(),
      ),
    ),
  );
}

// class EntryPoint extends StatefulWidget {
//   const EntryPoint({super.key});

//   @override
//   State<EntryPoint> createState() => _EntryPointState();
// }

// class _EntryPointState extends State<EntryPoint> {
//   bool _isInitializing = true;
//   Widget _initialScreen = const LoginScreen();

//   @override
//   void initState() {
//     super.initState();
//     _initializeApp();
//   }

//   Future<void> _initializeApp() async {
//     try {
//       final authProvider = context.read<AuthProvider>();

//       // Check if user is already authenticated
//       final isAuthenticated = await authProvider.checkAuthStatus();

//       if (isAuthenticated && authProvider.user != null) {
//         final user = authProvider.user!;
//         final isNewUser = user.isNewUser ?? false;

//         if (isNewUser) {
//           // User is authenticated and profile is complete -> Home page
//           _initialScreen = const RootView();
//         } else {
//           // User is authenticated but profile is incomplete -> Registration page
//           _initialScreen = RegistrationPage(phoneNumber: user.phoneNumber);
//         }
//       } else {
//         // User is not authenticated -> Login page
//         _initialScreen = const LoginScreen();
//       }
//     } catch (e) {
//       debugPrint('Error during app initialization: $e');
//       // Default to login screen on error
//       _initialScreen = const LoginScreen();
//     }

//     setState(() {
//       _isInitializing = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isInitializing) {
//       return const MaterialApp(
//         home: Scaffold(
//           body: Center(
//             child: CircularProgressIndicator(),
//           ),
//         ),
//       );
//     }

//     return ESXApp(initialScreen: _initialScreen);
//   }
// }

// class ESXApp extends StatefulWidget {
//   final Widget initialScreen;
//   const ESXApp({super.key, required this.initialScreen});

//   @override
//   State<ESXApp> createState() => _ESXAppState();
// }

// class _ESXAppState extends State<ESXApp> {
//   @override
//   void dispose() {
//     SocketService().dispose(); // Dispose of the socket service
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'ESX',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: ESXColors.primary),
//         useMaterial3: true,
//         fontFamily: 'Inter',
//       ),
//       home: AuthNavigationWrapper(child: widget.initialScreen),
//     );
//   }
// }

// // Wrapper to handle navigation based on auth state changes
// class AuthNavigationWrapper extends StatelessWidget {
//   final Widget child;

//   const AuthNavigationWrapper({super.key, required this.child});

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<AuthProvider>(
//       builder: (context, authProvider, _) {
//         // This will rebuild when auth state changes
//         if (authProvider.isAuthenticated && authProvider.user != null) {
//           return const RootView();
//         } else {
//           return const LoginScreen();
//         }
//       },
//     );
//   }
// }
