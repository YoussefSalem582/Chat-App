class OnboardingContent {
  final String title;
  final String description;
  final String image;

  OnboardingContent({
    required this.title,
    required this.description,
    required this.image,
  });
}

List<OnboardingContent> onboardingContents = [
  OnboardingContent(
    title: 'Connect with Friends',
    description:
        'Stay connected with your friends and family through instant messaging',
    image: '💬',
  ),
  OnboardingContent(
    title: 'Share Moments',
    description:
        'Share photos, documents, and your location with the people you care about',
    image: '📸',
  ),
  OnboardingContent(
    title: 'Stay Secure',
    description:
        'Your conversations are private and secure. Chat with confidence',
    image: '🔒',
  ),
];
