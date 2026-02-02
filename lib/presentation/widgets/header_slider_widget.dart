import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';
import 'custom_button.dart';

class HeaderSliderWidget extends StatefulWidget {
  const HeaderSliderWidget({super.key});

  @override
  State<HeaderSliderWidget> createState() => _HeaderSliderWidgetState();
}

class _HeaderSliderWidgetState extends State<HeaderSliderWidget> {
  int _currentCarouselIndex = 0;

  final List<String> _carouselImages = [
    'assets/images/jackets/Leather Jacket.png',
    'assets/images/bags/Handbags.png',
    'assets/images/Shoes/Shoes.png',
    'assets/images/headphones/Black Airpod.png',
    'assets/images/makeup/Makeup.png',
  ];

  final List<String> _carouselTitles = [
    'Premium Fashion Collection',
    'Designer Bags & Accessories',
    'Sports & Outdoor Gear',
    'Premium Audio Experience',
    'Beauty & Makeup Essentials',
  ];

  // Category mapping for each banner (matches Firebase 'category' field)
  final List<String> _carouselCategories = [
    'Fashion',            // Premium Fashion Collection
    'Fashion',            // Designer Bags & Accessories
    'Sports & Outdoors',  // Sports & Outdoor Gear
    'headphones',         // Premium Audio Experience
    'Beauty & Makeup',    // Beauty & Makeup Essentials
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 240,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            onPageChanged: (index, reason) {
              setState(() {
                _currentCarouselIndex = index;
              });
            },
          ),
          items: _carouselImages.asMap().entries.map((entry) {
            final index = entry.key;
            final imagePath = entry.value;
            final title = _carouselTitles[index];
            final category = _carouselCategories[index];

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppTheme.primaryColor.withOpacity(0.9),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTheme.headline3.copyWith(
                              color: AppTheme.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              text: 'Shop Now',
                              onPressed: () {
                                context.read<NavigationProvider>().setIndex(1);
                              },
                              height: 40,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 16),

        // Carousel Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _carouselImages.asMap().entries.map((entry) {
            final index = entry.key;
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentCarouselIndex == index
                    ? AppTheme.accentColor
                    : AppTheme.grey.withOpacity(0.3),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
