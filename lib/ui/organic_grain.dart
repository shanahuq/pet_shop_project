import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrganicGrain extends StatefulWidget {
  const OrganicGrain({super.key});

  @override
  State<OrganicGrain> createState() => _OrganicGrainState();
}

class _OrganicGrainState extends State<OrganicGrain> {
  bool isSelected = true;
  String selectedWeight = '2kg';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.arrow_back, color: Color(0xff57423D)),
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
                          (index) => Icon(Icons.star, color: Colors.amber),
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
                    SizedBox(height: 20.h,),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r),
                        ) ,
                      ),
                      onPressed: () {}, 
                      child: child
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
}
