import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/providers/auth_cubit.dart';
import '../../../../core/providers/events_cubit.dart';
import '../../../auth/domain/models/user_model.dart';
import '../../../chat/presentation/pages/chat_page.dart';
import '../../domain/models/event_model.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EventDetailsPage extends StatelessWidget {
  final String eventId;
  const EventDetailsPage({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventsCubit, EventsState>(
      builder: (context, state) {
        if (state is EventsLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        
        if (state is EventsLoaded) {
          final event = state.events.firstWhere((e) => e.id == eventId,
              orElse: () => EventModel(
                    id: '',
                    title: 'Not Found',
                    description: '',
                    date: DateTime.now(),
                    meetupLocation: '',
                    latitude: 0,
                    longitude: 0,
                    createdBy: '',
                  ));

          if (event.id.isEmpty) {
            return const Scaffold(body: Center(child: Text('Event not found')));
          }

          return BlocBuilder<AuthCubit, AuthState>(
            builder: (context, authState) {
              final user = (authState is AuthAuthenticated) ? authState.user : null;
              final bool isJoined = user != null && event.participants.any((p) => p.id == user.id);
              final bool isAdmin = user?.role == UserRole.admin;

              return Scaffold(
                body: CustomScrollView(
                  slivers: [
                    _buildAppBar(event),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow(Icons.calendar_today, DateFormat('MMM dd, yyyy \u2022 hh:mm a').format(event.date)),
                            const SizedBox(height: 12),
                            _buildInfoRow(Icons.location_on, event.meetupLocation),
                            const SizedBox(height: 24),
                            const Text('About the Ride', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(event.description, style: TextStyle(fontSize: 16, color: Colors.grey[400], height: 1.5)),
                            const SizedBox(height: 32),
                            _buildParticipantsList(context, event, isAdmin),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                floatingActionButton: (isJoined || isAdmin)
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 80.0), // Above the bottom sheet
                        child: FloatingActionButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatPage(eventId: event.id, eventTitle: event.title),
                              ),
                            );
                          },
                          backgroundColor: const Color(0xFFD32F2F),
                          foregroundColor: Colors.white,
                          elevation: 8,
                          child: const Icon(Icons.forum_rounded),
                        ),
                      )
                    : null,
                bottomSheet: _buildBottomBar(context, event, user, isJoined),
              );
            },
          );
        }
        
        return const Scaffold(body: Center(child: Text('Something went wrong')));
      },
    );
  }

  Widget _buildAppBar(EventModel event) {
    return SliverAppBar(
      expandedHeight: 250.0,
      pinned: true,
      backgroundColor: const Color(0xFF1E1E1E),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        background: Stack(
          fit: StackFit.expand,
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(event.latitude == 0 ? 37.7749 : event.latitude, event.longitude == 0 ? -122.4194 : event.longitude),
                zoom: 14.0,
              ),
              markers: {
                Marker(
                  markerId: MarkerId(event.id),
                  position: LatLng(event.latitude == 0 ? 37.7749 : event.latitude, event.longitude == 0 ? -122.4194 : event.longitude),
                ),
              },
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFD32F2F), size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
      ],
    );
  }

  Widget _buildParticipantsList(BuildContext context, EventModel event, bool isAdmin) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Riders Joined', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFFD32F2F).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
              child: Text('${event.participants.length}', style: const TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.bold)),
            )
          ],
        ),
        const SizedBox(height: 16),
        if (event.participants.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: event.participants.length,
            itemBuilder: (context, itemIndex) {
              final rider = event.participants[itemIndex];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFD32F2F),
                  child: Text(rider.name[0], style: const TextStyle(color: Colors.white)),
                ),
                title: Text(rider.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(rider.bikeModel ?? 'Riding soon', style: TextStyle(color: Colors.grey[400])),
                trailing: isAdmin ? IconButton(
                  icon: const Icon(Icons.person_remove_outlined, color: Colors.redAccent, size: 20),
                  onPressed: () {
                    _showRemoveRiderDialog(context, event.id, rider);
                  },
                ) : null,
              );
            },
          )
        else
          Text('Be the first to join this ride!', style: TextStyle(color: Colors.grey[500])),
      ],
    );
  }

  void _showRemoveRiderDialog(BuildContext context, String eventId, Participant rider) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove Rider'),
        content: Text('Are you sure you want to remove ${rider.name} from this ride?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('CANCEL')),
          TextButton(
            onPressed: () {
              context.read<EventsCubit>().removeRider(eventId, rider.id);
              Navigator.pop(dialogContext);
            },
            child: const Text('REMOVE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, EventModel event, UserModel? user, bool isJoined) {
    if (user == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      color: const Color(0xFF1E1E1E),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (isJoined) {
                context.read<EventsCubit>().leaveEvent(event.id);
              } else {
                context.read<EventsCubit>().joinEvent(event.id);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isJoined ? Colors.grey[800] : const Color(0xFFD32F2F),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              isJoined ? 'LEAVE RIDE' : 'JOIN RIDE',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
