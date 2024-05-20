import 'package:go_router/go_router.dart';
import 'package:iesportocristo_exposed/screens/home_screen.dart';
import 'package:iesportocristo_exposed/screens/student_screen.dart';

final goRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
        path: '/student',
        builder: (context, state) => StudentScreen(
              studentName: state.uri.queryParameters['name'] ?? '',
            )),
  ],
);
