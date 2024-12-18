import 'package:flutter/material.dart';
import 'package:gomatch/utils/colors.dart';
import 'package:page_transition/page_transition.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  static const String idScreen = 'SplashScreen';
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    _pageController = PageController();
    // _controller = AnimationController(
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    Future.delayed(Duration(seconds: 60), () {
      Navigator.pushReplacement(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          child: LoginScreen(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            color: AppColors.primaryColor,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              const SizedBox(height: 90),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  // color: AppColors.lightPrimary,
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.lightPrimary,
                      AppColors.primaryColor,
                      AppColors.secondaryColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage(
                        'assets/images/logoTransparent.png'), // Add your logo path
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // App Name and Tagline
              const Text(
                'GoMatch',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondaryColor,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                // 'Connecting People, Creating Memories',
                'Book your seats with ease.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 50),
              // Info Cards
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 12 : 8,
                    height: _currentPage == index ? 12 : 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index
                          ? AppColors.secondaryColor
                          : Colors.white70,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    // _buildCard(
                    //   'Discover Matches',
                    //   'Swipe right to connect with people you like.',
                    // ),
                    _buildCard(
                      'Affordable Rides',
                      'Get the best prices for your rides with our app.',
                      // 'assets/images/affordable.png',
                      'assets/bigcar.png',
                    ),
                    _buildCard(
                      'Secure & Private',
                      'Ride to your destination safely with our drivers',
                      'assets/tick.png',
                    ),
                    _buildCard(
                      'Easy Navigation',
                      'Navigate through the app with ease and comfort.',
                      'assets/wheel.png',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
          // Skip Button
          Positioned(
            bottom: 40,
            right: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  PageTransition(
                    type: PageTransitionType.fade,
                    child: LoginScreen(),
                  ),
                );
              },
              child: const Text(
                'Skip',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.secondaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String title, String description, String imagePath) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: Container(
          // color: AppColors.primaryColor,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.lightPrimary,
                AppColors.primaryColor,
                AppColors.secondaryColor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                imagePath,
                height: 120,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
