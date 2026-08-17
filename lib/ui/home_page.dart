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
  final TextEditingController searchController = TextEditingController();

  String searchQuery = '';

  final FirebaseFirestore db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> get categoriesStream {
    return db.collection('categories').snapshots();
  }

  Stream<QuerySnapshot> get productsStream {
    return db.collection('products').snapshots();
  }

  // final List<Map<String, String>> dogProducts = [
  //   {
  //     "image": "assets/Background.png",
  //     "brand": "Kibble & Co",
  //     "name": "Organic Dog Food",
  //     "price": "\$24.99",
  //   },
  //   {
  //     "image": "assets/toy.png",
  //     "brand": "PlaySmart",
  //     "name": "Interactive Bone",
  //     "price": "\$18.50",
  //   },
  //   {
  //     "image": "assets/Background (1).png",
  //     "brand": "PurePurr",
  //     "name": "Cat Wellness Kit",
  //     "price": "\$32.00",
  //   },
  //   {
  //     "image": "assets/Background (2).png",
  //     "brand": "WildWings",
  //     "name": "Modern Feeder",
  //     "price": "\$45.00",
  //   },
  // ];
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
      final productId = product['id'];

      final cartItemRef = FirebaseFirestore.instance
          .collection('carts')
          .doc(user.uid)
          .collection('items')
          .doc(productId);

      final cartItem = await cartItemRef.get();

      if (cartItem.exists) {
        final currentQuantity = (cartItem.data()?['quantity'] ?? 0) as int;

        await cartItemRef.update({'quantity': currentQuantity + 1});
      } else {
        await cartItemRef.set({
          'productId': productId,
          'name': product['name'] ?? '',
          'brand': product['brand'] ?? '',
          'image': product['imageUrl'] ?? '',
          'price': product['price'] ?? 0,
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

  Future<bool> toggleWishlist(Map<String, dynamic> product) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return false;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please login first')));

      return false;
    }

    final String productId = product['id'].toString();

    final bool isCurrentlyWishlisted = wishlistedProducts.contains(productId);

    try {
      final wishlistRef = FirebaseFirestore.instance
          .collection('Wishlist')
          .doc(user.uid)
          .collection('items')
          .doc(productId);

      if (isCurrentlyWishlisted) {
        await wishlistRef.delete();

        if (!mounted) return false;

        setState(() {
          wishlistedProducts.remove(productId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${product['name']} removed from wishlist')),
        );

        return false;
      } else {
        // Convert price safely to a number
        final dynamic priceData = product['price'];

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

        await wishlistRef.set({
          'productId': productId,
          'name': product['name']?.toString() ?? '',
          'brand': product['brand']?.toString() ?? '',
          'image': product['imageUrl']?.toString() ?? '',
          'price': price,
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

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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
                          controller: searchController,
                          keyboardType: TextInputType.text,

                          onChanged: (value) {
                            setState(() {
                              searchQuery = value.trim().toLowerCase();
                            });
                          },

                          decoration: InputDecoration(
                            hintText: 'Search for treats, toys, or food...',
                            hintStyle: TextStyle(fontSize: 12.sp),

                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.grey,
                            ),

                            suffixIcon:
                                searchQuery.isNotEmpty
                                    ? IconButton(
                                      icon: const Icon(
                                        Icons.clear,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () {
                                        searchController.clear();

                                        setState(() {
                                          searchQuery = '';
                                        });
                                      },
                                    )
                                    : null,

                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 10.h,
                            ),
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

                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     Text(
                        //       "Trending Now",
                        //       style: TextStyle(
                        //         fontSize: 14.sp,
                        //         fontWeight: FontWeight.bold,
                        //       ),
                        //     ),
                        //     TextButton(
                        //       onPressed: () {
                        //         final products =
                        //             productSnapshot.data!.docs.map((doc) {
                        //               final data =
                        //                   doc.data() as Map<String, dynamic>;

                        //               return {
                        //                 'id': doc.id,
                        //                 'name': data['name'] ?? '',
                        //                 'brand': data['brand'] ?? '',
                        //                 'imageUrl': data['imageUrl'] ?? '',
                        //                 'price': data['price'] ?? 0,
                        //                 'rating': data['rating'] ?? 0,
                        //                 'category': data['category'] ?? '',
                        //                 'categoryId': data['categoryId'] ?? '',
                        //               };
                        //             }).toList();

                        //         Navigator.push(
                        //           context,
                        //           MaterialPageRoute(
                        //             builder:
                        //                 (context) => ViewAllProductsList(
                        //                   products: products,
                        //                 ),
                        //           ),
                        //         );
                        //       },
                        //       child: Text(
                        //         'View All',
                        //         style: TextStyle(
                        //           fontSize: 12.sp,
                        //           color: const Color(0xffA73927),
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        StreamBuilder<QuerySnapshot>(
                          stream: productsStream,
                          builder: (context, productSnapshot) {
                            if (productSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (productSnapshot.hasError) {
                              return Center(
                                child: Text(
                                  'Error loading products: ${productSnapshot.error}',
                                ),
                              );
                            }

                            if (!productSnapshot.hasData ||
                                productSnapshot.data!.docs.isEmpty) {
                              return const Center(
                                child: Text('No products found'),
                              );
                            }

                            final productDocs = productSnapshot.data!.docs;

                            // Convert Firestore documents to List<Map<String, dynamic>>
                            final allProducts =
                                productDocs.map((doc) {
                                  final data =
                                      doc.data() as Map<String, dynamic>;

                                  return <String, dynamic>{
                                    'id': doc.id,
                                    'name': data['name'] ?? '',
                                    'brand': data['brand'] ?? '',
                                    'imageUrl': data['imageUrl'] ?? '',
                                    'price': data['price'] ?? 0,
                                    'rating': data['rating'] ?? 0,
                                    'category': data['category'] ?? '',
                                    'categoryId': data['categoryId'] ?? '',
                                  };
                                }).toList();

                            // =====================================================
                            // SEARCH PRODUCTS
                            // =====================================================

                            final products =
                                searchQuery.isEmpty
                                    ? allProducts
                                    : allProducts.where((product) {
                                      final name =
                                          product['name']
                                              .toString()
                                              .toLowerCase();

                                      return name.contains(searchQuery);
                                    }).toList();

                            return Column(
                              children: [
                                // =========================
                                // TRENDING NOW HEADER
                                // =========================
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                                (context) =>
                                                    ViewAllProductsList(
                                                      products: products,
                                                    ),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'View All',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: const Color(0xffA73927),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                // =========================
                                // PRODUCTS GRID
                                // =========================
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: products.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 15,
                                        mainAxisSpacing: 15.h,
                                        childAspectRatio: 0.58,
                                      ),
                                  itemBuilder: (context, index) {
                                    final product = products[index];

                                    final productId = product['id'].toString();

                                    final isWishlisted = wishlistedProducts
                                        .contains(productId);

                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => OrganicGrain(
                                                  product: product,
                                                ),
                                          ),
                                        );
                                      },
                                      child: Card(
                                        elevation: 3,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            15.r,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(10.w),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              // IMAGE
                                              SizedBox(
                                                height: 120.h,
                                                width: double.infinity,
                                                child: Stack(
                                                  children: [
                                                    Positioned.fill(
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              15.r,
                                                            ),
                                                        child: Image.network(
                                                          product['imageUrl'] ??
                                                              '',
                                                          fit: BoxFit.cover,
                                                          errorBuilder: (
                                                            context,
                                                            error,
                                                            stackTrace,
                                                          ) {
                                                            return Container(
                                                              color:
                                                                  Colors
                                                                      .grey
                                                                      .shade200,
                                                              child: const Icon(
                                                                Icons
                                                                    .image_not_supported,
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ),

                                                    // WISHLIST
                                                    Positioned(
                                                      top: 8.h,
                                                      right: 8.w,
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              shape:
                                                                  BoxShape
                                                                      .circle,
                                                            ),
                                                        child: IconButton(
                                                          padding:
                                                              EdgeInsets.zero,
                                                          constraints:
                                                              BoxConstraints(
                                                                minWidth: 30.w,
                                                                minHeight: 30.h,
                                                              ),
                                                          onPressed: () async {
                                                            await toggleWishlist(
                                                              product,
                                                            );
                                                          },
                                                          icon: Icon(
                                                            isWishlisted
                                                                ? Icons.favorite
                                                                : Icons
                                                                    .favorite_border,
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

                                              // BRAND
                                              Text(
                                                product['brand']
                                                        .toString()
                                                        .isEmpty
                                                    ? product['category']
                                                        .toString()
                                                    : product['brand']
                                                        .toString(),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color: const Color(
                                                    0xff57423D,
                                                  ),
                                                ),
                                              ),

                                              SizedBox(height: 8.h),

                                              // NAME
                                              Text(
                                                product['name'].toString(),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),

                                              SizedBox(height: 5.h),

                                              // PRICE
                                              Text(
                                                '\$${(product['price'] as num).toDouble().toStringAsFixed(2)}',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15.sp,
                                                ),
                                              ),

                                              const Spacer(),

                                              // ADD TO CART
                                              SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton(
                                                  onPressed: () async {
                                                    await addToCart(product);
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            const Color(
                                                              0xff006971,
                                                            ),
                                                      ),
                                                  child: Text(
                                                    'Add to Cart',
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
                                      ),
                                    );
                                  },
                                ),
                              ],
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
