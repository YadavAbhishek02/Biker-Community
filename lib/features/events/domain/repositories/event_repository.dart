import '../models/event_model.dart';

abstract class EventRepository {
  Future<List<EventModel>> getEvents();
  Future<EventModel> createEvent(EventModel event);
  Future<void> joinEvent(String eventId);
  Future<void> leaveEvent(String eventId);
  Future<void> removeRider(String eventId, String userId);
}
