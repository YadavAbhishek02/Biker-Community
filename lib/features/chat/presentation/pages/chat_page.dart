import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/injection_container.dart';
import '../../../../core/providers/auth_cubit.dart';
import '../bloc/chat_bloc.dart';
import '../../domain/models/message_model.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatelessWidget {
  final String eventId;
  final String eventTitle;

  const ChatPage({super.key, required this.eventId, required this.eventTitle});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatBloc(
        chatRepository: sl(),
        eventId: eventId,
      )..add(FetchMessages()),
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ride Chat',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(eventTitle,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          backgroundColor: const Color(0xFF1E1E1E),
        ),
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  if (state is ChatLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is ChatError) {
                    return Center(
                        child: Text(state.message,
                            style: const TextStyle(color: Colors.red)));
                  }
                  if (state is ChatLoaded) {
                    final messages = state.messages;
                    if (messages.isEmpty) {
                      return const Center(
                          child: Text('No messages yet. Say hi!'));
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        return _MessageBubble(message: message);
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            _ChatInput(eventId: eventId),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final bool isMe = authState is AuthAuthenticated && authState.user.id == message.userId;
    final bool isAdmin = message.userRole == 'admin';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, right: 4, bottom: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isAdmin) ...[
                  const Icon(Icons.shield, size: 14, color: Colors.amber),
                  const SizedBox(width: 4),
                ],
                Text(
                  isMe ? "You" : message.userName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isAdmin ? Colors.amber : Colors.grey[400],
                  ),
                ),
                if (isAdmin)
                  Container(
                    margin: const EdgeInsets.only(left: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.5), width: 0.5),
                    ),
                    child: const Text(
                      'OFFICIAL ADMIN',
                      style: TextStyle(fontSize: 8, color: Colors.amber, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: isMe
                  ? LinearGradient(
                      colors: isAdmin ? [const Color(0xFFFBC02D), const Color(0xFFF57F17)] : [const Color(0xFFD32F2F), const Color(0xFFB71C1C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      colors: isAdmin ? [const Color(0xFF1A1A1A), const Color(0xFF2C2C2C)] : [Colors.grey[850]!, Colors.grey[900]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 0),
                bottomRight: Radius.circular(isMe ? 0 : 16),
              ),
              border: isAdmin ? Border.all(color: Colors.amber.withValues(alpha: 0.5), width: 1.5) : null,
              boxShadow: [
                BoxShadow(
                  color: isAdmin ? Colors.amber.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.2),
                  blurRadius: isAdmin ? 8 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            child: IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isAdmin && isMe ? Colors.black : Colors.white,
                      fontSize: 15,
                      height: 1.4,
                      fontWeight: isAdmin ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        DateFormat('hh:mm a').format(message.createdAt),
                        style: TextStyle(
                          fontSize: 9,
                          color: isAdmin && isMe ? Colors.black.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ChatInput extends StatefulWidget {
  final String eventId;
  const _ChatInput({required this.eventId});

  @override
  State<_ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<_ChatInput> {
  final TextEditingController _controller = TextEditingController();

  void _send() {
    if (_controller.text.trim().isNotEmpty) {
      context.read<ChatBloc>().add(SendMessage(_controller.text.trim()));
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: const Color(0xFF1E1E1E),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _send,
              icon: const Icon(Icons.send, color: Color(0xFFD32F2F)),
            ),
          ],
        ),
      ),
    );
  }
}
