import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Initialize Timezone handling for scheduled notifications
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // You can handle what happens when they tap the notification here!
      },
    );
  }

  NotificationDetails _getPlatformDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'vaulto_premium_channel',
        'Vaulto Alerts',
        channelDescription: 'Premium notifications for Vaulto App',
        importance: Importance.max,
        priority: Priority.high,
        enableLights: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  // 1. Instant Test Notification
  Future<void> showWelcomeNotification() async {
    await _flutterLocalNotificationsPlugin.show(
      1,
      'Welcome to Vaulto 🚀',
      'Your premium financial tracker is ready to secure your wealth.',
      _getPlatformDetails(),
    );
  }

  // 2. Budget Warning Alert (Triggered when 80% or 100% budget reached)
  Future<void> showBudgetWarning({required double percentage}) async {
    await _flutterLocalNotificationsPlugin.show(
      2,
      'Budget Warning 🛑',
      'You have used ${percentage.toStringAsFixed(0)}% of your monthly budget. Time to slow down!',
      _getPlatformDetails(),
    );
  }

  // 3. Large Transaction Alert (Security / Mindfulness check)
  Future<void> showLargeTransactionAlert({required double amount, required String category}) async {
    await _flutterLocalNotificationsPlugin.show(
      3,
      'Large Expense Logged 💰',
      'A large transaction of \$$amount was just logged under $category.',
      _getPlatformDetails(),
    );
  }

  // 4. Goal Milestone Achieved (Positive reinforcement)
  Future<void> showGoalAchieved({required String goalName}) async {
    await _flutterLocalNotificationsPlugin.show(
      4,
      'Goal Achieved! 🎉',
      'Congratulations! You just hit your target for $goalName.',
      _getPlatformDetails(),
    );
  }

  // 5. Daily Logging Reminder (Scheduled for 8:00 PM every day)
  Future<void> scheduleDailyLoggingReminder() async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 20, 0); // 8:00 PM
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      5,
      'Vaulto Daily Check-in 💸',
      'Did you spend anything today? Take 10 seconds to log your transactions!',
      scheduledDate,
      _getPlatformDetails(),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeats daily at this time
    );
  }

  // 6. EMI / Subscription Due Alert (Scheduled 1 day before due date)
  Future<void> scheduleEMIDueReminder({required int id, required String name, required double amount, required DateTime dueDate}) async {
    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(dueDate, tz.local).subtract(const Duration(days: 1)); // 1 day before
    
    // Only schedule if the due date is in the future
    if (scheduledDate.isAfter(tz.TZDateTime.now(tz.local))) {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id, // Use unique ID for each EMI so they don't overwrite
        'Payment Due Tomorrow ⚠️',
        'Your $name payment of \$$amount is due tomorrow. Ensure you have sufficient funds.',
        scheduledDate,
        _getPlatformDetails(),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  // Utility to clear all
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
