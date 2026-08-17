import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please login first')));
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Order History',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xffA73927),
          ),
        ),
        centerTitle: true,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream:
            _firestore
                .collection('orders')
                .where('userId', isEqualTo: user.uid)
                .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            debugPrint('ORDER HISTORY ERROR: ${snapshot.error}');

            return Center(
              child: Padding(
                padding: EdgeInsets.all(25.w),
                child: Text(
                  'Error loading orders:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          debugPrint('==============================');
          debugPrint('ORDER HISTORY TEST');
          debugPrint('CURRENT UID: ${user.uid}');
          debugPrint('ORDER COUNT: ${snapshot.data?.docs.length}');
          debugPrint('==============================');

          if (snapshot.hasData) {
            for (final doc in snapshot.data!.docs) {
              debugPrint('ORDER ID: ${doc.id}');
              debugPrint('ORDER DATA: ${doc.data()}');
            }
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _emptyOrders();
          }

          final orders = snapshot.data!.docs;

          // Sort newest orders first
          orders.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;

            final bData = b.data() as Map<String, dynamic>;

            final Timestamp? aTime = aData['createdAt'] as Timestamp?;

            final Timestamp? bTime = bData['createdAt'] as Timestamp?;

            if (aTime == null && bTime == null) {
              return 0;
            }

            if (aTime == null) {
              return 1;
            }

            if (bTime == null) {
              return -1;
            }

            return bTime.compareTo(aTime);
          });

          return ListView.builder(
            padding: EdgeInsets.all(20.w),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final doc = orders[index];

              final data = doc.data() as Map<String, dynamic>;

              return _orderCard(context, data);
            },
          );
        },
      ),
    );
  }

  // ============================================================
  // ORDER CARD
  // ============================================================

  Widget _orderCard(BuildContext context, Map<String, dynamic> data) {
    final String orderId = data['orderId']?.toString() ?? '';

    final String status = data['status']?.toString() ?? 'Pending';

    final String paymentMethod = data['paymentMethod']?.toString() ?? '';

    final String deliveryAddress = data['deliveryAddress']?.toString() ?? '';

    final String city = data['city']?.toString() ?? '';

    final String phone = data['phone']?.toString() ?? '';

    final double subtotal = (data['subtotal'] as num?)?.toDouble() ?? 0;

    final double shipping = (data['shipping'] as num?)?.toDouble() ?? 0;

    final double total = (data['total'] as num?)?.toDouble() ?? 0;

    final Timestamp? createdAt = data['createdAt'] as Timestamp?;

    final List<dynamic> items = data['items'] as List<dynamic>? ?? [];

    String dateText = 'Date unavailable';

    if (createdAt != null) {
      final date = createdAt.toDate();

      dateText =
          '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    }

    return Container(
      margin: EdgeInsets.only(bottom: 18.h),
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xffDFC0BA)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==================================================
          // ORDER HEADER
          // ==================================================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Order #${orderId.length > 8 ? orderId.substring(0, 8) : orderId}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              _statusWidget(status),
            ],
          ),

          SizedBox(height: 5.h),

          Text(dateText, style: TextStyle(fontSize: 12.sp, color: Colors.grey)),

          SizedBox(height: 15.h),

          const Divider(),

          SizedBox(height: 10.h),

          // ==================================================
          // PRODUCTS
          // ==================================================
          Text(
            'Items',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),

          SizedBox(height: 10.h),

          ...items.map((item) {
            final itemData = item as Map<String, dynamic>;

            final String name = itemData['name']?.toString() ?? '';

            final String image = itemData['image']?.toString() ?? '';

            final double price = (itemData['price'] as num?)?.toDouble() ?? 0;

            final int quantity = (itemData['quantity'] as num?)?.toInt() ?? 1;

            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Row(
                children: [
                  // PRODUCT IMAGE
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: Image.network(
                      image,
                      width: 55.w,
                      height: 55.w,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
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

                  // PRODUCT NAME
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        SizedBox(height: 4.h),

                        Text(
                          'Qty: $quantity',
                          style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  Text(
                    '\$${(price * quantity).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xffA73927),
                    ),
                  ),
                ],
              ),
            );
          }),

          const Divider(),

          SizedBox(height: 10.h),

          // ==================================================
          // DELIVERY ADDRESS
          // ==================================================
          Text(
            'Delivery Address',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),

          SizedBox(height: 8.h),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on_outlined,
                color: const Color(0xffA73927),
                size: 20.sp,
              ),

              SizedBox(width: 8.w),

              Expanded(
                child: Text(
                  '$deliveryAddress, $city',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xff57423D),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 6.h),

          Row(
            children: [
              Icon(
                Icons.phone_outlined,
                color: const Color(0xffA73927),
                size: 18.sp,
              ),

              SizedBox(width: 8.w),

              Text(
                phone,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: const Color(0xff57423D),
                ),
              ),
            ],
          ),

          SizedBox(height: 15.h),

          // ==================================================
          // PAYMENT
          // ==================================================
          Row(
            children: [
              Icon(
                Icons.payment_outlined,
                color: const Color(0xffA73927),
                size: 20.sp,
              ),

              SizedBox(width: 8.w),

              Expanded(
                child: Text(
                  paymentMethod,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xff57423D),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 15.h),

          const Divider(),

          SizedBox(height: 10.h),

          // ==================================================
          // PRICE
          // ==================================================
          _summaryRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),

          SizedBox(height: 6.h),

          _summaryRow('Shipping', '\$${shipping.toStringAsFixed(2)}'),

          SizedBox(height: 10.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700),
              ),

              Text(
                '\$${total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xffA73927),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATUS
  // ============================================================

  Widget _statusWidget(String status) {
    Color backgroundColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'delivered':
        backgroundColor = const Color(0xffD9F5E5);
        textColor = const Color(0xff16753B);
        break;

      case 'cancelled':
        backgroundColor = const Color(0xffffdddd);
        textColor = Colors.red;
        break;

      case 'shipped':
        backgroundColor = const Color(0xffDDF3F5);
        textColor = const Color(0xff006971);
        break;

      default:
        backgroundColor = const Color(0xffffeadf);
        textColor = const Color(0xffA73927);
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  // ============================================================
  // SUMMARY ROW
  // ============================================================

  Widget _summaryRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 13.sp, color: const Color(0xff57423D)),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // ============================================================
  // EMPTY ORDERS
  // ============================================================

  Widget _emptyOrders() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 70.sp, color: Colors.grey),

          SizedBox(height: 15.h),

          Text(
            'No Orders Yet',
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
          ),

          SizedBox(height: 8.h),

          Text(
            'Your orders will appear here',
            style: TextStyle(fontSize: 13.sp, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
