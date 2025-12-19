import 'package:cron/cron.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:learningday1/database/user_database.dart';
import 'package:learningday1/model/user.dart';
import 'package:learningday1/services/user_api_service.dart';
import 'package:learningday1/services/user_sync_service.dart';

class UserProvider with ChangeNotifier {
  List<User> _users = [];
  bool _isLoading = false;
  bool _isSyncing = false;
  final Cron _cron = Cron();

  final UserDatabase _database = UserDatabase.instance;
  final UserSyncService _syncService = UserSyncService();

  List<User> get users => _users;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;

  // Fetch users from local database
  Future<void> fetchUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _users = await _database.readAllUsers();
    } catch (e) {
      print('Error fetching users: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check if network is available
  Future<bool> _isNetworkAvailable() async {
    try {
      final result = await Connectivity().checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      print('Error checking connectivity: $e');
      return false;
    }
  }

  // Sync users from API (no duplicates)
  Future<void> _syncUsers() async {
    if (_isSyncing) return; // Prevent multiple simultaneous syncs

    // Check network before syncing
    final hasNetwork = await _isNetworkAvailable();
    if (!hasNetwork) {
      print('No network connection - skipping sync');
      return;
    }

    _isSyncing = true;
    notifyListeners();

    try {
      print('Cron job: Syncing users from API...');
      final success = await _syncService.syncUsers();
      if (success) {
        await fetchUsers(); // Refresh local data
        print('Cron job: Sync completed successfully');
      }
    } catch (e) {
      print('Error syncing users: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  // Start automatic sync using cron
  Future<void> startAutoSync() async {
    // Don't sync immediately - only load from local storage
    // Cron job will handle syncing automatically

    // Schedule cron job to run every 2 minutes
    // Cron format: "*/2 * * * *" means every 2 minutes
    _cron.schedule(Schedule.parse('*/2 * * * *'), () async {
      print('Cron job triggered at ${DateTime.now()}');
      await _syncUsers();
    });

    print('Cron job scheduled: Sync every 2 minutes (no immediate sync)');

    // Also register background sync for mobile (when app is closed)
    if (!kIsWeb) {
      await _syncService.registerPeriodicSync();
    }
  }

  // Stop automatic sync
  void stopAutoSync() {
    _cron.close();
  }

  // Add user to API and local database
  Future<bool> addUser(User user) async {
    try {
      final hasNetwork = await _isNetworkAvailable();

      if (!hasNetwork) {
        print('Offline: Saving user locally to sync later');
        // Generate a temporary ID for local storage
        final tempUser = user.copyWith(
          id: DateTime.now().millisecondsSinceEpoch,
          needsSync: true,
        );
        await _database.create(tempUser);
        await fetchUsers();
        return true; // Return true because it was successfully saved locally
      }

      print('Adding user to API: ${user.name}');

      // Post to API
      final createdUser = await UserApiService().createUser(user);

      if (createdUser != null) {
        print('User created in API with ID: ${createdUser.id}');
        // Save to local database marked as synced
        await _database.create(createdUser.copyWith(needsSync: false));
        await fetchUsers();
        return true;
      } else {
        // Fallback: Save locally if API returns null but we have network
        final tempUser = user.copyWith(
          id: DateTime.now().millisecondsSinceEpoch,
          needsSync: true,
        );
        await _database.create(tempUser);
        await fetchUsers();
        return true;
      }
    } catch (e) {
      print('Error adding user, saving locally: $e');
      // Save locally as fallback for any error
      final tempUser = user.copyWith(
        id: DateTime.now().millisecondsSinceEpoch,
        needsSync: true,
      );
      await _database.create(tempUser);
      await fetchUsers();
      return true;
    }
  }

  @override
  void dispose() {
    _cron.close();
    super.dispose();
  }
}
