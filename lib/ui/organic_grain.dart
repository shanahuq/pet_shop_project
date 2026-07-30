import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrganicGrain extends StatefulWidget {
  const OrganicGrain({super.key});

  @override
  State<OrganicGrain> createState() => _OrganicGrainState();
}

class _OrganicGrainState extends State<OrganicGrain> {
  bool isSelected = true;
  String selectedWeight = '2kg';
  final String productId = 'ZtZgVFduAXq0feoW8RMK';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  Stream<QuerySnapshot> get reviewsStream {
    return _firestore
        .collection('reviews')
        .where('productId', isEqualTo: productId)
        .snapshots();
  }

  String formatReviewDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    }

    if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    }

    if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    }

    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back, color: Color(0xff57423D)),
        ),
        title: Center(
          child: Text(
            'PetLife',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 28.sp,
              color: Color(0xffA73927),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 40.w),
            child: Icon(Icons.notifications_none, color: Color(0xffA73927)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    height: 390.h,
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: Image.asset(
                        'assets/OrganicGrain.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 30,
                    right: 40,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isSelected = !isSelected;
                        });
                      },
                      child: CircleAvatar(
                        radius: 20.r,
                        backgroundColor: Colors.white,
                        child: Icon(
                          isSelected ? Icons.favorite : Icons.favorite_border,
                          color: isSelected ? Color(0xffA73927) : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 80,
                    right: 40,
                    child: CircleAvatar(
                      radius: 20.r,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.share, color: Color(0xff57423D)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 22.h,
                          width: 85.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.r),
                            color: Color(0xff93EEF9),
                          ),
                          child: Center(
                            child: Text(
                              'Best Seller',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12.sp,
                                color: Color(0xff006D76),
                              ),
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              '\$34.99',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 24.sp,
                                color: Color(0xffA73927),
                              ),
                            ),
                            Text(
                              '\$42.00',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 12.sp,
                                color: Color(0xff57423D),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      'Organic Grain-Free \nKibble',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 24.sp,
                        color: Color(0xff1B1C1C),
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (index) => Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 18.sp,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          '(4.8 • 124 reviews)',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14.sp,
                            color: Color(0xff57423D),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'SELECT WEIGHT',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp,
                        color: Color(0xff57423D),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      children: [
                        weightButton('2kg'),
                        SizedBox(width: 10.w),
                        weightButton('5kg'),
                        SizedBox(width: 10.w),
                        weightButton('10kg'),
                      ],
                    ),
                    SizedBox(height: 30.h),
                    Row(
                      children: [
                        Container(
                          height: 90.h,
                          width: 170.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.r),
                            color: Color(0xffEAE7E7),
                            border: Border.all(color: Color(0xff3C280008)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.eco_outlined,
                                color: Color(0xff006971),
                                size: 26.sp,
                              ),
                              Text(
                                '100% Organic',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.sp,
                                  color: Color(0xff1B1C1C),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Container(
                          height: 90.h,
                          width: 170.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.r),
                            color: Color(0xffEAE7E7),
                            border: Border.all(color: Color(0xff3C280008)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.restaurant,
                                color: Color(0xff006971),
                                size: 26.sp,
                              ),
                              Text(
                                'Grain Free',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.sp,
                                  color: Color(0xff1B1C1C),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'Product Details',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20.sp,
                        color: Color(0xff1B1C1C),
                      ),
                    ),
                    SizedBox(height: 15.h),
                    Text(
                      'Crafted for dogs with sensitive stomachs and \ndiscerning tastes. Our formula uses free- \nrange chicken and farm-fresh vegetables to \nprovide a complete, balanced diet that \nsupports digestion and coat health.',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14.sp,
                        color: Color(0xff57423D),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Container(
                      height: 70.h,
                      width: 350.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18.r),
                        color: Colors.white,
                        border: Border.all(
                          color: const Color.fromARGB(100, 158, 158, 158),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 20.w),
                            child: Text(
                              'Ingredients',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 20.sp,
                                color: Color(0xff1B1C1C),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 20.w),
                            child: Icon(
                              Icons.keyboard_arrow_down_sharp,
                              color: Color(0xff1B1C1C),
                              size: 28.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Container(
                      height: 70.h,
                      width: 350.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18.r),
                        color: Colors.white,
                        border: Border.all(
                          color: const Color.fromARGB(100, 158, 158, 158),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 20.w),
                            child: Text(
                              'Feeding Guide',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 20.sp,
                                color: Color(0xff1B1C1C),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 20.w),
                            child: Icon(
                              Icons.keyboard_arrow_down_sharp,
                              color: Color(0xff1B1C1C),
                              size: 28.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 25.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text(
                              'Customer Reviews',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 20.sp,
                                color: Color(0xff1B1C1C),
                              ),
                            ),
                            Text(
                              'Based on 124 verified purchases',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 12.sp,
                                color: Color(0xff57423D),
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'View All',
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 16.sp,
                              color: Color(0xffA73927),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 36.h),
                    StreamBuilder<QuerySnapshot>(
                      stream: reviewsStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          debugPrint('🔥 FIRESTORE ERROR: ${snapshot.error}');

                          return Padding(
                            padding: EdgeInsets.all(20.w),
                            child: Text(
                              'Error loading reviews:\n\n${snapshot.error}',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 14.sp,
                              ),
                            ),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text('No reviews yet.'));
                        }

                        final reviews = snapshot.data!.docs;

                        return Column(
                          children:
                              reviews.map((doc) {
                                final data = doc.data() as Map<String, dynamic>;

                                final String comment = data['comment'] ?? '';

                                final double rating =
                                    (data['rating'] ?? 0).toDouble();

                                final Timestamp? timestamp = data['createdAt'];

                                final String time =
                                    timestamp != null
                                        ? formatReviewDate(timestamp.toDate())
                                        : '';

                                return Padding(
                                  padding: EdgeInsets.only(bottom: 15.h),
                                  child: ReviewCard(
                                    initials: 'U',
                                    name: 'Customer',
                                    time: time,
                                    rating: rating,
                                    review: comment,
                                  ),
                                );
                              }).toList(),
                        );
                      },
                    ),
                    SizedBox(height: 30.h),
                    Row(
                      children: [
                        SizedBox(
                          width: 170.w,
                          height: 85.h,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Color(0xff006971)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.r),
                              ),
                            ),
                            onPressed: () {},
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.autorenew,
                                  color: Color(0xff006971),
                                  size: 26.sp,
                                ),
                                SizedBox(width: 6.w),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Subscribe',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16.sp,
                                        color: Color(0xff006971),
                                      ),
                                    ),
                                    Text(
                                      '& Save 15%',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16.sp,
                                        color: Color(0xff006971),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        SizedBox(
                          width: 165.w,
                          height: 85.h,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xffA73927),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.r),
                              ),
                            ),
                            onPressed: () {},
                            icon: Icon(
                              Icons.shopping_cart_outlined,
                              color: Colors.white,
                              size: 22.sp,
                            ),
                            label: Text(
                              'Add to Cart',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 16.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget weightButton(String weight) {
    bool selected = selectedWeight == weight;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedWeight = weight;
        });
      },
      child: Container(
        height: 52.h,
        width: 80.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: selected ? Color(0xffA73927) : Color(0xffDFC0BA),
          ),
          color: selected ? Color.fromARGB(43, 167, 56, 39) : Colors.white,
        ),
        child: Center(
          child: Text(
            weight,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 16.sp,
              color: selected ? Color(0xffA73927) : Color(0xff57423D),
            ),
          ),
        ),
      ),
    );
  }

  Widget ReviewCard({
    required String initials,
    required String name,
    required String time,
    required double rating,
    required String review,
  }) {
    return Container(
      width: 350.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: Colors.white,
        border: Border.all(color: const Color.fromARGB(97, 158, 158, 158)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.h),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 25.r,
                  backgroundColor: const Color(0xffFFDAD4),
                  child: Text(
                    initials,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16.sp,
                      color: const Color(0xff3F0300),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(right: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                          color: const Color(0xff1B1C1C),
                        ),
                      ),

                      Row(
                        children: List.generate(
                          5,
                          (index) => Icon(
                            index < rating.round()
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 18.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Text(
                  time,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 12.sp,
                    color: const Color(0xff57423D),
                  ),
                ),
              ],
            ),

            SizedBox(height: 10.h),

            Text(
              review,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14.sp,
                color: const Color(0xff57423D),
              ),
            ),

            SizedBox(height: 15.h),
          ],
        ),
      ),
    );
  }
}
