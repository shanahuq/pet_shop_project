import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pet_shop_project/ui/checkout_page.dart';
import 'organic_grain.dart';

/// ============================================================
/// OPEN PRODUCT DETAILS
/// ============================================================

Future<void> openProductDetails(
  BuildContext context,
  String productId, {
  String? productName,
  String? brand,
}) async {
  try {
    final firestore = FirebaseFirestore.instance;

    // ----------------------------------------------------------
    // STEP 1: Try productId as Firestore document ID
    // ----------------------------------------------------------

    DocumentSnapshot<Map<String, dynamic>> productDoc =
        await firestore.collection('products').doc(productId).get();

    // ----------------------------------------------------------
    // STEP 2: Try productId field
    // ----------------------------------------------------------

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

    // ----------------------------------------------------------
    // STEP 3: Search using name + brand
    // ----------------------------------------------------------

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

    // ----------------------------------------------------------
    // STEP 4: Product not found
    // ----------------------------------------------------------

    if (!productDoc.exists) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product not found: ${productName ?? productId}'),
          ),
        );
      }
      return;
    }

    // ----------------------------------------------------------
    // STEP 5: Get product data
    // ----------------------------------------------------------

    final productData = productDoc.data();

    if (productData == null) {
      return;
    }

    final product = {
      ...productData,
      'id': productDoc.id,
      'productDocId': productDoc.id,
    };

    // ----------------------------------------------------------
    // STEP 6: Open product details
    // ----------------------------------------------------------

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OrganicGrain(product: product)),
    );
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load product: $e')));
    }
  }
}

/// ============================================================
/// WISHLIST PAGE
/// ============================================================

class WishListPage extends StatefulWidget {
  const WishListPage({super.key});

  @override
  State<WishListPage> createState() => _WishListPageState();
}

class _WishListPageState extends State<WishListPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please login first')));
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,

          // ----------------------------------------------------
          // PROFILE IMAGE
          // ----------------------------------------------------
          leading: Padding(
            padding: EdgeInsets.only(left: 16.w),
            child: CircleAvatar(
              radius: 18.r,
              child: ClipOval(
                child: Image.asset(
                  'assets/profilepicture.png',
                  fit: BoxFit.cover,
                  width: 36.w,
                  height: 36.h,
                ),
              ),
            ),
          ),

          // ----------------------------------------------------
          // TITLE
          // ----------------------------------------------------
          title: Text(
            'PetLife',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20.sp,
              color: const Color(0xffA73927),
            ),
          ),

          // ----------------------------------------------------
          // ACTIONS
          // ----------------------------------------------------
          actions: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Icon(Icons.search, size: 25.sp),
            ),

            Padding(
              padding: EdgeInsets.only(right: 20.w),
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    _firestore
                        .collection('carts')
                        .doc(user.uid)
                        .collection('items')
                        .snapshots(),
                builder: (context, snapshot) {
                  final int cartCount = snapshot.data?.docs.length ?? 0;

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        color: const Color(0xffA73927),
                        size: 28.sp,
                      ),

                      if (cartCount > 0)
                        Positioned(
                          right: -5.w,
                          top: -5.h,
                          child: Container(
                            height: 17.w,
                            width: 17.w,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Center(
                              child: Text(
                                cartCount.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),

        // ======================================================
        // BODY
        // ======================================================
        body: SafeArea(
          child: OrientationBuilder(
            builder: (context, orientation) {
              final bool isLandscape = orientation == Orientation.landscape;

              return Column(
                children: [
                  SizedBox(height: isLandscape ? 8.h : 18.h),

                  // ------------------------------------------------
                  // TAB BAR
                  // ------------------------------------------------
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isLandscape ? 40.w : 20.w,
                    ),
                    child: Container(
                      height: isLandscape ? 48.h : 52.h,
                      decoration: BoxDecoration(
                        color: const Color(0xffF5F2F0),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: TabBar(
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicatorPadding: EdgeInsets.all(4.w),
                        dividerColor: Colors.transparent,
                        indicator: BoxDecoration(
                          color: const Color(0xffE7E2DF),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        labelColor: const Color(0xffA73927),
                        unselectedLabelColor: Colors.black54,
                        labelStyle: TextStyle(
                          fontSize: isLandscape ? 14.sp : 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        tabs: const [Tab(text: 'Cart'), Tab(text: 'Wishlist')],
                      ),
                    ),
                  ),

                  SizedBox(height: isLandscape ? 8.h : 20.h),

                  // ------------------------------------------------
                  // CONTENT
                  // ------------------------------------------------
                  Expanded(
                    child: TabBarView(
                      children: [
                        CartTab(userId: user.uid),
                        const WishListTab(),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// ============================================================
/// CART TAB
/// ============================================================

class CartTab extends StatelessWidget {
  final String userId;

  const CartTab({super.key, required this.userId});

  // ----------------------------------------------------------
  // GET PRICE
  // ----------------------------------------------------------

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

  // ----------------------------------------------------------
  // GET QUANTITY
  // ----------------------------------------------------------

  int getQuantity(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value.trim()) ?? 1;
    }

    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;

    return StreamBuilder<QuerySnapshot>(
      stream:
          firestore
              .collection('carts')
              .doc(userId)
              .collection('items')
              .snapshots(),
      builder: (context, snapshot) {
        // ======================================================
        // LOADING
        // ======================================================

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // ======================================================
        // ERROR
        // ======================================================

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Text(
                'Error loading cart:\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        // ======================================================
        // EMPTY CART
        // ======================================================

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'Your cart is empty',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          );
        }

        final cartItems = snapshot.data!.docs;

        // ======================================================
        // ORIENTATION
        // ======================================================

        return OrientationBuilder(
          builder: (context, orientation) {
            final bool isLandscape = orientation == Orientation.landscape;

            // ==================================================
            // CALCULATE SUBTOTAL
            // ==================================================

            double subtotal = 0;

            for (final doc in cartItems) {
              final data = doc.data() as Map<String, dynamic>;

              final price = getPrice(data['price']);
              final quantity = getQuantity(data['quantity']);

              subtotal += price * quantity;
            }

            // ==================================================
            // CART PRODUCTS
            //
            // IMPORTANT:
            // No ListView inside SingleChildScrollView.
            // We use Column so the whole cart scrolls together.
            // ==================================================

            final List<Widget> cartWidgets = [];

            for (final doc in cartItems) {
              final data = doc.data() as Map<String, dynamic>;

              final price = getPrice(data['price']);
              final quantity = getQuantity(data['quantity']);

              cartWidgets.add(
                CartItem(
                  productId: doc.id,
                  productDocId: data['productDocId']?.toString(),
                  userId: userId,
                  image: data['image']?.toString() ?? '',
                  name: data['name']?.toString() ?? '',
                  brand: data['brand']?.toString() ?? '',
                  price: '\$${price.toStringAsFixed(2)}',
                  quantity: quantity,
                ),
              );
            }

            // ==================================================
            // ORDER SUMMARY
            // ==================================================

            final Widget orderSummary = Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(
                horizontal: isLandscape ? 25.w : 30.w,
                vertical: 5.h,
              ),
              padding: EdgeInsets.all(isLandscape ? 15.w : 20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ------------------------------------------------
                  // TITLE
                  // ------------------------------------------------
                  Text(
                    'Order Summary',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: isLandscape ? 16.sp : 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: isLandscape ? 8.h : 15.h),

                  const Divider(),

                  SizedBox(height: isLandscape ? 8.h : 10.h),

                  // ------------------------------------------------
                  // SUBTOTAL
                  // ------------------------------------------------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Subtotal',
                        style: TextStyle(
                          fontSize: isLandscape ? 13.sp : 14.sp,
                          color: const Color(0xff57423D),
                        ),
                      ),

                      Text(
                        '\$${subtotal.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: isLandscape ? 13.sp : 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: isLandscape ? 10.h : 15.h),

                  // ------------------------------------------------
                  // SHIPPING
                  // ------------------------------------------------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Shipping',
                        style: TextStyle(
                          fontSize: isLandscape ? 13.sp : 14.sp,
                          color: const Color(0xff57423D),
                        ),
                      ),

                      Flexible(
                        child: Text(
                          'Calculated at checkout',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: isLandscape ? 11.sp : 13.sp,
                            color: const Color(0xff006971),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: isLandscape ? 15.h : 25.h),

                  // ==================================================
                  // CHECKOUT BUTTON - RESPONSIVE
                  // ==================================================
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final double buttonHeight =
                          isLandscape
                              ? (constraints.maxWidth < 600 ? 58.h : 64.h)
                              : 58.h;

                      return SizedBox(
                        width: double.infinity,
                        height: buttonHeight,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CheckoutPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffA73927),
                            padding: EdgeInsets.symmetric(
                              horizontal: isLandscape ? 24.w : 20.w,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  'Proceed to Checkout',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: isLandscape ? 13.sp : 23.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: isLandscape ? 12.w : 8.w),
                              Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: isLandscape ? 23.sp : 22.sp,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );

            // ======================================================
            // COMPLETE CART
            //
            // EVERYTHING IS ONE SCROLLABLE COLUMN
            // ======================================================

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                top: 5.h,
                bottom: isLandscape ? 15.h : 25.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ------------------------------------------------
                  // CART PRODUCTS
                  // ------------------------------------------------
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isLandscape ? 25.w : 30.w,
                    ),
                    child: Column(children: cartWidgets),
                  ),

                  SizedBox(height: isLandscape ? 5.h : 10.h),

                  // ------------------------------------------------
                  // ORDER SUMMARY
                  // ------------------------------------------------
                  orderSummary,
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// ============================================================
/// CART ITEM
/// ============================================================

class CartItem extends StatelessWidget {
  final String productId;
  final String? productDocId;
  final String userId;
  final String image;
  final String name;
  final String brand;
  final String price;
  final int quantity;

  const CartItem({
    super.key,
    required this.productId,
    this.productDocId,
    required this.userId,
    required this.image,
    required this.name,
    required this.brand,
    required this.price,
    required this.quantity,
  });

  // ------------------------------------------------------------
  // DELETE ITEM
  // ------------------------------------------------------------

  Future<void> deleteItem() async {
    await FirebaseFirestore.instance
        .collection('carts')
        .doc(userId)
        .collection('items')
        .doc(productId)
        .delete();
  }

  // ------------------------------------------------------------
  // UPDATE QUANTITY
  // ------------------------------------------------------------

  Future<void> updateQuantity(int newQuantity) async {
    if (newQuantity < 1) {
      return;
    }

    await FirebaseFirestore.instance
        .collection('carts')
        .doc(userId)
        .collection('items')
        .doc(productId)
        .update({'quantity': newQuantity});
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final bool isLandscape = orientation == Orientation.landscape;

        final double imageSize = isLandscape ? 65.w : 75.w;

        return InkWell(
          borderRadius: BorderRadius.circular(18.r),
          onTap: () async {
            await openProductDetails(
              context,
              productDocId ?? productId,
              productName: name,
              brand: brand,
            );
          },
          child: Card(
            elevation: 2,
            margin: EdgeInsets.only(bottom: isLandscape ? 10.h : 15.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(isLandscape ? 8.w : 12.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ==================================================
                  // PRODUCT IMAGE
                  // ==================================================
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: Image.network(
                      image,
                      width: imageSize,
                      height: imageSize,
                      fit: BoxFit.cover,

                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: imageSize,
                          height: imageSize,
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                          ),
                        );
                      },

                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }

                        return SizedBox(
                          width: imageSize,
                          height: imageSize,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(width: isLandscape ? 10.w : 12.w),

                  // ==================================================
                  // PRODUCT DETAILS
                  // ==================================================
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ------------------------------------------------
                        // PRODUCT NAME
                        // ------------------------------------------------
                        Text(
                          name,
                          maxLines: isLandscape ? 1 : 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isLandscape ? 14.sp : 15.sp,
                          ),
                        ),

                        SizedBox(height: isLandscape ? 2.h : 4.h),

                        // ------------------------------------------------
                        // BRAND
                        // ------------------------------------------------
                        Text(
                          brand,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: isLandscape ? 11.sp : 12.sp,
                          ),
                        ),

                        SizedBox(height: isLandscape ? 6.h : 8.h),

                        // ==================================================
                        // PRICE + QUANTITY
                        // ==================================================
                        /// ============================================================
                        /// PRICE + QUANTITY - RESPONSIVE
                        /// ============================================================
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final double availableWidth = constraints.maxWidth;

                            // Make the quantity control smaller when space is tight.
                            final bool compact = availableWidth < 260.w;

                            final double quantityBoxWidth =
                                compact ? 70.w : (isLandscape ? 78.w : 88.w);

                            final double quantityButtonWidth =
                                compact ? 20.w : (isLandscape ? 23.w : 27.w);

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // ========================================================
                                // PRICE
                                // ========================================================
                                Expanded(
                                  child: Text(
                                    price,
                                    maxLines: 1,
                                    softWrap: false,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: const Color(0xffA73927),
                                      fontWeight: FontWeight.bold,
                                      fontSize: isLandscape ? 14.sp : 16.sp,
                                    ),
                                  ),
                                ),

                                SizedBox(width: compact ? 4.w : 8.w),

                                // ========================================================
                                // QUANTITY BOX
                                // ========================================================
                                SizedBox(
                                  width: quantityBoxWidth,
                                  height: isLandscape ? 34.h : 38.h,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                      borderRadius: BorderRadius.circular(9.r),
                                    ),
                                    child: Row(
                                      children: [
                                        // ==================================================
                                        // MINUS BUTTON
                                        // ==================================================
                                        SizedBox(
                                          width: quantityButtonWidth,
                                          height: double.infinity,
                                          child: IconButton(
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(
                                              minWidth: 0,
                                              minHeight: 0,
                                            ),
                                            splashRadius: 14.r,
                                            onPressed:
                                                quantity <= 1
                                                    ? null
                                                    : () async {
                                                      try {
                                                        await updateQuantity(
                                                          quantity - 1,
                                                        );
                                                      } catch (e) {
                                                        if (context.mounted) {
                                                          ScaffoldMessenger.of(
                                                            context,
                                                          ).showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                'Failed to update quantity: $e',
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                      }
                                                    },
                                            icon: Icon(
                                              Icons.remove,
                                              size:
                                                  compact
                                                      ? 12.sp
                                                      : (isLandscape
                                                          ? 13.sp
                                                          : 15.sp),
                                            ),
                                          ),
                                        ),

                                        // ==================================================
                                        // NUMBER
                                        // ==================================================
                                        Expanded(
                                          child: Center(
                                            child: SizedBox(
                                              width: compact ? 22.w : 28.w,
                                              child: Text(
                                                quantity.toString(),
                                                maxLines: 1,
                                                softWrap: false,
                                                overflow: TextOverflow.visible,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      compact
                                                          ? 12.sp
                                                          : (isLandscape
                                                              ? 13.sp
                                                              : 14.sp),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),

                                        // ==================================================
                                        // PLUS BUTTON
                                        // ==================================================
                                        SizedBox(
                                          width: quantityButtonWidth,
                                          height: double.infinity,
                                          child: IconButton(
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(
                                              minWidth: 0,
                                              minHeight: 0,
                                            ),
                                            splashRadius: 14.r,
                                            onPressed: () async {
                                              try {
                                                await updateQuantity(
                                                  quantity + 1,
                                                );
                                              } catch (e) {
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Failed to update quantity: $e',
                                                      ),
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                            icon: Icon(
                                              Icons.add,
                                              size:
                                                  compact
                                                      ? 12.sp
                                                      : (isLandscape
                                                          ? 13.sp
                                                          : 15.sp),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    width: isLandscape ? 30.w : 35.w,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () async {
                        try {
                          await deleteItem();

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Item removed from cart'),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      },
                      icon: Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: isLandscape ? 20.sp : 22.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// ============================================================
/// WISHLIST TAB
/// ============================================================

class WishListTab extends StatelessWidget {
  const WishListTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // ----------------------------------------------------------
    // NOT LOGGED IN
    // ----------------------------------------------------------

    if (user == null) {
      return const Center(child: Text('Please login first'));
    }

    return OrientationBuilder(
      builder: (context, orientation) {
        final bool isLandscape = orientation == Orientation.landscape;

        return StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('wishlist')
                  .doc(user.uid)
                  .collection('items')
                  .orderBy('addedAt', descending: true)
                  .snapshots(),
          builder: (context, snapshot) {
            // --------------------------------------------------
            // LOADING
            // --------------------------------------------------

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // --------------------------------------------------
            // ERROR
            // --------------------------------------------------

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Text(
                    'Error loading wishlist:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            // --------------------------------------------------
            // EMPTY
            // --------------------------------------------------

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'Your wishlist is empty',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              );
            }

            final wishlistItems = snapshot.data!.docs;

            // --------------------------------------------------
            // LIST
            // --------------------------------------------------

            return ListView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: isLandscape ? 35.w : 20.w,
                vertical: isLandscape ? 5.h : 10.h,
              ),
              itemCount: wishlistItems.length,
              itemBuilder: (context, index) {
                final doc = wishlistItems[index];

                final data = doc.data() as Map<String, dynamic>;

                // ------------------------------------------------
                // PRICE
                // ------------------------------------------------

                final dynamic priceData = data['price'];

                double price = 0.0;

                if (priceData is num) {
                  price = priceData.toDouble();
                } else if (priceData is String) {
                  price =
                      double.tryParse(
                        priceData
                            .replaceAll('\$', '')
                            .replaceAll(',', '')
                            .trim(),
                      ) ??
                      0.0;
                }

                return WishlistItem(
                  productId: doc.id,
                  userId: user.uid,
                  image: data['image']?.toString() ?? '',
                  name: data['name']?.toString() ?? '',
                  brand: data['brand']?.toString() ?? '',
                  price: '\$${price.toStringAsFixed(2)}',
                );
              },
            );
          },
        );
      },
    );
  }
}

/// ============================================================
/// WISHLIST ITEM - RESPONSIVE
/// ============================================================

class WishlistItem extends StatelessWidget {
  final String productId;
  final String userId;
  final String image;
  final String name;
  final String brand;
  final String price;

  const WishlistItem({
    super.key,
    required this.productId,
    required this.userId,
    required this.image,
    required this.name,
    required this.brand,
    required this.price,
  });

  // ------------------------------------------------------------
  // REMOVE FROM WISHLIST
  // ------------------------------------------------------------

  Future<void> removeFromWishlist() async {
    await FirebaseFirestore.instance
        .collection('wishlist')
        .doc(userId)
        .collection('items')
        .doc(productId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final bool isLandscape = orientation == Orientation.landscape;

        return LayoutBuilder(
          builder: (context, constraints) {
            // ==================================================
            // RESPONSIVE IMAGE SIZE
            // ==================================================

            final double imageSize =
                isLandscape ? (constraints.maxWidth < 600 ? 60.w : 70.w) : 85.w;

            // ==================================================
            // CARD PADDING
            // ==================================================

            final double cardPadding = isLandscape ? 8.w : 12.w;

            // ==================================================
            // DELETE BUTTON WIDTH
            // ==================================================

            final double deleteButtonWidth = isLandscape ? 32.w : 40.w;

            return InkWell(
              borderRadius: BorderRadius.circular(18.r),
              onTap: () async {
                await openProductDetails(
                  context,
                  productId,
                  productName: name,
                  brand: brand,
                );
              },
              child: Card(
                elevation: 2,
                margin: EdgeInsets.only(bottom: isLandscape ? 10.h : 15.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(cardPadding),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ==================================================
                      // PRODUCT IMAGE
                      // ==================================================
                      SizedBox(
                        width: imageSize,
                        height: imageSize,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Image.network(
                            image,
                            width: imageSize,
                            height: imageSize,
                            fit: BoxFit.cover,

                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: imageSize,
                                height: imageSize,
                                color: Colors.grey.shade200,
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                  size: isLandscape ? 24.sp : 30.sp,
                                ),
                              );
                            },

                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }

                              return SizedBox(
                                width: imageSize,
                                height: imageSize,
                                child: Center(
                                  child: SizedBox(
                                    width: isLandscape ? 18.w : 22.w,
                                    height: isLandscape ? 18.w : 22.w,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      SizedBox(width: isLandscape ? 10.w : 15.w),

                      // ==================================================
                      // PRODUCT DETAILS
                      // ==================================================
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ------------------------------------------
                            // NAME
                            // ------------------------------------------
                            Text(
                              name,
                              maxLines: isLandscape ? 1 : 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isLandscape ? 14.sp : 16.sp,
                              ),
                            ),

                            SizedBox(height: isLandscape ? 3.h : 5.h),

                            // ------------------------------------------
                            // BRAND
                            // ------------------------------------------
                            Text(
                              brand,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: isLandscape ? 11.sp : 13.sp,
                              ),
                            ),

                            SizedBox(height: isLandscape ? 5.h : 8.h),

                            // ------------------------------------------
                            // PRICE
                            // ------------------------------------------
                            Text(
                              price,
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: const Color(0xffA73927),
                                fontWeight: FontWeight.bold,
                                fontSize: isLandscape ? 14.sp : 16.sp,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ==================================================
                      // REMOVE FROM WISHLIST
                      // ==================================================
                      SizedBox(
                        width: deleteButtonWidth,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 0,
                            minHeight: 0,
                          ),
                          onPressed: () async {
                            try {
                              await removeFromWishlist();

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Removed from wishlist'),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            }
                          },
                          icon: Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: isLandscape ? 22.sp : 25.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
