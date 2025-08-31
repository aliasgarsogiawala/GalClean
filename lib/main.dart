import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/gallery_screen.dart';
import 'screens/swipe_screen.dart';
import 'screens/summary_screen.dart';
import 'screens/welcome_screen.dart';
import 'services/gallery_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GalleryService()),
      ],
      child: MaterialApp(
        title: 'Gallery Cleaner',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: '/welcome',
        routes: {
          '/welcome': (context) => const WelcomeScreen(),
          '/': (context) => const HomeScreen(),
          '/gallery': (context) => const GalleryScreen(),
          '/swipe': (context) => const SwipeScreen(),
          '/summary': (context) => const SummaryScreen(),
        },
      ),
    );
  }
}
