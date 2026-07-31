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

          final priceString = data['price'] ?? '\$0';

          final price =
              double.tryParse(
                priceString.toString().replaceAll('\$', '').replaceAll(',', ''),
              ) ??
              0;

          final quantity = data['quantity'] ?? 1;

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
                      image: data['image'] ?? '',
                      name: data['name'] ?? '',
                      brand: data['brand'] ?? '',
                      price: data['price'] ?? '\$0',
                      quantity: data['quantity'] ?? 1,
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

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 15.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                image,
                width: 85,
                height: 85,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(brand, style: const TextStyle(color: Colors.grey)),

                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        price,
                        style: const TextStyle(
                          color: Color(0xffA73927),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),

                      Row(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.remove, size: 18),
                          ),

                          Text(
                            quantity.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),

                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.add, size: 18),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            IconButton(
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
              icon: const Icon(Icons.delete_outline, color: Colors.red),
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
    return const Center(child: Text("Wishlist Items Here"));
  }
}
