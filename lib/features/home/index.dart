import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/localization/strings.dart';
import '../../core/services/state_management/widgets/obs_widget.dart';
import '../../core/style/repo.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/image.dart';
import '../../core/widgets/svg_icon.dart';
import '../../gen/assets.gen.dart';
import 'controller.dart';
import 'models/service_categories.dart';
import 'story_model.dart';
import 'widgets/service_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final size = MediaQuery.of(context).size;
    final controller = Get.put(HomePageController());

    return Scaffold(
      backgroundColor: StyleRepo.deepBlue,
      body: Stack(
        children: [
          Positioned(
            top: r.value(mobile: -100.0, tablet: -117.0, desktop: -130.0),
            left: r.value(mobile: -220.0, tablet: -262.0, desktop: -300.0),
            right: 0,
            bottom: MediaQuery.of(context).size.height * 0.5,
            child: Opacity(
              opacity: 0.18,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: Assets.images.background.background.provider(),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      StyleRepo.deepBlue.withValues(alpha: 0.8),
                      BlendMode.multiply,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Column(
            children: [
              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo and notifications row
                    Padding(
                      padding: EdgeInsets.fromLTRB(r.space20, r.space4, r.space20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Assets.images.logo.renva.svg(
                            width: r.value(mobile: 100.0, tablet: 111.0, desktop: 120.0),
                            height: r.value(mobile: 25.0, tablet: 27.75, desktop: 30.0),
                            color: StyleRepo.softWhite,
                          ),
                          GestureDetector(
                            onTap: () => controller.onNotificationTap(),
                            child: SvgIcon(
                              icon: Assets.icons.messages.notifications,
                              color: StyleRepo.softWhite,
                              size: r.iconSize24,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.fromLTRB(r.space20, r.space16, r.space20, r.space12),
                      child: GestureDetector(
                        onTap: () => controller.onLocationTap(),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tr(LocaleKeys.home_your_location),
                              style: TextStyle(
                                fontSize: r.fontSize12,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'CustomFont',
                                color: StyleRepo.softWhite,
                              ),
                            ),
                            SizedBox(width: r.space12),
                            Row(
                              children: [
                                ObsVariableBuilder<String>(
                                  obs: controller.currentLocation,
                                  builder: (context, location) {
                                    return Text(
                                      location,
                                      style: TextStyle(
                                        color: StyleRepo.softWhite,
                                        fontWeight: FontWeight.w400,
                                        fontSize: r.value(mobile: 9.0, tablet: 10.0, desktop: 11.0),
                                      ),
                                    );
                                  },
                                  // Custom loader for location
                                  loader:
                                      (context) => SizedBox(
                                        width: r.value(mobile: 50.0, tablet: 60.0, desktop: 70.0),
                                        height: r.value(mobile: 8.0, tablet: 10.0, desktop: 12.0),
                                        child: LinearProgressIndicator(
                                          backgroundColor: StyleRepo.softWhite.withValues(
                                            alpha: 0.3,
                                          ),
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            StyleRepo.softWhite,
                                          ),
                                        ),
                                      ),
                                  // Custom error for location
                                  errorBuilder:
                                      (context, error) => Text(
                                        'Location Error',
                                        style: TextStyle(
                                          color: StyleRepo.softWhite.withValues(alpha: 0.7),
                                          fontWeight: FontWeight.w400,
                                          fontSize: r.value(
                                            mobile: 9.0,
                                            tablet: 10.0,
                                            desktop: 11.0,
                                          ),
                                        ),
                                      ),
                                ),
                                SizedBox(width: r.space4),
                                SvgIcon(
                                  icon: Assets.icons.arrows.down,
                                  color: StyleRepo.softWhite,
                                  height: r.value(mobile: 7.0, tablet: 8.0, desktop: 9.0),
                                  width: r.value(mobile: 7.0, tablet: 8.0, desktop: 9.0),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable part (services and white container)
              Expanded(
                child: MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(padding: const EdgeInsets.only(top: 0, bottom: 0)),
                  child: NestedScrollView(
                    headerSliverBuilder: (context, innerBoxIsScrolled) {
                      return [
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            r.value(mobile: 36.0, tablet: 47.0, desktop: 56.0),
                            r.space8,
                            r.value(mobile: 36.0, tablet: 47.0, desktop: 56.0),
                            r.space20,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: SizedBox(
                              height: r.value(
                                mobile: size.height * 0.28,
                                tablet: size.height * 0.32,
                                desktop: size.height * 0.35,
                              ),

                              child: ObsListBuilder<ServiceCategoryModel>(
                                obs: controller.serviceCategories,
                                onRefresh: controller.refreshData,
                                builder: (context, categories) {
                                  if (categories.isNotEmpty) {
                                    return _buildServicesFromBackend(categories, r);
                                  } else {
                                    return _buildEmptyServiceBoxes(r);
                                  }
                                },
                                // Custom loader for services grid
                                loader: (context) => _buildServiceGridSkeleton(r),
                                // Custom error widget for services
                                errorBuilder:
                                    (context, error) =>
                                        _buildServiceErrorState(controller, error, r),
                              ),
                            ),
                          ),
                        ),
                      ];
                    },
                    body: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(r.radius24)),
                      ),
                      child: CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          // Small handle at the top
                          SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: r.space16, bottom: r.space4),
                                child: Container(
                                  width: r.value(mobile: 35.0, tablet: 40.0, desktop: 45.0),
                                  height: r.value(mobile: 3.5, tablet: 4.0, desktop: 4.5),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(
                                      r.value(mobile: 1.5, tablet: 2.0, desktop: 2.5),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SliverToBoxAdapter(child: _buildStoriesSection(context, controller, r)),

                          // Join as Service Providers section
                          SliverToBoxAdapter(child: _buildJoinSection(context, controller, r)),

                          // Bottom padding for navigation bar
                          SliverToBoxAdapter(
                            child: SizedBox(
                              height: r.value(mobile: 70.0, tablet: 80.0, desktop: 90.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Services from backend
  Widget _buildServicesFromBackend(List<ServiceCategoryModel> categories, Responsive r) {
    return GridView.builder(
      physics: const ClampingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: r.space16,
        mainAxisSpacing: r.space16,
        childAspectRatio: r.value(mobile: 1.15, tablet: 1.23, desktop: 1.3),
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final service = categories[index];
        return ServiceCard(service: service);
      },
    );
  }

  // Empty service boxes
  Widget _buildEmptyServiceBoxes(Responsive r) {
    return GridView.builder(
      physics: ClampingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: r.space16,
        mainAxisSpacing: r.space16,
        childAspectRatio: r.value(mobile: 1.15, tablet: 1.23, desktop: 1.3),
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return _buildEmptyServiceBox(r);
      },
    );
  }

  Widget _buildEmptyServiceBox(Responsive r) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(r.radius16),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: r.value(mobile: 20.0, tablet: 25.8, desktop: 28.0),
          sigmaY: r.value(mobile: 20.0, tablet: 25.8, desktop: 28.0),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                StyleRepo.softWhite.withValues(alpha: 0.15),
                StyleRepo.softWhite,
                StyleRepo.softWhite,
                StyleRepo.softWhite.withValues(alpha: 0.15),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(r.radius16),
            color: Colors.white.withValues(alpha: 0.1),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.category_outlined,
                  color: Colors.white.withValues(alpha: 0.3),
                  size: r.value(mobile: 36.0, tablet: 40.0, desktop: 44.0),
                ),
                SizedBox(height: r.space8),
                Text(
                  tr(LocaleKeys.home_service),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: r.fontSize12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //  Custom error state for services
  Widget _buildServiceErrorState(HomePageController controller, String error, Responsive r) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: r.value(mobile: 56.0, tablet: 64.0, desktop: 72.0),
            color: Colors.white.withValues(alpha: 0.7),
          ),
          SizedBox(height: r.space16),
          Text(
            'Failed to load services',
            style: TextStyle(
              color: Colors.white,
              fontSize: r.fontSize16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: r.space8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: r.fontSize12),
          ),
          SizedBox(height: r.space16),
          ElevatedButton(
            onPressed: controller.retryFetch,
            style: ElevatedButton.styleFrom(
              backgroundColor: StyleRepo.softWhite,
              foregroundColor: StyleRepo.deepBlue,
              padding: EdgeInsets.symmetric(horizontal: r.space20, vertical: r.space12),
            ),
            child: Text('Retry', style: TextStyle(fontSize: r.fontSize14)),
          ),
        ],
      ),
    );
  }

  // Loading skeleton for service cards
  Widget _buildServiceGridSkeleton(Responsive r) {
    return GridView.builder(
      physics: ClampingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: r.space16,
        mainAxisSpacing: r.space16,
        childAspectRatio: r.value(mobile: 1.15, tablet: 1.25, desktop: 1.3),
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(r.radius16),
          ),
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(StyleRepo.softWhite),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStoriesSection(BuildContext context, HomePageController controller, Responsive r) {
    return Padding(
      padding: EdgeInsets.fromLTRB(r.space24, r.space16, r.space24, r.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr(LocaleKeys.home_curated_stories),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: r.fontSize16),
          ),
          SizedBox(height: r.space4),
          Text(
            tr(LocaleKeys.home_discover_horizons),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: r.fontSize12),
          ),
          SizedBox(height: r.space16),

          SizedBox(
            height: r.value(mobile: 190.0, tablet: 215.0, desktop: 240.0),
            child: ObsListBuilder<StoryModel>(
              obs: controller.stories,
              onRefresh: controller.refreshData,
              builder: (context, stories) {
                if (stories.isEmpty) {
                  return _buildEmptyStories(r);
                }

                // Build the stories list
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.only(left: r.space4),
                  itemCount: stories.length,
                  itemBuilder: (context, index) {
                    final story = stories[index];
                    return _buildStoryItem(story, controller, r);
                  },
                );
              },
              // Custom loader for stories
              loader: (context) => _buildStoriesSkeleton(r),
              // Custom error for stories
              errorBuilder:
                  (context, error) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: r.value(mobile: 42.0, tablet: 48.0, desktop: 54.0),
                          color: Colors.grey,
                        ),
                        SizedBox(height: r.space8),
                        Text(
                          'Failed to load stories',
                          style: TextStyle(color: Colors.grey, fontSize: r.fontSize14),
                        ),
                        SizedBox(height: r.space8),
                        ElevatedButton(
                          onPressed: controller.retryFetch,
                          child: Text('Retry', style: TextStyle(fontSize: r.fontSize14)),
                        ),
                      ],
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  // Story item with progress indicators
  Widget _buildStoryItem(StoryModel story, HomePageController controller, Responsive r) {
    final itemWidth = r.value(mobile: 145.0, tablet: 159.0, desktop: 170.0);
    final itemHeight = r.value(mobile: 190.0, tablet: 213.0, desktop: 230.0);

    return GestureDetector(
      onTap: () => controller.onStoryTap(story),
      child: Container(
        width: itemWidth,
        height: itemHeight,
        margin: EdgeInsets.only(right: r.space12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(r.radius12),
          child: Stack(
            children: [
              story.isRenvaStory
                  ? Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: StyleRepo.deepBlue,
                    child: Center(
                      child: Assets.images.logo.logo.svg(
                        width: r.value(mobile: 36.0, tablet: 40.0, desktop: 44.0),
                        height: r.value(mobile: 36.0, tablet: 40.0, desktop: 44.0),
                        color: Colors.white,
                      ),
                    ),
                  )
                  : AppImage(
                    path: story.imageUrl,
                    type: ImageType.CachedNetwork,
                    fit: BoxFit.cover,
                    height: itemHeight,
                    width: double.infinity,
                    errorWidget: Container(
                      color: Colors.grey[300],
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey[500],
                          size: r.value(mobile: 28.0, tablet: 30.0, desktop: 32.0),
                        ),
                      ),
                    ),
                  ),

              Positioned(
                top: r.space8,
                left: r.space8,
                right: r.space8,
                child: Row(
                  children: List.generate(3, (index) {
                    return Expanded(
                      child: Container(
                        height: r.value(mobile: 1.5, tablet: 2.0, desktop: 2.5),
                        margin: EdgeInsets.only(right: index < 2 ? r.space4 : 0),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoriesSkeleton(Responsive r) {
    final itemWidth = r.value(mobile: 145.0, tablet: 159.0, desktop: 170.0);
    final itemHeight = r.value(mobile: 190.0, tablet: 213.0, desktop: 230.0);

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.only(left: r.space4),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          width: itemWidth,
          height: itemHeight,
          margin: EdgeInsets.only(right: r.space12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(r.radius12),
            child: Stack(
              children: [
                Container(color: Colors.grey[200]),
                // Progress indicators
                Positioned(
                  top: r.space8,
                  left: r.space8,
                  right: r.space8,
                  child: Row(
                    children: List.generate(3, (index) {
                      return Expanded(
                        child: Container(
                          height: r.value(mobile: 1.5, tablet: 2.0, desktop: 2.5),
                          margin: EdgeInsets.only(right: index < 2 ? r.space4 : 0),
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Empty stories
  Widget _buildEmptyStories(Responsive r) {
    final itemWidth = r.value(mobile: 145.0, tablet: 159.0, desktop: 170.0);
    final itemHeight = r.value(mobile: 190.0, tablet: 213.0, desktop: 230.0);

    return Center(
      child: SizedBox(
        width: itemWidth,
        height: itemHeight,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(r.radius12),
          child: Stack(
            children: [
              Container(
                color: StyleRepo.deepBlue,
                child: Center(
                  child: Assets.images.logo.logo.svg(
                    width: r.value(mobile: 36.0, tablet: 40.0, desktop: 44.0),
                    height: r.value(mobile: 36.0, tablet: 40.0, desktop: 44.0),
                    color: Colors.white,
                  ),
                ),
              ),
              // Progress indicators
              Positioned(
                top: r.space8,
                left: r.space8,
                right: r.space8,
                child: Row(
                  children: List.generate(3, (index) {
                    return Expanded(
                      child: Container(
                        height: r.value(mobile: 1.5, tablet: 2.0, desktop: 2.5),
                        margin: EdgeInsets.only(right: index < 2 ? r.space4 : 0),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Join section
  Widget _buildJoinSection(BuildContext context, HomePageController controller, Responsive r) {
    return Padding(
      padding: EdgeInsets.fromLTRB(r.space24, r.space20, r.space24, r.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr(LocaleKeys.home_join_as_service_provider),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: r.fontSize16),
          ),
          SizedBox(height: r.space4),
          Text(
            tr(LocaleKeys.home_top_providers),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: r.fontSize12),
          ),
          SizedBox(height: r.space16),

          Container(
            height: r.value(mobile: 125.0, tablet: 140.0, desktop: 155.0),
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(r.radius16),
              color: StyleRepo.deepBlue,
            ),
            child: Stack(
              children: [
                Positioned(
                  left: r.value(mobile: 200.0, tablet: 231.0, desktop: 260.0),
                  child: Opacity(
                    opacity: 0.1,
                    child: Assets.images.logo.logoBlue.svg(
                      width: r.value(mobile: 120.0, tablet: 138.0, desktop: 150.0),
                      height: r.value(mobile: 120.0, tablet: 138.0, desktop: 150.0),
                    ),
                  ),
                ),
                Row(
                  children: [
                    SizedBox(
                      width: r.value(mobile: 105.0, tablet: 120.0, desktop: 135.0),
                      height: r.value(mobile: 125.0, tablet: 140.0, desktop: 155.0),
                      child: ClipRRect(
                        child: Assets.images.styling.joinBannerModelPng.image(
                          width: r.value(mobile: 105.0, tablet: 120.0, desktop: 135.0),
                          height: r.value(mobile: 125.0, tablet: 140.0, desktop: 155.0),
                        ),
                      ),
                    ),

                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(r.space16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          tr(LocaleKeys.home_join_as_service_provider),
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            color: Colors.white,
                                            fontSize: r.fontSize14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(width: r.space8),
                                      Assets.icons.essentials.securityUser.svg(
                                        width: r.value(mobile: 12.0, tablet: 14.0, desktop: 16.0),
                                        height: r.value(mobile: 12.0, tablet: 14.0, desktop: 16.0),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: r.space8),

                            // Bullet points
                            Text(
                              tr(LocaleKeys.home_personal_services),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: r.value(mobile: 9.0, tablet: 10.0, desktop: 11.0),
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            SizedBox(height: r.space8),
                            Text(
                              tr(LocaleKeys.home_professional_services),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: r.value(mobile: 9.0, tablet: 10.0, desktop: 11.0),
                                fontWeight: FontWeight.w300,
                              ),
                            ),

                            const Spacer(),

                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () => controller.onJoinProvider(),
                                child: Container(
                                  width: r.value(mobile: 72.0, tablet: 81.0, desktop: 90.0),
                                  height: r.value(mobile: 19.0, tablet: 21.0, desktop: 23.0),
                                  decoration: BoxDecoration(
                                    color: StyleRepo.forestGreen,
                                    borderRadius: BorderRadius.circular(
                                      r.value(mobile: 20.0, tablet: 25.0, desktop: 30.0),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      tr(LocaleKeys.home_join),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: r.fontSize12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
