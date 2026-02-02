class AppConstants {
  // App Info
  static const String appName = 'SwiftCart';
  static const String appVersion = '1.0.0';

  // API Endpoints (for future backend integration)
  static const String baseUrl = 'https://api.swiftcart.com';

  // Asset Paths
  static const String logoPath = 'assets/images/logo.png';
  static const String placeholderImage = 'assets/images/placeholder.png';

  // Dimensions
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 8.0;
  static const double cardBorderRadius = 12.0;

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Screen Breakpoints for Responsive Design
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1200;

  // Cart and Wishlist Limits
  static const int maxCartItems = 99;
  static const int maxWishlistItems = 100;

  // Product Display
  static const int itemsPerPage = 20;
  static const int carouselItemsCount = 5;
  static const int categoriesPerRow = 4;

  // Flash Sale
  static const Duration flashSaleDuration = Duration(hours: 24);

  // Onboarding
  static const int onboardingSteps = 3;

  // Validation
  static const int minPasswordLength = 8;
  static const int maxNameLength = 50;
  static const int maxAddressLength = 200;

  // Payment
  static const double minOrderAmount = 10.0;
  static const double maxOrderAmount = 10000.0;

  // Social Media Links (placeholders)
  static const String googleClientId = 'your_google_client_id';
  static const String appleServiceId = 'your_apple_service_id';

  // FCM Configuration
  static const String projectId = 'chat-5c41a';
  static const String fcmServerKey = 'legacy_key_not_used_in_v1';
  static const String serviceAccountPath = 'assets/chat-5c41a-firebase-adminsdk-fbsvc-bbef9f578a.json';

  // Support
  static const String supportEmail = 'support@swiftcart.com';
  static const String supportPhone = '+1-234-567-8900';

  // Cache Keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String cartItemsKey = 'cart_items';
  static const String wishlistItemsKey = 'wishlist_items';
  static const String onboardingCompletedKey = 'onboarding_completed';

  // Route Names
  static const String splashRoute = '/splash';
  static const String onboardingRoute = '/onboarding';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String homeRoute = '/home';
  static const String productDetailsRoute = '/product-details';
  static const String cartRoute = '/cart';
  static const String checkoutRoute = '/checkout';
  static const String profileRoute = '/profile';
  static const String wishlistRoute = '/wishlist';
  static const String ordersRoute = '/orders';
  static const String settingsRoute = '/settings';
  static const String helpRoute = '/help';
}


