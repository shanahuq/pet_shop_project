import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pet_shop_project/ui/organic_grain.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewAllProductsList extends StatelessWidget {
  final List<Map<String, dynamic>> products;

  const ViewAllProductsList({super.key, required this.products});
  Future<void> addToCart(
    BuildContext context,
    Map<String, dynamic> product,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please login first')));
        return;
      }

      final productId = product['id']?.toString();

      if (productId == null || productId.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Product ID is missing')));
        return;
      }

      final cartItemRef = FirebaseFirestore.instance
          .collection('carts')
          .doc(user.uid)
          .collection('items')
          .doc(productId);

      final existingItem = await cartItemRef.get();

      if (existingItem.exists) {
        // Product already exists
        final data = existingItem.data();

        final currentQuantity = (data?['quantity'] as num?)?.toInt() ?? 1;

        await cartItemRef.update({'quantity': currentQuantity + 1});
      } else {
        // Add new product
        await cartItemRef.set({
          'productId': productId,
          'name': product['name']?.toString() ?? '',
          'brand': product['brand']?.toString() ?? '',
          'category': product['category']?.toString() ?? '',
          'image': product['imageUrl']?.toString() ?? '',
          'price': product['price'] ?? 0,
          'quantity': 1,
          'addedAt': FieldValue.serverTimestamp(),
        });
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product['name'] ?? 'Product'} added to cart'),
          ),
        );
      }
    } catch (e) {
      print('ADD TO CART ERROR: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to add to cart: $e')));
      }
    }
  }

  Future<void> toggleWishlist(
    BuildContext context,
    Map<String, dynamic> product,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please login first')));
        return;
      }

      final productId = product['id']?.toString();

      if (productId == null || productId.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Product ID is missing')));
        return;
      }

      final wishlistItemRef = FirebaseFirestore.instance
          .collection('wishlist')
          .doc(user.uid)
          .collection('items')
          .doc(productId);

      final existingItem = await wishlistItemRef.get();

      if (existingItem.exists) {
        // Remove from wishlist
        await wishlistItemRef.delete();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Removed from wishlist')),
          );
        }
      } else {
        // Add to wishlist
        await wishlistItemRef.set({
          'productId': productId,
          'name': product['name']?.toString() ?? '',
          'brand': product['brand']?.toString() ?? '',
          'category': product['category']?.toString() ?? '',
          'image': product['imageUrl']?.toString() ?? '',
          'price': product['price'] ?? 0,
          'addedAt': FieldValue.serverTimestamp(),
        });

        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Added to wishlist ❤️')));
        }
      }
    } catch (e) {
      print('WISHLIST ERROR: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Wishlist error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All Products',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xffA73927),
          ),
        ),
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(20.w),
        itemCount: products.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15.w,
          mainAxisSpacing: 15.h,
          childAspectRatio: 0.58,
        ),
        itemBuilder: (context, index) {
          final product = products[index];
          final brand = product["brand"]?.toString().trim();
          final category = product["category"]?.toString().trim();

          print("PRODUCT $index");
          print(product);
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(10.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 120.h,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15.r),
                            child: Image.network(
                              product["imageUrl"]?.toString() ?? "",
                              fit: BoxFit.cover,
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) {
                                  return child;
                                }

                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade200,
                                  child: const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        // ❤️ Favorite button
                        Positioned(
                          top: 8.h,
                          right: 8.w,
                          child: Container(
                            width: 38.w,
                            height: 38.w,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                            child: StreamBuilder<DocumentSnapshot>(
                              stream:
                                  FirebaseAuth.instance.currentUser == null
                                      ? null
                                      : FirebaseFirestore.instance
                                          .collection('wishlist')
                                          .doc(
                                            FirebaseAuth
                                                .instance
                                                .currentUser!
                                                .uid,
                                          )
                                          .collection('items')
                                          .doc(product['id']?.toString())
                                          .snapshots(),
                              builder: (context, snapshot) {
                                final isWishlisted =
                                    snapshot.data?.exists ?? false;

                                return IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    toggleWishlist(context, product);
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
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 10.h),

                    Text(
                      brand != null && brand.isNotEmpty
                          ? brand
                          : category ?? "Category unavailable",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xff57423D),
                      ),
                    ),

                    SizedBox(height: 10.h),

                    Text(
                      product["name"]?.toString() ?? "Unnamed Product",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: 5.h),

                    Text(
                      product["price"]?.toString() ?? "Price unavailable",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,
                      ),
                    ),

                    SizedBox(height: 5.h),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          addToCart(context, product);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff006971),
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
            ),
          );
        },
      ),
    );
  }
}
