import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:the_wallpaper_company/core/constants.dart';
import 'package:the_wallpaper_company/features/favorite/provider/favorite_provider.dart';
import 'package:the_wallpaper_company/features/home/presentation/screen/home_screen.dart';
import 'package:the_wallpaper_company/features/home/provider/wallpaper_provider.dart';
import 'package:the_wallpaper_company/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WallpaperProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()..init()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;
  @override
  void initState() {
    super.initState();
    _initRemoteConfig();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'The Wallpaper Co.',
      theme: _isDarkMode
          ? ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black)
          : ThemeData.light().copyWith(
              appBarTheme: const AppBarTheme(
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: Color(0xFFF5F5F5),
                  statusBarIconBrightness: Brightness.dark, // dark icons
                  statusBarBrightness: Brightness.light, // for iOS
                ),
              ),
            ),
      home: const HomeScreen(),
    );
  }

  void _initRemoteConfig() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: Duration.zero,
        ),
      );
      await remoteConfig.fetchAndActivate();
      setState(() {
        _isDarkMode = remoteConfig.getBool(AppConstants.remoteConfigKey);
        debugPrint('hello Dark Mode:[${_isDarkMode}');
      });
      remoteConfig.onConfigUpdated.listen((event) async {
        await remoteConfig.activate();
        setState(() {
          _isDarkMode = remoteConfig.getBool(AppConstants.remoteConfigKey);
        });
      });
    } catch (e, stack) {
      debugPrint('RemoteConfig error: $e');
      debugPrint('Stack: $stack');
    }
  }
}
