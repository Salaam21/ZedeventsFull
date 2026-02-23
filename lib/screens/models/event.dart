class Event {
  final String id;
  final String title;
  final String date;
  final String location;
  final String imageUrl;
  final List<String> categories;
  final double price;
  final String organizer;
  bool isLiked;

  Event({
    required this.id,
    required this.title,
    required this.date,
    required this.location,
    required this.imageUrl,
    required this.categories,
    required this.price,
    required this.organizer,
    this.isLiked = false,
  });
}
