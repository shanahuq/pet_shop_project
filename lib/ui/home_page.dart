import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  final List<Map<String, dynamic>> categories = [
    {"icon": Icons.pets, "name": "Dogs"},
    {"icon": Icons.cruelty_free, "name": "Cats"},
    {"icon": Icons.set_meal, "name": "Fish"},
    {"icon": Icons.flutter_dash, "name": "Birds"},
  ];
  final List<Map<String, String>> dogProducts = [
    {
      "image": "assets/Background.png",
      "brand": "Kibble & Co",
      "name": "Organic Dog Food",
      "price": "\$24.99",
    },
    {
      "image":
          "assets/toy.png",
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
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
        body: IndexedStack(
          index: selectedIndex,
          children: [
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
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
                        padding:  EdgeInsets.only(bottom: 10.h,left: 15.w),
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
                          onPressed: () {},
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
                      child: TabBar(
                        // isScrollable: true,
                        indicatorColor: Colors.transparent,
                        dividerColor: Colors.transparent,
                        labelPadding: EdgeInsets.symmetric(horizontal: 12.w),
                        tabs:
                            categories.map((category) {
                              return SizedBox(
                                width: 70.w,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 28.r,
                                      backgroundColor: Colors.grey.shade300,
                                      child: Icon(
                                        category["icon"],
                                        color: Colors.black,
                                        size: 24.sp,
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      category["name"],
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                      ),
                    ),

                    Expanded(
                      child: TabBarView(
                        children: [
                          // Dogs Tab
                          SingleChildScrollView(
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15.r),
                                  child: Image.asset(
                                    "assets/Section - Featured Banner.png",
                                    width: double.infinity,
                                    height: 180.h,
                                    fit: BoxFit.cover,
                                  ),
                                ),

                                SizedBox(height: 5.h),

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
                                      onPressed: () {},
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
                                        childAspectRatio: 0.62,
                                      ),
                                  itemBuilder: (context, index) {
                                    final product = dogProducts[index];
                                    return Card(
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
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(15.r),
                                              child: SizedBox(
                                                height: 120.h,
                                                width: double.infinity,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        15.r,
                                                      ),
                                                  child: Image.asset(
                                                    product["image"]!,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
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
                                                onPressed: () {},
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
                          ),

                          // Cats Tab
                          Center(
                            child: Text(
                              "Cats Page",
                              style: TextStyle(fontSize: 20.sp),
                            ),
                          ),

                          // Fish Tab
                          Center(
                            child: Text(
                              "Fish Page",
                              style: TextStyle(fontSize: 20.sp),
                            ),
                          ),

                          // Birds Tab
                          Center(
                            child: Text(
                              "Birds Page",
                              style: TextStyle(fontSize: 20.sp),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: const Color(0xffA73927),
          unselectedItemColor: Colors.grey,
          currentIndex: selectedIndex,
          onTap: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),

            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              label: "Wishlist",
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              label: "Cart",
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}
