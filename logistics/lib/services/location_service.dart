import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LocationService extends ChangeNotifier {
  // Singleton instance
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  // Supabase client
  final SupabaseClient _supabase = Supabase.instance.client;

  // Current location state
  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;

  // Tracking state
  bool _isTracking = false;
  bool get isTracking => _isTracking;
  StreamSubscription<Position>? _positionStreamSubscription;

  // Stream controller for location updates
  final StreamController<Position> _locationController =
      StreamController<Position>.broadcast();
  Stream<Position> get locationStream => _locationController.stream;

  /// Check if location services are enabled
  Future<bool> get _isLocationEnabled async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Request location permissions using Geolocator
  Future<bool> get _hasLocationPermission async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // Check for background tracking requirement (iOS-specific)
    if (permission == LocationPermission.whileInUse &&
        defaultTargetPlatform == TargetPlatform.iOS) {
      debugPrint(
        "Warning: Background tracking may require 'always' permission on iOS",
      );
    }

    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Initialize location service
  Future<void> initialize() async {
    if (!await _isLocationEnabled) {
      throw LocationServiceException(
        "Location services are disabled. Please enable location services in your device settings.",
      );
    }

    if (!await _hasLocationPermission) {
      throw LocationServiceException(
        "Location permission denied. Please grant location permission to use this feature.",
      );
    }
  }

  /// Get current location once
  Future<Position?> getCurrentLocation() async {
    try {
      await initialize();

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
        timeLimit: const Duration(seconds: 10),
      );

      notifyListeners();
      return _currentPosition;
    } on LocationServiceException {
      rethrow;
    } catch (e) {
      debugPrint("LocationService Error: $e");
      throw LocationServiceException(
        "Failed to get current location: ${e.toString()}",
      );
    }
  }

  /// Start live location tracking
  Future<void> startLiveTracking({
    required String driverId,
    int intervalSeconds = 10,
    int distanceFilter = 10,
  }) async {
    if (_isTracking) {
      debugPrint("Location tracking is already active");
      return;
    }

    try {
      await initialize();
      _isTracking = true;
      notifyListeners();

      // Configure LocationSettings for Geolocator
      final LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: distanceFilter,
      );

      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) async {
          _currentPosition = position;

          // Emit to local stream
          if (!_locationController.isClosed) {
            _locationController.add(position);
          }

          // Update Supabase in real-time
          await _updateDriverLocation(driverId, position);
          notifyListeners();
        },
        onError: (error) {
          debugPrint("Location stream error: $error");
          _handleLocationError(error);
        },
        cancelOnError: false,
      );
    } catch (e) {
      _isTracking = false;
      await _positionStreamSubscription?.cancel();
      _positionStreamSubscription = null;
      notifyListeners();
      debugPrint("Failed to start location tracking: $e");
      throw LocationServiceException(
        "Failed to start tracking: ${e.toString()}",
      );
    }
  }

  /// Stop live tracking
  Future<void> stopLiveTracking() async {
    if (_positionStreamSubscription != null) {
      await _positionStreamSubscription!.cancel();
      _positionStreamSubscription = null;
    }
    _isTracking = false;
    notifyListeners();
    debugPrint("Location tracking stopped");
  }

  /// Handle location stream errors
  void _handleLocationError(dynamic error) async {
    debugPrint("Location error: $error");

    // Check if location services are disabled
    if (!await _isLocationEnabled) {
      _locationController.addError(
        LocationServiceException("Location services are disabled"),
      );
    }
    // Check if permission is denied
    else if (!await _hasLocationPermission) {
      _locationController.addError(
        LocationServiceException("Location permission denied"),
      );
    }
    // Handle other errors
    else {
      _locationController.addError(
        LocationServiceException("Location error: ${error.toString()}"),
      );
    }
    notifyListeners();
  }

  /// Update driver location in Supabase with exponential backoff retry logic
  Future<void> _updateDriverLocation(String driverId, Position position) async {
    const int maxRetries = 3;
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        await _supabase.from('driver_locations').upsert({
          'driver_id': driverId,
          'lat': position.latitude,
          'lng': position.longitude,
          'accuracy': position.accuracy,
          'heading': position.heading,
          'speed': position.speed,
          'altitude': position.altitude,
          'timestamp': position.timestamp.toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        break;
      } catch (e) {
        retryCount++;
        debugPrint("Supabase update error (attempt $retryCount): $e");

        if (retryCount >= maxRetries) {
          debugPrint("Failed to update location after $maxRetries attempts");
          throw LocationServiceException(
            "Failed to update location: ${e.toString()}",
          );
        }

        // Exponential backoff
        await Future.delayed(Duration(seconds: 1 << retryCount));
      }
    }
  }

  /// Calculate distance between two points in meters
  double calculateDistance({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  /// Calculate bearing between two points
  double calculateBearing({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) {
    return Geolocator.bearingBetween(startLat, startLng, endLat, endLng);
  }

  /// Open location settings
  Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (e) {
      debugPrint("Failed to open location settings: $e");
      return false;
    }
  }

  /// Open app settings for permissions
  Future<bool> openAppSettings() async {
    try {
      return await Geolocator.openAppSettings();
    } catch (e) {
      debugPrint("Failed to open app settings: $e");
      return false;
    }
  }

  /// Get location permission status
  Future<LocationPermission> getLocationPermissionStatus() async {
    return await Geolocator.checkPermission();
  }

  /// Check if location permission is permanently denied
  Future<bool> isLocationPermissionPermanentlyDenied() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.deniedForever;
  }

  /// Request location permission with detailed handling
  Future<LocationPermission> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    notifyListeners();
    return permission;
  }

  /// Check if we have sufficient location permission
  bool hasValidLocationPermission(LocationPermission permission) {
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Clean up resources
  @override
  void dispose() {
    if (_positionStreamSubscription != null) {
      _positionStreamSubscription!.cancel();
      _positionStreamSubscription = null;
    }
    if (!_locationController.isClosed) {
      _locationController.close();
    }
    _isTracking = false;
    super.dispose();
  }
}

/// Custom exception for location service errors
class LocationServiceException implements Exception {
  final String message;

  const LocationServiceException(this.message);

  @override
  String toString() => 'LocationServiceException: $message';
}
