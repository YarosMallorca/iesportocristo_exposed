import 'package:go_router/go_router.dart';
import 'package:iesportocristo_exposed/auth/auth_manager.dart';
import 'package:iesportocristo_exposed/screens/home_screen.dart';
import 'package:iesportocristo_exposed/screens/meme_screen.dart';
import 'package:iesportocristo_exposed/screens/memes_screen.dart';
import 'package:iesportocristo_exposed/screens/profile_screen.dart';
import 'package:iesportocristo_exposed/screens/student_screen.dart';
import 'package:iesportocristo_exposed/screens/students_screen.dart';
import 'package:iesportocristo_exposed/screens/teacher_screen.dart';
import 'package:iesportocristo_exposed/screens/teachers_screen.dart';
import 'package:provider/provider.dart';

final goRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/perfil',
      builder: (context, state) => ProfileScreen(
        userId: state.uri.queryParameters['uid'],
      ),
      redirect: (context, state) async {
        final authManager = Provider.of<AuthManager>(context, listen: false);
        if (authManager.user == null &&
            state.uri.queryParameters['uid'] == null) {
          authManager.signInWithGoogle();
          return '/';
        }

        return null;
      },
    ),
    GoRoute(
      path: '/alumnos',
      builder: (context, state) => const StudentsScreen(),
    ),
    GoRoute(
      path: '/alumno',
      builder: (context, state) => StudentScreen(
        studentName: state.uri.queryParameters['name'] ?? '',
      ),
    ),
    GoRoute(
      path: '/profes',
      builder: (context, state) => const TeachersScreen(),
    ),
    GoRoute(
      path: '/profe',
      builder: (context, state) => TeacherScreen(
        teacherName: state.uri.queryParameters['name'] ?? '',
      ),
    ),
    GoRoute(
      path: '/meme',
      builder: (context, state) => MemeScreen(
        memeId: state.uri.queryParameters['id'] ?? '',
      ),
    ),
    GoRoute(path: '/memes', builder: (context, state) => const MemesScreen()),
  ],
);
