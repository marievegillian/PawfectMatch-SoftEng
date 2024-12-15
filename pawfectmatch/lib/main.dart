import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pawfectmatch/blocs/active_dog/active_dog_cubit.dart';
import 'package:pawfectmatch/blocs/bloc.dart';
import 'package:pawfectmatch/screens/screens.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pawfectmatch/services/locator.dart';
import 'firebase_options.dart';
//import 'models/models.dart';
import 'repositories/database_repository.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:uni_links3/uni_links.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: ".env");
  setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => DatabaseRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => SwipeBloc(
              databaseRepository: context.read<DatabaseRepository>(),
            ),
          ),
          BlocProvider(
            create: (_) => ActiveDogCubit(),
          ),
        ],
        child: MaterialApp(
          title: 'Flutter Demo',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme:
                ColorScheme.fromSeed(seedColor: const Color(0xff011F3F)),
            useMaterial3: true,
          ),
          //home: const SplashScreen(),
          routes: {
            '/': (context) => const SplashScreen(),
            '/map': (context) => MapScreen(),
            //'/dogs': (context) => const DogsScreen(dog: this.settings.argument as Dog),
            '/chats': (context) => const ChatListScreen(),
            //'/appointments': (context) => const AppointmentsScreen(), // Replace with the actual screen
            '/profile': (context) => const UserProfileScreen(),
          },
        ),
      ),
    );
  }
}


/*
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    // _handleInitialDeepLink();
    // _handleIncomingDeepLinks();
    _initializeDeepLinkHandling();
  }
  void _initializeDeepLinkHandling() async {
    // Handle initial deep link (when app is launched via link)
    final initialUri = await getInitialUri();
    if (initialUri != null && mounted) {
      _navigateFromUri(initialUri);
    }

    // Listen to incoming deep links (while app is running)
    _sub = uriLinkStream.listen((Uri? uri) {
      if (uri != null && mounted) {
        _navigateFromUri(uri);
      }
    }, onError: (err) {
      debugPrint('Deep link error: $err');
    });
  }
/*
  Future<void> _handleInitialDeepLink() async {
    // Handles the deep link when the app is launched
    final initialUri = await getInitialUri();
    if (initialUri != null) {
      _navigateFromUri(initialUri);
    }
  }

  void _handleIncomingDeepLinks() {
    // Handles deep links when the app is already running
    _sub = uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _navigateFromUri(uri);
      }
    }, onError: (err) {
      debugPrint('Failed to parse incoming URI: $err');
    });
  }
*/
  // void _navigateFromUri(Uri uri) {
  //   if (uri.scheme == 'yourapp') {
  //     if (uri.path == '/profile') {
  //       // Navigate to profile screen
  //       Navigator.pushNamedAndRemoveUntil(
  //           context, '/profile', (route) => false);
  //     } else {
  //       // Navigate to the default screen or home
  //       Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  //     }
  //   }
  // }
  void _navigateFromUri(Uri uri) {
    if (uri.scheme == 'yourapp') {
      String path = uri.path;
      switch (path) {
        case '/profile':
          _navigateToScreen('/profile');
          break;
        default:
          _navigateToScreen('/');
      }
    }
  }
  void _navigateToScreen(String route) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
    });
  }
  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => DatabaseRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => SwipeBloc(
              databaseRepository: context.read<DatabaseRepository>(),
            ),
          ),
          BlocProvider(
            create: (_) => ActiveDogCubit(),
          ),
        ],
        child: MaterialApp(
          title: 'Flutter Demo',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme:
                ColorScheme.fromSeed(seedColor: const Color(0xff011F3F)),
            useMaterial3: true,
          ),
          routes: {
            '/': (context) => const SplashScreen(),
            '/map': (context) => MapScreen(),
            '/chats': (context) => const ChatListScreen(),
            '/profile': (context) => const UserProfileScreen(),
          },
        ),
      ),
    );
  }
}
*/