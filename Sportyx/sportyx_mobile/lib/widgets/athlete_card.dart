import 'package:flutter/material.dart';

class AthleteCard extends StatelessWidget {
  final Map<String, dynamic> athlete;
  final VoidCallback onTap;

  const AthleteCard({
    super.key,
    required this.athlete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        child: ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.person),
          ),
          title: Text(athlete['name']),
          subtitle: Text(athlete['sport']),
          onTap: onTap,
        ),
      ),
    );
  }
}