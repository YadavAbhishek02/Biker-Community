import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/auth_cubit.dart';
import '../../../../core/providers/events_cubit.dart';
import '../../../auth/domain/models/user_model.dart';
import '../../../events/domain/models/event_model.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState is AuthAuthenticated) {
          final user = authState.user;
          return BlocBuilder<EventsCubit, EventsState>(
            builder: (context, eventsState) {
              final List<EventModel> myEvents = (eventsState is EventsLoaded)
                  ? eventsState.events.where((e) => e.participants.any((p) => p.id == user.id)).toList()
                  : [];

              final List<EventModel> upcoming = myEvents.where((e) => e.date.isAfter(DateTime.now())).toList()
                ..sort((a, b) => a.date.compareTo(b.date));
              final List<EventModel> past = myEvents.where((e) => e.date.isBefore(DateTime.now())).toList()
                ..sort((a, b) => b.date.compareTo(a.date));

              return Scaffold(
                appBar: AppBar(
                  title: const Text('My Profile'),
                  backgroundColor: Colors.black,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.logout, color: Color(0xFFD32F2F)),
                      onPressed: () {
                        context.read<AuthCubit>().logout();
                        context.go('/login');
                      },
                    )
                  ],
                ),
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildProfileHeader(user),
                      _buildSection('Upcoming Rides', upcoming, Icons.calendar_month),
                      _buildSection('Riding History', past, Icons.verified, isPast: true),
                    ],
                  ),
                ),
              );
            },
          );
        } else if (authState is AuthLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        } else {
          return const Scaffold(body: Center(child: Text('Not logged in')));
        }
      },
    );
  }

  Widget _buildProfileHeader(UserModel user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        border: Border(bottom: BorderSide(color: Colors.white12)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: user.profileImageUrl != null ? NetworkImage(user.profileImageUrl!) : null,
            backgroundColor: Colors.grey[800],
            child: user.profileImageUrl == null ? const Icon(Icons.person, size: 50, color: Colors.white) : null,
          ),
          const SizedBox(height: 16),
          Text(user.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(user.bikeModel ?? 'No bike added', style: TextStyle(fontSize: 16, color: Colors.grey[400])),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFD32F2F).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
            child: Text(user.role.name.toUpperCase(), style: const TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<EventModel> events, IconData icon, {bool isPast = false}) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (events.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text('No rides to show.', style: TextStyle(color: Colors.grey[600])),
              ),
            )
          else
            ...events.map((event) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: const Color(0xFF2A2A2A),
                  child: ListTile(
                    onTap: () => (context) => GoRouter.of(context).push('/event/${event.id}'),
                    leading: Icon(icon, color: isPast ? Colors.green : const Color(0xFFD32F2F)),
                    title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(DateFormat('MMM dd, yyyy').format(event.date)),
                    trailing: const Icon(Icons.chevron_right, size: 16),
                  ),
                )),
        ],
      ),
    );
  }
}
