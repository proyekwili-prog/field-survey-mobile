import 'package:flutter_application_1/screens/auth/login_page.dart';
import 'package:flutter_application_1/screens/splash/splash_screen.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';

class AppPages {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
    ],
  );
}