import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pet_shop_project/ui/organic_grain.dart';
import 'package:pet_shop_project/ui/search_categories.dart';
import 'package:pet_shop_project/ui/view_all_categories.dart';
import 'package:pet_shop_project/ui/view_all_products_list.dart';

import 'wish_list_page.dart';

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

  // ============================================================
  // FIREBASE STREAMS
  // ============================================================

  Stream<QuerySnapshot> get categoriesStream {
    return db.collection('categories').snapshots();
  }

  Stream<QuerySnapshot> get productsStream {
    return db.collection('products').snapshots();
  }

  // ============================================================
  // SAFE NUMBER CONVERSION
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

  double getRating(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value.trim()) ?? 0.0;
    }

    return 0.0;
  }

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

 Future<void> addToCart(Map<String, dynamic> product) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please login first')),
    );

    return;
  }

  try {
    final productId = product['id'].toString();

    final double price = getPrice(product['price']);

    debugPrint('====================================');
    debugPrint('PRODUCT NAME: ${product['name']}');
    debugPrint('ORIGINAL PRICE: ${product['price']}');
    debugPrint('ORIGINAL PRICE TYPE: ${product['price'].runtimeType}');
    debugPrint('CONVERTED PRICE: $price');
    debugPrint('CONVERTED PRICE TYPE: ${price.runtimeType}');
    debugPrint('====================================');

    final cartItemRef = FirebaseFirestore.instance
        .collection('carts')
        .doc(user.uid)
        .collection('items')
        .doc(productId);

    final cartItem = await cartItemRef.get();

    if (cartItem.exists) {
      final data = cartItem.data();

      final currentQuantity = getQuantity(data?['quantity']);

      await cartItemRef.update({
        'quantity': currentQuantity + 1,
        'price': price,
      });
    } else {
      await cartItemRef.set({
        'productId': productId,
        'name': product['name']?.toString() ?? '',
        'brand': product['brand']?.toString() ?? '',
        'image': product['imageUrl']?.toString() ?? '',
        'price': price,
        'quantity': 1,
        'addedAt': FieldValue.serverTimestamp(),
      });
    }

    // READ IT BACK FROM FIRESTORE
    final check = await cartItemRef.get();

    final savedData = check.data();

    debugPrint('====================================');
    debugPrint('FIRESTORE PRICE: ${savedData?['price']}');
    debugPrint(
      'FIRESTORE PRICE TYPE: ${savedData?['price'].runtimeType}',
    );
    debugPrint('====================================');

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product['name']} added to cart'),
      ),
    );
  } catch (e) {
    debugPrint('FIREBASE ERROR: $e');

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to add product: $e'),
      ),
    );
  }
}

  // ============================================================
  // TOGGLE WISHLIST
  // ============================================================

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
          .collection('wishlist')
          .doc(user.uid)
          .collection('items')
          .doc(productId);

      // ========================================================
      // REMOVE FROM WISHLIST
      // ========================================================

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
      }

      // ========================================================
      // ADD TO WISHLIST
      // ========================================================

      final double price = getPrice(product['price']);

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

  // ============================================================
  // LOAD WISHLIST
  // ============================================================

  Future<void> loadWishlist() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('wishlist')
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

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    loadWishlist();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    searchController.dispose();

    super.dispose();
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

            // ==================================================
            // RESPONSIVE VALUES
            // ==================================================

            final bool isLandscape = orientation == Orientation.landscape;

            // final bool isTablet = screenWidth >= 600;

            final double horizontalPadding =
                screenWidth < 400
                    ? 20.w
                    : isLandscape
                    ? 25.w
                    : 30.w;

            final double searchHeight = isLandscape ? 45.h : 40.h;

            return Scaffold(
              // =================================================
              // APP BAR
              // =================================================
              appBar: AppBar(
                automaticallyImplyLeading: false,

                leading: Padding(
                  padding: EdgeInsets.only(left: isLandscape ? 15.w : 20.w),

                  child: CircleAvatar(
                    radius: 25.r,

                    child: ClipOval(
                      child: Image.asset(
                        'assets/Border.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                title: Text(
                  'PetLife',

                  style: TextStyle(
                    fontWeight: FontWeight.w700,

                    fontSize: isLandscape ? 18.sp : 20.sp,

                    color: const Color(0xffA73927),
                  ),
                ),

                actions: [
                  Padding(
                    padding: EdgeInsets.only(right: isLandscape ? 20.w : 30.w),

                    child: Icon(
                      Icons.shopping_cart_outlined,

                      color: const Color(0xffA73927),

                      size: 25.sp,
                    ),
                  ),
                ],
              ),

              // =================================================
              // BODY
              // =================================================
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        SizedBox(height: isLandscape ? 15.h : 30.h),

                        // =======================================
                        // WELCOME
                        // =======================================
                        Text(
                          'Welcome back,',

                          style: TextStyle(
                            fontWeight: FontWeight.w500,

                            fontSize: isLandscape ? 11.sp : 12.sp,

                            color: const Color(0xff57423D),
                          ),
                        ),

                        SizedBox(height: 6.h),

                        Text(
                          'Hello, Pet Lover!',

                          maxLines: 1,

                          overflow: TextOverflow.ellipsis,

                          style: TextStyle(
                            fontWeight: FontWeight.w600,

                            fontSize: isLandscape ? 16.sp : 18.sp,
                          ),
                        ),

                        SizedBox(height: isLandscape ? 12.h : 20.h),

                        // =======================================
                        // SEARCH BAR
                        // =======================================
                        Container(
                          height: searchHeight,

                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),

                            color: const Color.fromARGB(136, 158, 158, 158),
                          ),

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

                              hintStyle: TextStyle(
                                fontSize: isLandscape ? 11.sp : 12.sp,
                              ),

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

                        SizedBox(height: isLandscape ? 15.h : 20.h),

                        // =======================================
                        // CATEGORY HEADER
                        // =======================================
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Shop by Category',

                                maxLines: 1,

                                overflow: TextOverflow.ellipsis,

                                style: TextStyle(
                                  fontWeight: FontWeight.w600,

                                  fontSize: isLandscape ? 16.sp : 18.sp,
                                ),
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

                                  color: const Color(0xffA73927),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 10.h),

                        // =======================================
                        // CATEGORIES
                        // =======================================
                        SizedBox(
                          height: isLandscape ? 90 : 90,
                          width: double.infinity,

                          child: StreamBuilder<QuerySnapshot>(
                            stream: categoriesStream,

                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              if (snapshot.hasError) {
                                return Center(
                                  child: Text('Error: ${snapshot.error}'),
                                );
                              }

                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return const Center(
                                  child: Text('No categories found'),
                                );
                              }

                              final categories = snapshot.data!.docs;

                              return ListView.separated(
                                scrollDirection: Axis.horizontal,

                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                ),

                                itemCount: categories.length,

                                separatorBuilder: (context, index) {
                                  return const SizedBox(width: 6);
                                },

                                itemBuilder: (context, index) {
                                  final data =
                                      categories[index].data()
                                          as Map<String, dynamic>;

                                  final categoryName =
                                      data['name']?.toString() ?? '';

                                  final imageUrl =
                                      data['imageUrl']?.toString() ?? '';

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => SearchCategories(
                                                title: categoryName,
                                                categoryId:
                                                    categories[index].id,
                                              ),
                                        ),
                                      );
                                    },

                                    child: SizedBox(
                                      width: isLandscape ? 100 : 95,

                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // ==========================================
                                          // CATEGORY IMAGE
                                          // ==========================================
                                          SizedBox(
                                            width: isLandscape ? 58 : 60,
                                            height: isLandscape ? 58 : 60,

                                            child: ClipOval(
                                              child:
                                                  imageUrl.isNotEmpty
                                                      ? Image.network(
                                                        imageUrl,
                                                        width:
                                                            isLandscape
                                                                ? 58
                                                                : 60,
                                                        height:
                                                            isLandscape
                                                                ? 58
                                                                : 60,
                                                        fit: BoxFit.cover,

                                                        loadingBuilder: (
                                                          context,
                                                          child,
                                                          loadingProgress,
                                                        ) {
                                                          if (loadingProgress ==
                                                              null) {
                                                            return child;
                                                          }

                                                          return Container(
                                                            color:
                                                                Colors
                                                                    .grey
                                                                    .shade200,
                                                            child: const Center(
                                                              child:
                                                                  CircularProgressIndicator(
                                                                    strokeWidth:
                                                                        2,
                                                                  ),
                                                            ),
                                                          );
                                                        },

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
                                                              Icons.pets,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          );
                                                        },
                                                      )
                                                      : Container(
                                                        color:
                                                            Colors
                                                                .grey
                                                                .shade200,
                                                        child: const Icon(
                                                          Icons.pets,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                            ),
                                          ),

                                          // ==========================================
                                          // SMALL SPACE
                                          // ==========================================
                                          SizedBox(height: 2.h),

                                          // ==========================================
                                          // CATEGORY NAME
                                          // ==========================================
                                          Text(
                                            categoryName,

                                            maxLines: 2,

                                            overflow: TextOverflow.ellipsis,

                                            textAlign: TextAlign.center,

                                            style: TextStyle(
                                              fontSize:
                                                  isLandscape ? 10.sp : 11.sp,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                              height: 1.1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),

                        SizedBox(height: 0),
                        // =======================================
                        // FEATURED BANNER

                        // =======================================
                        // FEATURED BANNER
                        // =======================================
                        AspectRatio(
                          aspectRatio: 2.2,

                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15.r),

                            child: Image.asset(
                              "assets/Section - Featured Banner.png",
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        SizedBox(height: isLandscape ? 10.h : 15.h),

                        // =======================================
                        // PRODUCTS
                        // =======================================
                        buildProducts(context, isLandscape),

                        SizedBox(height: 30.h),
                      ],
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
  // CATEGORY COUNT
  // ============================================================

  // ============================================================
  // CATEGORY ITEM
  // ============================================================

  // Widget categoryItem(BuildContext context, int index) {
  //   return StreamBuilder<QuerySnapshot>(
  //     stream: categoriesStream,

  //     builder: (context, snapshot) {
  //       if (!snapshot.hasData) {
  //         return const SizedBox();
  //       }

  //       final categories = snapshot.data!.docs;

  //       if (index >= categories.length) {
  //         return const SizedBox();
  //       }

  //       final data = categories[index].data() as Map<String, dynamic>;

  //       return GestureDetector(
  //         onTap: () {
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //               builder:
  //                   (_) => SearchCategories(
  //                     title: data['name']?.toString() ?? '',

  //                     categoryId: categories[index].id,
  //                   ),
  //             ),
  //           );
  //         },

  //         child: SizedBox(
  //           width: 75.w,

  //           child: Padding(
  //             padding: EdgeInsets.symmetric(horizontal: 5.w),

  //             child: Column(
  //               mainAxisAlignment: MainAxisAlignment.center,

  //               children: [
  //                 CircleAvatar(
  //                   radius: 27.r,

  //                   backgroundColor: Colors.grey.shade300,

  //                   backgroundImage: NetworkImage(
  //                     data['imageUrl']?.toString() ?? '',
  //                   ),
  //                 ),

  //                 SizedBox(height: 7.h),

  //                 Text(
  //                   data['name']?.toString() ?? '',

  //                   maxLines: 1,

  //                   overflow: TextOverflow.ellipsis,

  //                   textAlign: TextAlign.center,

  //                   style: TextStyle(fontSize: 11.sp, color: Colors.black),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  // ============================================================
  // PRODUCTS
  // ============================================================

  Widget buildProducts(BuildContext context, bool isLandscape) {
    return StreamBuilder<QuerySnapshot>(
      stream: productsStream,

      builder: (context, productSnapshot) {
        if (productSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (productSnapshot.hasError) {
          return Center(
            child: Text('Error loading products: ${productSnapshot.error}'),
          );
        }

        if (!productSnapshot.hasData || productSnapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No products found'));
        }

        final productDocs = productSnapshot.data!.docs;

        // ======================================================
        // CONVERT FIRESTORE DATA
        // ======================================================

        final allProducts =
            productDocs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;

              return <String, dynamic>{
                'id': doc.id,

                'name': data['name']?.toString() ?? '',

                'brand': data['brand']?.toString() ?? '',

                'imageUrl': data['imageUrl']?.toString() ?? '',

                // Keep original value.
                // getPrice() will safely convert it.
                'price': data['price'] ?? 0,

                'rating': data['rating'] ?? 0,

                'category': data['category']?.toString() ?? '',

                'categoryId': data['categoryId']?.toString() ?? '',
              };
            }).toList();

        // ======================================================
        // SEARCH
        // ======================================================

        final products =
            searchQuery.isEmpty
                ? allProducts
                : allProducts.where((product) {
                  final name = product['name'].toString().toLowerCase();

                  return name.contains(searchQuery);
                }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ==================================================
            // HEADER
            // ==================================================
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Trending Now',

                    maxLines: 1,

                    overflow: TextOverflow.ellipsis,

                    style: TextStyle(
                      fontSize: isLandscape ? 15.sp : 16.sp,

                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                ViewAllProductsList(products: products),
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

            SizedBox(height: 5.h),

            // ==================================================
            // RESPONSIVE GRID
            // ==================================================
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;

                int crossAxisCount;

                if (width >= 1200) {
                  crossAxisCount = 5;
                } else if (width >= 900) {
                  crossAxisCount = 4;
                } else if (width >= 600) {
                  crossAxisCount = 3;
                } else {
                  crossAxisCount = 2;
                }

                // Card height
                double cardHeight;

                if (width < 500) {
                  cardHeight = 375;
                } else if (width < 700) {
                  cardHeight = 365;
                } else if (width < 1000) {
                  cardHeight = 375;
                } else {
                  cardHeight = 395;
                }
                return GridView.builder(
                  shrinkWrap: true,

                  physics: const NeverScrollableScrollPhysics(),

                  itemCount: products.length,

                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,

                    crossAxisSpacing: 12.w,

                    mainAxisSpacing: 15.h,

                    // IMPORTANT:
                    // Instead of childAspectRatio,
                    // use a fixed card height.
                    mainAxisExtent: cardHeight,
                  ),

                  itemBuilder: (context, index) {
                    final product = products[index];

                    return buildProductCard(context, product, isLandscape);
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // PRODUCT CARD
  // ============================================================

  Widget buildProductCard(
    BuildContext context,
    Map<String, dynamic> product,
    bool isLandscape,
  ) {
    final productId = product['id'].toString();

    final isWishlisted = wishlistedProducts.contains(productId);

    final double price = getPrice(product['price']);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrganicGrain(product: product),
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
              // ==================================================
              // PRODUCT IMAGE
              // ==================================================
              SizedBox(
                width: double.infinity,

                // Slightly smaller image gives more room
                // for brand + product name + button.
                height: isLandscape ? 120 : 140,

                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),

                        child: Image.network(
                          product['imageUrl']?.toString() ?? '',

                          fit: BoxFit.cover,

                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,

                              child: Icon(
                                Icons.image_not_supported,

                                color: Colors.grey,

                                size: 30.sp,
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // ==================================================
                    // WISHLIST
                    // ==================================================
                    Positioned(
                      top: 5,
                      right: 5,

                      child: Material(
                        color: Colors.white,

                        shape: const CircleBorder(),

                        child: SizedBox(
                          width: 32,
                          height: 32,

                          child: IconButton(
                            padding: EdgeInsets.zero,

                            onPressed: () async {
                              await toggleWishlist(product);
                            },

                            icon: Icon(
                              isWishlisted
                                  ? Icons.favorite
                                  : Icons.favorite_border,

                              color:
                                  isWishlisted
                                      ? Colors.red
                                      : const Color(0xffA73927),

                              size: 19.sp,
                            ),
                          ),
                        ),
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
              // BRAND
              // ==================================================
              SizedBox(
                width: double.infinity,

                // Increased from 22 → 28
                height: 28,

                child: Text(
                  product['brand']?.toString().trim().isNotEmpty == true
                      ? product['brand'].toString()
                      : product['category']?.toString() ?? '',

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

              // ==================================================
              // SPACE BETWEEN BRAND AND NAME
              // ==================================================
              SizedBox(height: 4.h),

              // ==================================================
              // PRODUCT NAME
              // ==================================================
              SizedBox(
                width: double.infinity,

                // Increased from 42 → 50
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
              SizedBox(height: 6.h),

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
                      color: const Color(0xffA73927),

                      fontWeight: FontWeight.bold,

                      fontSize: isLandscape ? 13.sp : 15.sp,
                    ),
                  ),
                ),
              ),

              // ==================================================
              // EXTRA SPACE BEFORE BUTTON
              // ==================================================
              SizedBox(height: 8.h),

              // ==================================================
              // ADD TO CART
              // ==================================================
              SizedBox(
                width: double.infinity,

                // Slightly taller button
                height: isLandscape ? 36 : 40,

                child: ElevatedButton(
                  onPressed: () async {
                    await addToCart(product);
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff006971),

                    padding: EdgeInsets.zero,

                    minimumSize: Size.zero,

                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
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
      ),
    );
  }
}
