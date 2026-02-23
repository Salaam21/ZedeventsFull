import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_shell.dart';

class InterestsScreen extends StatefulWidget {
  /// When true, used from drawer: save and pop with result instead of going to Home.
  final bool editMode;

  const InterestsScreen({super.key, this.editMode = false});

  @override
  _InterestsScreenState createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  List<String> interests = [
    'Music Concerts',
    'Live Music',
    'Festivals',
    'Movies',
    'Theater',
    'Comedy Shows',
    'Sports Events',
    'Football',
    'Basketball',
    'MMA',
    'Motor Shows',
    'Art Exhibitions',
    'House Parties',
    'Galas',
    'Food Festivals',
    'Wine Tastings',
    'Cooking Classes',
    'Travel',
    'Technology',
    'Fashion',
    'Gaming',
  ];
  List<String> selectedInterests = [];

  @override
  void initState() {
    super.initState();
    if (widget.editMode) _loadSavedInterests();
  }

  Future<void> _loadSavedInterests() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('selectedInterests') ?? [];
    if (mounted) setState(() => selectedInterests = List.from(saved));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade800, Colors.purple.shade200],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What do you want to see on Zed Events?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  alignment: WrapAlignment.center,
                  children: interests.map((interest) {
                    return ChoiceChip(
                      label: Text(
                        interest,
                        style: TextStyle(color: const Color.fromARGB(255, 15, 11, 11)),
                      ),
                      selectedColor: Colors.deepPurple,
                      selected: selectedInterests.contains(interest),
                      onSelected: (bool isSelected) { // Corrected onSelected callback
                        setState(() {
                          if (isSelected) {
                            selectedInterests.add(interest);
                          } else {
                            selectedInterests.remove(interest);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: selectedInterests.isNotEmpty
                      ? () async {
                          final prefs = await SharedPreferences.getInstance();
                          prefs.setStringList('selectedInterests', selectedInterests);
                          if (widget.editMode && context.mounted) {
                            Navigator.pop(context, selectedInterests);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Interests updated. Pull to refresh the feed.'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else if (!widget.editMode && context.mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    MainShell(selectedInterests: selectedInterests),
                              ),
                            );
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    widget.editMode ? 'Save' : 'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.deepPurple,
                    ),
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