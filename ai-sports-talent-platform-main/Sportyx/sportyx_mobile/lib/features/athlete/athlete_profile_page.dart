import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import '../../core/colors.dart';
import '../../core/session.dart';
import '../../services/api_service.dart';
import 'live_recording_screen.dart';

class AthleteProfilePage extends StatefulWidget {
  final Map<String, dynamic> athlete;

  const AthleteProfilePage({
    super.key,
    required this.athlete,
  });

  @override
  State<AthleteProfilePage> createState() => _AthleteProfilePageState();
}

class _AthleteProfilePageState extends State<AthleteProfilePage> {
  int _selectedBottomTab = 0;
  final ImagePicker _imagePicker = ImagePicker();
  List<Map<String, dynamic>> _videos = [];
  List<Map<String, dynamic>> _assessments = [];
  List<Map<String, dynamic>> _events = [];
  bool _loadingData = true;
  final Set<String> _registeredEventIds = <String>{};

  @override
  void initState() {
    super.initState();
    Session.selectedAthleteId = widget.athlete['id']?.toString();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final athleteId = widget.athlete['id']?.toString();
    if (athleteId == null || athleteId.isEmpty) {
      setState(() => _loadingData = false);
      return;
    }
    try {
      final videos = await ApiService.getVideosByAthlete(athleteId);
      final assessments = await ApiService.getAssessmentsByAthlete(athleteId);
      final events = await ApiService.getEventsForAthlete(athleteId);
      if (!mounted) return;
      setState(() {
        _videos = videos.whereType<Map<String, dynamic>>().toList();
        _assessments = assessments.whereType<Map<String, dynamic>>().toList();
        _events = events.whereType<Map<String, dynamic>>().toList();
        _loadingData = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingData = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _buildTabContent(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedBottomTab,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library),
            label: 'Videos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Upload',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        onTap: (index) {
          setState(() {
            _selectedBottomTab = index;
          });

          if (index == 2) {
            _openVideoRecorder();
          }
        },
      ),
    );
  }

  Widget _buildTabContent() {
    if (_selectedBottomTab == 0) {
      return _buildVideosTab();
    } else if (_selectedBottomTab == 1) {
      return _buildEventsTab();
    } else if (_selectedBottomTab == 3) {
      return _buildSettingsTab();
    }
    return _buildProfileTab();
  }

  // Videos Tab
  Widget _buildVideosTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Videos',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 16),
                if (_loadingData)
                  const Center(child: CircularProgressIndicator())
                else if (_videos.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.accent.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.video_library,
                          size: 60,
                          color: AppColors.accent,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No videos uploaded yet',
                          style: TextStyle(
                            color: AppColors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ..._videos.map((video) => _buildVideoCard(video)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(Map<String, dynamic> video) {
    final status = video['adminReviewStatus']?.toString() ?? 'PENDING';
    final statusColor = status == 'REVIEWED'
        ? Colors.green
        : status == 'REJECTED'
            ? Colors.red
            : Colors.orange;
    final statusIcon = status == 'REVIEWED'
        ? Icons.check_circle
        : status == 'REJECTED'
            ? Icons.warning_amber_rounded
            : Icons.schedule;
    final statusText = status == 'REVIEWED'
        ? 'PASSED (Sent to Admin)'
        : status == 'REJECTED'
            ? 'NEEDS IMPROVEMENT'
            : 'PENDING REVIEW';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video['title']?.toString() ?? 'Video',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${video['durationSeconds'] ?? 0}s • ${video['sportCategory'] ?? "General"}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (video['adminFeedback'] != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: status == 'REVIEWED'
                      ? Colors.green.withOpacity(0.08)
                      : status == 'REJECTED'
                          ? Colors.red.withOpacity(0.08)
                          : Colors.purple.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: status == 'REVIEWED'
                        ? Colors.green.withOpacity(0.3)
                        : status == 'REJECTED'
                            ? Colors.red.withOpacity(0.3)
                            : Colors.purple.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          status == 'REVIEWED'
                              ? Icons.auto_awesome
                              : Icons.analytics_outlined,
                          size: 16,
                          color: status == 'REVIEWED'
                              ? Colors.green.shade700
                              : status == 'REJECTED'
                                  ? Colors.red.shade700
                                  : AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            status == 'REVIEWED'
                                ? '🤖 AI Assessment Result (Passed)'
                                : status == 'REJECTED'
                                    ? '🤖 AI Coaching Feedback'
                                    : '🤖 AI Analysis Feedback',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: status == 'REVIEWED'
                                  ? Colors.green.shade800
                                  : status == 'REJECTED'
                                      ? Colors.red.shade800
                                      : AppColors.primaryDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildFormattedFeedbackWidget(video['adminFeedback']?.toString() ?? ''),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final url = video['videoUrl']?.toString();
                  if (url != null && url.isNotEmpty) {
                    showDialog(
                      context: context,
                      builder: (_) => _VideoPlayerDialog(videoUrl: url),
                    );
                  }
                },
                icon: const Icon(Icons.play_circle_fill),
                label: const Text('Watch'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.primaryDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormattedFeedbackWidget(String rawFeedback) {
    if (rawFeedback.trim().isEmpty) return const SizedBox.shrink();

    String? scoreText;
    String? repsText;

    final scoreMatch = RegExp(r'Score:\s*([\d\.]+(?:/100)?)', caseSensitive: false).firstMatch(rawFeedback);
    if (scoreMatch != null) {
      scoreText = scoreMatch.group(1);
      if (!scoreText!.contains('/100')) scoreText += '/100';
    }

    final repsMatch = RegExp(r'Valid Reps:\s*([\d/]+)', caseSensitive: false).firstMatch(rawFeedback);
    if (repsMatch != null) {
      repsText = repsMatch.group(1);
    }

    List<String> strengths = [];
    List<String> areasToImprove = [];
    String? recommendation;

    if (rawFeedback.contains('Strengths:')) {
      final strPart = rawFeedback.split('Strengths:').last.split('Areas to Improve:').first.split('Please re-record').first;
      strengths = strPart
          .split(RegExp(r'[\.\,]+'))
          .map((s) => s.replaceAll(RegExp(r'^\s*AI Feedback|\s*Score:.*|\s*Valid Reps:.*'), '').trim())
          .where((s) => s.isNotEmpty && !s.contains('Score') && !s.contains('Valid Reps'))
          .toList();
    }

    if (rawFeedback.contains('Areas to Improve:')) {
      final impPart = rawFeedback.split('Areas to Improve:').last.split('Please re-record').first.split('Recommendation:').first;
      areasToImprove = impPart
          .split(RegExp(r'[\,]+|\.\s+'))
          .map((s) => s.replaceAll(RegExp(r'[\.\,]+$'), '').trim())
          .where((s) => s.isNotEmpty && !s.startsWith('Please re-record'))
          .toList();
    }

    if (rawFeedback.contains('Please re-record')) {
      recommendation = 'Please re-record and re-upload video for better form alignment.';
    } else if (rawFeedback.contains('Recommendation:')) {
      recommendation = rawFeedback.split('Recommendation:').last.trim();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (scoreText != null || repsText != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (scoreText != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.speed, size: 12, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text(
                          'Score: $scoreText',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (repsText != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.purple.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.fitness_center, size: 12, color: Colors.purple),
                        const SizedBox(width: 4),
                        Text(
                          'Valid Reps: $repsText',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        if (strengths.isNotEmpty) ...[
          const Text(
            '🎯 Key Strengths:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 4),
          ...strengths.map((item) => Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(fontSize: 12, color: AppColors.primaryDark),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 6),
        ],
        if (areasToImprove.isNotEmpty) ...[
          const Text(
            '⚠️ Areas for Improvement:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 4),
          ...areasToImprove.map((item) => Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(fontSize: 12, color: AppColors.primaryDark),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 6),
        ],
        if (recommendation != null)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.amber.shade700.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline, size: 14, color: Colors.amber),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    recommendation,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (strengths.isEmpty && areasToImprove.isEmpty && recommendation == null)
          Text(
            rawFeedback,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.primaryDark,
              height: 1.4,
            ),
          ),
      ],
    );
  }

  // Events Tab
  Widget _buildEventsTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Upcoming Events',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 16),
                if (_loadingData)
                  const Center(child: CircularProgressIndicator())
                else if (_events.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.event,
                          size: 60,
                          color: AppColors.accent,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No upcoming events',
                          style: TextStyle(color: AppColors.grey),
                        ),
                      ],
                    ),
                  )
                else
                  ..._events.map((event) => _buildEventCard(event)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event['title']?.toString() ?? 'Event',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              event['location']?.toString() ?? 'Location',
              style: const TextStyle(fontSize: 14, color: AppColors.grey),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Date',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        event['eventDate']?.toString() ?? '-',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Register By',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        event['registrationDeadline']?.toString() ?? '-',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _registerToEvent(event),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.primaryDark,
                ),
                child: const Text('Register'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Settings Tab
  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Profile Settings',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Profile Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSettingField('Full Name', widget.athlete['name']?.toString() ?? 'N/A'),
                _buildSettingField('Sport', widget.athlete['sport']?.toString() ?? 'N/A'),
                _buildSettingField('Gender', widget.athlete['gender']?.toString() ?? 'N/A'),
                _buildSettingField('Age', '${widget.athlete['age']?.toString() ?? "N/A"} years'),
                _buildSettingField('Height', '${widget.athlete['height']?.toString() ?? "N/A"} cm'),
                _buildSettingField('Weight', '${widget.athlete['weight']?.toString() ?? "N/A"} kg'),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _openEditAthleteSheet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.primaryDark,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Edit Profile',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.accent.withOpacity(0.3)),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Profile Tab (default)
  Widget _buildProfileTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'About',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.athlete['bio']?.toString() ?? 'No bio provided',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.grey,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Statistics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  children: [
                    _buildStatCard('Videos', _videos.length.toString()),
                    _buildStatCard('Events', _events.length.toString()),
                    _buildStatCard('Assessments', _assessments.length.toString()),
                    _buildStatCard('Height', '${widget.athlete['height']} cm'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 1),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: _openEditAthleteSheet,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  color: AppColors.accent,
                ),
                child: widget.athlete['profilePhotoUrl'] != null
                    ? ClipOval(
                        child: Image.network(
                          widget.athlete['profilePhotoUrl'],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.white,
                      ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.athlete['name']?.toString() ?? 'Athlete',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.athlete['sport']?.toString() ?? 'Sport',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.accent.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _registerToEvent(Map<String, dynamic> event) async {
    final athleteId = widget.athlete['id']?.toString();
    final eventId = event['id']?.toString();

    if (athleteId == null ||
        athleteId.isEmpty ||
        eventId == null ||
        eventId.isEmpty) {
      return;
    }

    try {
      await ApiService.registerAthleteForEvent(
        athleteId: athleteId,
        eventId: eventId,
      );

      if (!mounted) return;
      setState(() => _registeredEventIds.add(eventId));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registered for ${event['title']?.toString() ?? "event"}'),
          backgroundColor: AppColors.accent,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
      );
    }
  }

  Future<void> _openVideoRecorder() async {
    try {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext sheetContext) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.bolt, color: AppColors.primary, size: 28),
                  title: const Text(
                    'Live Task Recording (Interactive)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Random tasks & animated emojis every 10-15s'),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await _startLiveRecording();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.videocam),
                  title: const Text('Standard Camera Recording'),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await _recordVideo();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.image),
                  title: const Text('Pick from Gallery'),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await _pickVideoFromGallery();
                  },
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _startLiveRecording() async {
    try {
      final recordedPath = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (_) => LiveRecordingScreen(
            athleteName: widget.athlete['name']?.toString() ?? 'Athlete',
            sportCategory: widget.athlete['sport']?.toString() ?? 'General',
          ),
        ),
      );

      if (recordedPath != null && recordedPath.isNotEmpty) {
        await _processAndUploadVideo(recordedPath, titlePrefix: "Live Task Challenge");
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Live recording error: $e')),
      );
    }
  }

  Future<void> _recordVideo() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.camera,
      );

      if (video != null) {
        await _processAndUploadVideo(video.path, titlePrefix: "Standard Performance");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera error: $e')),
        );
      }
    }
  }

  Future<void> _processAndUploadVideo(String filePath, {String titlePrefix = "Performance"}) async {
    try {
      final athleteId = widget.athlete['id']?.toString();
      final managerId = Session.managerId ??
          widget.athlete['managerId']?.toString() ??
          (widget.athlete['manager'] is Map ? widget.athlete['manager']['id']?.toString() : null);

      if (athleteId == null || athleteId.isEmpty || managerId == null || managerId.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Missing Athlete or Manager ID for upload.')),
        );
        return;
      }

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const AlertDialog(
          title: Text('Uploading & Analyzing Video...'),
          content: SizedBox(
            height: 60,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 8),
                Text('Running AI Model Analysis...', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ),
      );

      await ApiService.uploadVideoFile(
        managerId: managerId,
        athleteId: athleteId,
        filePath: filePath,
        title: "${widget.athlete['name'] ?? 'Athlete'} $titlePrefix Video",
        sportCategory: widget.athlete['sport']?.toString() ?? "General",
        skillType: "General",
        durationSeconds: 60,
      );

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      await _loadProfileData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Video uploaded & analyzed successfully!'),
          backgroundColor: AppColors.accent,
        ),
      );
      setState(() => _selectedBottomTab = 0);
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    }
  }

  Future<void> _pickVideoFromGallery() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
      );

      if (video != null) {
        final athleteId = widget.athlete['id']?.toString();
        final managerId = Session.managerId ??
            widget.athlete['managerId']?.toString() ??
            (widget.athlete['manager'] is Map ? widget.athlete['manager']['id']?.toString() : null);

        if (athleteId == null || athleteId.isEmpty || managerId == null || managerId.isEmpty) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Missing Athlete or Manager ID for upload.')),
          );
          return;
        }

        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const AlertDialog(
            title: Text('Uploading & Analyzing Video...'),
            content: SizedBox(
              height: 60,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text('Running AI Model Analysis...', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ),
        );

        await ApiService.uploadVideoFile(
          managerId: managerId,
          athleteId: athleteId,
          filePath: video.path,
          title: "${widget.athlete['name'] ?? 'Athlete'} Performance Video",
          sportCategory: widget.athlete['sport']?.toString() ?? "General",
          skillType: "General",
          durationSeconds: 60,
        );

        if (!mounted) return;
        Navigator.pop(context);
        await _loadProfileData();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Video uploaded & analyzed successfully!'),
            backgroundColor: AppColors.accent,
          ),
        );
        setState(() => _selectedBottomTab = 0);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    }
  }

  Future<void> _openEditAthleteSheet() async {
    final TextEditingController nameController =
        TextEditingController(text: widget.athlete['name']?.toString() ?? '');
    final TextEditingController sportController =
        TextEditingController(text: widget.athlete['sport']?.toString() ?? '');
    final TextEditingController bioController =
        TextEditingController(text: widget.athlete['bio']?.toString() ?? '');
    String gender = widget.athlete['gender']?.toString() ?? 'Male';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Edit Profile',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: sportController,
                decoration: const InputDecoration(
                  labelText: 'Sport Category',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: gender,
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (v) => gender = v ?? gender,
                decoration: const InputDecoration(labelText: 'Gender'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: bioController,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final athleteId = widget.athlete['id']?.toString();
                    if (athleteId == null || athleteId.isEmpty) return;
                    try {
                      await ApiService.updateAthlete(
                        athleteId: athleteId,
                        payload: {
                          "fullName": nameController.text.trim(),
                          "gender": gender,
                          "sportCategory": sportController.text.trim(),
                          "skillLevel": "BEGINNER",
                          "schoolInstitution": bioController.text.trim(),
                          "contactInfo": {
                            "age": widget.athlete['age'],
                            "height": widget.athlete['height'],
                            "weight": widget.athlete['weight'],
                          }
                        },
                      );

                      if (!mounted) return;
                      setState(() {
                        widget.athlete['name'] = nameController.text.trim();
                        widget.athlete['gender'] = gender;
                        widget.athlete['sport'] = sportController.text.trim();
                        widget.athlete['bio'] = bioController.text.trim();
                      });
                      if (!mounted) return;
                      Navigator.pop(context);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile updated successfully')),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Update failed: $e')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.primaryDark,
                  ),
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _VideoPlayerDialog extends StatefulWidget {
  final String videoUrl;

  const _VideoPlayerDialog({required this.videoUrl});

  @override
  State<_VideoPlayerDialog> createState() => _VideoPlayerDialogState();
}

class _VideoPlayerDialogState extends State<_VideoPlayerDialog> {
  VideoPlayerController? _controller;
  Future<void>? _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    _initializeVideoPlayerFuture = _controller!.initialize();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FutureBuilder<void>(
            future: _initializeVideoPlayerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Column(
                  children: [
                    AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: VideoPlayer(_controller!),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _controller!.value.isPlaying
                                  ? _controller!.pause()
                                  : _controller!.play();
                            });
                          },
                          icon: Icon(
                            _controller!.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                          ),
                          label: Text(
                            _controller!.value.isPlaying ? 'Pause' : 'Play',
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              } else {
                return const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
