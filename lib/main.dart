import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:biker_community/core/services/notification_service.dart';
import 'package:biker_community/core/theme/app_theme.dart';
import 'package:biker_community/core/utils/router.dart';
import 'package:biker_community/core/providers/auth_cubit.dart';
import 'package:biker_community/core/providers/events_cubit.dart';
import 'package:biker_community/core/injection_container.dart' as di;
import 'package:biker_community/features/auth/domain/repositories/auth_repository.dart';
import 'package:biker_community/features/events/domain/repositories/event_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  // Initialize Dependency Injection
  await di.init();

  // Run the app FIRST — don't block on network calls
  runApp(const BikerCommunityApp());

  // Initialize Notifications AFTER app is running (non-blocking)
  try {
    final notificationService = di.sl<NotificationService>();
    await notificationService.initialize();
  } catch (e) {
    debugPrint('Notification init error: $e');
  }
}

class BikerCommunityApp extends StatelessWidget {
  const BikerCommunityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(di.sl<AuthRepository>()),
        ),
        BlocProvider<EventsCubit>(
          create: (context) => EventsCubit(di.sl<EventRepository>()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Biker Community',
        theme: AppTheme.darkTheme,
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
