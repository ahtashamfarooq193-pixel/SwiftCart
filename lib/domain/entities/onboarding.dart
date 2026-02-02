class OnboardingItem {
  final String id;
  final String title;
  final String description;
  final String imagePath;
  final String? iconName;

  const OnboardingItem({
    required this.id,
    required this.title,
    required this.description,
    required this.imagePath,
    this.iconName,
  });
}

class OnboardingData {
  static const List<OnboardingItem> items = [
    OnboardingItem(
      id: '1',
      title: 'Discover Amazing Products',
      description: 'Explore thousands of premium products from trusted vendors around the world. Find exactly what you need with our advanced search and filters.',
      imagePath: 'assets/images/jackets/Leather Jacket.png',
      iconName: 'shopping_bag',
    ),
    OnboardingItem(
      id: '2',
      title: 'Secure & Fast Checkout',
      description: 'Enjoy a seamless shopping experience with multiple payment options, secure checkout, and fast delivery to your doorstep.',
      imagePath: 'assets/images/bags/hand bag.png',
      iconName: 'payment',
    ),
    OnboardingItem(
      id: '3',
      title: 'Track Your Orders',
      description: 'Stay updated with real-time order tracking, receive notifications, and manage your purchases all in one place.',
      imagePath: 'assets/images/Shoes/Nike Shoes.png',
      iconName: 'local_shipping',
    ),
  ];
}


