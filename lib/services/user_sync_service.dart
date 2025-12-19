import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:learningday1/database/user_database.dart';
import 'package:learningday1/services/user_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

class UserSyncService {
  static const String syncTaskName = 'userSyncTask';
  static const String uniqueTaskName = 'userSyncUniqueTask';

  final UserApiService _apiService = UserApiService();
  final UserDatabase _database = UserDatabase.instance;

  // Initialize background sync
  static Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  }

  // Register periodic sync task (runs every 15 minutes)
  Future<void> registerPeriodicSync() async {
    await Workmanager().registerPeriodicTask(
      uniqueTaskName,
      syncTaskName,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  // Cancel sync task
  Future<void> cancelSync() async {
    await Workmanager().cancelByUniqueName(uniqueTaskName);
  }

  // Manual sync with pagination
  Future<bool> syncUsers() async {
    try {
      // 1. Sync pending offline users first
      await syncPendingUsers();

      // 2. Check connectivity for fetching new users
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        print('No internet connection for fetching new users');
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      int currentPage = prefs.getInt('sync_page') ?? 1;

      // Fetch users from API (5 per page)
      final users = await _apiService.fetchUsers(page: currentPage, perPage: 5);

      if (users.isEmpty) {
        // Reset to page 1 if no more data
        await prefs.setInt('sync_page', 1);
        return true;
      }

      // Save to local database (avoid duplicates)
      for (var user in users) {
        if (user.id != null) {
          final exists = await _database.userExists(user.id!);
          if (!exists) {
            await _database.create(user);
          }
        }
      }

      // Increment page for next sync
      await prefs.setInt('sync_page', currentPage + 1);
      await prefs.setString('last_sync', DateTime.now().toIso8601String());

      print('Synced ${users.length} users from page $currentPage');
      return true;
    } catch (e) {
      print('Sync error: $e');
      return false;
    }
  }

  // Sync users created while offline
  Future<void> syncPendingUsers() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) return;

    final pendingUsers = await _database.getPendingSyncUsers();
    if (pendingUsers.isEmpty) return;

    print('Syncing ${pendingUsers.length} pending users to API...');

    for (var user in pendingUsers) {
      try {
        final createdUser = await _apiService.createUser(user);
        if (createdUser != null) {
          // Update local user with real ID and mark as synced
          // Since DummyJSON generates 101+ for new users, we replace the temp one
          await _database.delete(user.id!);
          await _database.create(createdUser.copyWith(needsSync: false));
          print('Successfully synced user: ${user.name}');
        }
      } catch (e) {
        print('Failed to sync pending user ${user.name}: $e');
      }
    }
  }

  // Get last sync time
  Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSyncString = prefs.getString('last_sync');
    if (lastSyncString != null) {
      return DateTime.parse(lastSyncString);
    }
    return null;
  }

  // Reset sync
  Future<void> resetSync() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('sync_page', 1);
  }
}

// Background task callback
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      if (task == UserSyncService.syncTaskName) {
        final syncService = UserSyncService();
        await syncService.syncUsers();
      }
      return Future.value(true);
    } catch (e) {
      print('Background task error: $e');
      return Future.value(false);
    }
  });
}
