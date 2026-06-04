import 'package:equatable/equatable.dart';

class EventModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String meetupLocation;
  final double latitude;
  final double longitude;
  final String createdBy;
  final List<Participant> participants;

  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.meetupLocation,
    required this.latitude,
    required this.longitude,
    required this.createdBy,
    this.participants = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'meetupLocation': meetupLocation,
      'latitude': latitude,
      'longitude': longitude,
      'createdBy': createdBy,
    };
  }

  factory EventModel.fromMap(Map<String, dynamic> map, String? id) {
    return EventModel(
      id: id ?? map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: DateTime.parse(map['date']),
      meetupLocation: map['meetupLocation'] ?? map['meetup_location'] ?? '',
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      createdBy: map['createdBy'] ?? map['created_by'] ?? '',
      participants: (map['participants'] as List?)
              ?.map((p) => Participant.fromMap(p))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [id, title, description, date, meetupLocation, latitude, longitude, createdBy, participants];
}

class Participant extends Equatable {
  final String id;
  final String name;
  final String? bikeModel;

  const Participant({required this.id, required this.name, this.bikeModel});

  factory Participant.fromMap(dynamic data) {
    if (data is String) {
      return Participant(id: data, name: 'Unknown');
    }
    return Participant(
      id: data['id'] ?? '',
      name: data['name'] ?? 'Unknown',
      bikeModel: data['bikeModel'],
    );
  }

  @override
  List<Object?> get props => [id, name, bikeModel];
}
