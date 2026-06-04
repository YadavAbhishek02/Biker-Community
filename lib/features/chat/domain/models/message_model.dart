import 'package:equatable/equatable.dart';

class MessageModel extends Equatable {
  final String id;
  final String eventId;
  final String userId;
  final String userName;
  final String userRole;
  final String content;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.content,
    required this.createdAt,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] ?? '',
      eventId: map['event_id'] ?? '',
      userId: map['user_id'] ?? '',
      userName: map['user_name'] ?? 'Unknown',
      userRole: map['user_role'] ?? 'user',
      content: map['content'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  @override
  List<Object?> get props => [id, eventId, userId, userName, userRole, content, createdAt];
}
