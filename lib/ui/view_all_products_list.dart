import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:pet_shop_project/ui/organic_grain.dart';

class ViewAllProductsList extends StatelessWidget {
  final List<Map<String, dynamic>> products;

  const ViewAllProductsList({super.key, required this.products});

  // ============================================================
  // PRICE
  // ============================================================

  double getPrice(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(
            value.replaceAll('\$', '').replaceAll(',', '').trim(),
          ) ??
          0.0;
    }

    return 0.0;
  }

  // ============================================================
  // QUANTITY
  // ============================================================

  int getQuantity(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value) ?? 0;
    }

    return 0;
  }

  // ============================================================
  // ADD TO CART
  // ============================================================

  Future<void> addToCart(
    BuildContext context,
    Map<String, dynamic> product,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        if (!context.mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please login first')));

        return;
      }

      final productId = product['id']?.toString();

      if (productId == null || productId.isEmpty) {
        if (!context.mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Product ID is missing')));

        return;
      }

      final double price = getPrice(product['price']);

      final cartItemRef = FirebaseFirestore.instance
          .collection('carts')
          .doc(user.uid)
          .collection('items')
          .doc(productId);

      final existingItem = await cartItemRef.get();

      if (existingItem.exists) {
        final data = existingItem.data();

        final currentQuantity = getQuantity(data?['quantity']);

        await cartItemRef.update({
          'quantity': currentQuantity + 1,
          'price': price,
        });
      } else {
        await cartItemRef.set({
          'productId': productId,
          'productDocId': productId,
          'name': product['name']?.toString() ?? '',
          'brand': product['brand']?.toString() ?? '',
          'category': product['category']?.toString() ?? '',
          'image': product['imageUrl']?.toString() ?? '',
          'imageUrl': product['imageUrl']?.toString() ?? '',
          'price': price,
          'quantity': 1,
          'addedAt': FieldValue.serverTimestamp(),
        });
      }

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product['name'] ?? 'Product'} added to cart'),
        ),
      );
    } catch (e) {
      debugPrint('ADD TO CART ERROR: $e');

      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add product: $e')));
    }
  }

  // ============================================================
  // TOGGLE WISHLIST
  // ============================================================

  Future<void> toggleWishlist(
    BuildContext context,
    Map<String, dynamic> product,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        if (!context.mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please login first')));

        return;
      }

      final productId = product['id']?.toString();

      if (productId == null || productId.isEmpty) {
        if (!context.mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Product ID is missing')));

        return;
      }

      final wishlistItemRef = FirebaseFirestore.instance
          .collection('wishlist')
          .doc(user.uid)
          .collection('items')
          .doc(productId);

      final existingItem = await wishlistItemRef.get();

      if (existingItem.exists) {
        await wishlistItemRef.delete();

        if (!context.mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Removed from wishlist')));
      } else {
        final double price = getPrice(product['price']);

        await wishlistItemRef.set({
          'productId': productId,
          'productDocId': productId,
          'name': product['name']?.toString() ?? '',
          'brand': product['brand']?.toString() ?? '',
          'category': product['category']?.toString() ?? '',
          'image': product['imageUrl']?.toString() ?? '',
          'imageUrl': product['imageUrl']?.toString() ?? '',
          'price': price,
          'addedAt': FieldValue.serverTimestamp(),
        });

        if (!context.mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Added to wishlist ❤️')));
      }
    } catch (e) {
      debugPrint('WISHLIST ERROR: $e');

      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Wishlist error: $e')));
    }
  }

  // ============================================================
  // RESPONSIVE COLUMN COUNT
  // SAME LOGIC AS HOME PAGE
  // ============================================================

  int getCrossAxisCount(double width) {
    if (width >= 1200) {
      return 5;
    }

    if (width >= 900) {
      return 4;
    }

    if (width >= 600) {
      return 3;
    }

    return 2;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final double screenWidth = constraints.maxWidth;

            final bool isLandscape = orientation == Orientation.landscape;

            // ==================================================
            // SAME PADDING AS HOME PAGE
            // ==================================================

            final double horizontalPadding =
                screenWidth < 400
                    ? 20.w
                    : isLandscape
                    ? 25.w
                    : 30.w;

            // ==================================================
            // GRID WIDTH
            // ==================================================

            final double gridWidth = screenWidth - (horizontalPadding * 2);

            // ==================================================
            // SAME COLUMN LOGIC AS HOME PAGE
            // ==================================================

            final int crossAxisCount = getCrossAxisCount(screenWidth);

            // ==================================================
            // SAME SPACING AS HOME PAGE
            // ==================================================

            final double crossAxisSpacing = 12.w;

            final double mainAxisSpacing = 15.h;

            // ==================================================
            // CARD WIDTH
            // ==================================================

            final double cardWidth =
                (gridWidth - ((crossAxisCount - 1) * crossAxisSpacing)) /
                crossAxisCount;

            // ==================================================
            // SAME CARD HEIGHT AS HOME PAGE
            // ==================================================

            final double cardHeight;

            if (screenWidth < 500) {
              cardHeight = 375;
            } else if (screenWidth < 700) {
              cardHeight = 365;
            } else if (screenWidth < 1000) {
              cardHeight = 375;
            } else {
              cardHeight = 395;
            }

            // ==================================================
            // SAME IMAGE HEIGHT AS HOME PAGE
            // ==================================================

            final double imageHeight = isLandscape ? 120 : 140;

            // ==================================================
            // WISHLIST SIZE
            // ==================================================

            final double favoriteSize = (cardWidth * 0.20).clamp(32.0, 44.0);

            final double favoriteIconSize = favoriteSize * 0.55;

            return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                elevation: 0,

                title: Text(
                  'All Products',
                  style: TextStyle(
                    fontSize: isLandscape ? 18.sp : 20.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xffA73927),
                  ),
                ),
              ),

              body: SafeArea(
                child: GridView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 15.h,
                  ),

                  itemCount: products.length,

                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,

                    crossAxisSpacing: crossAxisSpacing,

                    mainAxisSpacing: mainAxisSpacing,

                    mainAxisExtent: cardHeight,
                  ),

                  itemBuilder: (context, index) {
                    final product = products[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => OrganicGrain(product: product),
                          ),
                        );
                      },

                      child: Card(
                        elevation: 3,

                        margin: EdgeInsets.zero,

                        clipBehavior: Clip.antiAlias,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.r),
                        ),

                        child: Padding(
                          padding: EdgeInsets.all(isLandscape ? 7.w : 8.w),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,

                            children: [
                              // ==========================================
                              // PRODUCT IMAGE
                              // ==========================================
                              SizedBox(
                                width: double.infinity,

                                height: imageHeight,

                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),

                                        child: Image.network(
                                          product['imageUrl']?.toString() ?? '',

                                          width: double.infinity,

                                          height: double.infinity,

                                          fit: BoxFit.cover,

                                          loadingBuilder: (
                                            context,
                                            child,
                                            loadingProgress,
                                          ) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }

                                            return const Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            );
                                          },

                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return Container(
                                              color: Colors.grey.shade200,

                                              child: Icon(
                                                Icons.image_not_supported,

                                                color: Colors.grey,

                                                size: isLandscape ? 30 : 35,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),

                                    // ======================================
                                    // WISHLIST
                                    // ======================================
                                    Positioned(
                                      top: favoriteSize * 0.10,

                                      right: favoriteSize * 0.10,

                                      child: Container(
                                        width: favoriteSize,

                                        height: favoriteSize,

                                        decoration: BoxDecoration(
                                          color: Colors.white,

                                          shape: BoxShape.circle,

                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.10,
                                              ),

                                              blurRadius: 4,

                                              spreadRadius: 0.5,

                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),

                                        child: StreamBuilder<
                                          DocumentSnapshot<Map<String, dynamic>>
                                        >(
                                          stream:
                                              FirebaseAuth
                                                          .instance
                                                          .currentUser ==
                                                      null
                                                  ? null
                                                  : FirebaseFirestore.instance
                                                      .collection('wishlist')
                                                      .doc(
                                                        FirebaseAuth
                                                            .instance
                                                            .currentUser!
                                                            .uid,
                                                      )
                                                      .collection('items')
                                                      .doc(
                                                        product['id']
                                                            ?.toString(),
                                                      )
                                                      .snapshots(),

                                          builder: (context, snapshot) {
                                            final bool isWishlisted =
                                                snapshot.data?.exists ?? false;

                                            return IconButton(
                                              padding: EdgeInsets.zero,

                                              constraints:
                                                  const BoxConstraints(),

                                              onPressed: () {
                                                toggleWishlist(
                                                  context,
                                                  product,
                                                );
                                              },

                                              icon: Icon(
                                                isWishlisted
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,

                                                color:
                                                    isWishlisted
                                                        ? Colors.red
                                                        : const Color(
                                                          0xffA73927,
                                                        ),

                                                size: favoriteIconSize,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // ==========================================
                              // SPACE AFTER IMAGE
                              // ==========================================
                              SizedBox(height: 8.h),

                              // ==========================================
                              // PRODUCT DETAILS
                              // ==========================================
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,

                                  children: [
                                    // ==================================
                                    // BRAND
                                    // ==================================
                                    SizedBox(
                                      width: double.infinity,

                                      height: 28,

                                      child: Text(
                                        product['brand']
                                                    ?.toString()
                                                    .trim()
                                                    .isNotEmpty ==
                                                true
                                            ? product['brand'].toString()
                                            : product['category']?.toString() ??
                                                '',

                                        maxLines: 2,

                                        overflow: TextOverflow.ellipsis,

                                        textAlign: TextAlign.center,

                                        style: TextStyle(
                                          fontSize: isLandscape ? 10.sp : 11.sp,

                                          fontWeight: FontWeight.w500,

                                          color: const Color(0xff57423D),

                                          height: 1.2,
                                        ),
                                      ),
                                    ),

                                    // ==================================
                                    // SPACE
                                    // ==================================
                                    SizedBox(height: 4.h),

                                    // ==================================
                                    // PRODUCT NAME
                                    // ==================================
                                    SizedBox(
                                      width: double.infinity,

                                      height: 55,

                                      child: Text(
                                        product['name']?.toString() ?? '',

                                        maxLines: 2,

                                        overflow: TextOverflow.ellipsis,

                                        textAlign: TextAlign.center,

                                        style: TextStyle(
                                          fontSize: isLandscape ? 11.sp : 13.sp,

                                          fontWeight: FontWeight.w600,

                                          height: 1.25,

                                          color: const Color(0xff1B1C1C),
                                        ),
                                      ),
                                    ),

                                    // ==================================
                                    // SPACE
                                    // ==================================
                                    SizedBox(height: 6.h),

                                    // ==================================
                                    // PRICE
                                    // ==================================
                                    SizedBox(
                                      height: 26,

                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,

                                        child: Text(
                                          '\$${getPrice(product['price']).toStringAsFixed(2)}',

                                          maxLines: 1,

                                          style: TextStyle(
                                            color: const Color(0xffA73927),

                                            fontWeight: FontWeight.bold,

                                            fontSize:
                                                isLandscape ? 13.sp : 15.sp,
                                          ),
                                        ),
                                      ),
                                    ),

                                    // ==================================
                                    // SPACE BEFORE BUTTON
                                    // ==================================
                                    const Spacer(),

                                    // ==================================
                                    // ADD TO CART
                                    // ==================================
                                    SizedBox(
                                      width: double.infinity,

                                      height: isLandscape ? 36 : 40,

                                      child: ElevatedButton(
                                        onPressed: () async {
                                          await addToCart(context, product);
                                        },

                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xff006971,
                                          ),

                                          foregroundColor: Colors.white,

                                          padding: EdgeInsets.zero,

                                          minimumSize: Size.zero,

                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,

                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8.r,
                                            ),
                                          ),
                                        ),

                                        child: Text(
                                          'Add to Cart',

                                          maxLines: 1,

                                          overflow: TextOverflow.ellipsis,

                                          style: TextStyle(
                                            fontSize: 12.sp,

                                            fontWeight: FontWeight.w500,

                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
