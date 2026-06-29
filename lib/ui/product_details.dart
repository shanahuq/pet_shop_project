import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductDetails extends StatefulWidget {
  const ProductDetails({super.key});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  int selectedSize = 0;
  int selectedColor = 0;
  bool isfavorite = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: Icon(Icons.arrow_back),
        title: Center(
          child: Text(
            'PetLife',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20.sp,
              color: Color(0xffA73927),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 30.w),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  color: Color(0xffA73927),
                  size: 28.sp,
                ),
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    height: 16.h,
                    width: 16.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.r),
                      color: Colors.red,
                    ),
                    child: Center(
                      child: Text(
                        '2',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                Container(
                  height: 390.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Image.asset(
                    'assets/Hero Product Image.png',
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Premium Plush Dog \nBed',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18.sp,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      '\$89.00',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 24.sp,
                        color: Color(0xffA73927),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Orthopedic & Self-Warming',
                    style: TextStyle(fontSize: 14.sp, color: Color(0xff57423D)),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'Designed to provide ultimate comfort and support for nyour furry friend Features high-quality memory foam and a luxuriously soft faux-fur cover thats easy to remove and machine wash',
                  style: TextStyle(fontSize: 14.sp, color: Color(0xff57423D)),
                ),
                SizedBox(height: 10.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'SELECT SIZE',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    _sizeButton("S", 0),
                    SizedBox(width: 10.w),
                    _sizeButton("M", 1),
                    SizedBox(width: 10.w),
                    _sizeButton("L", 2),
                  ],
                ),
                SizedBox(height: 10.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'COLOR: SLATE GREY',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    _colorButton(const Color(0xff65758B), 0),
                    SizedBox(width: 12.w),
                    _colorButton(Colors.grey.shade400, 1),
                    SizedBox(width: 12.w),
                    _colorButton(const Color(0xffF5E8A8), 2),
                  ],
                ),
                SizedBox(height: 15.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Similar Products',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20.sp,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'View All',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                          color: Color(0xffA73927),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 180.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      final images = [
                        "assets/dogsbed.png",
                        "assets/dogsbed2.png",
                        "assets/dogsbed3.webp",
                      ];
                      final names = [
                        "Woven Basket Bed",
                        "Modern Lifted bed",
                        "Cozy Donut Bed",
                      ];
                      final prices = ["\$65.00", "\$120.00", "\$45.00"];
                      return Padding(
                        padding: EdgeInsets.only(right: 15.w),
                        child: SizedBox(
                          width: 120.w,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 110.h,
                                width: 120.w,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16.r),
                                  color: Colors.grey,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16.r),
                                  child: Image.asset(
                                    images[index],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(height: 5.h),
                              Text(
                                names[index],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12.sp,
                                ),
                              ),
                              SizedBox(height: 3.h),
                              Text(
                                prices[index],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.sp,
                                  color: Color(0xffA73927),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 25.h),
                Row(
                  children: [
                    Container(
                      height: 55.h,
                      width: 55.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: isfavorite ?  Color(0xffA73927):Colors.grey ,
                        ),
                      ),
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            isfavorite = !isfavorite;
                          });
                        },
                        icon: Icon(
                          isfavorite 
                          ? Icons.favorite 
                          : Icons.favorite_border,
                          color:
                              isfavorite
                                  ? const Color(0xffA73927)
                                  : Colors.grey,
                        ),
                      ),
                    ),
                    SizedBox(width: 15.w),
                    Expanded(
                      child: SizedBox(
                        height: 55.h,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: Icon(
                            Icons.shopping_bag_outlined,
                            color: Colors.grey,
                          ),
                          label: Text(
                            'Add to Cart',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16.sp,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xffA73927),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sizeButton(String text, int index) {
    bool isSelected = selectedSize == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSize = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 42.h,
        width: 42.w,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xffF27A62) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? const Color(0xffF27A62) : Colors.grey.shade300,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _colorButton(Color color, int index) {
    bool isSelected = selectedColor == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? const Color(0xffA73927) : Colors.transparent,
            width: 2,
          ),
        ),
        child: CircleAvatar(radius: 15.r, backgroundColor: color),
      ),
    );
  }
}
