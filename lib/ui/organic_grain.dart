import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrganicGrain extends StatefulWidget {
  final Map<String, dynamic> product;

  const OrganicGrain({super.key, required this.product});

  @override
  State<OrganicGrain> createState() => _OrganicGrainState();
}

class _OrganicGrainState extends State<OrganicGrain> {
  String selectedWeight = '2kg';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ============================================================
  // PRODUCT ID
  // ============================================================

  String get productId {
    return widget.product['id']?.toString() ?? '';
  }

  // ============================================================
  // REVIEWS STREAM
  // ============================================================

  Stream<QuerySnapshot> get reviewsStream {
    return _firestore
        .collection('reviews')
        .where('productId', isEqualTo: productId)
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
      return double.tryParse(value) ?? 0.0;
    }

    return 0.0;
  }

  // ============================================================
  // REVIEW DATE
  // ============================================================

  String formatReviewDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    }

    if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    }

    if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    }

    return '${date.day}/${date.month}/${date.year}';
  }

  // ============================================================
  // ADD TO CART
  // ============================================================

  Future<void> addToCart() async {
    final user = _auth.currentUser;

    if (user == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please login first')));

      return;
    }

    try {
      final product = widget.product;

      final String productDocId = product['id']?.toString() ?? '';

      if (productDocId.isEmpty) {
        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Product ID is missing')));

        return;
      }

      final cartItemRef = FirebaseFirestore.instance
          .collection('carts')
          .doc(user.uid)
          .collection('items')
          .doc(productDocId);

      final cartItem = await cartItemRef.get();

      if (cartItem.exists) {
        final data = cartItem.data();

        final dynamic quantityValue = data?['quantity'];

        int currentQuantity = 1;

        if (quantityValue is num) {
          currentQuantity = quantityValue.toInt();
        } else if (quantityValue is String) {
          currentQuantity = int.tryParse(quantityValue) ?? 1;
        }

        await cartItemRef.update({
          'quantity': currentQuantity + 1,
          'productDocId': productDocId,
          'price': getPrice(product['price']),
        });
      } else {
        await cartItemRef.set({
          'productId': product['productId']?.toString() ?? productDocId,
          'productDocId': productDocId,
          'name': product['name']?.toString() ?? '',
          'brand': product['brand']?.toString() ?? '',
          'category': product['category']?.toString() ?? '',
          'image': product['imageUrl']?.toString() ?? '',
          'imageUrl': product['imageUrl']?.toString() ?? '',
          'price': getPrice(product['price']),
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add product to cart: $e')),
      );
    }
  }

  // ============================================================
  // TOGGLE WISHLIST
  // ============================================================

  Future<void> toggleWishlist() async {
    final user = _auth.currentUser;

    if (user == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please login first')));

      return;
    }

    try {
      final product = widget.product;

      final String id = product['id']?.toString() ?? '';

      if (id.isEmpty) return;

      final wishlistRef = _firestore
          .collection('wishlist')
          .doc(user.uid)
          .collection('items')
          .doc(id);

      final wishlistDoc = await wishlistRef.get();

      if (wishlistDoc.exists) {
        await wishlistRef.delete();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${product['name'] ?? 'Product'} removed from wishlist',
            ),
          ),
        );
      } else {
        await wishlistRef.set({
          'productId': id,
          'productDocId': id,
          'name': product['name']?.toString() ?? '',
          'brand': product['brand']?.toString() ?? '',
          'category': product['category']?.toString() ?? '',
          'image': product['imageUrl']?.toString() ?? '',
          'imageUrl': product['imageUrl']?.toString() ?? '',
          'price': getPrice(product['price']),
          'rating': getRating(product['rating']),
          'addedAt': FieldValue.serverTimestamp(),
        });

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product['name'] ?? 'Product'} added to wishlist'),
          ),
        );
      }
    } catch (e) {
      debugPrint('WISHLIST ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Wishlist error: $e')));
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final bool isLandscape = orientation == Orientation.landscape;

        return Scaffold(
          backgroundColor: Colors.white,

          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,

            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: const Color(0xff650700),
                size: isLandscape ? 22 : 25,
              ),
              onPressed: () => Navigator.pop(context),
            ),

            title: Text(
              'Product Details',
              style: TextStyle(
                color: const Color(0xff650700),
                fontSize: isLandscape ? 17.sp : 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double screenWidth = constraints.maxWidth;

                // Landscape phone/tablet gets two columns.
                // If the screen is too narrow, use one column.
                final bool useTwoColumn = isLandscape && screenWidth >= 600;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),

                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isLandscape ? 20.w : 16.w,
                      vertical: 10.h,
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        // ==================================================
                        // PRODUCT IMAGE + INFORMATION
                        // ==================================================
                        if (useTwoColumn)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Expanded(
                                flex: 5,
                                child: _buildProductImage(
                                  widget.product['imageUrl']?.toString() ?? '',
                                  screenWidth * 0.45,
                                  true,
                                ),
                              ),

                              SizedBox(width: 20.w),

                              Expanded(
                                flex: 5,
                                child: _buildProductInformation(
                                  context,
                                  widget.product,
                                  widget.product['name']?.toString() ?? '',
                                  widget.product['brand']?.toString() ?? '',
                                  getPrice(widget.product['price']),
                                  true,
                                ),
                              ),
                            ],
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              _buildProductImage(
                                widget.product['imageUrl']?.toString() ?? '',
                                screenWidth,
                                isLandscape,
                              ),

                              SizedBox(height: 15.h),

                              _buildProductInformation(
                                context,
                                widget.product,
                                widget.product['name']?.toString() ?? '',
                                widget.product['brand']?.toString() ?? '',
                                getPrice(widget.product['price']),
                                isLandscape,
                              ),
                            ],
                          ),

                        SizedBox(height: 20.h),

                        // ==================================================
                        // PRODUCT DETAILS
                        // ==================================================
                        _buildProductDetails(context, isLandscape),

                        SizedBox(height: 20.h),

                        // ==================================================
                        // REVIEWS
                        // ==================================================
                        _buildReviews(context, isLandscape),

                        SizedBox(height: 20.h),

                        // ==================================================
                        // BOTTOM BUTTONS
                        // ==================================================
                        _buildBottomButtons(context, isLandscape),

                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  PreferredSizeWidget _buildAppBar(bool isLandscape) {
    return AppBar(
      automaticallyImplyLeading: false,

      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },

        icon: Icon(
          Icons.arrow_back,
          color: const Color(0xff57423D),
          size: isLandscape ? 22 : 25,
        ),
      ),

      title: Text(
        'PetLife',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: isLandscape ? 20.sp : 24.sp,
          color: const Color(0xffA73927),
        ),
      ),

      centerTitle: true,

      actions: [
        Padding(
          padding: EdgeInsets.only(right: isLandscape ? 20 : 25),

          child: Icon(
            Icons.notifications_none,
            color: const Color(0xffA73927),
            size: isLandscape ? 23 : 26,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PORTRAIT
  // ============================================================

  Widget _buildPortraitLayout(
    BuildContext context,
    Map<String, dynamic> product,
    String name,
    String brand,
    String image,
    double price,
    double screenWidth,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        SizedBox(height: 10.h),

        _buildProductImage(image, screenWidth, false),

        SizedBox(height: 20.h),

        _buildProductInformation(context, product, name, brand, price, false),

        SizedBox(height: 30.h),

        _buildProductDetails(context, false),

        SizedBox(height: 25.h),

        _buildReviews(context, false),

        SizedBox(height: 30.h),

        _buildBottomButtons(context, false),

        SizedBox(height: 30.h),
      ],
    );
  }

  // ============================================================
  // LANDSCAPE
  // ============================================================

  Widget _buildLandscapeLayout(
    BuildContext context,
    Map<String, dynamic> product,
    String name,
    String brand,
    String image,
    double price,
    double screenWidth,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        SizedBox(height: 15.h),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Expanded(
              flex: 5,
              child: _buildProductImage(image, screenWidth * 0.45, true),
            ),

            SizedBox(width: 25.w),

            Expanded(
              flex: 5,
              child: _buildProductInformation(
                context,
                product,
                name,
                brand,
                price,
                true,
              ),
            ),
          ],
        ),

        SizedBox(height: 30.h),

        _buildProductDetails(context, true),

        SizedBox(height: 25.h),

        _buildReviews(context, true),

        SizedBox(height: 30.h),

        _buildBottomButtons(context, true),

        SizedBox(height: 30.h),
      ],
    );
  }

  // ============================================================
  // PRODUCT IMAGE
  // ============================================================

  // ============================================================
  // PRODUCT IMAGE
  // ============================================================

  Widget _buildProductImage(String image, double width, bool isLandscape) {
    return SizedBox(
      width: double.infinity,
      child: AspectRatio(
        aspectRatio: isLandscape ? 1.20 : 1.05,
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.r),
                child:
                    image.isNotEmpty
                        ? Image.network(
                          image,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }

                            return Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return _imageError(isLandscape);
                          },
                        )
                        : _imageError(isLandscape),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // IMAGE ERROR
  // ============================================================

  Widget _imageError(bool isLandscape) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey.shade200,
      child: Center(
        child: Icon(
          Icons.image_not_supported,
          color: Colors.grey,
          size: isLandscape ? 32 : 40,
        ),
      ),
    );
  }

  // ============================================================
  // PRODUCT INFORMATION
  // ============================================================

  Widget _buildProductInformation(
    BuildContext context,
    Map<String, dynamic> product,
    String name,
    String brand,
    double price,
    bool isLandscape,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        // ==================================================
        // BRAND + PRICE
        // ==================================================
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Flexible(
              flex: 5,

              child: Container(
                constraints: const BoxConstraints(minHeight: 28),

                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),

                  color: const Color(0xff93EEF9),
                ),

                child: Text(
                  brand.isNotEmpty ? brand : 'Pet Food',

                  maxLines: 2,

                  overflow: TextOverflow.ellipsis,

                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontWeight: FontWeight.w600,

                    fontSize: isLandscape ? 10.sp : 12.sp,

                    color: const Color(0xff57423D),
                  ),
                ),
              ),
            ),

            SizedBox(width: 10.w),

            Flexible(
              flex: 4,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,

                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,

                    child: Text(
                      '\$${price.toStringAsFixed(2)}',

                      style: TextStyle(
                        fontWeight: FontWeight.w600,

                        fontSize: isLandscape ? 20.sp : 24.sp,

                        color: const Color(0xffA73927),
                      ),
                    ),
                  ),

                  SizedBox(height: 2.h),

                  Text(
                    '\$42.00',

                    maxLines: 1,

                    style: TextStyle(
                      fontWeight: FontWeight.w400,

                      fontSize: isLandscape ? 10.sp : 12.sp,

                      color: const Color(0xff57423D),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        SizedBox(height: 12.h),

        // ==================================================
        // PRODUCT NAME
        // ==================================================
        Text(
          name,

          maxLines: isLandscape ? 3 : 4,

          overflow: TextOverflow.ellipsis,

          style: TextStyle(
            fontWeight: FontWeight.w600,

            fontSize: isLandscape ? 20.sp : 24.sp,

            color: const Color(0xff1B1C1C),

            height: 1.2,
          ),
        ),

        SizedBox(height: 8.h),

        // ==================================================
        // RATING
        // ==================================================
        Row(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,

              children: List.generate(5, (index) {
                return Icon(
                  Icons.star,
                  color: Colors.amber,

                  size: isLandscape ? 16.sp : 18.sp,
                );
              }),
            ),

            SizedBox(width: 7.w),

            Flexible(
              child: Text(
                '(4.8 • 124 reviews)',

                maxLines: 1,

                overflow: TextOverflow.ellipsis,

                style: TextStyle(
                  fontWeight: FontWeight.w400,

                  fontSize: isLandscape ? 10.sp : 13.sp,

                  color: const Color(0xff57423D),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 18.h),

        // ==================================================
        // SELECT WEIGHT
        // ==================================================
        Text(
          'SELECT WEIGHT',

          style: TextStyle(
            fontWeight: FontWeight.w600,

            fontSize: isLandscape ? 11.sp : 12.sp,

            color: const Color(0xff57423D),
          ),
        ),

        SizedBox(height: 10.h),

        Row(
          children: [
            Expanded(child: weightButton('2kg', isLandscape)),

            SizedBox(width: 7.w),

            Expanded(child: weightButton('5kg', isLandscape)),

            SizedBox(width: 7.w),

            Expanded(child: weightButton('10kg', isLandscape)),
          ],
        ),

        SizedBox(height: 18.h),

        // ==================================================
        // FEATURES
        // ==================================================
        Row(
          children: [
            Expanded(
              child: _featureCard(
                icon: Icons.eco_outlined,
                title: '100% Organic',
                isLandscape: isLandscape,
              ),
            ),

            SizedBox(width: 8.w),

            Expanded(
              child: _featureCard(
                icon: Icons.restaurant,
                title: 'Grain Free',
                isLandscape: isLandscape,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // WEIGHT BUTTON
  // ============================================================

  Widget weightButton(String weight, bool isLandscape) {
    final bool selected = selectedWeight == weight;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedWeight = weight;
        });
      },

      child: Container(
        height: isLandscape ? 44 : 50,

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.r),

          border: Border.all(
            color: selected ? const Color(0xffA73927) : const Color(0xffDFC0BA),
          ),

          color:
              selected ? const Color.fromARGB(43, 167, 56, 39) : Colors.white,
        ),

        child: Center(
          child: Text(
            weight,

            style: TextStyle(
              fontWeight: FontWeight.w400,

              fontSize: isLandscape ? 12.sp : 15.sp,

              color:
                  selected ? const Color(0xffA73927) : const Color(0xff57423D),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FEATURE CARD
  // ============================================================

  // ============================================================
  // FEATURE CARD
  // ============================================================

  // ============================================================
  // FEATURE CARD
  // ============================================================

  Widget _featureCard({
    required IconData icon,
    required String title,
    required bool isLandscape,
  }) {
    return Container(
      width: double.infinity,

      padding: EdgeInsets.symmetric(
        horizontal: 6.w,
        vertical: isLandscape ? 10.h : 12.h,
      ),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: const Color(0xffEAE7E7),
        border: Border.all(color: const Color(0x083C2800)),
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Icon(
            icon,
            color: const Color(0xff006971),
            size: isLandscape ? 20.sp : 26.sp,
          ),

          SizedBox(height: 5.h),

          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,

            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: isLandscape ? 9.sp : 12.sp,
              color: const Color(0xff1B1C1C),
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PRODUCT DETAILS
  // ============================================================

  Widget _buildProductDetails(BuildContext context, bool isLandscape) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          'Product Details',

          style: TextStyle(
            fontWeight: FontWeight.w600,

            fontSize: isLandscape ? 18.sp : 20.sp,

            color: const Color(0xff1B1C1C),
          ),
        ),

        SizedBox(height: 12.h),

        Text(
          'Crafted for dogs with sensitive stomachs and discerning tastes. '
          'Our formula uses free-range chicken and farm-fresh vegetables '
          'to provide a complete, balanced diet that supports digestion '
          'and coat health.',

          style: TextStyle(
            fontWeight: FontWeight.w400,

            fontSize: isLandscape ? 12.sp : 14.sp,

            color: const Color(0xff57423D),

            height: 1.5,
          ),
        ),

        SizedBox(height: 18.h),

        _expandableDetail(title: 'Ingredients', isLandscape: isLandscape),

        SizedBox(height: 10.h),

        _expandableDetail(title: 'Feeding Guide', isLandscape: isLandscape),
      ],
    );
  }

  // ============================================================
  // EXPANDABLE DETAIL
  // ============================================================

  Widget _expandableDetail({required String title, required bool isLandscape}) {
    return Container(
      width: double.infinity,

      constraints: const BoxConstraints(minHeight: 60),

      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),

        color: Colors.white,

        border: Border.all(color: const Color.fromARGB(100, 158, 158, 158)),
      ),

      child: Row(
        children: [
          Expanded(
            child: Text(
              title,

              style: TextStyle(
                fontWeight: FontWeight.w600,

                fontSize: isLandscape ? 16.sp : 19.sp,

                color: const Color(0xff1B1C1C),
              ),
            ),
          ),

          Icon(
            Icons.keyboard_arrow_down_sharp,

            color: const Color(0xff1B1C1C),

            size: isLandscape ? 24.sp : 28.sp,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REVIEWS
  // ============================================================

  Widget _buildReviews(BuildContext context, bool isLandscape) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    'Customer Reviews',

                    maxLines: 1,

                    overflow: TextOverflow.ellipsis,

                    style: TextStyle(
                      fontWeight: FontWeight.w600,

                      fontSize: isLandscape ? 18.sp : 20.sp,

                      color: const Color(0xff1B1C1C),
                    ),
                  ),

                  SizedBox(height: 3.h),

                  Text(
                    'Based on 124 verified purchases',

                    maxLines: 1,

                    overflow: TextOverflow.ellipsis,

                    style: TextStyle(
                      fontWeight: FontWeight.w400,

                      fontSize: isLandscape ? 10.sp : 12.sp,

                      color: const Color(0xff57423D),
                    ),
                  ),
                ],
              ),
            ),

            TextButton(
              onPressed: () {},

              child: Text(
                'View All',

                style: TextStyle(
                  fontWeight: FontWeight.w400,

                  fontSize: isLandscape ? 13.sp : 16.sp,

                  color: const Color(0xffA73927),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 15.h),

        // ==================================================
        // FIRESTORE REVIEWS
        // ==================================================
        StreamBuilder<QuerySnapshot>(
          stream: reviewsStream,

          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              debugPrint('FIRESTORE ERROR: ${snapshot.error}');

              return Padding(
                padding: EdgeInsets.all(15.w),

                child: Text(
                  'Error loading reviews:\n\n'
                  '${snapshot.error}',

                  style: TextStyle(color: Colors.red, fontSize: 14.sp),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No reviews yet.'));
            }

            final reviews = snapshot.data!.docs;

            return Column(
              children:
                  reviews.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;

                    final String comment = data['comment']?.toString() ?? '';

                    final double rating = getRating(data['rating']);

                    final dynamic timestamp = data['createdAt'];

                    String time = '';

                    if (timestamp is Timestamp) {
                      time = formatReviewDate(timestamp.toDate());
                    }

                    return Padding(
                      padding: EdgeInsets.only(bottom: 15.h),

                      child: ReviewCard(
                        initials: 'U',
                        name: 'Customer',
                        time: time,
                        rating: rating,
                        review: comment,
                        isLandscape: isLandscape,
                      ),
                    );
                  }).toList(),
            );
          },
        ),
      ],
    );
  }

  // ============================================================
  // REVIEW CARD
  // ============================================================

  Widget ReviewCard({
    required String initials,
    required String name,
    required String time,
    required double rating,
    required String review,
    required bool isLandscape,
  }) {
    return Container(
      width: double.infinity,

      padding: EdgeInsets.all(isLandscape ? 12.w : 15.w),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),

        color: Colors.white,

        border: Border.all(color: const Color.fromARGB(97, 158, 158, 158)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              CircleAvatar(
                radius: isLandscape ? 21.r : 25.r,

                backgroundColor: const Color(0xffFFDAD4),

                child: Text(
                  initials,

                  style: TextStyle(
                    fontWeight: FontWeight.w700,

                    fontSize: isLandscape ? 14.sp : 16.sp,

                    color: const Color(0xff3F0300),
                  ),
                ),
              ),

              SizedBox(width: 10.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      name,

                      maxLines: 1,

                      overflow: TextOverflow.ellipsis,

                      style: TextStyle(
                        fontWeight: FontWeight.w600,

                        fontSize: isLandscape ? 11.sp : 12.sp,

                        color: const Color(0xff1B1C1C),
                      ),
                    ),

                    SizedBox(height: 3.h),

                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < rating.round()
                              ? Icons.star
                              : Icons.star_border,

                          color: Colors.amber,

                          size: isLandscape ? 14.sp : 16.sp,
                        );
                      }),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 5.w),

              Flexible(
                child: Text(
                  time,

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                  textAlign: TextAlign.end,

                  style: TextStyle(
                    fontWeight: FontWeight.w400,

                    fontSize: isLandscape ? 9.sp : 11.sp,

                    color: const Color(0xff57423D),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          Text(
            review,

            style: TextStyle(
              fontWeight: FontWeight.w400,

              fontSize: isLandscape ? 12.sp : 14.sp,

              color: const Color(0xff57423D),

              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTTOM BUTTONS
  // ============================================================

  // ============================================================
  // BOTTOM BUTTONS
  // ============================================================

  // ============================================================
  // BOTTOM BUTTONS
  // ============================================================

  Widget _buildBottomButtons(BuildContext context, bool isLandscape) {
    // Same height for both buttons.
    // Use a fixed logical height so rotation does not change it.
    const double buttonHeight = 64.0;

    return SizedBox(
      height: buttonHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ==================================================
          // SUBSCRIBE
          // ==================================================
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: Size.zero,
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                side: const BorderSide(color: Color(0xff006971)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.r),
                ),
              ),
              onPressed: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.autorenew,
                    color: const Color(0xff006971),
                    size: isLandscape ? 19.sp : 22.sp,
                  ),

                  SizedBox(width: 6.w),

                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Subscribe',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: isLandscape ? 10.sp : 13.sp,
                            color: const Color(0xff006971),
                            height: 1.0,
                          ),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          '& Save 15%',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: isLandscape ? 10.sp : 13.sp,
                            color: const Color(0xff006971),
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(width: 10.w),

          // ==================================================
          // ADD TO CART
          // ==================================================
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: Size.zero,
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: const Color(0xffA73927),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.r),
                ),
              ),
              onPressed: addToCart,
              icon: Icon(
                Icons.shopping_cart_outlined,
                color: Colors.white,
                size: isLandscape ? 18.sp : 21.sp,
              ),
              label: Text(
                'Add to Cart',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: isLandscape ? 11.sp : 15.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
