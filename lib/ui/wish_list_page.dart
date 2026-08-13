import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WishListPage extends StatefulWidget {
  const WishListPage({super.key});

  @override
  State<WishListPage> createState() => _WishListPageState();
}

class _WishListPageState extends State<WishListPage> {
  int selectedIndex = 0;

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

          title: Text(
            'PetLife',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20.sp,
              color: const Color(0xffA73927),
            ),
          ),

          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.search, size: 25.sp),
            ),

            Padding(
              padding: EdgeInsets.only(right: 30.w),
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    _firestore
                        .collection('carts')
                        .doc(user.uid)
                        .collection('items')
                        .snapshots(),
                builder: (context, snapshot) {
                  int cartCount = snapshot.data?.docs.length ?? 0;

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
                          right: -2,
                          top: -2,
                          child: Container(
                            height: 16.h,
                            width: 16.w,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Center(
                              child: Text(
                                cartCount.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.sp,
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

        body: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 18.h),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Container(
                  height: 52.h,
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
                    tabs: const [Tab(text: "Cart"), Tab(text: "Wishlist")],
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              Expanded(
                child: TabBarView(
                  children: [CartTab(userId: user.uid), const WishListTab()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CartTab extends StatelessWidget {
  final String userId;

  const CartTab({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    return StreamBuilder<QuerySnapshot>(
      stream:
          firestore
              .collection('carts')
              .doc(userId)
              .collection('items')
              .snapshots(),

      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading cart:\n${snapshot.error}',
              textAlign: TextAlign.center,
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'Your cart is empty',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          );
        }

        final cartItems = snapshot.data!.docs;

        double subtotal = 0;

        for (final doc in cartItems) {
          final data = doc.data() as Map<String, dynamic>;

          final price = (data['price'] as num?)?.toDouble() ?? 0.0;
          final quantity = (data['quantity'] as num?)?.toInt() ?? 1;

          subtotal += price * quantity;
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final doc = cartItems[index];

                    final data = doc.data() as Map<String, dynamic>;

                    return CartItem(
                      productId: doc.id,
                      userId: userId,
                      image: data['image']?.toString() ?? '',
                      name: data['name']?.toString() ?? '',
                      brand: data['brand']?.toString() ?? '',
                      price:
                          '\$${(data['price'] as num?)?.toDouble().toStringAsFixed(2) ?? '0.00'}',
                      quantity: (data['quantity'] as num?)?.toInt() ?? 1,
                    );
                  },
                ),
              ),

              const Divider(),

              SizedBox(height: 10.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subtotal',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xff57423D),
                    ),
                  ),

                  Text(
                    '\$${subtotal.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 15.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Shipping',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xff57423D),
                    ),
                  ),

                  Text(
                    'Calculated at checkout',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xff006971),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              SizedBox(
                width: 300.w,
                height: 55.h,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffA73927),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Proceed to Checkout',
                        style: TextStyle(fontSize: 16.sp, color: Colors.white),
                      ),

                      SizedBox(width: 10.w),

                      const Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20.h),
            ],
          ),
        );
      },
    );
  }
}

class CartItem extends StatelessWidget {
  final String productId;
  final String userId;
  final String image;
  final String name;
  final String brand;
  final String price;
  final int quantity;

  const CartItem({
    super.key,
    required this.productId,
    required this.userId,
    required this.image,
    required this.name,
    required this.brand,
    required this.price,
    required this.quantity,
  });

  Future<void> deleteItem() async {
    await FirebaseFirestore.instance
        .collection('carts')
        .doc(userId)
        .collection('items')
        .doc(productId)
        .delete();
  }

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
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 15.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PRODUCT IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: Image.network(
                image,
                width: 75.w,
                height: 75.w,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 75.w,
                    height: 75.w,
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
                    width: 75.w,
                    height: 75.w,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
              ),
            ),

            SizedBox(width: 12.w),

            // PRODUCT DETAILS
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // PRODUCT NAME
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                    ),
                  ),

                  SizedBox(height: 4.h),

                  // BRAND
                  Text(
                    brand,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                  ),

                  SizedBox(height: 8.h),

                  // PRICE + QUANTITY
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // PRICE
                      Flexible(
                        child: Text(
                          price,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: const Color(0xffA73927),
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),

                      SizedBox(width: 5.w),

                      // QUANTITY CONTROLS
                      Container(
                        height: 36.h,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // MINUS
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(
                                minWidth: 30.w,
                                minHeight: 30.h,
                              ),
                              onPressed: () async {
                                try {
                                  await updateQuantity(quantity - 1);
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Failed to update quantity: $e',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                              icon: Icon(Icons.remove, size: 16.sp),
                            ),

                            // QUANTITY
                            Text(
                              quantity.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                              ),
                            ),

                            // PLUS
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(
                                minWidth: 30.w,
                                minHeight: 30.h,
                              ),
                              onPressed: () async {
                                try {
                                  await updateQuantity(quantity + 1);
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Failed to update quantity: $e',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                              icon: Icon(Icons.add, size: 16.sp),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // DELETE BUTTON
            SizedBox(
              width: 35.w,
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () async {
                  try {
                    await deleteItem();

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Item removed from cart')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  }
                },
                icon: Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 22.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WishListTab extends StatelessWidget {
  const WishListTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // User is not logged in
    if (user == null) {
      return const Center(child: Text('Please login first'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('Wishlist')
              .doc(user.uid)
              .collection('items')
              .orderBy('addedAt', descending: true)
              .snapshots(),

      builder: (context, snapshot) {
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Error
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading wishlist:\n${snapshot.error}',
              textAlign: TextAlign.center,
            ),
          );
        }

        // Empty wishlist
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'Your wishlist is empty',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          );
        }

        // Wishlist products
        final wishlistItems = snapshot.data!.docs;

        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          itemCount: wishlistItems.length,
          itemBuilder: (context, index) {
            final doc = wishlistItems[index];

            final data = doc.data() as Map<String, dynamic>;

            final dynamic priceData = data['price'];

            double price = 0.0;

            if (priceData is num) {
              price = priceData.toDouble();
            } else if (priceData is String) {
              price =
                  double.tryParse(
                    priceData.replaceAll('\$', '').replaceAll(',', '').trim(),
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
  }
}

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

  Future<void> removeFromWishlist() async {
    await FirebaseFirestore.instance
        .collection('Wishlist')
        .doc(userId)
        .collection('items')
        .doc(productId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 15.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Row(
          children: [
            // PRODUCT IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.network(
                image,
                width: 85.w,
                height: 85.h,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 85.w,
                    height: 85.h,
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
                    width: 85.w,
                    height: 85.h,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
              ),
            ),

            SizedBox(width: 15.w),

            // PRODUCT DETAILS
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),

                  SizedBox(height: 5.h),

                  Text(
                    brand,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                  ),

                  SizedBox(height: 8.h),

                  Text(
                    price,
                    style: TextStyle(
                      color: const Color(0xffA73927),
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ),
            ),

            // REMOVE FROM WISHLIST
            IconButton(
              onPressed: () async {
                try {
                  await removeFromWishlist();

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Removed from wishlist')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
              icon: Icon(Icons.favorite, color: Colors.red, size: 25.sp),
            ),
          ],
        ),
      ),
    );
  }
}
