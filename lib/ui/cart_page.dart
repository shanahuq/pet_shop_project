import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pet_shop_project/ui/checkout.dart';
import 'home_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  int selectedIndex = 2;
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,

          leading: Padding(
            padding: EdgeInsets.only(left: 16.w),
            child: CircleAvatar(
              radius: 18.r,
              child: ClipOval(
                child: Image.asset(
                  'assets/profilepicture.png',
                  fit: BoxFit.cover,
                  width: 36.w,
                  height: 36.h,
                ),
              ),
            ),
          ),

          title: Text(
            'PetLife',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20.sp,
              color: const Color(0xffA73927),
            ),
          ),

          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.search, size: 25.sp),
            ),
            Padding(
              padding: EdgeInsets.only(right: 30.w),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    color: const Color(0xffA73927),
                    size: 28.sp,
                  ),
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      height: 16.h,
                      width: 16.w,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Center(
                        child: Text(
                          "2",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
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
          child: Column(
            children: [
              SizedBox(height: 18.h),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Container(
                  height: 52.h,
                  decoration: BoxDecoration(
                    color: const Color(0xffF5F2F0),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorPadding: EdgeInsets.all(4.w),
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      color: const Color(0xffE7E2DF),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    labelColor: const Color(0xffA73927),
                    unselectedLabelColor: Colors.black54,
                    tabs: const [Tab(text: "Cart"), Tab(text: "Wishlist")],
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              Expanded(child: TabBarView(children: [CartTab(), WishListTab()])),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedIndex,
          selectedItemColor: const Color(0xffA73927),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            if (index == selectedIndex) return;

            switch (index) {
              case 0:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                ); // or Navigator.push to HomePage
                break;

              case 1:
                // Navigate to Wishlist page
                break;

              case 2:
                // Already on Cart page
                break;

              case 3:
                // Navigate to Profile page
                break;
            }

            setState(() {
              selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              label: "Wishlist",
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

class CartTab extends StatelessWidget {
  const CartTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      child: Column(
        children: [
          CartItem(
            image: 'assets/dogsfood.png',
            name: 'Organic Salmon Kibble',
            subtitle: '2.5kg • Sensitive Digestion',
            price: '\$42.00',
          ),
          SizedBox(height: 15.h),
          CartItem(
            image: 'assets/dogscoir.png',
            name: 'Hemp Braided Tug',
            subtitle: 'Eco-friendly • Large',
            price: '\$18.50',
          ),
          SizedBox(height: 15.h),
          Divider(),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal',
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14.sp,
                  color: Color(0xff57423D),
                ),
              ),
              Text(
                '\$60.50',
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14.sp,
                  color: Color(0xff1B1C1C),
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shipping',
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  color: Color(0xff57423D),
                ),
              ),
              Text(
                'Calculated at checkout',
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 16.sp,
                  color: Color(0xff006971),
                ),
              ),
            ],
          ),
          Spacer(),
          // SizedBox(height: 40.h),
          SizedBox(
            width: 300.w,
            height: 55.h,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Checkout()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xffA73927),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Proceed to Checkout',
                    style: TextStyle(fontSize: 16.sp, color: Colors.white),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10.w),
                    child: Icon(Icons.arrow_forward, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget CartItem({
    required String image,
    required String name,
    required String subtitle,
    required String price,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                image,
                width: 85,
                height: 85,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 19,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(subtitle, style: const TextStyle(color: Colors.grey)),

                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        price,
                        style: const TextStyle(
                          color: Color(0xffA73927),
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.remove, size: 18),
                            SizedBox(width: 8),
                            Text("1"),
                            SizedBox(width: 8),
                            Icon(Icons.add, size: 18),
                          ],
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
    );
  }
}

class WishListTab extends StatelessWidget {
  const WishListTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Wishlist Items Here"));
  }
}
