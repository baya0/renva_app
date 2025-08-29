import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:renva0/core/services/rest_api/constants/end_points.dart';
import 'package:renva0/core/widgets/modern_toast.dart';

import '../../core/demo/media.dart';
import '../../core/services/rest_api/api_service.dart';
import '../../core/services/rest_api/models/request.dart';
import '../../core/services/state_management/obs.dart';
import 'models/service_categories.dart';
import 'story_model.dart';

class HomePageController extends GetxController {
  final ObsList<ServiceCategoryModel> serviceCategories = ObsList<ServiceCategoryModel>([]);
  final ObsList<StoryModel> stories = ObsList<StoryModel>([]);
  final ObsVar<String> currentLocation = ObsVar<String>('Location Name');

  final Duration networkTimeout = const Duration(seconds: 10);

  APIService? _apiService;

  @override
  void onInit() {
    super.onInit();
    _initializeAPIService();
    fetchAllData();
  }

  // Initialize API service safely
  void _initializeAPIService() {
    try {
      _apiService = Get.find<APIService>();
      print('API Service found and ready');
    } catch (e) {
      print(' API Service not found, using mock data only');
      _apiService = null;
    }
  }

  Future<void> fetchAllData() async {
    try {
      if (_apiService != null) {
        print(' Fetching data from backend...');
        await _fetchHomeServices();
      } else {
        print(' Using mock data (API service not available)');
        await _fetchMockData();
      }
    } catch (e) {
      print(' Error fetching data: $e');
      serviceCategories.error = e.toString();
      stories.error = e.toString();
      currentLocation.error = e.toString();
      PopUpToast.show(e.toString());
    }
  }

  Future<void> _fetchHomeServices() async {
    try {
      await Future.wait([
        _fetchServiceCategoriesFromBackend(),
        _fetchStoriesFromBackend(),
        _fetchUserLocationFromBackend(),
      ]).timeout(networkTimeout);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _fetchServiceCategoriesFromBackend() async {
    if (_apiService == null) return;

    try {
      final response = await _apiService!
          .request(
            Request(
              endPoint: EndPoints.provider_categories,
              method: RequestMethod.Get,
              fromJson: (json) => json, // Get raw data first
            ),
          )
          .timeout(networkTimeout);

      if (response.success && response.data != null) {
        // Check if APIService returns the data directly or wrapped
        List<dynamic> categoriesData;

        if (response.data is List) {
          // APIService extracted the data field already
          categoriesData = response.data as List<dynamic>;
        } else if (response.data is Map<String, dynamic>) {
          // Response still has wrapper structure
          final responseData = response.data as Map<String, dynamic>;
          categoriesData = responseData['data'] ?? [];
        } else {
          throw Exception('Unexpected response data type: ${response.data.runtimeType}');
        }

        // Convert to ServiceCategoryModel
        List<ServiceCategoryModel> categories =
            categoriesData
                .map((categoryJson) => ServiceCategoryModel.fromJson(categoryJson))
                .toList();

        serviceCategories.value = categories;
      } else {
        throw Exception('API returned error: ${response.message}');
      }
    } catch (e) {
      print(' Error fetching service categories from backend: $e');

      serviceCategories.error = e.toString();
      rethrow;
    }
  }

  Future<void> _fetchStoriesFromBackend() async {
    try {
      List<StoryModel> storyList = [
        StoryModel(id: '1', imageUrl: 'renva_logo'),
        StoryModel(id: '2', imageUrl: DemoMedia.getAppRandomImage),
        StoryModel(id: '3', imageUrl: DemoMedia.getAppRandomImage),
        StoryModel(id: '4', imageUrl: DemoMedia.getAppRandomImage),
        StoryModel(id: '5', imageUrl: DemoMedia.getAppRandomImage),
        StoryModel(id: '6', imageUrl: DemoMedia.getAppRandomImage),
      ];

      stories.value = storyList;
    } catch (e) {
      stories.error = e.toString();
    }
  }

  Future<void> _fetchUserLocationFromBackend() async {
    try {
      currentLocation.value = 'Location Name';
    } catch (e) {
      currentLocation.error = e.toString();
    }
  }

  // Mock data for development/fallback
  Future<void> _fetchMockData() async {
    try {
      print(' Loading mock data...');

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));

      //  Set empty list
      serviceCategories.value = [];

      stories.value = [
        StoryModel(id: '1', imageUrl: 'renva_logo'),
        StoryModel(id: '2', imageUrl: DemoMedia.getAppRandomImage),
        StoryModel(id: '3', imageUrl: DemoMedia.getAppRandomImage),
        StoryModel(id: '4', imageUrl: DemoMedia.getAppRandomImage),
        StoryModel(id: '5', imageUrl: DemoMedia.getAppRandomImage),
        StoryModel(id: '6', imageUrl: DemoMedia.getAppRandomImage),
      ];

      currentLocation.value = 'Location Name';
    } catch (e) {
      serviceCategories.error = e.toString();
      stories.error = e.toString();
      currentLocation.error = e.toString();
    }
  }

  Future<void> refreshData() async {
    // Reset all observables to loading state
    serviceCategories.reset();
    stories.reset();
    currentLocation.reset();

    await fetchAllData();
  }

  // Existing methods (keeping your implementation)
  void onStoryTap(StoryModel story) {
    if (story.isRenvaStory) {
      _showRenvaInfo();
    } else {
      print(' Story tapped: ${story.id}');
      // TODO: Implement story viewing
    }
  }

  void onJoinProvider() {
    //  Navigate to the updated join as provider page
    Get.toNamed('/join_as_provider');
  }

  void onLocationTap() {
    // TODO: Implement location selection
    Get.dialog(
      AlertDialog(
        title: const Text('Select Location'),
        content: const Text('Location selection will be implemented here'),
        actions: [TextButton(onPressed: () => Get.back(), child: const Text('Close'))],
      ),
    );
  }

  void onNotificationTap() {
    // TODO: Navigate to notifications page ///zzzzzzzz
    print(' Notifications tapped');
  }

  // Show Renva info dialog
  void _showRenvaInfo() {
    Get.dialog(
      AlertDialog(
        title: const Text('About Renva'),
        content: const Text(
          'Renva is your trusted platform for connecting with service providers. '
          'Find qualified professionals for all your service needs.',
        ),
        actions: [TextButton(onPressed: () => Get.back(), child: const Text('Close'))],
      ),
    );
  }

  void retryFetch() {
    refreshData();
  }

  bool get hasRealData => serviceCategories.hasData && serviceCategories.valueLength > 0;
}
