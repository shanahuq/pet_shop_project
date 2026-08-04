import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pet_shop_project/ui/home_page.dart';
import 'package:pet_shop_project/ui/wish_list_page.dart';

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
  final List<Map<String, dynamic>> products = [
    {
      'image': 'assets/durable_rubber.png',
      'name': 'Durable Rubber…',
      'price': '\$12.50',
      'rating': '4.9',
      'favorite': false,
    },
    {
      'image': 'assets/Comfort Nylon….png',
      'name': 'Comfort Nylon…',
      'price': '\$24.00',
      'rating': '4.7',
      'favorite': false,
    },
    {
      'image': 'assets/Orthopedic Cloud.png',
      'name': 'Comfort Nylon…',
      'price': '\$85.00',
      'rating': '5.0',
      'favorite': false,
    },
    {
      'image': 'assets/Flow-Stream….png',
      'name': 'Flow-Stream…',
      'price': '\$42.99',
      'rating': '4.8',
      'favorite': false,
    },
    {
      'image': 'assets/Salmon Fusion….png',
      'name': 'Salmon Fusion…',
      'price': '\$18.00',
      'rating': '4.9',
      'favorite': false,
    },
    {
      'image': 'assets/Eco-Ceramic….png',
      'name': 'Eco-Ceramic…',
      'price': '\$28.50',
      'rating': '4.6',
      'favorite': false,
    },
  ];
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
      final productId = product['name']
          .toString()
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
          .replaceAll(RegExp(r'^_|_$'), '');

      final cartItemRef = FirebaseFirestore.instance
          .collection('carts')
          .doc(user.uid)
          .collection('items')
          .doc(productId);

      final cartItem = await cartItemRef.get();

      if (cartItem.exists) {
        // Product already exists
        // Increase quantity by 1
        await cartItemRef.update({'quantity': FieldValue.increment(1)});
      } else {
        // First time adding product
        await cartItemRef.set({
          'productId': productId,
          'name': product['name'].toString(),
          'image': product['image'].toString(),
          'price': product['price'].toString(),
          'rating': product['rating'].toString(),
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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add product: $e')));
    }
  }

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
      final productId = product['name']
          .toString()
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
          .replaceAll(RegExp(r'^_|_$'), '');

      await FirebaseFirestore.instance
          .collection('Wishlist')
          .doc(user.uid)
          .collection('items')
          .doc(productId)
          .set({
            'productId': productId,
            'name': product['name'].toString(),
            'image': product['image'].toString(),
            'price': product['price'].toString(),
            'rating': product['rating'].toString(),
            'addedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      debugPrint('WISHLIST ADD ERROR: $e');
    }
  }

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
      final productId = product['name']
          .toString()
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
          .replaceAll(RegExp(r'^_|_$'), '');

      await FirebaseFirestore.instance
          .collection('Wishlist')
          .doc(user.uid)
          .collection('items')
          .doc(productId)
          .delete();
    } catch (e) {
      debugPrint('WISHLIST REMOVE ERROR: $e');
    }
  }

  Future<void> toggleWishlist(Map<String, dynamic> product, int index) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please login first')));
      return;
    }

    final bool isCurrentlyFavorite = product['favorite'] == true;

    // Update UI first
    setState(() {
      products[index]['favorite'] = !isCurrentlyFavorite;
    });

    try {
      if (isCurrentlyFavorite) {
        // Heart was colored -> Remove from wishlist
        await removeFromWishlist(product);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${product['name']} removed from wishlist')),
        );
      } else {
        // Heart was not colored -> Add to wishlist
        await addToWishlist(product);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${product['name']} added to wishlist')),
        );
      }
    } catch (e) {
      // If Firestore fails, restore previous UI state
      if (!mounted) return;

      setState(() {
        products[index]['favorite'] = isCurrentlyFavorite;
      });

      debugPrint('TOGGLE WISHLIST ERROR: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    loadWishlistStatus();
  }

  Future<void> loadWishlistStatus() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('Wishlist')
              .doc(user.uid)
              .collection('items')
              .get();

      final wishlistIds = snapshot.docs.map((doc) => doc.id).toSet();

      if (!mounted) return;

      setState(() {
        for (int i = 0; i < products.length; i++) {
          final productId = products[i]['name']
              .toString()
              .toLowerCase()
              .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
              .replaceAll(RegExp(r'^_|_$'), '');

          products[i]['favorite'] = wishlistIds.contains(productId);
        }
      });
    } catch (e) {
      debugPrint('LOAD WISHLIST ERROR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 60.w,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios),
        ),
        title: Center(
          child: Padding(
            padding: EdgeInsets.only(left: 30.w),
            child: Text(
              'PetLife',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 28.sp,
                color: Color(0xffA73927),
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 40.w),
            child: Icon(
              Icons.notifications_none,
              color: Color(0xffA73927),
              size: 25.sp,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 30.h),

                Text(
                  widget.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 28.sp,
                    color: Color(0xff1B1C1C),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
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

                      SizedBox(width: 8.w),

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
                ),
                SizedBox(height: 10.h),
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
                          duration: const Duration(microseconds: 250),
                          padding: EdgeInsets.symmetric(
                            horizontal: 18.w,
                            vertical: 10.h,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.r),
                            color:
                                isSelected ? Color(0xffF27059) : Colors.white,
                            border: Border.all(
                              color:
                                  isSelected ? Colors.white : Color(0xffDFC0BA),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              tabs[index],
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12.sp,
                                color: Color(0xff650700),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20.h),
                Builder(
                  builder: (context) {
                    if (selectedTab == 0) {
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),

                        itemCount: products.length,

                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 15.w,
                          mainAxisSpacing: 15.h,
                          childAspectRatio: 0.55,
                        ),

                        itemBuilder: (context, index) {
                          final item = products[index];

                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.r),
                              color: Colors.white,
                              border: Border.all(
                                color: const Color(0xffFFFFFF),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16.r),
                                      child: Image.asset(
                                        item['image'],
                                        height: 140.h,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),

                                    Positioned(
                                      top: 8.h,
                                      right: 12.w,
                                      child: GestureDetector(
                                        onTap: () async {
                                          await toggleWishlist(item, index);
                                        },
                                        child: CircleAvatar(
                                          radius: 16.r,
                                          backgroundColor: Colors.white,
                                          child: Icon(
                                            item['favorite'] == true
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            size: 18.sp,
                                            color:
                                                item['favorite'] == true
                                                    ? const Color(0xffA73927)
                                                    : Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 10.h),

                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: const Color(0xffA73927),
                                      size: 16.sp,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      item['rating'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12.sp,
                                        color: const Color(0xff57423D),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 8.h),

                                Text(
                                  item['name'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16.sp,
                                    color: const Color(0xff1B1C1C),
                                  ),
                                ),

                                SizedBox(height: 5.h),

                                Text(
                                  item['price'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 18.sp,
                                    color: const Color(0xffA73927),
                                  ),
                                ),

                                SizedBox(height: 10.h),

                                SizedBox(
                                  width: double.infinity,
                                  height: 45.h,
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: const Color(0xffA73927),
                                      side: const BorderSide(
                                        color: Color(0xffA73927),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          16.r,
                                        ),
                                      ),
                                      padding: EdgeInsets.zero,
                                    ),
                                    onPressed: () async {
                                      await addToCart(item);

                                      if (!context.mounted) return;

                                      // Navigate to your CartPage here
                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //     builder: (context) => const CartPage(),
                                      //   ),
                                      // );
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.shopping_cart_outlined,
                                          color: Colors.white,
                                          size: 20.sp,
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          'Add to Cart',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12.sp,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }

                    return const Center(child: Text('no items'));
                  },
                ),
                SizedBox(height: 30.h),
                Center(
                  child: Text(
                    'Showing 6 of 24 items',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12.sp,
                      color: Color(0xff57423D),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Center(
                  child: SizedBox(
                    width: 150.w,
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 4.h,
                            width: 150.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20.r),
                                bottomLeft: Radius.circular(20.r),
                              ),
                              color: Color(0xffA73927),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 4.h,
                            width: 150.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20.r),
                                bottomRight: Radius.circular(20.r),
                              ),
                              color: Color(0xffE4E2E1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Center(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(190.w, 55.h),
                      side: BorderSide(color: Color(0xffA73927)),
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
                        color: Color(0xffA73927),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
