import 'package:get_it/get_it.dart';
import 'package:biker_community/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:biker_community/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:biker_community/features/auth/domain/repositories/auth_repository.dart';
import 'package:biker_community/features/events/data/datasources/event_remote_data_source.dart';
import 'package:biker_community/features/events/data/repositories/event_repository_impl.dart';
import 'package:biker_community/features/events/domain/repositories/event_repository.dart';
import 'package:biker_community/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:biker_community/features/chat/domain/repositories/chat_repository.dart';
import 'package:biker_community/core/services/notification_service.dart';
import 'package:biker_community/core/api/api_client.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core
  sl.registerLazySingleton(() => ApiClient());
  sl.registerLazySingleton(() => NotificationService(sl()));

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<EventRemoteDataSource>(
    () => EventRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(apiClient: sl()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<EventRepository>(
    () => EventRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(remoteDataSource: sl()),
  );
}
