import 'dart:ui';

import 'package:flutter/material.dart';
import 'create_event_screen.dart';
import 'auth_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:event_app/data/category_enum.dart';
import 'package:event_app/data/event_model.dart';
import 'package:event_app/data/ticket_model.dart';
import 'package:event_app/services/api_service.dart';
import 'package:event_app/services/payment/payment_models.dart';
import 'checkout_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'for_venues_screen.dart';
import 'my_tickets_screen.dart';
import 'saved_events_screen.dart';
import 'interests_screen.dart';
import 'settings_screen.dart';
import 'package:event_app/utils/calendar_helper.dart';

class HomeScreen extends StatefulWidget {
  final List<String> selectedInterests;

  const HomeScreen({super.key, required this.selectedInterests});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  List<EventModel> _events = [];
  List<EventModel> _filteredEvents = [];
  final Set<String> _likedEventIds = <String>{};
  final String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final events = await _apiService.getAllEvents();
    if (!mounted) return;
    setState(() {
      _events = events;
      _filteredEvents = _filterEvents(events);
      _isLoading = false;
    });
  }

  List<EventModel> _filterEvents(List<EventModel> events) {
    return events.where((event) {
      final matchesSearch = event.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          event.organizer.name.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesInterests = widget.selectedInterests.isEmpty ||
          widget.selectedInterests.any(
            (interest) =>
                event.category.displayName.toLowerCase().contains(interest.toLowerCase()) ||
                interest.toLowerCase().contains(event.category.displayName.toLowerCase()),
          );

      return matchesSearch && matchesInterests;
    }).toList();
  }

  /// Events for the Zambian soccer / local football section
  List<EventModel> get _soccerEvents => _events.where((e) {
        if (e.category == EventCategory.football) return true;
        if (e.category != EventCategory.sports) return false;
        final t = e.title.toLowerCase();
        final tags = e.tags.map((x) => x.toLowerCase()).join(' ');
        return t.contains('league') || t.contains('football') || t.contains('soccer') ||
            tags.contains('football') || tags.contains('super league');
      }).toList();

  void _toggleLike(String eventId) {
    setState(() {
      if (_likedEventIds.contains(eventId)) {
        _likedEventIds.remove(eventId);
      } else {
        _likedEventIds.add(eventId);
      }
    });
  }

  String _formatKwacha(double amount) =>
      amount == 0 ? 'Free' : 'K${amount.toStringAsFixed(2)}';

  Future<void> _showEventDetails(EventModel event) async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      barrierDismissible: true,
      builder: (dialogContext) => _EventDetailModal(
        event: event,
        formatKwacha: _formatKwacha,
        onBuyTicket: (ticket, quantity) async {
          final total = ticket.price * quantity;
          if (total == 0) {
            await _apiService.bookTicket(event.id, ticket.id, quantity);
            if (!context.mounted) return;
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Ticket booked: ${event.title} (free)')),
            );
            return;
          }
          if (!context.mounted) return;
          showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (checkoutContext) => CheckoutDialog(
              orderDescription: '${event.title} — ${ticket.type.displayName} × $quantity',
              totalAmount: total,
              currency: 'ZMW',
              reference: '${event.id}_${ticket.id}_${DateTime.now().millisecondsSinceEpoch}',
              onComplete: (result) {
                Navigator.of(checkoutContext).pop();
                if (result.success) {
                  _apiService.bookTicket(event.id, ticket.id, quantity);
                  Navigator.of(dialogContext).pop();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Payment successful. Ticket booked: ${event.title} — ${_formatKwacha(ticket.price)} × $quantity'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (result.status == PaymentStatus.failed && result.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result.errorMessage!), backgroundColor: Colors.red),
                  );
                }
              },
            ),
          );
        },
        onClose: () => Navigator.of(dialogContext).pop(),
      ),
    );
  }

  Future<void> _openCreateEvent() async {
    final createdEvent = await Navigator.push<EventModel>(
      context,
      MaterialPageRoute(builder: (context) => const CreateEventScreen()),
    );

    if (createdEvent == null) return;

    setState(() {
      _events = [createdEvent, ..._events];
      _filteredEvents = _filterEvents(_events);
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const AuthScreen()),
      (route) => false,
    );
    await _apiService.logout();
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      onTap: onTap,
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final savedEvents = _events.where((e) => _likedEventIds.contains(e.id)).toList();
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1a237e),
              Color(0xFF3949ab),
              Color(0xFF7c4dff),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              DrawerHeader(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                margin: EdgeInsets.zero,
                decoration: const BoxDecoration(),
                child: SizedBox(
                  height: 96,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          'assets/images/app_icon.png',
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.event, size: 22, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'ZedEvents',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Discover · Reels · Tickets',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                      child: Text(
                        'MY ACTIVITY',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    _drawerItem(
                      icon: Icons.confirmation_number_outlined,
                      title: 'My tickets',
                      subtitle: 'View & show QR at the gate',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MyTicketsScreen()),
                        );
                      },
                    ),
                    _drawerItem(
                      icon: Icons.favorite_rounded,
                      title: 'Saved events',
                      subtitle: savedEvents.isEmpty ? 'No saved events' : '${savedEvents.length} saved',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SavedEventsScreen(
                              events: savedEvents,
                              onRemoveAll: savedEvents.isEmpty
                                  ? null
                                  : () {
                                      setState(() => _likedEventIds.clear());
                                    },
                            ),
                          ),
                        ).then((_) => setState(() {}));
                      },
                    ),
                    _drawerItem(
                      icon: Icons.tune_rounded,
                      title: 'Edit interests',
                      subtitle: 'Change what events you see',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const InterestsScreen(editMode: true),
                          ),
                        ).then((_) => setState(() {}));
                      },
                    ),
                    const Divider(color: Colors.white24, height: 24),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                      child: Text(
                        'CREATE & PROMOTE',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    _drawerItem(
                      icon: Icons.add_circle_outline_rounded,
                      title: 'Create event',
                      subtitle: 'List your event and sell tickets',
                      onTap: () {
                        Navigator.pop(context);
                        _openCreateEvent();
                      },
                    ),
                    _drawerItem(
                      icon: Icons.video_library_rounded,
                      title: 'Promote with reels',
                      subtitle: 'Post short clips to reach more people',
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Post reels from the Reels tab — coming soon: upload from here'),
                          ),
                        );
                      },
                    ),
                    const Divider(color: Colors.white24, height: 24),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                      child: Text(
                        'FOR VENUES & PARTNERS',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    _drawerItem(
                      icon: Icons.business_center_rounded,
                      title: 'Why ZedEvents for venues',
                      subtitle: 'Better than social media & billboards',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ForVenuesScreen()),
                        );
                      },
                    ),
                    const Divider(color: Colors.white24, height: 24),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                      child: Text(
                        'APP',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    _drawerItem(
                      icon: Icons.settings_rounded,
                      title: 'Settings',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SettingsScreen()),
                        );
                      },
                    ),
                    _drawerItem(
                      icon: Icons.help_outline_rounded,
                      title: 'Help & FAQ',
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Help & FAQ coming soon')),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: Icon(Icons.logout_rounded, color: Colors.white.withValues(alpha: 0.9), size: 22),
                      title: const Text(
                        'Log out',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      onTap: _logout,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2196F3), Color(0xFF9C27B0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => showSearch(
              context: context,
              delegate: EventSearchDelegate(events: _events),
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE3F2FD), Color(0xFFF3E5F5)],
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _loadEvents,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Interests',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.selectedInterests.length,
                          itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Chip(
                              label: Text(widget.selectedInterests[index]),
                              backgroundColor: Colors.blue.shade50,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_soccerEvents.isNotEmpty)
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Row(
                          children: [
                            Icon(Icons.sports_soccer, color: Colors.green.shade700, size: 24),
                            const SizedBox(width: 8),
                            const Text(
                              'Zambian Soccer',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D2D2D),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 4, 16, 0),
                        child: Text(
                          'Super League & local football — get tickets',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: _soccerEvents.length,
                          itemBuilder: (context, index) {
                            final event = _soccerEvents[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: SizedBox(
                                width: 260,
                                height: 200,
                                child: _SoccerEventCard(
                                  event: event,
                                  onLike: () => _toggleLike(event.id),
                                  onTap: () => _showEventDetails(event),
                                  isLiked: _likedEventIds.contains(event.id),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.0,
                    mainAxisSpacing: 12.0,
                    childAspectRatio: 0.58,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => EventCard(
                      event: _filteredEvents[index],
                      onLike: () => _toggleLike(_filteredEvents[index].id),
                      onTap: () => _showEventDetails(_filteredEvents[index]),
                      isLiked: _likedEventIds.contains(_filteredEvents[index].id),
                    ),
                    childCount: _filteredEvents.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateEvent,
        backgroundColor: const Color(0xFF2196F3),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _EventDetailModal extends StatefulWidget {
  final EventModel event;
  final String Function(double) formatKwacha;
  final void Function(TicketModel ticket, int quantity) onBuyTicket;
  final VoidCallback onClose;

  const _EventDetailModal({
    required this.event,
    required this.formatKwacha,
    required this.onBuyTicket,
    required this.onClose,
  });

  @override
  State<_EventDetailModal> createState() => _EventDetailModalState();
}

class _EventDetailModalState extends State<_EventDetailModal> {
  final PageController _pageController = PageController();
  int _imageIndex = 0;
  TicketModel? _selectedTicket;
  int _quantity = 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final images = event.images;
    final media = MediaQuery.of(context);
    final maxW = media.size.width * 0.92;
    final maxH = media.size.height * 0.88;

    return Material(
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Blurred backdrop — tap to close
          Positioned.fill(
            child: GestureDetector(
              onTap: widget.onClose,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(color: Colors.black26),
                ),
              ),
            ),
          ),
          // Centered card
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW, maxHeight: maxH),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header: close button
                    Stack(
                      children: [
                        // Image carousel
                        SizedBox(
                          height: 220,
                          width: double.infinity,
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: images.length,
                            onPageChanged: (i) => setState(() => _imageIndex = i),
                            itemBuilder: (context, i) => Image.network(
                              images[i],
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.image_not_supported, size: 48),
                              ),
                            ),
                          ),
                        ),
                        // Gradient overlay at top for close button
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: 56,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.black54, Colors.transparent],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: media.padding.top + 8,
                          right: 12,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white, size: 28),
                            onPressed: widget.onClose,
                          ),
                        ),
                        // Dots
                        if (images.length > 1)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 12,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                images.length,
                                (i) => Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  width: _imageIndex == i ? 10 : 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: _imageIndex == i
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    // Scrollable details + tickets
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade700),
                                const SizedBox(width: 6),
                                Text(
                                  event.date,
                                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                                ),
                                if (event.startTime != null || event.endTime != null) ...[
                                  const SizedBox(width: 12),
                                  Icon(Icons.schedule, size: 16, color: Colors.grey.shade700),
                                  const SizedBox(width: 4),
                                  Text(
                                    [event.startTime, event.endTime].whereType<String>().join(' – '),
                                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 16, color: Colors.grey.shade700),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    event.location,
                                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                                  ),
                                ),
                              ],
                            ),
                            if (!event.isOnline) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  OutlinedButton.icon(
                                    icon: const Icon(Icons.directions, size: 18),
                                    label: const Text('Directions'),
                                    onPressed: () async {
                                      final Uri url;
                                      if (event.latitude != null && event.longitude != null) {
                                        url = Uri.parse(
                                          'https://www.google.com/maps/search/?api=1&query=${event.latitude},${event.longitude}',
                                        );
                                      } else {
                                        url = Uri.parse(
                                          'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(event.location)}',
                                        );
                                      }
                                      if (await canLaunchUrl(url)) {
                                        await launchUrl(url, mode: LaunchMode.externalApplication);
                                      }
                                    },
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton.icon(
                                    icon: const Icon(Icons.event_rounded, size: 18),
                                    label: const Text('Add to calendar'),
                                    onPressed: () async {
                                      final added = await addEventToCalendar(event);
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(added
                                              ? 'Added to calendar'
                                              : 'Could not parse date. Add manually.'),
                                          backgroundColor: added ? Colors.green : null,
                                        ),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (event.isOnline && event.meetingUrl != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Online event',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            Text(
                              event.description,
                              style: TextStyle(fontSize: 14, height: 1.4, color: Colors.grey.shade800),
                            ),
                            const SizedBox(height: 14),
                            // Organizer
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.grey.shade300,
                                  child: Text(
                                    event.organizer.name.isNotEmpty
                                        ? event.organizer.name[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        event.organizer.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      if (event.organizer.eventsHosted > 0)
                                        Text(
                                          '${event.organizer.eventsHosted} events',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (event.tags.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  Chip(
                                    label: Text(event.category.displayName),
                                    backgroundColor: Colors.blue.shade50,
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  ...event.tags.take(5).map(
                                        (t) => Chip(
                                          label: Text(t),
                                          backgroundColor: Colors.grey.shade200,
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 18),
                            const Text(
                              'Tickets',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (event.tickets.isEmpty)
                              const Text('No tickets available for this event.')
                            else
                              ...event.tickets.map((ticket) {
                                final selected = _selectedTicket?.id == ticket.id;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Material(
                                    color: selected
                                        ? Colors.blue.shade50
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: ticket.isSoldOut
                                          ? null
                                          : () => setState(() => _selectedTicket = ticket),
                                      child: Padding(
                                        padding: const EdgeInsets.all(14),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    ticket.type.displayName,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    widget.formatKwacha(ticket.price),
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      color: ticket.price == 0
                                                          ? Colors.green.shade700
                                                          : Colors.black87,
                                                    ),
                                                  ),
                                                  Text(
                                                    ticket.isSoldOut
                                                        ? 'Sold out'
                                                        : '${ticket.available} left',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey.shade600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (ticket.isSoldOut)
                                              const Text('Unavailable', style: TextStyle(color: Colors.red))
                                            else
                                              Icon(
                                                selected ? Icons.check_circle : Icons.radio_button_unchecked,
                                                color: selected ? Colors.blue.shade700 : Colors.grey,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            if (event.hasAvailableTickets && _selectedTicket != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Text('Quantity: ', style: TextStyle(fontSize: 14)),
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    onPressed: _quantity <= 1
                                        ? null
                                        : () => setState(() => _quantity = _quantity - 1),
                                  ),
                                  Text('$_quantity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: () => setState(() => _quantity = _quantity + 1),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed: () => widget.onBuyTicket(_selectedTicket!, _quantity),
                                  icon: const Icon(Icons.confirmation_number_outlined),
                                  label: Text(
                                    'Buy ticket — ${widget.formatKwacha(_selectedTicket!.price)}${_quantity > 1 ? ' × $_quantity' : ''}',
                                  ),
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact card for the Zambian Soccer horizontal list (fits fixed height, no overflow).
class _SoccerEventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onLike;
  final VoidCallback onTap;
  final bool isLiked;

  const _SoccerEventCard({
    required this.event,
    required this.onLike,
    required this.onTap,
    required this.isLiked,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: SizedBox(
                    height: 88,
                    width: double.infinity,
                    child: Image.network(
                      event.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.image_not_supported, size: 32, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 2,
                  right: 2,
                  child: IconButton(
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : Colors.white,
                      size: 18,
                    ),
                    onPressed: onLike,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black26,
                      padding: const EdgeInsets.all(4),
                      minimumSize: Size.zero,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Color(0xFF2D2D2D),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    event.date,
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    event.minPrice == 0 ? 'Free' : 'K${event.minPrice.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onLike;
  final VoidCallback onTap;
  final bool isLiked;

  const EventCard({
    super.key,
    required this.event,
    required this.onLike,
    required this.onTap,
    required this.isLiked,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Color(0xFFF8F9FA)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: SizedBox(
                      height: 110,
                      width: double.infinity,
                      child: Image.network(
                        event.image,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey.shade200,
                            child: Center(
                              child: SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            (loadingProgress.expectedTotalBytes ?? 1)
                                      : null,
                                ),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => Container(
                          height: 110,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.white,
                        size: 22,
                      ),
                      onPressed: onLike,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black26,
                        padding: const EdgeInsets.all(6),
                      ),
                    ),
                  ),
                ],
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFF2D2D2D),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 12, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            event.date,
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 12, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.location,
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event.minPrice == 0 ? 'Free' : 'K${event.minPrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        event.organizer.name,
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EventSearchDelegate extends SearchDelegate<EventModel?> {
  final List<EventModel> events;

  EventSearchDelegate({required this.events});

  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        )
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults();

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults();

  Widget _buildSearchResults() {
    final results = events.where((event) =>
        event.title.toLowerCase().contains(query.toLowerCase()) ||
        event.organizer.name.toLowerCase().contains(query.toLowerCase()));

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final e = results.elementAt(index);
        return ListTile(
          leading: SizedBox(
            width: 50,
            height: 50,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                e.image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
          ),
          title: Text(e.title, maxLines: 2, overflow: TextOverflow.ellipsis),
          subtitle: Text(e.organizer.name, maxLines: 1, overflow: TextOverflow.ellipsis),
          onTap: () => close(context, e),
        );
      },
    );
  }
}