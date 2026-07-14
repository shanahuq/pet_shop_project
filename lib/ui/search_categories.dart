import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchCategories extends StatefulWidget {
  final String title;
  const SearchCategories({super.key, required this.title});

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
      'favorite': true,
    },
    {
      'image': 'assets/Comfort Nylon….png',
      'name': 'Comfort Nylon…',
      'price': '\$24.00',
      'rating': '4.7',
      'favorite': true,
    },
    {
      'image': 'assets/Orthopedic Cloud.png',
      'name': 'Comfort Nylon…',
      'price': '\$85.00',
      'rating': '5.0',
      'favorite': true,
    },
    {
      'image': 'assets/Flow-Stream….png',
      'name': 'Flow-Stream…',
      'price': '\$42.99',
      'rating': '4.8',
      'favorite': true,
    },
    {
      'image': 'assets/Salmon Fusion….png',
      'name': 'Salmon Fusion…',
      'price': '\$18.00',
      'rating': '4.9',
      'favorite': true,
    },
    {
      'image': 'assets/Eco-Ceramic….png',
      'name': 'Eco-Ceramic…',
      'price': '\$28.50',
      'rating': '4.6',
      'favorite': true,
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 60.w,
        leading: CircleAvatar(
          radius: 20.r,
          child: ClipOval(
            child: Image.asset('assets/dogs_essential.png', fit: BoxFit.cover),
          ),
        ),
        title: Padding(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30.h),
              Row(
                children: [
                  Text(
                    'Home',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                      color: Color(0xff57423D),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.w),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Color(0xff57423D),
                      size: 13.sp,
                    ),
                  ),
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                      color: Color(0xffA73927),
                    ),
                  ),
                ],
              ),
              Text(
                widget.title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 28.sp,
                  color: Color(0xff1B1C1C),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '24 premium items for your best friend',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14.sp,
                      color: Color(0xff57423D),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Color(0xffF0EDED),
                      side: BorderSide(color: Color(0xffDFC0BA)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.tune, color: Colors.black, size: 22.sp),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Filter',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12.sp,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
                          color: isSelected ? Color(0xffF27059) : Colors.white,
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
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (selectedTab == 0) {
                      return GridView.builder(
                        itemCount: products.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 15.w,
                          mainAxisSpacing: 15.h,
                          childAspectRatio: 0.62,
                        ),

                        itemBuilder: (context, index) {
                          final item = products[index];
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.r),
                              color: Colors.white,
                              border: Border.all(color: Color(0xffFFFFFF)),
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          16.r,
                                        ),
                                        child: Image.asset(
                                          item['image'],
                                          height: 140.h,
                                          width: 140.w,
                                        ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 12,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              products[index]['favorite'] =
                                                  !products[index]['favorite'];
                                            });
                                          },
                                          child: CircleAvatar(
                                            radius: 16.r,
                                            backgroundColor: Colors.white,
                                            child: Icon(
                                              products[index]['favorite']
                                                  ? Icons.favorite_border
                                                  : Icons.favorite,
                                              size: 18.sp,
                                              color:
                                                  products[index]['favorite']
                                                      ? Colors.grey
                                                      : Color(0xffA73927),
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
                                        color: Color(0xffA73927),
                                        size: 16.sp,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        item['rating'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12.sp,
                                          color: Color(0xff57423D),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    item['name'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16.sp,
                                      color: Color(0xff1B1C1C),
                                    ),
                                  ),
                                  SizedBox(height: 5.h),
                                  Text(
                                    item['price'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 18.sp,
                                      color: Color(0xffA73927),
                                    ),
                                  ),
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Color(0xffA73927),
                                      side: BorderSide(
                                        color: Color(0xffA73927),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          16.r,
                                        ),
                                      ),
                                    ),
                                    onPressed: () {},
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(15.0),
                                          child: Icon(
                                            Icons.shopping_cart_outlined,
                                            color: Colors.white,
                                          ),
                                        ),
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
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }
                    return Center(child: const Text('no items'));
                  },
                ),
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
    );
  }
}
