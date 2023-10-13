import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:the_better_todolist/screens/home.dart';
import 'package:the_better_todolist/screens/sign-in.dart';

// GoRouter configuration
final router = GoRouter(
  routes: [
    GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(title: 'Better todolist'),
        redirect: (BuildContext context, GoRouterState state) {
          final supabase = Supabase.instance.client;
          final User? user = supabase.auth.currentUser;
          if (user == null) {
            return '/sign-in';
          }
          return null;
        }),
    GoRoute(path: '/sign-in', builder: (context, state) => const SignIn())
  ],
);
