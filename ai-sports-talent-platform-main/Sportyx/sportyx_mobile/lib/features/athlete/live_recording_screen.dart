import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../core/colors.dart';

class TaskPrompt {
  final String id;
  final String title;
  final String emoji;
  final String description;
  final IconData icon;
  final Color accentColor;

  const TaskPrompt({
    required this.id,
    required this.title,
    required this.emoji,
    required this.description,
    required this.icon,
    required this.accentColor,
  });
}

class LiveRecordingScreen extends StatefulWidget {
  final String athleteName;
  final String sportCategory;

  const LiveRecordingScreen({
    super.key,
    required this.athleteName,
    required this.sportCategory,
  });

  @override
  State<LiveRecordingScreen> createState() => _LiveRecordingScreenState();
}

class _LiveRecordingScreenState extends State<LiveRecordingScreen>
    with TickerProviderStateMixin {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  bool _isInitializing = true;
  bool _isRecording = false;
  bool _isFlashOn = false;
  String? _errorMessage;

  // Recording timer
  Timer? _recordingTimer;
  int _elapsedSeconds = 0;

  // Task scheduler state
  Timer? _nextTaskDelayTimer;
  Timer? _taskDisplayCountdownTimer;
  bool _showTaskOverlay = false;
  int _taskDisplaySecondsLeft = 6; // Display task for 6 seconds
  TaskPrompt? _currentTask;

  // Non-repeating randomized pool of tasks
  List<TaskPrompt> _unseenTasksPool = [];
  final Random _random = Random();

  // Animations
  late AnimationController _emojiAnimController;
  late Animation<double> _emojiScaleAnimation;

  late AnimationController _taskBannerAnimController;
  late Animation<double> _taskBannerFadeAnimation;
  late Animation<Offset> _taskBannerSlideAnimation;

  // Exact 10 Simple, Safe Sports & Assessment Tasks
  static const List<TaskPrompt> _masterTaskList = [
    TaskPrompt(
      id: 'jump_once',
      title: 'Jump once',
      emoji: '🦘',
      description: 'Jump up once with both feet!',
      icon: Icons.height,
      accentColor: Color(0xFFFF6D00),
    ),
    TaskPrompt(
      id: 'raise_hands',
      title: 'Raise both hands',
      emoji: '🙆‍♂️',
      description: 'Raise both hands straight above your head!',
      icon: Icons.accessibility_new,
      accentColor: Color(0xFF2979FF),
    ),
    TaskPrompt(
      id: 'clap_twice',
      title: 'Clap hands twice',
      emoji: '👏',
      description: 'Clap your hands 2 times clearly!',
      icon: Icons.sign_language,
      accentColor: Color(0xFF00E676),
    ),
    TaskPrompt(
      id: 'turn_around',
      title: 'Turn around once',
      emoji: '🔄',
      description: 'Turn around 360 degrees on the spot!',
      icon: Icons.autorenew,
      accentColor: Color(0xFFFF4081),
    ),
    TaskPrompt(
      id: 'say_name',
      title: 'Say your name',
      emoji: '🗣️',
      description: 'Say your full name aloud to the camera!',
      icon: Icons.record_voice_over,
      accentColor: Color(0xFF00E5FF),
    ),
    TaskPrompt(
      id: 'touch_shoulders',
      title: 'Touch your shoulders',
      emoji: '🏋️‍♂️',
      description: 'Touch both your shoulders with your hands!',
      icon: Icons.front_hand,
      accentColor: Color(0xFFAA00FF),
    ),
    TaskPrompt(
      id: 'stand_one_leg',
      title: 'Stand on one leg',
      emoji: '🦩',
      description: 'Balance on one leg for 3 seconds!',
      icon: Icons.directions_walk,
      accentColor: Color(0xFFFF9100),
    ),
    TaskPrompt(
      id: 'steps_forward',
      title: 'Two steps forward',
      emoji: '🚶‍♂️',
      description: 'Take two steps forward towards the camera!',
      icon: Icons.straighten,
      accentColor: Color(0xFF76FF03),
    ),
    TaskPrompt(
      id: 'do_squat',
      title: 'Do one squat',
      emoji: '🏋️',
      description: 'Bend your knees and perform 1 deep squat!',
      icon: Icons.fitness_center,
      accentColor: Color(0xFFFF1744),
    ),
    TaskPrompt(
      id: 'wave_camera',
      title: 'Wave at camera',
      emoji: '👋',
      description: 'Smile and wave your hand at the camera!',
      icon: Icons.waving_hand,
      accentColor: Color(0xFFFFD600),
    ),
  ];

  @override
  void initState() {
    super.initState();

    // Pulse animation for emoji
    _emojiAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..repeat(reverse: true);

    _emojiScaleAnimation = Tween<double>(begin: 0.92, end: 1.15).animate(
      CurvedAnimation(
        parent: _emojiAnimController,
        curve: Curves.easeInOutBack,
      ),
    );

    // Fade + Slide banner animation
    _taskBannerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _taskBannerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _taskBannerAnimController,
        curve: Curves.easeIn,
      ),
    );

    _taskBannerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _taskBannerAnimController,
        curve: Curves.easeOutBack,
      ),
    );

    _initTaskPool();
    _initCamera();
  }

  void _initTaskPool() {
    _unseenTasksPool = List.from(_masterTaskList);
    _unseenTasksPool.shuffle(_random);
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() {
          _errorMessage = 'No camera hardware found on device.';
          _isInitializing = false;
        });
        return;
      }

      int defaultCamIndex = _cameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
      );
      if (defaultCamIndex == -1) defaultCamIndex = 0;
      _selectedCameraIndex = defaultCamIndex;

      await _setupCameraController(_cameras[_selectedCameraIndex]);
    } catch (e) {
      setState(() {
        _errorMessage = 'Camera setup failed: $e';
        _isInitializing = false;
      });
    }
  }

  Future<void> _setupCameraController(CameraDescription camera) async {
    setState(() => _isInitializing = true);
    await _controller?.dispose();

    final controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: true,
    );

    try {
      await controller.initialize();
      if (!mounted) return;
      setState(() {
        _controller = controller;
        _isInitializing = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Could not access camera: $e';
        _isInitializing = false;
      });
    }
  }

  Future<void> _toggleCamera() async {
    if (_cameras.length < 2 || _isRecording) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _setupCameraController(_cameras[_selectedCameraIndex]);
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      if (_isFlashOn) {
        await _controller!.setFlashMode(FlashMode.off);
        setState(() => _isFlashOn = false);
      } else {
        await _controller!.setFlashMode(FlashMode.torch);
        setState(() => _isFlashOn = true);
      }
    } catch (_) {}
  }

  void _startRecording() async {
    if (_controller == null || !_controller!.value.isInitialized || _isRecording) {
      return;
    }

    try {
      await _controller!.startVideoRecording();
      setState(() {
        _isRecording = true;
        _elapsedSeconds = 0;
        _showTaskOverlay = false;
      });

      // Main recording timer (elapsed seconds)
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;
        setState(() => _elapsedSeconds++);
      });

      // Schedule first task after ~10 seconds of recording (Requirements 1.A.4 & 1.A.5)
      _scheduleNextTask(delaySeconds: 10);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start recording: $e')),
      );
    }
  }

  void _scheduleNextTask({required int delaySeconds}) {
    _nextTaskDelayTimer?.cancel();

    // Add slight random variation (0 to 3 seconds) for unpredictability
    final actualDelay = delaySeconds + _random.nextInt(4);

    _nextTaskDelayTimer = Timer(Duration(seconds: actualDelay), () {
      if (!mounted || !_isRecording) return;
      _triggerTaskOverlay();
    });
  }

  void _triggerTaskOverlay() {
    if (_unseenTasksPool.isEmpty) {
      _initTaskPool();
    }

    // Pick task from unseen pool, ensuring no consecutive repeat
    TaskPrompt nextTask = _unseenTasksPool.removeAt(0);
    if (nextTask.id == _currentTask?.id && _unseenTasksPool.isNotEmpty) {
      final swap = nextTask;
      nextTask = _unseenTasksPool.removeAt(0);
      _unseenTasksPool.add(swap);
    }

    setState(() {
      _currentTask = nextTask;
      _showTaskOverlay = true;
      _taskDisplaySecondsLeft = 6; // Display task card for 6 seconds
    });

    _taskBannerAnimController.reset();
    _taskBannerAnimController.forward();

    // Start 6-second display countdown timer
    _taskDisplayCountdownTimer?.cancel();
    _taskDisplayCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || !_isRecording) return;

      setState(() {
        if (_taskDisplaySecondsLeft > 1) {
          _taskDisplaySecondsLeft--;
        } else {
          _dismissTaskOverlay();
        }
      });
    });
  }

  void _dismissTaskOverlay() {
    _taskDisplayCountdownTimer?.cancel();

    _taskBannerAnimController.reverse().then((_) {
      if (!mounted) return;
      setState(() {
        _showTaskOverlay = false;
      });

      // Schedule next task after approximately 10 seconds pause
      if (_isRecording) {
        _scheduleNextTask(delaySeconds: 10);
      }
    });
  }

  Future<void> _stopRecordingAndSave() async {
    if (_controller == null || !_isRecording) return;

    try {
      _recordingTimer?.cancel();
      _nextTaskDelayTimer?.cancel();
      _taskDisplayCountdownTimer?.cancel();

      final XFile recordedFile = await _controller!.stopVideoRecording();

      setState(() {
        _isRecording = false;
        _showTaskOverlay = false;
      });

      if (!mounted) return;
      // Return file path to caller
      Navigator.pop(context, recordedFile.path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to stop recording: $e')),
      );
    }
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _nextTaskDelayTimer?.cancel();
    _taskDisplayCountdownTimer?.cancel();
    _emojiAnimController.dispose();
    _taskBannerAnimController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  String _formatTimer(int totalSeconds) {
    final mins = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Full Screen Live Camera Preview
          _buildCameraPreview(),

          // 2. Overlay HUD when camera initialized
          if (_controller != null && _controller!.value.isInitialized) ...[
            // Top Header: Back Button, REC Badge, Flash
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 16,
              right: 16,
              child: _buildTopHeader(),
            ),

            // Random Task Overlay Banner (Compact overlay near top)
            if (_showTaskOverlay && _currentTask != null)
              Positioned(
                top: MediaQuery.of(context).padding.top + 70,
                left: 16,
                right: 16,
                child: _buildTaskBannerOverlay(),
              ),

            // Bottom Recording Controls
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 24,
              left: 0,
              right: 0,
              child: _buildBottomControls(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_isInitializing) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.accent),
            SizedBox(height: 16),
            Text(
              'Initializing Camera...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.videocam_off, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go Back'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final size = MediaQuery.of(context).size;
    var scale = size.aspectRatio * _controller!.value.aspectRatio;
    if (scale < 1) scale = 1 / scale;

    return Transform.scale(
      scale: scale,
      child: Center(
        child: CameraPreview(_controller!),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Exit / Back Button
        Container(
          decoration: const BoxDecoration(
            color: Colors.black45,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              if (_isRecording) {
                _showCancelDialog();
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ),

        // Recording Status / Timer Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _isRecording ? Colors.red.withValues(alpha: 0.85) : Colors.black54,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isRecording ? Colors.redAccent : Colors.white24,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _isRecording ? Colors.white : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _isRecording ? 'REC ${_formatTimer(_elapsedSeconds)}' : 'READY TO RECORD',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),

        // Flash Button
        Container(
          decoration: const BoxDecoration(
            color: Colors.black45,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              _isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: _isFlashOn ? Colors.yellow : Colors.white,
            ),
            onPressed: _toggleFlash,
          ),
        ),
      ],
    );
  }

  Widget _buildTaskBannerOverlay() {
    final task = _currentTask!;
    final progress = _taskDisplaySecondsLeft / 6.0;

    return SlideTransition(
      position: _taskBannerSlideAnimation,
      child: FadeTransition(
        opacity: _taskBannerFadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                task.accentColor.withValues(alpha: 0.92),
                Colors.black87,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: task.accentColor.withValues(alpha: 0.5),
                blurRadius: 18,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header tag & Dismiss button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bolt, color: Colors.yellowAccent, size: 16),
                          SizedBox(width: 4),
                          Text(
                            '⚡ QUICK CHALLENGE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Quick Dismiss button
                    InkWell(
                      onTap: _dismissTaskOverlay,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Dismiss',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 2),
                            Icon(Icons.close, color: Colors.white, size: 13),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Main Task Banner: Animated Emoji + Task Name & Description
                Row(
                  children: [
                    // Animated Bouncing Emoji
                    ScaleTransition(
                      scale: _emojiScaleAnimation,
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: task.accentColor.withValues(alpha: 0.6),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            task.emoji,
                            style: const TextStyle(fontSize: 30),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 14),

                    // Task Instruction Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            task.description,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 13,
                              height: 1.25,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Countdown Ring Timer
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 42,
                          height: 42,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 4,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.yellowAccent,
                            ),
                          ),
                        ),
                        Text(
                          '${_taskDisplaySecondsLeft}s',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Switch Camera Button
          IconButton(
            onPressed: _isRecording ? null : _toggleCamera,
            iconSize: 32,
            icon: Icon(
              Icons.cameraswitch,
              color: _isRecording ? Colors.grey : Colors.white,
            ),
          ),

          // Main Record / Stop Recording Button
          GestureDetector(
            onTap: () {
              if (_isRecording) {
                _stopRecordingAndSave();
              } else {
                _startRecording();
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 80,
              height: 80,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 4,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: _isRecording ? Colors.red : AppColors.accent,
                  borderRadius: BorderRadius.circular(_isRecording ? 16 : 40),
                ),
                child: Center(
                  child: Icon(
                    _isRecording ? Icons.stop : Icons.videocam,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
              ),
            ),
          ),

          // Hint / Info button
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Random physical challenges will appear during recording every ~10s!',
                  ),
                  duration: Duration(seconds: 3),
                ),
              );
            },
            iconSize: 32,
            icon: const Icon(
              Icons.info_outline,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Discard Recording?'),
        content: const Text(
          'Are you sure you want to stop and discard this live recording session?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue Recording'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Exit screen
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }
}
