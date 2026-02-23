import 'package:flutter/material.dart';

/// List of tickets the user has booked (mock + API).
class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  List<_BookedTicket> _tickets = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    // In a real app, call API like _api.getMyTickets(). For now use mock.
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() {
      _tickets = _mockBookedTickets();
      _loading = false;
    });
  }

  List<_BookedTicket> _mockBookedTickets() {
    return [
      _BookedTicket(
        eventTitle: 'Lusaka Music & Arts Festival',
        eventDate: 'Mar 15, 2025',
        venue: 'Showgrounds, Lusaka',
        ticketType: 'General Admission',
        quantity: 2,
        orderId: 'ORD-001',
        qrPlaceholder: true,
      ),
      _BookedTicket(
        eventTitle: 'Zambia Super League Derby Night',
        eventDate: 'Mar 22, 2025',
        venue: 'Levy Mwanawasa Stadium, Ndola',
        ticketType: 'VIP',
        quantity: 1,
        orderId: 'ORD-002',
        qrPlaceholder: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tickets'),
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _tickets.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.confirmation_number_outlined, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'No tickets yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Book an event to see your tickets here',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadTickets,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _tickets.length,
                    itemBuilder: (context, i) {
                      final t = _tickets[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => _showTicketDetail(t),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(Icons.confirmation_number, color: Colors.blue.shade700),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            t.eventTitle,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            '${t.ticketType} × ${t.quantity}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                                    const SizedBox(width: 6),
                                    Text(t.eventDate, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                                    const SizedBox(width: 16),
                                    Icon(Icons.place, size: 14, color: Colors.grey.shade600),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        t.venue,
                                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Order ${t.orderId}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  void _showTicketDetail(_BookedTicket t) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(t.eventTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('${t.ticketType} × ${t.quantity}', style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(Icons.qr_code_2, size: 120, color: Colors.grey.shade600),
                  const SizedBox(height: 8),
                  Text('Show this QR at the gate', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _BookedTicket {
  final String eventTitle;
  final String eventDate;
  final String venue;
  final String ticketType;
  final int quantity;
  final String orderId;
  final bool qrPlaceholder;

  _BookedTicket({
    required this.eventTitle,
    required this.eventDate,
    required this.venue,
    required this.ticketType,
    required this.quantity,
    required this.orderId,
    required this.qrPlaceholder,
  });
}
