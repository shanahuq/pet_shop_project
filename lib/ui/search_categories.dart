import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'organic_grain.dart';

class SearchCategories extends StatefulWidget {
  final String title;
  final String categoryId;

  const SearchCategories({
    super.key,
    required this.title,
    required this.categoryId,
  });

  @override
  State<SearchCategories> createState() => _SearchCategoriesState();
}

class _SearchCategoriesState extends State<SearchCategories> {
  int selectedTab = 0;

  final List<String> tabs = ['All Items', 'Toys', 'Walk Gear', 'Wellness'];

  final FirebaseFirestore db = FirebaseFirestore.instance;

  // ============================================================
  // PRODUCTS STREAM
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> get productsStream {
    return db
        .collection('products')
        .where('categoryId', isEqualTo: widget.categoryId)
        .snapshots();
  }

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
  // RATING
  // ============================================================

  double getRating(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value.trim()) ?? 0.0;
    }

    return 0.0;
  }

  // ============================================================
  // GET IMAGE URL
  // ============================================================

  String getImageUrl(Map<String, dynamic> product) {
    final possibleFields = [
      product['imageUrl'],
      product['imageURL'],
      product['image'],
      product['photoUrl'],
      product['photoURL'],
    ];

    for (final value in possibleFields) {
      if (value == null) continue;

      if (value is String) {
        final url = value.trim();

        if (url.isNotEmpty &&
            (url.startsWith('http://') || url.startsWith('https://'))) {
          return url;
        }
      }

      // In case imageUrl is accidentally stored as a list.
      if (value is List && value.isNotEmpty) {
        for (final image in value) {
          if (image is String) {
            final url = image.trim();

            if (url.isNotEmpty &&
                (url.startsWith('http://') || url.startsWith('https://'))) {
              return url;
            }
          }
        }
      }

      // In case imageUrl is stored as a map such as {url: "..."}.
      if (value is Map) {
        final mapUrl = value['url'] ?? value['downloadUrl'];

        if (mapUrl is String) {
          final url = mapUrl.trim();

          if (url.isNotEmpty &&
              (url.startsWith('http://') || url.startsWith('https://'))) {
            return url;
          }
        }
      }
    }

    return '';
  }

  // ============================================================
  // IMAGE PLACEHOLDER
  // ============================================================

  Widget imagePlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey.shade500,
        size: 30.sp,
      ),
    );
  }

  // ============================================================
  // PRODUCT IMAGE
  // ============================================================

  Widget buildProductImage(Map<String, dynamic> product, double imageHeight) {
    final imageUrl = getImageUrl(product);

    if (imageUrl.isEmpty) {
      return imagePlaceholder();
    }

    return Image.network(
      imageUrl,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,

      // If one Firebase image is broken, only that image becomes
      // a placeholder. The rest of the grid continues normally.
      errorBuilder: (context, error, stackTrace) {
        debugPrint('IMAGE ERROR: ${product['name']} -> $imageUrl');

        return imagePlaceholder();
      },

      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }

        return Container(
          color: Colors.grey.shade100,
          alignment: Alignment.center,
          child: const CircularProgressIndicator(strokeWidth: 2),
        );
      },
    );
  }

  // ============================================================
  // OPEN PRODUCT DETAILS
  // ============================================================

  Future<void> openProductDetails(
    BuildContext context,
    String productId, {
    String? productName,
    String? brand,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;

      DocumentSnapshot<Map<String, dynamic>> productDoc =
          await firestore.collection('products').doc(productId).get();

      // Try productId field if document ID was not found.
      if (!productDoc.exists) {
        final querySnapshot =
            await firestore
                .collection('products')
                .where('productId', isEqualTo: productId)
                .limit(1)
                .get();

        if (querySnapshot.docs.isNotEmpty) {
          productDoc = querySnapshot.docs.first;
        }
      }

      // Try name + brand.
      if (!productDoc.exists && productName != null) {
        Query<Map<String, dynamic>> query = firestore
            .collection('products')
            .where('name', isEqualTo: productName);

        if (brand != null && brand.isNotEmpty) {
          query = query.where('brand', isEqualTo: brand);
        }

        final querySnapshot = await query.limit(1).get();

        if (querySnapshot.docs.isNotEmpty) {
          productDoc = querySnapshot.docs.first;
        }
      }

      if (!productDoc.exists) {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product not found: ${productName ?? productId}'),
          ),
        );

        return;
      }

      final productData = productDoc.data();

      if (productData == null) {
        return;
      }

      final product = {
        ...productData,
        'id': productDoc.id,
        'productDocId': productDoc.id,
      };

      if (!context.mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OrganicGrain(product: product)),
      );
    } catch (e) {
      debugPrint('OPEN PRODUCT ERROR: $e');

      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load product: $e')));
    }
  }

  // ============================================================
  // ADD TO CART
  // ============================================================

  Future<void> addToCart(Map<String, dynamic> product) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please login first')));

      return;
    }

    try {
      final String productDocId = product['id'].toString();

      final cartItemRef = FirebaseFirestore.instance
          .collection('carts')
          .doc(user.uid)
          .collection('items')
          .doc(productDocId);

      final cartItem = await cartItemRef.get();

      final imageUrl = getImageUrl(product);

      if (cartItem.exists) {
        await cartItemRef.update({
          'quantity': FieldValue.increment(1),
          'productId': productDocId,
          'productDocId': productDocId,
          'image': imageUrl,
          'imageUrl': imageUrl,
        });
      } else {
        await cartItemRef.set({
          'productId': productDocId,
          'productDocId': productDocId,
          'name': product['name']?.toString() ?? '',
          'brand': product['brand']?.toString() ?? '',
          'image': imageUrl,
          'imageUrl': imageUrl,
          'price': getPrice(product['price']),
          'rating': getRating(product['rating']),
          'quantity': 1,
          'addedAt': FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product['name'] ?? 'Product'} added to cart'),
        ),
      );
    } catch (e) {
      debugPrint('ADD TO CART ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add product: $e')));
    }
  }

  // ============================================================
  // ADD TO WISHLIST
  // ============================================================

  Future<void> addToWishlist(Map<String, dynamic> product) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please login first')));

      return;
    }

    try {
      final String productDocId = product['id'].toString();

      final imageUrl = getImageUrl(product);

      await FirebaseFirestore.instance
          .collection('wishlist')
          .doc(user.uid)
          .collection('items')
          .doc(productDocId)
          .set({
            'productId': productDocId,
            'productDocId': productDocId,
            'name': product['name']?.toString() ?? '',
            'brand': product['brand']?.toString() ?? '',
            'image': imageUrl,
            'imageUrl': imageUrl,
            'price': getPrice(product['price']),
            'rating': getRating(product['rating']),
            'addedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      debugPrint('WISHLIST ADD ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add wishlist: $e')));
    }
  }

  // ============================================================
  // REMOVE FROM WISHLIST
  // ============================================================

  Future<void> removeFromWishlist(Map<String, dynamic> product) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please login first')));

      return;
    }

    try {
      final String productDocId = product['id'].toString();

      await FirebaseFirestore.instance
          .collection('wishlist')
          .doc(user.uid)
          .collection('items')
          .doc(productDocId)
          .delete();
    } catch (e) {
      debugPrint('WISHLIST REMOVE ERROR: $e');
    }
  }

  // ============================================================
  // TOGGLE WISHLIST
  // ============================================================

  Future<void> toggleWishlist(Map<String, dynamic> product) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please login first')));

      return;
    }

    final String productDocId = product['id'].toString();

    final docRef = FirebaseFirestore.instance
        .collection('wishlist')
        .doc(user.uid)
        .collection('items')
        .doc(productDocId);

    try {
      final doc = await docRef.get();

      if (doc.exists) {
        await removeFromWishlist(product);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${product['name']} removed from wishlist')),
        );
      } else {
        await addToWishlist(product);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${product['name']} added to wishlist')),
        );
      }
    } catch (e) {
      debugPrint('TOGGLE WISHLIST ERROR: $e');
    }
  }

  // ============================================================
  // RESPONSIVE GRID SETTINGS
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
  // RESPONSIVE TITLE SIZE
  // ============================================================

  double getTitleSize(double width) {
    if (width < 600) {
      return 28.sp;
    }

    if (width < 900) {
      return 24.sp;
    }

    return 28.sp;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, size: 20.sp),
        ),

        title: Text(
          'PetLife',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 26.sp,
            color: const Color(0xffA73927),
          ),
        ),

        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20.w),
            child: Icon(
              Icons.notifications_none,
              color: const Color(0xffA73927),
              size: 25.sp,
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double screenWidth = constraints.maxWidth;

            final bool isLandscape =
                MediaQuery.orientationOf(context) == Orientation.landscape;

            final double horizontalPadding =
                screenWidth < 600
                    ? 20.w
                    : isLandscape
                    ? 25.w
                    : 30.w;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // TOP TITLE
                  // ==================================================
                  SizedBox(height: isLandscape ? 15.h : 25.h),

                  Text(
                    widget.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: getTitleSize(screenWidth),
                      color: const Color(0xff1B1C1C),
                    ),
                  ),

                  SizedBox(height: 10.h),

                  // ==================================================
                  // DESCRIPTION + FILTER
                  // ==================================================
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          '24 premium items for your best friend',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14.sp,
                            color: const Color(0xff57423D),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      SizedBox(width: 10.w),

                      OutlinedButton.icon(
                        onPressed: () {},

                        icon: Icon(
                          Icons.tune,
                          color: Colors.black,
                          size: 18.sp,
                        ),

                        label: Text(
                          'Filter',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12.sp,
                            color: Colors.black,
                          ),
                        ),

                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xffF0EDED),

                          side: const BorderSide(color: Color(0xffDFC0BA)),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),

                          padding: EdgeInsets.symmetric(horizontal: 8.w),

                          minimumSize: Size.zero,

                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 15.h),

                  // ==================================================
                  // CATEGORY TABS
                  // ==================================================
                  SizedBox(
                    height: 45.h,

                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,

                      separatorBuilder: (_, __) => SizedBox(width: 10.w),

                      itemCount: tabs.length,

                      itemBuilder: (context, index) {
                        final bool isSelected = selectedTab == index;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedTab = index;
                            });
                          },

                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),

                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth < 600 ? 18.w : 15.w,
                              vertical: 10.h,
                            ),

                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.r),

                              color:
                                  isSelected
                                      ? const Color(0xffF27059)
                                      : Colors.white,

                              border: Border.all(
                                color:
                                    isSelected
                                        ? Colors.white
                                        : const Color(0xffDFC0BA),
                              ),
                            ),

                            child: Center(
                              child: Text(
                                tabs[index],
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.sp,
                                  color: const Color(0xff650700),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // ==================================================
                  // PRODUCTS
                  // ==================================================
                  if (selectedTab == 0)
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: productsStream,

                      builder: (context, snapshot) {
                        // ------------------------------------------
                        // LOADING
                        // ------------------------------------------

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        // ------------------------------------------
                        // ERROR
                        // ------------------------------------------

                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Error loading products:\n'
                              '${snapshot.error}',
                              textAlign: TextAlign.center,
                            ),
                          );
                        }

                        // ------------------------------------------
                        // EMPTY
                        // ------------------------------------------

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(30),
                              child: Text('No products found'),
                            ),
                          );
                        }

                        final products = snapshot.data!.docs;

                        // ==================================================
                        // GRID
                        // ==================================================

                        return LayoutBuilder(
                          builder: (context, gridConstraints) {
                            final double width = gridConstraints.maxWidth;

                            final int crossAxisCount = getCrossAxisCount(width);

                            final double spacing = width < 600 ? 12.w : 15.w;

                            // ==================================================
                            // CARD HEIGHT
                            // ==================================================

                            final double cardHeight;

                            if (width < 500) {
                              cardHeight = 375;
                            } else if (width < 700) {
                              cardHeight = 365;
                            } else if (width < 1000) {
                              cardHeight = 375;
                            } else {
                              cardHeight = 395;
                            }

                            // ==================================================
                            // IMAGE HEIGHT
                            // ==================================================

                            final double imageHeight = isLandscape ? 120 : 140;

                            return GridView.builder(
                              shrinkWrap: true,

                              physics: const NeverScrollableScrollPhysics(),

                              padding: EdgeInsets.zero,

                              itemCount: products.length,

                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,

                                    crossAxisSpacing: spacing,

                                    mainAxisSpacing: spacing,

                                    mainAxisExtent: cardHeight,
                                  ),

                              itemBuilder: (context, index) {
                                final productDoc = products[index];
                                final double cardWidth =
                                    (gridConstraints.maxWidth -
                                        ((crossAxisCount - 1) * spacing)) /
                                    crossAxisCount;

                                final double favoriteSize =
                                    isLandscape
                                        ? (cardWidth * 0.20).clamp(30.0, 40.0)
                                        : (cardWidth * 0.20).clamp(32.0, 44.0);

                                final double favoriteIconSize =
                                    favoriteSize * 0.55;

                                // REAL FIRESTORE DOCUMENT ID
                                final item = {
                                  ...productDoc.data(),

                                  'id': productDoc.id,

                                  'productDocId': productDoc.id,
                                };

                                final double price = getPrice(item['price']);

                                final double rating = getRating(item['rating']);

                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,

                                    borderRadius: BorderRadius.circular(15.r),

                                    boxShadow: const [
                                      BoxShadow(
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                        offset: Offset(0, 3),
                                        color: Colors.black12,
                                      ),
                                    ],
                                  ),

                                  clipBehavior: Clip.antiAlias,

                                  child: Padding(
                                    padding: EdgeInsets.all(
                                      isLandscape ? 7.w : 8.w,
                                    ),

                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,

                                      children: [
                                        // ==================================================
                                        // PRODUCT IMAGE
                                        // ==================================================
                                        SizedBox(
                                          width: double.infinity,

                                          height: imageHeight,

                                          child: Stack(
                                            children: [
                                              Positioned.fill(
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        12.r,
                                                      ),

                                                  child: buildProductImage(
                                                    item,
                                                    imageHeight,
                                                  ),
                                                ),
                                              ),

                                              // ==================================================
                                              // WISHLIST
                                              // ==================================================
                                              Positioned(
                                                // Responsive position
                                                top: favoriteSize * 0.10,
                                                right: favoriteSize * 0.10,

                                                child: StreamBuilder<
                                                  DocumentSnapshot<
                                                    Map<String, dynamic>
                                                  >
                                                >(
                                                  stream:
                                                      FirebaseFirestore.instance
                                                          .collection(
                                                            'wishlist',
                                                          )
                                                          .doc(
                                                            FirebaseAuth
                                                                .instance
                                                                .currentUser
                                                                ?.uid,
                                                          )
                                                          .collection('items')
                                                          .doc(
                                                            item['id']
                                                                .toString(),
                                                          )
                                                          .snapshots(),

                                                  builder: (context, snapshot) {
                                                    final bool isWishlisted =
                                                        snapshot.data?.exists ??
                                                        false;

                                                    // ============================================
                                                    // RESPONSIVE CIRCLE SIZE
                                                    // ============================================

                                                    // final double cardWidth =
                                                    //     (gridConstraints
                                                    //             .maxWidth -
                                                    //         ((crossAxisCount -
                                                    //                 1) *
                                                    //             spacing)) /
                                                    //     crossAxisCount;

                                                    // final double
                                                    // favoriteCircleSize =
                                                    //     isLandscape
                                                    //         ? (cardWidth * 0.20)
                                                    //             .clamp(
                                                    //               30.0,
                                                    //               40.0,
                                                    //             )
                                                    //         : (cardWidth * 0.20)
                                                    //             .clamp(
                                                    //               32.0,
                                                    //               44.0,
                                                    //             );

                                                    // final double
                                                    // favoriteIconSize =
                                                    //     favoriteCircleSize *
                                                    //     0.55;

                                                    return GestureDetector(
                                                      behavior:
                                                          HitTestBehavior
                                                              .opaque,

                                                      onTap: () {
                                                        toggleWishlist(item);
                                                      },

                                                      child: AnimatedContainer(
                                                        duration:
                                                            const Duration(
                                                              milliseconds: 180,
                                                            ),

                                                        width: favoriteSize,
                                                        height: favoriteSize,

                                                        decoration: BoxDecoration(
                                                          color: Colors.white,

                                                          shape:
                                                              BoxShape.circle,

                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                    0.10,
                                                                  ),
                                                              blurRadius: 4,
                                                              spreadRadius: 0.5,
                                                              offset:
                                                                  const Offset(
                                                                    0,
                                                                    1,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),

                                                        child: Center(
                                                          child: AnimatedSwitcher(
                                                            duration:
                                                                const Duration(
                                                                  milliseconds:
                                                                      180,
                                                                ),

                                                            child: Icon(
                                                              isWishlisted
                                                                  ? Icons
                                                                      .favorite
                                                                  : Icons
                                                                      .favorite_border,

                                                              key: ValueKey(
                                                                isWishlisted,
                                                              ),

                                                              size:
                                                                  favoriteIconSize,

                                                              color:
                                                                  isWishlisted
                                                                      ? Colors
                                                                          .red
                                                                      : const Color(
                                                                        0xffA73927,
                                                                      ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // ==================================================
                                        // SPACE AFTER IMAGE
                                        // ==================================================
                                        SizedBox(height: 8.h),

                                        // ==================================================
                                        // CONTENT
                                        // ==================================================
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,

                                            children: [
                                              // ==================================================
                                              // RATING
                                              // ==================================================
                                              SizedBox(
                                                height: 22,

                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,

                                                  children: [
                                                    const Icon(
                                                      Icons.star,
                                                      color: Colors.amber,
                                                      size: 16,
                                                    ),

                                                    const SizedBox(width: 3),

                                                    Text(
                                                      rating.toStringAsFixed(1),

                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              const SizedBox(height: 3),

                                              // ==================================================
                                              // BRAND
                                              // ==================================================
                                              SizedBox(
                                                width: double.infinity,

                                                height: 28,

                                                child: Text(
                                                  item['brand']
                                                              ?.toString()
                                                              .trim()
                                                              .isNotEmpty ==
                                                          true
                                                      ? item['brand'].toString()
                                                      : item['category']
                                                              ?.toString() ??
                                                          '',

                                                  maxLines: 2,

                                                  overflow:
                                                      TextOverflow.ellipsis,

                                                  textAlign: TextAlign.center,

                                                  style: TextStyle(
                                                    fontSize:
                                                        isLandscape
                                                            ? 10.sp
                                                            : 11.sp,

                                                    fontWeight: FontWeight.w500,

                                                    color: const Color(
                                                      0xff57423D,
                                                    ),

                                                    height: 1.2,
                                                  ),
                                                ),
                                              ),

                                              // ==================================================
                                              // SPACE
                                              // ==================================================
                                              SizedBox(height: 4.h),

                                              // ==================================================
                                              // PRODUCT NAME
                                              // ==================================================
                                              SizedBox(
                                                width: double.infinity,

                                                height: 55,

                                                child: Text(
                                                  item['name']?.toString() ??
                                                      '',

                                                  maxLines: 2,

                                                  overflow:
                                                      TextOverflow.ellipsis,

                                                  textAlign: TextAlign.center,

                                                  style: TextStyle(
                                                    fontSize:
                                                        isLandscape
                                                            ? 11.sp
                                                            : 13.sp,

                                                    fontWeight: FontWeight.w600,

                                                    height: 1.25,

                                                    color: const Color(
                                                      0xff1B1C1C,
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              // ==================================================
                                              // PRICE
                                              // ==================================================
                                              SizedBox(
                                                height: 26,

                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,

                                                  child: Text(
                                                    '\$${price.toStringAsFixed(2)}',

                                                    maxLines: 1,

                                                    style: TextStyle(
                                                      color: const Color(
                                                        0xffA73927,
                                                      ),

                                                      fontWeight:
                                                          FontWeight.bold,

                                                      fontSize:
                                                          isLandscape
                                                              ? 13.sp
                                                              : 15.sp,
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              // ==================================================
                                              // SPACE BEFORE BUTTON
                                              // ==================================================
                                              SizedBox(height: 8.h),

                                              // ==================================================
                                              // ADD TO CART
                                              // ==================================================
                                              SizedBox(
                                                width: double.infinity,

                                                height: isLandscape ? 36 : 40,

                                                child: ElevatedButton(
                                                  onPressed: () async {
                                                    await addToCart(item);
                                                  },

                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color(0xff006971),

                                                    padding: EdgeInsets.zero,

                                                    minimumSize: Size.zero,

                                                    tapTargetSize:
                                                        MaterialTapTargetSize
                                                            .shrinkWrap,

                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8.r,
                                                          ),
                                                    ),
                                                  ),

                                                  child: Text(
                                                    'Add to Cart',

                                                    maxLines: 1,

                                                    overflow:
                                                        TextOverflow.ellipsis,

                                                    style: TextStyle(
                                                      fontSize: 12.sp,

                                                      fontWeight:
                                                          FontWeight.w500,

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
                                );
                              },
                            );
                          },
                        );
                      },
                    )
                  // ==================================================
                  // OTHER TABS
                  // ==================================================
                  else
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Text('No items'),
                      ),
                    ),

                  SizedBox(height: 30.h),

                  // ==================================================
                  // SHOWING ITEMS
                  // ==================================================
                  Center(
                    child: Text(
                      'Showing 6 of 24 items',

                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12.sp,
                        color: const Color(0xff57423D),
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // ==================================================
                  // PROGRESS BAR
                  // ==================================================
                  Center(
                    child: SizedBox(
                      width: 150.w,

                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 4.h,

                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20.r),
                                  bottomLeft: Radius.circular(20.r),
                                ),

                                color: const Color(0xffA73927),
                              ),
                            ),
                          ),

                          Expanded(
                            child: Container(
                              height: 4.h,

                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(20.r),
                                  bottomRight: Radius.circular(20.r),
                                ),

                                color: const Color(0xffE4E2E1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // ==================================================
                  // LOAD MORE
                  // ==================================================
                  Center(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(
                          screenWidth < 600 ? 190.w : 210.w,
                          55.h,
                        ),

                        side: const BorderSide(color: Color(0xffA73927)),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.r),
                        ),
                      ),

                      onPressed: () {},

                      child: Text(
                        'Load More Essentials',

                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                          color: const Color(0xffA73927),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 30.h),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
