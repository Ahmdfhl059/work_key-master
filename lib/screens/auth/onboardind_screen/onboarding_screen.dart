import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:work_key/screens/auth/auth_navigation.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/utils/constants.dart';
import 'package:work_key/utils/shared%20preferences.dart';

class OnboardingModel {
  final String image;
  final String title;
  final String body;

  OnboardingModel({required this.image, required this.title, required this.body});
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  var boardController = PageController();
  bool isLast = false;

  List<OnboardingModel> boarding = [
    OnboardingModel(
      image: 'assets/images/1.png',
      title: 'Find Your Dream Job',
      body: 'Explore thousands of job opportunities tailored just for you.',
    ),
    OnboardingModel(
      image: 'assets/images/2.png',
      title: 'Easy Application',
      body: 'Apply to your favorite jobs with just one click using your digital CV.',
    ),
    OnboardingModel(
      image: 'assets/images/3.png',
      title: 'Track Your Progress',
      body: 'Stay updated with your application status and interview schedules.',
    ),
  ];

  void submit() {
    print('--- UI: Onboarding Finished. Saving to Cache ---');
    CacheHelper.saveData(key: 'onBoarding', value: true).then((value) {
      if (value) {
        print('--- UI: Cache Saved. Navigating to WelcomeScreen ---');
        AuthNavigation.continueAsGuest(context);
      } else {
        print('--- UI ERROR: Failed to save Onboarding state to Cache ---');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          DefaultTextButton(
            onPressed: () {
              print('--- UI: Skip Onboarding Pressed ---');
              submit();
            },
            text: "SKIP",
            textStyle: TextStyle(color: primary, fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: boardController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  print('--- UI: Onboarding Page Changed to: $index ---');
                  if (index == boarding.length - 1) {
                    setState(() => isLast = true);
                  } else {
                    setState(() => isLast = false);
                  }
                },
                itemBuilder: (context, index) => _buildBoardingItem(boarding[index]),
                itemCount: boarding.length,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                SmoothPageIndicator(
                  controller: boardController,
                  count: boarding.length,
                  effect: ExpandingDotsEffect(
                    dotColor: Colors.grey.shade300,
                    activeDotColor: primary,
                    dotHeight: 8,
                    expansionFactor: 4,
                    dotWidth: 8,
                    spacing: 5.0,
                  ),
                ),
                const Spacer(),
                FloatingActionButton(
                  onPressed: () {
                    if (isLast) {
                      print('--- UI: Last Page FAB Pressed ---');
                      submit();
                    } else {
                      print('--- UI: Next Page FAB Pressed ---');
                      boardController.nextPage(
                        duration: const Duration(milliseconds: 750),
                        curve: Curves.fastLinearToSlowEaseIn,
                      );
                    }
                  },
                  backgroundColor: primary,
                  elevation: 10,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoardingItem(OnboardingModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Center(
            child: Image.asset(model.image, fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 30),
        DefaultText(
          text: model.title,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        const SizedBox(height: 15),
        DefaultText(
          text: model.body,
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600, height: 1.5),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
