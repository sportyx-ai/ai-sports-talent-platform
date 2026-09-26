import 'package:flutter/material.dart';
import '../athlete/add_athlete_page.dart';
import '../../widgets/athlete_card.dart';
import '../../widgets/custom_button.dart';
import '../athlete/athlete_profile_page.dart';
import '../../core/session.dart';
import '../../core/colors.dart';
import '../../services/api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> athletes = [];
  List<Map<String, dynamic>> events = [];
  bool _loading = true;
  String? _error;

  void addAthlete(Map<String, dynamic> athlete) {
    setState(() {
      athletes.add(athlete);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadAthletes();
  }

  Future<void> _loadAthletes() async {
    final managerId = Session.managerId;
    if (managerId == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final response = await ApiService.getAthletesByManager(managerId);
      final upcomingEvents = await ApiService.getUpcomingEvents();

      setState(() {
        athletes = response
            .whereType<Map<String, dynamic>>()
            .map((athlete) => {
                  'id': athlete['id']?.toString(),
                  'name': athlete['fullName'] ?? '',
                  'age': '',
                  'gender': athlete['gender'] ?? '',
                  'sport': athlete['sportCategory'] ?? '',
                  'height': '',
                  'weight': '',
                  'bio': athlete['schoolInstitution'] ?? '',
                  'profilePhotoUrl': athlete['profilePhotoUrl'],
                  'raw': athlete,
                })
            .toList();

        events = upcomingEvents.whereType<Map<String, dynamic>>().toList();

        _loading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Error loading data: $e';
      });
    }
  }

  void _navigateToAddAthlete() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddAthletePage(),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      addAthlete(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        backgroundColor: AppColors.primary,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _error ?? 'Error',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() => _loading = true);
                          _loadAthletes();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : athletes.isEmpty
                  ? Center(
                      child: CustomButton(
                        text: "Add Athlete",
                        width: 150,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        fontSize: 16,
                        borderRadius: 16,
                        outlined: true,
                        onPressed: _navigateToAddAthlete,
                      ),
                    )
                  : ListView(
                      children: [
                        if (events.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                            child: const Text(
                              'Upcoming Events',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ...events.map(
                          (event) => Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                title: Text(
                                  event['title']?.toString() ?? 'Event',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  '${event['sportCategory'] ?? 'Sport'} | ${event['location'] ?? 'Location'}',
                                ),
                                trailing: Icon(
                                  Icons.event,
                                  color: AppColors.accent,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text(
                            'Your Athletes',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ...athletes.map(
                          (athlete) => AthleteCard(
                            athlete: athlete,
                            onTap: () {
                              Session.selectedAthleteId = athlete['id']?.toString();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AthleteProfilePage(
                                    athlete: athlete,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                          child: Center(
                            child: CustomButton(
                              text: "Add Athlete",
                              width: 150,
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              fontSize: 16,
                              borderRadius: 16,
                              outlined: true,
                              onPressed: _navigateToAddAthlete,
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }
}
