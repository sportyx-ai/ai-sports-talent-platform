import 'package:flutter/material.dart';
import '../athlete/add_athlete_page.dart';
import '../../widgets/athlete_card.dart';
import '../athlete/athlete_profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> athletes = [];

  void addAthlete(Map<String, dynamic> athlete) {
    setState(() {
      athletes.add(athlete);
    });
  }

  void _navigateToAddAthlete() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddAthletePage(),
      ),
    );

    if (result != null) {
      addAthlete(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: athletes.isEmpty
          ? Center(
              child: ElevatedButton.icon(
                onPressed: _navigateToAddAthlete,
                icon: const Icon(Icons.add),
                label: const Text("Add Athlete"),
              ),
            )
          : ListView.builder(
              itemCount: athletes.length + 1,
              itemBuilder: (context, index) {
                if (index == athletes.length) {
                  // Add button at the end of the list
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                    child: ElevatedButton.icon(
                      onPressed: _navigateToAddAthlete,
                      icon: const Icon(Icons.add),
                      label: const Text("Add Athlete"),
                    ),
                  );
                }
                return AthleteCard(
                  athlete: athletes[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AthleteProfilePage(
                          athlete: athletes[index],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}