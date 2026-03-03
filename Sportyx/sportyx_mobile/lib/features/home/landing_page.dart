import 'package:flutter/material.dart';
import '../auth/login_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  late PageController _pageController;
  int _currentPage = 0;

  final List<SlideData> slides = [
    SlideData(
      title: 'Welcome to Sportyx',
      description: 'Discover talented athletes and showcase your skills',
      icon: Icons.sports_basketball,
      color: Colors.blue,
    ),
    SlideData(
      title: 'Connect & Collaborate',
      description: 'Network with other athletes and scouts in your sport',
      icon: Icons.group,
      color: Colors.purple,
    ),
    SlideData(
      title: 'Grow Your Career',
      description: 'Share your performance videos and get recognized',
      icon: Icons.trending_up,
      color: Colors.orange,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: slides.length,
              itemBuilder: (context, index) {
                return _buildSlide(slides[index]);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                slides.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: _currentPage == index ? 30 : 10,
                  height: 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: _currentPage == index ? Colors.blue : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (_currentPage > 0)
                  OutlinedButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Text('Previous'),
                  ),
                if (_currentPage < slides.length - 1)
                  ElevatedButton(
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Text('Next'),
                  )
                else
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const LoginPage(),
                        ),
                      );
                    },
                    child: const Text('Get Started'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide(SlideData slide) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          slide.icon,
          size: 100,
          color: slide.color,
        ),
        const SizedBox(height: 40),
        Text(
          slide.title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            slide.description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class SlideData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  SlideData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
