import 'package:flutter_application_1/screens/auth/register_page.dart';
import 'package:flutter_application_1/screens/splash/edit_profil_page.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth/login_page.dart';
import '../screens/dashboard/dashboard_page.dart';
import 'app_routes.dart';

class AppPages {
  static final router = GoRouter(
    initialLocation: AppRoutes.login,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),

      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
      path: '/edit-profil',
      builder: (context, state) => const EditProfilePage(), // sesuaikan nama class halaman edit profilmu
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(), // Sesuaikan dengan nama class Register kamu
    ),
    ],
  );
}