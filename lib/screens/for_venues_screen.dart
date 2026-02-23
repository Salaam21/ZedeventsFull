import 'package:flutter/material.dart';

/// Pitch screen for venues (PIAZA, Mulungushi, etc.): why ZedEvents beats
/// social media, billboards, and physical tickets.
class ForVenuesScreen extends StatelessWidget {
  const ForVenuesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('For Venues & Partners'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2196F3), Color(0xFF9C27B0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SectionHeader(
            icon: Icons.business_center_rounded,
            title: 'Why ZedEvents beats social media & billboards',
          ),
          const SizedBox(height: 12),
          _AdvantageTile(
            icon: Icons.groups_rounded,
            title: 'Reach people who want to attend',
            body: 'No wasted spend on scrollers. Everyone on ZedEvents is looking for events—conferences, concerts, trade shows. Higher conversion than Facebook or billboards.',
          ),
          _AdvantageTile(
            icon: Icons.dashboard_rounded,
            title: 'One platform: list, promote, sell, check-in',
            body: 'Create the event, post reels to promote it, sell tickets and collect MoMo/card payments, send reminders, and use digital check-in. No juggling posters, ticket booths, and cash.',
          ),
          _AdvantageTile(
            icon: Icons.analytics_rounded,
            title: 'Real data you can use',
            body: 'See who’s coming, which events sell, revenue per event, and demographics. Social media and billboards give you almost no actionable data.',
          ),
          const SizedBox(height: 24),
          _SectionHeader(
            icon: Icons.confirmation_number_outlined,
            title: 'Better than physical tickets',
          ),
          const SizedBox(height: 12),
          _AdvantageTile(
            icon: Icons.qr_code_2_rounded,
            title: 'Digital tickets & fast check-in',
            body: 'Attendees get tickets in the app. Show QR at the door—no printing, no long queues. Less staff, faster entry, fewer no-shows thanks to reminders.',
          ),
          _AdvantageTile(
            icon: Icons.payment_rounded,
            title: 'Payments in one place',
            body: 'MoMo and card in-app. No cash handling at the door, fewer errors, and automatic records for your accounts.',
          ),
          _AdvantageTile(
            icon: Icons.event_busy_rounded,
            title: 'Capacity & waitlist',
            body: 'Set capacity and sell out cleanly. Optional waitlist when sold out—no overbooking, no disappointed customers.',
          ),
          const SizedBox(height: 24),
          _SectionHeader(
            icon: Icons.video_library_rounded,
            title: 'Reels = free, high-impact ads',
          ),
          const SizedBox(height: 12),
          _AdvantageTile(
            icon: Icons.auto_awesome,
            title: 'Short clips from your venue',
            body: 'Post reels from past events—conference halls, stages, networking. They appear in the Reels feed and work as social proof. No ad budget needed.',
          ),
          const SizedBox(height: 24),
          _SectionHeader(
            icon: Icons.place_rounded,
            title: 'Built for places like yours',
          ),
          const SizedBox(height: 12),
          _ChipRow(
            labels: ['PIAZA', 'Mulungushi Conference Centre', 'Trade Fairs', 'Hotels', 'Stadiums', 'Universities'],
          ),
          const SizedBox(height: 32),
          Card(
            elevation: 0,
            color: Colors.blue.shade50,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.rocket_launch_rounded, color: Colors.blue.shade700, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        'Get your venue on ZedEvents',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'List your space, publish events, and start selling tickets. Contact us to set up a venue account and featured placement.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Venue sign-up: contact@zedevents.com'),
                          backgroundColor: Color(0xFF1976D2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.email_outlined, size: 20),
                    label: const Text('Contact us'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.blue.shade700, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
      ],
    );
  }
}

class _AdvantageTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _AdvantageTile({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.blue.shade600, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    body,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: Colors.grey.shade700,
                    ),
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

class _ChipRow extends StatelessWidget {
  final List<String> labels;

  const _ChipRow({required this.labels});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: labels.map((l) => Chip(
        label: Text(l, style: const TextStyle(fontSize: 12)),
        backgroundColor: Colors.purple.shade50,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      )).toList(),
    );
  }
}
