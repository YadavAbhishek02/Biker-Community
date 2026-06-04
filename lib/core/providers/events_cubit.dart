import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:biker_community/features/events/domain/models/event_model.dart';
import 'package:biker_community/features/events/domain/repositories/event_repository.dart';

abstract class EventsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class EventsInitial extends EventsState {}
class EventsLoading extends EventsState {}
class EventsLoaded extends EventsState {
  final List<EventModel> events;
  final bool isRefreshing;
  EventsLoaded(this.events, {this.isRefreshing = false});
  @override
  List<Object?> get props => [events, isRefreshing];
}
class EventsError extends EventsState {
  final String message;
  EventsError(this.message);
  @override
  List<Object?> get props => [message];
}

class EventsCubit extends Cubit<EventsState> {
  final EventRepository _eventRepository;

  EventsCubit(this._eventRepository) : super(EventsInitial()) {
    loadEvents();
  }

  Future<void> loadEvents({bool isRefresh = false}) async {
    if (!isRefresh) emit(EventsLoading());
    try {
      final events = await _eventRepository.getEvents();
      emit(EventsLoaded(events));
    } catch (e) {
      emit(EventsError(e.toString()));
    }
  }

  Future<void> addEvent(EventModel event) async {
    final currentState = state;
    List<EventModel> currentEvents = [];
    if (currentState is EventsLoaded) {
      currentEvents = currentState.events;
    }

    try {
      final newEvent = await _eventRepository.createEvent(event);
      // Success: Emit Loaded with new event immediately
      emit(EventsLoaded([...currentEvents, newEvent]));
    } catch (e) {
      emit(EventsError(e.toString()));
    }
  }

  Future<void> joinEvent(String eventId) async {
    try {
      await _eventRepository.joinEvent(eventId);
      await loadEvents(isRefresh: true);
    } catch (e) {
      emit(EventsError(e.toString()));
    }
  }

  Future<void> leaveEvent(String eventId) async {
    try {
      await _eventRepository.leaveEvent(eventId);
      await loadEvents(isRefresh: true);
    } catch (e) {
      emit(EventsError(e.toString()));
    }
  }

  Future<void> removeRider(String eventId, String userId) async {
    try {
      await _eventRepository.removeRider(eventId, userId);
      await loadEvents(isRefresh: true);
    } catch (e) {
      emit(EventsError(e.toString()));
    }
  }

  List<EventModel> getUpcomingEvents(List<EventModel> events) {
    return events.where((event) => event.date.isAfter(DateTime.now())).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }
  
  List<EventModel> getPastEvents(List<EventModel> events) {
    return events.where((event) => event.date.isBefore(DateTime.now())).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
}
