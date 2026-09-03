import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:pet_shop_project/ui/wish_list_page.dart';

class OrganicGrain extends StatefulWidget {
  final Map<String, dynamic> product;

  const OrganicGrain({super.key, required this.product});

  @override
  State<OrganicGrain> createState() => _OrganicGrainState();
}

class _OrganicGrainState extends State<OrganicGrain> {
  bool isSelected = true;

  String selectedWeight = '2kg';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get productId {
    return widget.product['id'].toString();
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

      final String id = product['id'].toString();

      final cartItemRef = _firestore
          .collection('carts')
          .doc(user.uid)
          .collection('items')
          .doc(id);

      final cartItem = await cartItemRef.get();

      if (cartItem.exists) {
        final data = cartItem.data();

        final dynamic quantityValue = data?['quantity'];

        int currentQuantity = 0;

        if (quantityValue is num) {
          currentQuantity = quantityValue.toInt();
        } else if (quantityValue is String) {
          currentQuantity = int.tryParse(quantityValue) ?? 0;
        }

        await cartItemRef.update({'quantity': currentQuantity + 1});
      } else {
        await cartItemRef.set({
          'productId': id,

          'name': product['name']?.toString() ?? '',

          'brand': product['brand']?.toString() ?? '',

          'image': product['imageUrl']?.toString() ?? '',

          'price': getPrice(product['price']),

          'quantity': 1,

          'addedAt': FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product['name']} added to cart')),
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
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    final String name = product['name']?.toString() ?? '';

    final String brand = product['brand']?.toString() ?? '';

    final String image = product['imageUrl']?.toString() ?? '';

    final double price = getPrice(product['price']);

    return OrientationBuilder(
      builder: (BuildContext context, Orientation orientation) {
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double screenWidth = constraints.maxWidth;

            final bool isLandscape = orientation == Orientation.landscape;

            final bool isTablet = screenWidth >= 600;

            // ==================================================
            // RESPONSIVE PADDING
            // ==================================================

            final double horizontalPadding =
                screenWidth < 400
                    ? 20
                    : isLandscape
                    ? 25
                    : 30;

            // ==================================================
            // RESPONSIVE FONT SIZES
            // ==================================================

            final double titleSize = isLandscape ? 20 : 24;

            final double sectionTitleSize = isLandscape ? 18 : 20;

            // ==================================================
            // APP BAR
            // ==================================================

            return Scaffold(
              appBar: AppBar(
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
              ),

              // =================================================
              // BODY
              // =================================================
              body: SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),

                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),

                    child:
                        isLandscape && isTablet
                            ? _buildLandscapeLayout(
                              context,
                              product,
                              name,
                              brand,
                              image,
                              price,
                              screenWidth,
                            )
                            : _buildPortraitLayout(
                              context,
                              product,
                              name,
                              brand,
                              image,
                              price,
                              screenWidth,
                            ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // PORTRAIT LAYOUT
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
  // LANDSCAPE LAYOUT
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
      children: [
        SizedBox(height: 15.h),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ================================================
            // LEFT SIDE - IMAGE
            // ================================================
            Expanded(
              flex: 5,
              child: _buildProductImage(image, screenWidth * 0.45, true),
            ),

            SizedBox(width: 25.w),

            // ================================================
            // RIGHT SIDE - INFORMATION
            // ================================================
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

  Widget _buildProductImage(String image, double width, bool isLandscape) {
    return AspectRatio(
      aspectRatio: isLandscape ? 1.25 : 1.05,

      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15.r),

              child:
                  image.isNotEmpty
                      ? Image.network(
                        image,
                        fit: BoxFit.cover,

                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }

                          return Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },

                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                              size: 35.sp,
                            ),
                          );
                        },
                      )
                      : Container(
                        color: Colors.grey.shade200,
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                          size: 35.sp,
                        ),
                      ),
            ),
          ),

          // ==================================================
          // WISHLIST
          // ==================================================
          Positioned(
            top: 15,
            right: 15,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isSelected = !isSelected;
                });
              },
              child: CircleAvatar(
                radius: isLandscape ? 18 : 20,
                backgroundColor: Colors.white,
                child: Icon(
                  isSelected ? Icons.favorite : Icons.favorite_border,
                  color: isSelected ? const Color(0xffA73927) : Colors.grey,
                  size: isLandscape ? 19 : 22,
                ),
              ),
            ),
          ),

          // ==================================================
          // SHARE
          // ==================================================
          Positioned(
            top: isLandscape ? 60 : 75,
            right: 15,
            child: CircleAvatar(
              radius: isLandscape ? 18 : 20,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.share,
                color: const Color(0xff57423D),
                size: isLandscape ? 19 : 22,
              ),
            ),
          ),
        ],
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
            Expanded(
              child: Container(
                constraints: const BoxConstraints(minHeight: 25),

                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),

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

            SizedBox(width: 15.w),

            Column(
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
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: isLandscape ? 10.sp : 12.sp,
                    color: const Color(0xff57423D),
                  ),
                ),
              ],
            ),
          ],
        ),

        SizedBox(height: 12.h),

        // ==================================================
        // PRODUCT NAME
        // ==================================================
        Text(
          name,
          maxLines: 3,
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
              children: List.generate(5, (index) {
                return Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: isLandscape ? 16.sp : 18.sp,
                );
              }),
            ),

            SizedBox(width: 8.w),

            Flexible(
              child: Text(
                '(4.8 • 124 reviews)',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: isLandscape ? 11.sp : 14.sp,
                  color: const Color(0xff57423D),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 20.h),

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

        SizedBox(height: 12.h),

        Row(
          children: [
            Expanded(child: weightButton('2kg', isLandscape)),

            SizedBox(width: 8.w),

            Expanded(child: weightButton('5kg', isLandscape)),

            SizedBox(width: 8.w),

            Expanded(child: weightButton('10kg', isLandscape)),
          ],
        ),

        SizedBox(height: 20.h),

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

            SizedBox(width: 10.w),

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
        height: isLandscape ? 45 : 52,

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),

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
              fontSize: isLandscape ? 13.sp : 16.sp,
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

  Widget _featureCard({
    required IconData icon,
    required String title,
    required bool isLandscape,
  }) {
    return Container(
      height: isLandscape ? 75 : 90,

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),

        color: const Color(0xffEAE7E7),

        border: Border.all(color: const Color(0x083C2800)),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Icon(
            icon,
            color: const Color(0xff006971),
            size: isLandscape ? 22.sp : 26.sp,
          ),

          SizedBox(height: 4.h),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),

            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: isLandscape ? 10.sp : 12.sp,
                color: const Color(0xff1B1C1C),
              ),
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

        SizedBox(height: 20.h),

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
      constraints: const BoxConstraints(minHeight: 65),

      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),

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
                fontSize: isLandscape ? 17.sp : 20.sp,
                color: const Color(0xff1B1C1C),
              ),
            ),
          ),

          Icon(
            Icons.keyboard_arrow_down_sharp,
            color: const Color(0xff1B1C1C),
            size: isLandscape ? 25.sp : 28.sp,
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

        SizedBox(height: 20.h),

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
                padding: EdgeInsets.all(20.w),

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
            children: [
              // ============================================
              // PROFILE
              // ============================================
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

              // ============================================
              // NAME + RATING
              // ============================================
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

              // ============================================
              // TIME
              // ============================================
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

  Widget _buildBottomButtons(BuildContext context, bool isLandscape) {
    return Row(
      children: [
        // ==================================================
        // SUBSCRIBE
        // ==================================================
        Expanded(
          child: SizedBox(
            height: isLandscape ? 65 : 85,

            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xff006971)),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.r),
                ),
              ),

              onPressed: () {},

              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Icon(
                    Icons.autorenew,
                    color: const Color(0xff006971),
                    size: isLandscape ? 21.sp : 26.sp,
                  ),

                  SizedBox(width: 6.w),

                  Flexible(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,

                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          'Subscribe',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,

                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: isLandscape ? 12.sp : 16.sp,
                            color: const Color(0xff006971),
                          ),
                        ),

                        Text(
                          '& Save 15%',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,

                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: isLandscape ? 12.sp : 16.sp,
                            color: const Color(0xff006971),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        SizedBox(width: 10.w),

        // ==================================================
        // ADD TO CART
        // ==================================================
        Expanded(
          child: SizedBox(
            height: isLandscape ? 65 : 85,

            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffA73927),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.r),
                ),
              ),

              onPressed: () async {
                await addToCart();

                if (!mounted) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WishListPage()),
                );
              },

              icon: Icon(
                Icons.shopping_cart_outlined,
                color: Colors.white,
                size: isLandscape ? 19.sp : 22.sp,
              ),

              label: Text(
                'Add to Cart',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,

                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: isLandscape ? 12.sp : 16.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
