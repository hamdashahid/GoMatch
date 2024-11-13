import 'package:flutter/material.dart';
import 'package:gomatch/utils/colors.dart';

class FAQScreen extends StatelessWidget {
  static const String idScreen = "FaqScreen";

  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FAQ"),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const FAQCategory(
            category: 'My profile',
            faqs: [
              FAQItem(title: 'My account is blocked', screen: FAQDetailScreen(detail: 'If your account is blocked, please contact our support team for assistance.')),
              FAQItem(title: 'How to change my info?', screen: FAQDetailScreen(detail: 'To change your info, go to the profile section and update your details.')),
              FAQItem(title: 'How to delete my account?', screen: FAQDetailScreen(detail: 'To delete your account, please go to settings and select "Delete Account".')),
            ],
          ),
          const FAQCategory(
            category: 'Safety',
            faqs: [
              FAQItem(title: 'Driver verification', screen: FAQDetailScreen(detail: 'All drivers are verified through a thorough background check.')),
              FAQItem(title: 'Safety tips', screen: FAQDetailScreen(detail: 'Always verify the driver and car details before starting your ride.')),
              FAQItem(title: 'Service rules', screen: FAQDetailScreen(detail: 'Please follow our community guidelines to ensure a safe experience for everyone.')),
              FAQItem(title: 'Safety features', screen: FAQDetailScreen(detail: 'Our app includes safety features like emergency contacts and ride tracking.')),
              FAQItem(title: 'Information security', screen: FAQDetailScreen(detail: 'We use advanced encryption to protect your personal information.')),
              FAQItem(title: 'Insurance', screen: FAQDetailScreen(detail: 'Our rides are covered by comprehensive insurance policies.')),
            ],
          ),
          const FAQCategory(
            category: 'Payment',
            faqs: [
              FAQItem(title: 'How much should I offer?', screen: FAQDetailScreen(detail: 'The amount you offer depends on the distance and time of the ride.')),
              FAQItem(title: 'Payment methods', screen: FAQDetailScreen(detail: 'We accept various payment methods including credit cards and digital wallets.')),
              FAQItem(title: 'Toll roads', screen: FAQDetailScreen(detail: 'Toll charges are automatically added to your fare.')),
            ],
          ),
          const FAQCategory(
            category: 'Before the Ride',
            faqs: [
              FAQItem(title: 'How to find a driver?', screen: FAQDetailScreen(detail: 'Use the app to search for available drivers in your area.')),
              FAQItem(title: 'How to join a ride in RideShare?', screen: FAQDetailScreen(detail: 'Select a ride from the list of available rides and confirm your booking.')),
              FAQItem(title: 'How to cancel an accepted order?', screen: FAQDetailScreen(detail: 'Go to your bookings and select the ride you want to cancel.')),
            ],
          ),
          const FAQCategory(
            category: 'Order Issues',
            faqs: [
              FAQItem(title: 'Driver asked to cancel', screen: FAQDetailScreen(detail: 'If the driver asks to cancel, please contact support for further assistance.')),
              FAQItem(title: 'I left my belongings in the car', screen: FAQDetailScreen(detail: 'Contact the driver through the app to retrieve your belongings.')),
              FAQItem(title: 'Different driver or car', screen: FAQDetailScreen(detail: 'If the driver or car is different, please report the issue through the app.')),
            ],
          ),
          const FAQCategory(
            category: 'Questions about drivers',
            faqs: [
              FAQItem(title: 'How to call the driver?', screen: FAQDetailScreen(detail: 'Use the call button in the app to contact your driver.')),
              FAQItem(title: 'Driver asked to cancel', screen: FAQDetailScreen(detail: 'If the driver asks to cancel, please contact support for further assistance.')),
              FAQItem(title: 'How to become a driver?', screen: FAQDetailScreen(detail: 'To become a driver, sign up through our app and complete the verification process.')),
            ],
          ),
          const FAQCategory(
            category: 'Common Questions',
            faqs: [
              FAQItem(title: 'How to use the app?', screen: FAQDetailScreen(detail: 'Our app is user-friendly. Follow the on-screen instructions to navigate.')),
              FAQItem(title: 'What are the app policies?', screen: FAQDetailScreen(detail: 'Please refer to our terms and conditions for detailed app policies.')),
            ],
          ),
          const HelpAndSupport(),
        ],
      ),
    );
  }
}

class FAQCategory extends StatelessWidget {
  final String category;
  final List<FAQItem> faqs;

  const FAQCategory({super.key, required this.category, required this.faqs});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        category,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Brand-Bold'),
      ),
      children: faqs,
    );
  }
}

class FAQItem extends StatelessWidget {
  final String title;
  final Widget screen;

  const FAQItem({super.key, required this.title, required this.screen});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontFamily: 'Brand-Regular',
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 15,
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
    );
  }
}

class FAQDetailScreen extends StatelessWidget {
  final String detail;

  const FAQDetailScreen({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FAQ Detail"),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          detail,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class HelpAndSupport extends StatelessWidget {
  const HelpAndSupport({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: const Text(
            'Live Chat',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Brand-Regular',
            ),
          ),
          trailing: const Icon(
            Icons.chat,
            size: 15,
          ),
          onTap: () {
            // Implement live chat functionality here
          },
        ),
        ListTile(
          title: const Text(
            'Call Support',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Brand-Regular',
            ),
          ),
          trailing: const Icon(
            Icons.phone,
            size: 15,
          ),
          onTap: () {
            // Implement call support functionality here
          },
        ),
      ],
    );
  }
}
