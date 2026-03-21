import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/meal_plan_screen.dart';
import 'screens/add_recipe_screen.dart';
import 'screens/recipe_detail_screen.dart';
import 'screens/profile_screen.dart';
import 'models/recipe_model.dart';

import 'service_locator.dart';

void main() {
  locator.init();
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: '/meal_plan',
      builder: (context, state) => const MealPlanScreen(),
    ),
    GoRoute(
      path: '/add_recipe',
      builder: (context, state) => const AddRecipeScreen(),
    ),
    GoRoute(
      path: '/recipe_detail',
      builder: (context, state) {
        final recipe = state.extra as RecipeModel?;
        return RecipeDetailScreen(recipe: recipe);
      },
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FreshBite Recipes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF53d22d),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.manropeTextTheme(
          Theme.of(context).textTheme,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF53d22d),
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.manropeTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}
