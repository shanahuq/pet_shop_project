import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pet_shop_project/ui/organic_grain.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController addressController = TextEditingController();

  final TextEditingController cityController = TextEditingController();

  final TextEditingController phoneController = TextEditingController();

  String selectedPayment = 'Cash on Delivery';

  bool isPlacingOrder = false;

  // Shipping fee
  final double shippingFee = 5.00;

  @override
  void dispose() {
    addressController.dispose();
    cityController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  // ============================================================
  // GET CART
  // ============================================================

  Stream<QuerySnapshot> get cartStream {
    final user = _auth.currentUser;

    if (user == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('carts')
        .doc(user.uid)
        .collection('items')
        .snapshots();
  }

  // ============================================================
  // CONVERT PRICE SAFELY
  // ============================================================

  double getPrice(dynamic priceData) {
    if (priceData is num) {
      return priceData.toDouble();
    }

    if (priceData is String) {
      return double.tryParse(
            priceData.replaceAll('\$', '').replaceAll(',', '').trim(),
          ) ??
          0.0;
    }

    return 0.0;
  }

  // ============================================================
  // OPEN PRODUCT DETAIL PAGE
  // ============================================================

  Future<void> openProductDetails(Map<String, dynamic> cartData) async {
    try {
      // ----------------------------------------------------------
      // Get the original product document ID
      // ----------------------------------------------------------

      final String productDocId =
          cartData['productDocId']?.toString() ??
          cartData['productId']?.toString() ??
          '';

      if (productDocId.isEmpty) {
        showMessage('Product information is not available.');
        return;
      }

      // ----------------------------------------------------------
      // Get original product from Firestore
      // ----------------------------------------------------------

      final DocumentSnapshot productSnapshot =
          await _firestore.collection('products').doc(productDocId).get();

      if (!productSnapshot.exists) {
        showMessage('Product details could not be found.');
        return;
      }

      final Map<String, dynamic> data =
          productSnapshot.data() as Map<String, dynamic>;

      // ----------------------------------------------------------
      // Create complete product map
      //
      // This is important because OrganicGrain needs
      // price2kg, price5kg and price10kg.
      // ----------------------------------------------------------

      final Map<String, dynamic> product = {
        // Firestore document ID
        'id': productSnapshot.id,

        // Product ID
        'productId':
            data['productId'] ?? cartData['productId'] ?? productSnapshot.id,

        // Product document ID
        'productDocId': productSnapshot.id,

        // Name
        'name': data['name'] ?? cartData['name'] ?? '',

        // Brand
        'brand': data['brand'] ?? cartData['brand'] ?? '',

        // Category
        'category': data['category'] ?? cartData['category'] ?? '',

        // Image
        'imageUrl':
            data['imageUrl'] ?? cartData['imageUrl'] ?? cartData['image'] ?? '',

        // --------------------------------------------------------
        // WEIGHT PRICES
        // --------------------------------------------------------
        'price2kg': data['price2kg'] ?? data['price2Kg'] ?? 0,

        'price5kg': data['price5kg'] ?? data['price5Kg'] ?? 0,

        'price10kg': data['price10kg'] ?? data['price10Kg'] ?? 0,

        // Default price = 2kg
        'price': data['price2kg'] ?? data['price2Kg'] ?? cartData['price'] ?? 0,

        // Rating
        'rating': data['rating'] ?? cartData['rating'] ?? 0,

        // Other product fields from Firestore
        ...data,
      };

      if (!mounted) return;

      // ----------------------------------------------------------
      // OPEN ORGANIC GRAIN DETAIL PAGE
      // ----------------------------------------------------------

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OrganicGrain(product: product)),
      );
    } catch (e) {
      debugPrint('OPEN PRODUCT DETAILS ERROR: $e');

      if (!mounted) return;

      showMessage('Unable to open product details.');
    }
  }

  // ============================================================
  // PLACE ORDER
  // ============================================================

  Future<void> placeOrder(List<QueryDocumentSnapshot> cartItems) async {
    final user = _auth.currentUser;

    if (user == null) {
      showMessage('Please login first');
      return;
    }

    // Validate address
    if (addressController.text.trim().isEmpty) {
      showMessage('Please enter your delivery address');
      return;
    }

    if (cityController.text.trim().isEmpty) {
      showMessage('Please enter your city');
      return;
    }

    if (phoneController.text.trim().isEmpty) {
      showMessage('Please enter your phone number');
      return;
    }

    if (cartItems.isEmpty) {
      showMessage('Your cart is empty');
      return;
    }

    setState(() {
      isPlacingOrder = true;
    });

    try {
      double subtotal = 0;

      List<Map<String, dynamic>> orderItems = [];

      for (final doc in cartItems) {
        final data = doc.data() as Map<String, dynamic>;

        final double price = getPrice(data['price']);

        final int quantity = (data['quantity'] as num?)?.toInt() ?? 1;

        subtotal += price * quantity;

        orderItems.add({
          'productId': data['productId'] ?? doc.id,

          'productDocId': data['productDocId'] ?? doc.id,

          'name': data['name'] ?? '',

          'brand': data['brand'] ?? '',

          'image': data['image'] ?? '',

          'imageUrl': data['imageUrl'] ?? data['image'] ?? '',

          'price': price,

          'weight': data['weight'] ?? '2kg',

          'quantity': quantity,
        });
      }

      final double total = subtotal + shippingFee;

      // ========================================================
      // CREATE ORDER
      // ========================================================

      final orderRef = _firestore.collection('orders').doc();

      await orderRef.set({
        'orderId': orderRef.id,

        'userId': user.uid,

        'items': orderItems,

        'subtotal': subtotal,

        'shipping': shippingFee,

        'total': total,

        'paymentMethod': selectedPayment,

        'deliveryAddress': addressController.text.trim(),

        'city': cityController.text.trim(),

        'phone': phoneController.text.trim(),

        'status': 'Pending',

        'createdAt': FieldValue.serverTimestamp(),
      });

      // ========================================================
      // DELETE CART ITEMS
      // ========================================================

      final batch = _firestore.batch();

      for (final doc in cartItems) {
        batch.delete(
          _firestore
              .collection('carts')
              .doc(user.uid)
              .collection('items')
              .doc(doc.id),
        );
      }

      await batch.commit();

      if (!mounted) return;

      setState(() {
        isPlacingOrder = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order placed successfully!'),
          backgroundColor: Color(0xff006971),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      debugPrint('PLACE ORDER ERROR: $e');

      if (!mounted) return;

      setState(() {
        isPlacingOrder = false;
      });

      showMessage('Failed to place order: $e');
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // ============================================================
  // PAYMENT OPTION
  // ============================================================

  Widget paymentOption({required String title, required IconData icon}) {
    final bool selected = selectedPayment == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPayment = title;
        });
      },

      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),

        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 14.h),

        decoration: BoxDecoration(
          color: selected ? const Color(0xfffff3f0) : Colors.white,

          borderRadius: BorderRadius.circular(14.r),

          border: Border.all(
            color: selected ? const Color(0xffA73927) : const Color(0xffDFC0BA),

            width: selected ? 1.5 : 1,
          ),
        ),

        child: Row(
          children: [
            Icon(icon, color: const Color(0xffA73927), size: 24.sp),

            SizedBox(width: 12.w),

            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
            ),

            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,

              color: selected ? const Color(0xffA73927) : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please login first')));
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined),

          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: Text(
          'Checkout',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20.sp,
            color: const Color(0xffA73927),
          ),
        ),

        centerTitle: true,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: cartStream,

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

          // ======================================================
          // CALCULATE SUBTOTAL
          // ======================================================

          double subtotal = 0;

          for (final doc in cartItems) {
            final data = doc.data() as Map<String, dynamic>;

            final double price = getPrice(data['price']);

            final int quantity = (data['quantity'] as num?)?.toInt() ?? 1;

            subtotal += price * quantity;
          }

          final double total = subtotal + shippingFee;

          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 15.h),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // =================================================
                  // DELIVERY ADDRESS
                  // =================================================
                  sectionTitle(
                    icon: Icons.location_on_outlined,
                    title: 'Delivery Address',
                  ),

                  SizedBox(height: 12.h),

                  checkoutTextField(
                    controller: addressController,
                    hint: 'Street address',
                    icon: Icons.home_outlined,
                  ),

                  SizedBox(height: 10.h),

                  checkoutTextField(
                    controller: cityController,
                    hint: 'City',
                    icon: Icons.location_city_outlined,
                  ),

                  SizedBox(height: 10.h),

                  checkoutTextField(
                    controller: phoneController,
                    hint: 'Phone number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),

                  SizedBox(height: 25.h),

                  // =================================================
                  // PAYMENT METHOD
                  // =================================================
                  sectionTitle(
                    icon: Icons.payment_outlined,
                    title: 'Payment Method',
                  ),

                  SizedBox(height: 12.h),

                  paymentOption(
                    title: 'Cash on Delivery',
                    icon: Icons.money_outlined,
                  ),

                  paymentOption(
                    title: 'Credit / Debit Card',
                    icon: Icons.credit_card_outlined,
                  ),

                  paymentOption(
                    title: 'UPI',
                    icon: Icons.account_balance_outlined,
                  ),

                  SizedBox(height: 20.h),

                  // =================================================
                  // ORDER SUMMARY
                  // =================================================
                  sectionTitle(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Order Summary',
                  ),

                  SizedBox(height: 12.h),

                  Container(
                    padding: EdgeInsets.all(15.w),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius: BorderRadius.circular(16.r),

                      border: Border.all(color: const Color(0xffDFC0BA)),
                    ),

                    child: Column(
                      children: [
                        // =================================================
                        // CART PRODUCTS
                        // =================================================
                        ListView.builder(
                          shrinkWrap: true,

                          physics: const NeverScrollableScrollPhysics(),

                          itemCount: cartItems.length,

                          itemBuilder: (context, index) {
                            final data =
                                cartItems[index].data() as Map<String, dynamic>;

                            final double price = getPrice(data['price']);

                            final int quantity =
                                (data['quantity'] as num?)?.toInt() ?? 1;

                            final double itemTotal = price * quantity;

                            return GestureDetector(
                              // =================================================
                              // CLICK PRODUCT
                              // =================================================
                              onTap: () {
                                openProductDetails(data);
                              },

                              child: Container(
                                margin: EdgeInsets.only(bottom: 12.h),

                                padding: EdgeInsets.symmetric(vertical: 5.h),

                                child: Row(
                                  children: [
                                    // =========================================
                                    // IMAGE
                                    // =========================================
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10.r),

                                      child: Image.network(
                                        data['imageUrl']?.toString() ??
                                            data['image']?.toString() ??
                                            '',

                                        width: 55.w,

                                        height: 55.w,

                                        fit: BoxFit.cover,

                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return Container(
                                            width: 55.w,
                                            height: 55.w,
                                            color: Colors.grey.shade200,
                                            child: const Icon(
                                              Icons.image_not_supported,
                                              color: Colors.grey,
                                            ),
                                          );
                                        },
                                      ),
                                    ),

                                    SizedBox(width: 12.w),

                                    // =========================================
                                    // PRODUCT NAME
                                    // =========================================
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,

                                        children: [
                                          Text(
                                            data['name']?.toString() ?? '',

                                            maxLines: 2,

                                            overflow: TextOverflow.ellipsis,

                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13.sp,
                                            ),
                                          ),

                                          SizedBox(height: 3.h),

                                          Text(
                                            'Qty: $quantity',

                                            style: TextStyle(
                                              fontSize: 11.sp,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // =========================================
                                    // PRICE
                                    // =========================================
                                    Text(
                                      '\$${itemTotal.toStringAsFixed(2)}',

                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13.sp,
                                        color: const Color(0xffA73927),
                                      ),
                                    ),

                                    SizedBox(width: 8.w),

                                    // =========================================
                                    // ARROW
                                    // =========================================
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 14.sp,
                                      color: const Color(0xffA73927),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        const Divider(),

                        SizedBox(height: 10.h),

                        // =================================================
                        // SUBTOTAL
                        // =================================================
                        summaryRow(
                          'Subtotal',
                          '\$${subtotal.toStringAsFixed(2)}',
                        ),

                        SizedBox(height: 8.h),

                        // =================================================
                        // SHIPPING
                        // =================================================
                        summaryRow(
                          'Shipping',
                          '\$${shippingFee.toStringAsFixed(2)}',
                        ),

                        SizedBox(height: 10.h),

                        const Divider(),

                        SizedBox(height: 10.h),

                        // =================================================
                        // TOTAL
                        // =================================================
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [
                            Text(
                              'Total',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 18.sp,
                              ),
                            ),

                            Text(
                              '\$${total.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 18.sp,
                                color: const Color(0xffA73927),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 30.h),

                  // =================================================
                  // PLACE ORDER
                  // =================================================
                  SizedBox(
                    width: double.infinity,

                    height: 55.h,

                    child: ElevatedButton(
                      onPressed:
                          isPlacingOrder
                              ? null
                              : () {
                                placeOrder(cartItems);
                              },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffA73927),

                        disabledBackgroundColor: Colors.grey,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),

                      child:
                          isPlacingOrder
                              ? const SizedBox(
                                width: 25,
                                height: 25,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : Row(
                                mainAxisAlignment: MainAxisAlignment.center,

                                children: [
                                  Text(
                                    'Place Order',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16.sp,
                                    ),
                                  ),

                                  SizedBox(width: 10.w),

                                  const Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                    ),
                  ),

                  SizedBox(height: 30.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ===============================================================
  // SECTION TITLE
  // ===============================================================

  Widget sectionTitle({required IconData icon, required String title}) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xffA73927), size: 23.sp),

        SizedBox(width: 8.w),

        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 19.sp,
            color: const Color(0xff1B1C1C),
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // TEXT FIELD
  // ===============================================================

  Widget checkoutTextField({
    required TextEditingController controller,

    required String hint,

    required IconData icon,

    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,

      keyboardType: keyboardType,

      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xffA73927)),

        hintText: hint,

        filled: true,

        fillColor: Colors.white,

        contentPadding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),

          borderSide: const BorderSide(color: Color(0xffDFC0BA)),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),

          borderSide: const BorderSide(color: Color(0xffDFC0BA)),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),

          borderSide: const BorderSide(color: Color(0xffA73927)),
        ),
      ),
    );
  }

  // ===============================================================
  // SUMMARY ROW
  // ===============================================================

  Widget summaryRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [
        Text(
          title,
          style: TextStyle(fontSize: 14.sp, color: const Color(0xff57423D)),
        ),

        Text(
          value,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
