import '../../domain/models/event_model.dart';
import '../../../../core/api/api_client.dart';

abstract class EventRemoteDataSource {
  Future<List<EventModel>> getEvents();
  Future<EventModel> createEvent(EventModel event);
  Future<void> joinEvent(String eventId);
  Future<void> leaveEvent(String eventId);
  Future<void> removeRider(String eventId, String userId);
}

class EventRemoteDataSourceImpl implements EventRemoteDataSource {
  final ApiClient apiClient;

  EventRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<EventModel>> getEvents() async {
    try {
      final response = await apiClient.dio.get('/events');
      if (response.statusCode == 200) {
        final List data = response.data['data'];
        return data.map((e) => EventModel.fromMap(e, null)).toList();
      } else {
        throw Exception('Failed to fetch events');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<EventModel> createEvent(EventModel event) async {
    try {
      final response = await apiClient.dio.post('/events', data: {
        'title': event.title,
        'description': event.description,
        'date': event.date.toIso8601String(),
        'meetupLocation': event.meetupLocation,
        'latitude': event.latitude,
        'longitude': event.longitude,
      });

      if (response.statusCode == 201) {
        return EventModel.fromMap(response.data['data'], null);
      } else {
        throw Exception('Failed to create event');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> joinEvent(String eventId) async {
    try {
      await apiClient.dio.post('/events/$eventId/join');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> leaveEvent(String eventId) async {
    try {
      await apiClient.dio.delete('/events/$eventId/leave');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> removeRider(String eventId, String userId) async {
    try {
      await apiClient.dio.delete('/events/$eventId/riders/$userId');
    } catch (e) {
      rethrow;
    }
  }
}
