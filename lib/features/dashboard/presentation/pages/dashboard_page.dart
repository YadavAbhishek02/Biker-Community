import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/auth_cubit.dart';
import '../../../../core/providers/events_cubit.dart';
import '../../../auth/domain/models/user_model.dart';
import '../../../events/domain/models/event_model.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState is AuthAuthenticated) {
          final user = authState.user;
          final isAdmin = user.role == UserRole.admin;

          return BlocBuilder<EventsCubit, EventsState>(
            builder: (context, eventsState) {
              final List<EventModel> events = (eventsState is EventsLoaded) 
                ? context.read<EventsCubit>().getUpcomingEvents(eventsState.events)
                : [];

              return Scaffold(
                appBar: AppBar(
                  title: const Text('RIDE TOGETHER', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  backgroundColor: Colors.black,
                  elevation: 0,
                  actions: [
                    IconButton(
                        icon: const Icon(Icons.refresh), 
                        onPressed: () => context.read<EventsCubit>().loadEvents(isRefresh: true)
                    )
                  ],
                ),
                drawer: _buildDrawer(context, user),
                body: Container(
                  color: Colors.black,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(user, isAdmin),
                      Expanded(
                        child: _buildEventsList(context, eventsState, events, user, isAdmin),
                      ),
                    ],
                  ),
                ),
                floatingActionButton: isAdmin
                    ? FloatingActionButton.extended(
                        onPressed: () => context.push('/create-event'),
                        backgroundColor: const Color(0xFFD32F2F),
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text('Create Ride', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      )
                    : null,
              );
            },
          );
        } else if (authState is AuthLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/login'));
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
      },
    );
  }

  Widget _buildDrawer(BuildContext context, UserModel user) {
    return Drawer(
      backgroundColor: const Color(0xFF1E1E1E),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Colors.black, border: Border(bottom: BorderSide(color: Color(0xFFD32F2F), width: 2))),
            accountName: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text(user.email),
            currentAccountPicture: CircleAvatar(
              backgroundImage: user.profileImageUrl != null ? NetworkImage(user.profileImageUrl!) : null,
              backgroundColor: const Color(0xFFD32F2F),
              child: user.profileImageUrl == null ? const Icon(Icons.person, color: Colors.white) : null,
            ),
          ),
          ListTile(leading: const Icon(Icons.home, color: Colors.white), title: const Text('Dashboard', style: TextStyle(color: Colors.white)), onTap: () => context.pop()),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.white),
            title: const Text('Profile', style: TextStyle(color: Colors.white)),
            onTap: () {
              context.pop();
              context.push('/profile');
            },
          ),
          const Divider(color: Colors.white24),
          ListTile(
            leading: const Icon(Icons.logout, color: Color(0xFFD32F2F)),
            title: const Text('Logout', style: TextStyle(color: Color(0xFFD32F2F))),
            onTap: () {
              context.read<AuthCubit>().logout();
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(UserModel user, bool isAdmin) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, Color(0xFF1E1E1E)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Welcome back,', style: TextStyle(fontSize: 14, color: Colors.grey[400])),
              const Spacer(),
              _buildRoleBadge(isAdmin),
            ],
          ),
          Text(user.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(bool isAdmin) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isAdmin ? const Color(0xFFD32F2F).withValues(alpha: 0.2) : Colors.green[400]!.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isAdmin ? const Color(0xFFD32F2F) : Colors.green[400]!),
      ),
      child: Text(
        isAdmin ? 'ADMIN' : 'RIDER',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isAdmin ? const Color(0xFFD32F2F) : Colors.green[400],
        ),
      ),
    );
  }

  Widget _buildEventsList(BuildContext context, EventsState state, List<EventModel> events, UserModel user, bool isAdmin) {
    if (state is EventsLoading && events.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFD32F2F)));
    }

    if (state is EventsError && events.isEmpty) {
      return _buildErrorView(context, state.message);
    }

    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.motorcycle, size: 64, color: Colors.grey[800]),
            const SizedBox(height: 16),
            Text('No upcoming rides. Check back later!', style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFFD32F2F),
      onRefresh: () async => context.read<EventsCubit>().loadEvents(isRefresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: events.length,
        itemBuilder: (context, index) => _buildEventCard(context, events[index], user, isAdmin),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFD32F2F), size: 48),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[400])),
          TextButton(onPressed: () => context.read<EventsCubit>().loadEvents(), child: const Text('RETRY')),
        ],
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, EventModel event, UserModel user, bool isAdmin) {
    final isJoined = event.participants.any((p) => p.id == user.id);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isJoined ? const Color(0xFFD32F2F) : Colors.transparent, width: 2),
      ),
      child: InkWell(
        onTap: () => context.push('/event/${event.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(event.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                  if (isJoined || isAdmin) _buildChatActiveBadge(),
                  if (isJoined) ...[
                    const SizedBox(width: 8),
                    _buildJoinedBadge(),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              _buildIconText(Icons.calendar_today, DateFormat('MMM dd, yyyy \u2022 hh:mm a').format(event.date)),
              const SizedBox(height: 8),
              _buildIconText(Icons.location_on, event.meetupLocation),
              const SizedBox(height: 16),
              _buildParticipantCount(event.participants.length),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatActiveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble, size: 10, color: Colors.blueAccent),
          SizedBox(width: 4),
          Text('LIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
        ],
      ),
    );
  }

  Widget _buildJoinedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFFD32F2F), borderRadius: BorderRadius.circular(12)),
      child: const Text('JOINED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(color: Colors.grey, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _buildParticipantCount(int count) {
    return Row(
      children: [
        Icon(Icons.directions_bike, size: 18, color: Colors.green[400]),
        const SizedBox(width: 8),
        Text('$count riders going', style: TextStyle(color: Colors.green[400], fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}
