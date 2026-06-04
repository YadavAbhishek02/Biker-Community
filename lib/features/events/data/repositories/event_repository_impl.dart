import '../../domain/models/event_model.dart';
import '../../domain/repositories/event_repository.dart';
import '../datasources/event_remote_data_source.dart';

class EventRepositoryImpl implements EventRepository {
  final EventRemoteDataSource remoteDataSource;

  EventRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<EventModel>> getEvents() async {
    return await remoteDataSource.getEvents();
  }

  @override
  Future<EventModel> createEvent(EventModel event) async {
    return await remoteDataSource.createEvent(event);
  }

  @override
  Future<void> joinEvent(String eventId) async {
    await remoteDataSource.joinEvent(eventId);
  }

  @override
  Future<void> leaveEvent(String eventId) async {
    await remoteDataSource.leaveEvent(eventId);
  }

  @override
  Future<void> removeRider(String eventId, String userId) async {
    await remoteDataSource.removeRider(eventId, userId);
  }
}
