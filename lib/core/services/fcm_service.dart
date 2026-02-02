import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import '../../core/constants/app_constants.dart';
import '../../main.dart';
import '../../presentation/screens/admin_dashboard_screen.dart';
import '../../domain/entities/product.dart';
import '../../presentation/screens/product_detail_screen.dart';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Navigation callback
  Function(Map<String, dynamic>)? onNotificationTap;

  Future<void> initialize() async {
    try {
      debugPrint('FCM: Starting initialization...');
      // Request permission for notifications
      await _requestPermission();
      debugPrint('FCM: Permissions requested');

      // Initialize local notifications
      await _initializeLocalNotifications();
      debugPrint('FCM: Local notifications initialized');

      // Get FCM token and save for admin (Don't let this block if possible, but it's awaited here)
      // Wrapping this sub-step specifically to avoid it hanging everything
      try {
        await _setupFCMToken().timeout(const Duration(seconds: 5));
        debugPrint('FCM: Token setup complete');
      } catch (e) {
        debugPrint('FCM: Token setup failed or timed out: $e');
      }

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification tap when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
      debugPrint('FCM: Initialization finished successfully');
    } catch (e) {
      debugPrint('FCM: Initialization ERROR: $e');
      // We don't rethrow because we want the app to still start even if FCM fails
    }
  }

  Future<void> _requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_notification');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _setupFCMToken() async {
    // Get FCM token
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      print('FCM Token: $token');

      // Save token for current user (admin)
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });
      }
    }

    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      print('FCM Token refreshed: $newToken');
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'fcmToken': newToken,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
      _showLocalNotification(message);
    }
  }

  Future<void> _handleNotificationTap(RemoteMessage message) async {
    print('Notification tapped: ${message.data}');
    _handleNotificationNavigation(message.data);
  }

  void _onNotificationTap(NotificationResponse response) {
    print('Notification tapped with payload: ${response.payload}');
    if (response.payload != null) {
      final data = jsonDecode(response.payload!);
      _handleNotificationNavigation(data);
    }
  }

  Future<void> _handleNotificationNavigation(Map<String, dynamic> data) async {
    final type = data['type'];
    
    if (type == 'new_order') {
      // Navigate to admin dashboard
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => const AdminDashboardScreen(),
        ),
      );
    } else if (type == 'review_prompt') {
      final productId = data['productId'];
      if (productId != null) {
        try {
          // Show loading (optional, but good UX if feasible, or just wait)
          // Fetch product details
          final doc = await FirebaseFirestore.instance.collection('products').doc(productId).get();
          if (doc.exists) {
            final productData = doc.data()!;
            // Map to Product entity (Simplified mapping based on usage)
            
            // Helper to safely get list
            List<String> getList(String key) {
               if (productData[key] is List) return List<String>.from(productData[key]);
               if (productData[key] is String) return [productData[key]];
               return [];
            }

            final product = Product(
              id: doc.id,
              name: productData['name'] ?? 'Unknown',
              description: productData['description'] ?? '',
              price: (productData['price'] ?? 0).toDouble(),
              originalPrice: (productData['originalPrice'] ?? (productData['price'] ?? 0)).toDouble(),
              imageUrl: productData['image'] ?? '',
              images: getList('images'),
              categoryId: '', 
              categoryName: productData['category'] ?? '',
              brand: productData['brand'] ?? '',
              rating: (productData['rating'] ?? 0).toDouble(),
              reviewCount: productData['reviewCount'] ?? 0,
              isInStock: productData['isInStock'] ?? true,
              stockQuantity: productData['stockQuantity'] ?? 0,
              sizes: getList('sizes'),
              colors: getList('colors'),
              specifications: productData['specifications'] ?? {},
              vendorId: productData['vendorId'] ?? '',
              vendorName: productData['vendorName'] ?? '',
              createdAt: (productData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
              updatedAt: (productData['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            );

            // Navigate to Product Detail
            navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(product: product),
              ),
            );
          }
        } catch (e) {
          print('Error navigating to product: $e');
        }
      }
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: 'ic_notification',
      color: Color(0xFFA78BFA), // Set accent color explicitly for local notifications too
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title ?? 'New Order',
      message.notification?.body ?? 'You have a new order to process',
      platformChannelSpecifics,
      payload: jsonEncode(message.data),
    );
  }

  Future<void> sendStatusUpdateNotification({
    required String userId,
    required String orderId,
    required String status,
    String? productName, // FIRST item name
    String? productId,   // FIRST item id
  }) async {
    try {
      // Get user's FCM token
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      final token = userDoc.data()?['fcmToken'] as String?;

      if (token == null || token.isEmpty) {
        print('FCM: User has no FCM token');
        return;
      }

      String title = 'Order Update! 📦';
      String body = 'Your order #$orderId is now $status';
      String type = 'order_update';

      if (status == 'Delivered') {
        title = 'Delivered! 🎁';
        body = 'Your order #$orderId has been delivered! Please leave a review for ${productName ?? 'your items'}.';
        type = 'review_prompt';
      }

      final message = {
        'message': {
          'token': token,
          'notification': {
            'title': title,
            'body': body,
          },
          'android': {
            'notification': {
              'color': '#A78BFA',
              'channel_id': 'high_importance_channel',
            },
          },
          'data': {
            'type': type,
            'orderId': orderId,
            'status': status,
            if (productId != null) 'productId': productId,
          },
        },
      };

      await _sendNotificationToSingleToken(message);
    } catch (e) {
      print('FCM: Error sending status notification: $e');
    }
  }

  Future<void> _sendNotificationToSingleToken(Map<String, dynamic> message) async {
    final String fcmUrl = 'https://fcm.googleapis.com/v1/projects/${AppConstants.projectId}/messages:send';
    final String? accessToken = await _getAccessToken();

    if (accessToken == null) return;

    try {
      final response = await http.post(
        Uri.parse(fcmUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        print('FCM: Notification sent successfully');
      } else {
        print('FCM: Failed to send notification: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('FCM: Error sending notification: $e');
    }
  }

  Future<void> sendOrderNotificationToAdmins({
    required String userName,
    required String orderId,
    required double totalAmount,
  }) async {
    try {
      // Get all admin users
      final adminUsers = await FirebaseFirestore.instance
          .collection('users')
          .where('isAdmin', isEqualTo: true)
          .get();

      final tokens = adminUsers.docs
          .map((doc) => doc.data()['fcmToken'] as String?)
          .where((token) => token != null && token.isNotEmpty)
          .cast<String>()
          .toList();

      if (tokens.isEmpty) {
        print('No admin FCM tokens found');
        return;
      }

      final message = {
        'message': {
          'notification': {
            'title': 'New Order Received! 🎉',
            'body': '$userName placed order #$orderId - Order is now in Processing',
          },
          'android': {
            'notification': {
              'color': '#A78BFA', // Purple theme color
              'title': 'New Order',
            },
          },
          'data': {
            'type': 'new_order',
            'orderId': orderId,
            'userName': userName,
            'totalAmount': totalAmount.toString(),
          },
        },
      };

      await _sendNotificationToMultipleTokens(tokens, message);
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  Future<String?> _getAccessToken() async {
    try {
      final serviceAccountJson = await rootBundle.loadString(AppConstants.serviceAccountPath);
      final accountCredentials = auth.ServiceAccountCredentials.fromJson(serviceAccountJson);
      final scopes = ['https://www.googleapis.com/auth/cloud-platform'];

      final client = await auth.clientViaServiceAccount(accountCredentials, scopes);
      final accessToken = client.credentials.accessToken.data;
      client.close();
      return accessToken;
    } catch (e) {
      debugPrint('FCM: Error getting access token: $e');
      return null;
    }
  }

  Future<void> _sendNotificationToMultipleTokens(
      List<String> tokens, Map<String, dynamic> message) async {
    final String fcmUrl = 'https://fcm.googleapis.com/v1/projects/${AppConstants.projectId}/messages:send';
    final String? accessToken = await _getAccessToken();

    if (accessToken == null) {
      print('FCM: Failed to get access token, skipping notifications');
      return;
    }

    for (final token in tokens) {
      // Create a deep-ish copy to avoid token overwriting in shared message map
      final requestBody = {
        'message': {
          ...(message['message'] as Map<String, dynamic>),
          'token': token,
        },
      };

      try {
        final response = await http.post(
          Uri.parse(fcmUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode(requestBody),
        );

        if (response.statusCode == 200) {
          print('FCM: Notification sent successfully to token: ${token.substring(0, 10)}...');
        } else {
          print('FCM: Failed to send notification: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        print('FCM: Error sending notification to token: $e');
      }
    }
  }

  // Get initial message when app is launched from terminated state
  Future<RemoteMessage?> getInitialMessage() async {
    return await FirebaseMessaging.instance.getInitialMessage();
  }
}
