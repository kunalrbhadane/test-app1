import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../create_bill/models/available_product_model.dart';
import 'available_stock_card.dart';

class AvailableStockCarousel extends StatefulWidget {
  final List<AvailableProductModel> products;

  const AvailableStockCarousel({
    super.key,
    required this.products,
  });

  @override
  State<AvailableStockCarousel> createState() => _AvailableStockCarouselState();
}

class _AvailableStockCarouselState extends State<AvailableStockCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: widget.products.length > 1 ? 0.94 : 1.0,
    );
  }

  @override
  void didUpdateWidget(covariant AvailableStockCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.products.length != widget.products.length) {
      _pageController.dispose();
      _pageController = PageController(
        viewportFraction: widget.products.length > 1 ? 0.94 : 1.0,
      );
      if (_currentPage >= widget.products.length) {
        _currentPage = widget.products.isEmpty ? 0 : widget.products.length - 1;
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) {
      return const SizedBox.shrink();
    }

    // If only 1 product, render directly without carousel dots
    if (widget.products.length == 1) {
      return AvailableStockCard(
        product: widget.products.first,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Horizontal Swipeable Cards
        SizedBox(
          height: 134,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.products.length,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: AvailableStockCard(
                  product: widget.products[index],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),

        // Carousel Dot Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.products.length, (index) {
            final isActive = _currentPage == index;
            return GestureDetector(
              onTap: () {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(horizontal: 3.5),
                width: isActive ? 18.0 : 6.0,
                height: 6.0,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primaryBlue
                      : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(3.0),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
