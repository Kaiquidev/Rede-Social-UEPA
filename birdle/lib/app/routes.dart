import 'package:flutter/material.dart';

import '../features/admin/admin_dashboard_page.dart';
import '../features/auth/login_page.dart';
import '../features/auth/register_page.dart';
import '../features/feed/feed_page.dart';
import '../features/profile/profile_page.dart';
import '../features/profile/public_profile_page.dart';
import '../features/search/search_page.dart';
import '../features/splash/splash_page.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String feed = '/feed';
  static const String profile = '/profile';
  static const String publicProfile = '/public-profile';
  static const String search = '/search';
  static const String admin = '/admin';

  static Map<String, WidgetBuilder> routes = {
    splash: (_) => const SplashPage(),
    login: (_) => const LoginPage(),
    register: (_) => const RegisterPage(),
    feed: (_) => const FeedPage(),
    profile: (_) => const ProfilePage(),
    publicProfile: (_) => const PublicProfilePage(),
    search: (_) => const SearchPage(),
    admin: (_) => const AdminDashboardPage(),
  };
}
