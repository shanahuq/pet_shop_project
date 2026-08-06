import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pet_shop_project/ui/organic_grain.dart';
import 'package:pet_shop_project/ui/search_categories.dart';
import 'package:pet_shop_project/ui/search_page.dart';
import 'package:pet_shop_project/ui/view_all_categories.dart';
import 'package:pet_shop_project/ui/view_all_products_list.dart';
import 'wish_list_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  final VoidCallback? onGoToWishlist;

  const HomePage({super.key, this.onGoToWishlist});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  final Set<String> wishlistedProducts = {};

  final FirebaseFirestore db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> get categoriesStream {
    return db.collection('categories').snapshots();
  }

  final List<Map<String, String>> dogProducts = [
    {
      "image": "assets/Background.png",
      "brand": "Kibble & Co",
      "name": "Organic Dog Food",
      "price": "\$24.99",
    },
    {
      "image": "assets/toy.png",
      "brand": "PlaySmart",
      "name": "Interactive Bone",
      "price": "\$18.50",
    },
    {
      "image": "assets/Background (1).png",
      "brand": "PurePurr",
      "name": "Cat Wellness Kit",
      "price": "\$32.00",
    },
    {
      "image": "assets/Background (2).png",
      "brand": "WildWings",
      "name": "Modern Feeder",
      "price": "\$45.00",
    },
  ];
  Future<void> addToCart(Map<String, String> product) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please login first')));
      return;
    }

    try {
      final productId = product['name']!
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
          .replaceAll(RegExp(r'^_|_$'), '');

      final cartItemRef = FirebaseFirestore.instance
          .collection('carts')
          .doc(user.uid)
          .collection('items')
          .doc(productId);

      // Check if product already exists in cart
      final cartItem = await cartItemRef.get();

      if (cartItem.exists) {
        // Get current quantity
        final currentQuantity = cartItem.data()?['quantity'] ?? 0;

        // Increase quantity by 1
        await cartItemRef.update({'quantity': currentQuantity + 1});
      } else {
        // Product doesn't exist, create it with quantity 1
        await cartItemRef.set({
          'productId': productId,
          'name': product['name'],
          'brand': product['brand'],
          'image': product['image'],
          'price': product['price'],
          'quantity': 1,
          'addedAt': FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product['name']} added to cart')),
      );
    } catch (e) {
      debugPrint('FIREBASE ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add product: $e')));
    }
  }

  Future<bool> toggleWishlist(Map<String, String> product) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return false;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please login first')));

      return false;
    }

    final productId = product['name']!
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');

    final bool isCurrentlyWishlisted = wishlistedProducts.contains(productId);

    try {
      if (isCurrentlyWishlisted) {
        // Remove from wishlist
        await FirebaseFirestore.instance
            .collection('Wishlist')
            .doc(user.uid)
            .collection('items')
            .doc(productId)
            .delete();

        if (!mounted) return false;

        setState(() {
          wishlistedProducts.remove(productId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${product['name']} removed from wishlist')),
        );

        return false;
      } else {
        // Add to wishlist
        await FirebaseFirestore.instance
            .collection('Wishlist')
            .doc(user.uid)
            .collection('items')
            .doc(productId)
            .set({
              'productId': productId,
              'name': product['name'],
              'brand': product['brand'],
              'image': product['image'],
              'price': product['price'],
              'addedAt': FieldValue.serverTimestamp(),
            });

        if (!mounted) return false;

        setState(() {
          wishlistedProducts.add(productId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${product['name']} added to wishlist')),
        );

        return true;
      }
    } catch (e) {
      debugPrint('TOGGLE WISHLIST ERROR: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update wishlist: $e')),
        );
      }

      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    loadWishlist();
  }

  Future<void> loadWishlist() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('Wishlist')
              .doc(user.uid)
              .collection('items')
              .get();

      if (!mounted) return;

      setState(() {
        wishlistedProducts.clear();

        for (final doc in snapshot.docs) {
          wishlistedProducts.add(doc.id);
        }
      });
    } catch (e) {
      debugPrint('LOAD WISHLIST ERROR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: categoriesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('No categories found')),
          );
        }

        final categories = snapshot.data!.docs;

        return Scaffold(
          appBar: AppBar(
            leading: Padding(
              padding: EdgeInsets.only(left: 20.w),
              child: CircleAvatar(
                radius: 30.r,
                child: Image.asset('assets/Border.png', fit: BoxFit.cover),
              ),
            ),
            title: Text(
              'PetLife',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20.sp,
                color: Color(0xffA73927),
              ),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 30.w),
                child: Icon(
                  Icons.shopping_cart_outlined,
                  color: Color(0xffA73927),
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
                      'Welcome back,',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12.sp,
                        color: Color(0xff57423D),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'Hello, Pet Lover!',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18.sp,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Container(
                      height: 40.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        color: const Color.fromARGB(136, 158, 158, 158),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 10.h, left: 15.w),
                        child: TextField(
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: 'Search for treats, toys, or food...',
                            hintStyle: TextStyle(fontSize: 12.sp),
                            prefix: Icon(Icons.search, color: Colors.grey),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Shop by Category',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18.sp,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewAllCategories(),
                              ),
                            );
                          },
                          child: Text(
                            'View All',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Color(0xffA73927),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15.h),
                    SizedBox(
                      height: 110.h,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        itemBuilder: (context, index) {
                          final data =
                              categories[index].data() as Map<String, dynamic>;

                          return GestureDetector(
                            onTap: () {
                              print("Clicked category: ${data['name']}");

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => SearchCategories(
                                        title: data['name'],
                                        categoryId: categories[index].id,
                                      ),
                                ),
                              );
                            },
                            child: SizedBox(
                              width: 70.w,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6.w),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 28.r,
                                      backgroundColor: Colors.grey.shade300,
                                      backgroundImage: NetworkImage(
                                        data['imageUrl'] ?? '',
                                      ),
                                    ),

                                    SizedBox(height: 8.h),

                                    Text(
                                      data['name'] ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.black,
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

                    Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15.r),
                          child: Image.asset(
                            "assets/Section - Featured Banner.png",
                            width: double.infinity,
                            height: 200.h,
                            fit: BoxFit.cover,
                          ),
                        ),

                        SizedBox(height: 5.h),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Trending Now",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => ViewAllProductsList(
                                          products: dogProducts,
                                        ),
                                  ),
                                );
                              },
                              child: Text(
                                'View All',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Color(0xffA73927),
                                ),
                              ),
                            ),
                          ],
                        ),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: dogProducts.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 15,
                                mainAxisSpacing: 15.h,
                                childAspectRatio: 0.58,
                              ),
                          itemBuilder: (context, index) {
                            final product = dogProducts[index];
                            final productId = product['name']!
                                .toLowerCase()
                                .replaceAll(' ', '_');

                            // Check if THIS product is wishlisted
                            final isWishlisted = wishlistedProducts.contains(
                              productId,
                            );
                            return Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.r),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(10.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: 120.h,
                                      width: double.infinity,
                                      child: Stack(
                                        children: [
                                          // PRODUCT IMAGE
                                          Positioned.fill(
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(15.r),
                                              child: GestureDetector(
                                                onTap: () {
                                                  if (index == 0) {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder:
                                                            (context) =>
                                                                OrganicGrain(),
                                                      ),
                                                    );
                                                  }
                                                },
                                                child: Image.asset(
                                                  product["image"]!,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),

                                          // WISHLIST HEART BUTTON
                                          // WISHLIST HEART BUTTON
                                          Positioned(
                                            top: 8.h,
                                            right: 8.w,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.15),
                                                    blurRadius: 5,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: IconButton(
                                                padding: EdgeInsets.zero,
                                                constraints: BoxConstraints(
                                                  minWidth: 30.w,
                                                  minHeight: 30.h,
                                                ),
                                                onPressed: () async {
                                                  final user =
                                                      FirebaseAuth
                                                          .instance
                                                          .currentUser;

                                                  if (user == null) {
                                                    if (!context.mounted)
                                                      return;

                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          'Please login first',
                                                        ),
                                                      ),
                                                    );

                                                    return;
                                                  }

                                                  final productId =
                                                      product['name']!
                                                          .toLowerCase()
                                                          .replaceAll(
                                                            RegExp(
                                                              r'[^a-z0-9]+',
                                                            ),
                                                            '_',
                                                          )
                                                          .replaceAll(
                                                            RegExp(r'^_|_$'),
                                                            '',
                                                          );

                                                  final isCurrentlyWishlisted =
                                                      wishlistedProducts
                                                          .contains(productId);

                                                  // --------------------------------------------------
                                                  // REMOVE FROM WISHLIST
                                                  // --------------------------------------------------

                                                  if (isCurrentlyWishlisted) {
                                                    try {
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(
                                                            'Wishlist',
                                                          )
                                                          .doc(user.uid)
                                                          .collection('items')
                                                          .doc(productId)
                                                          .delete();

                                                      if (!context.mounted)
                                                        return;

                                                      setState(() {
                                                        wishlistedProducts
                                                            .remove(productId);
                                                      });

                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            '${product['name']} removed from wishlist',
                                                          ),
                                                        ),
                                                      );
                                                    } catch (e) {
                                                      debugPrint(
                                                        'REMOVE WISHLIST ERROR: $e',
                                                      );
                                                    }

                                                    return;
                                                  }

                                                  // --------------------------------------------------
                                                  // ADD TO WISHLIST
                                                  // --------------------------------------------------

                                                  try {
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('Wishlist')
                                                        .doc(user.uid)
                                                        .collection('items')
                                                        .doc(productId)
                                                        .set({
                                                          'productId':
                                                              productId,
                                                          'name':
                                                              product['name'],
                                                          'brand':
                                                              product['brand'],
                                                          'image':
                                                              product['image'],
                                                          'price':
                                                              product['price'],
                                                          'addedAt':
                                                              FieldValue.serverTimestamp(),
                                                        });

                                                    if (!context.mounted)
                                                      return;

                                                    setState(() {
                                                      wishlistedProducts.add(
                                                        productId,
                                                      );
                                                    });

                                                    // Show message
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          '${product['name']} added to wishlist',
                                                        ),
                                                      ),
                                                    );

                                                    // --------------------------------------------------
                                                    // GO TO WISHLIST TAB
                                                    // --------------------------------------------------

                                                    widget.onGoToWishlist
                                                        ?.call();
                                                  } catch (e) {
                                                    debugPrint(
                                                      'ADD WISHLIST ERROR: $e',
                                                    );

                                                    if (!context.mounted)
                                                      return;

                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'Failed to add wishlist: $e',
                                                        ),
                                                      ),
                                                    );
                                                  }
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
                                                  size: 22.sp,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 10.h),
                                    Text(
                                      product["brand"]!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Color(0xff57423D),
                                      ),
                                    ),
                                    SizedBox(height: 10.h),

                                    Text(
                                      product["name"]!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),

                                    SizedBox(height: 5.h),

                                    Text(
                                      product["price"]!,
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15.sp,
                                      ),
                                    ),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          await addToCart(product);

                                          if (context.mounted) {
                                            widget.onGoToWishlist?.call();
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xff006971,
                                          ),
                                        ),
                                        child: Text(
                                          "Add to Cart",
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
                            );
                          },
                        ),

                        // Add your dog products here
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
