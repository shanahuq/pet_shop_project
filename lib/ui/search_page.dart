import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pet_shop_project/ui/search_categories.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<String> recentsearches = [
    'Grain-free kibble',
    'Chew toys',
    'Cat scratcher',
  ];
  final List<Map<String, dynamic>> categories = [
    {
      'name': 'Dogs',
      'bgcolor': const Color.fromARGB(54, 242, 112, 89),
      'icon': Icons.pets,
      'iconcolor': const Color(0xffF27059),
    },
    {
      'name': 'Cats',
      'bgcolor': const Color.fromARGB(53, 0, 108, 118),
      'icon': Icons.cruelty_free,
      'iconcolor': const Color(0xff006D76),
    },
    {
      'name': 'Fish',
      'bgcolor': const Color.fromARGB(50, 72, 71, 66),
      'icon': Icons.set_meal,
      'iconcolor': const Color(0xff484742),
    },
    {
      'name': 'Birds',
      'bgcolor': const Color.fromARGB(30, 242, 112, 89),
      'icon': Icons.flutter_dash,
      'iconcolor': const Color(0xff57423D),
    },
  ];
  final List<Map<String, dynamic>> trendingSearch = [
    {'title': 'Organic Puppy Food', 'subtitle': '1.2k searches today'},
    {'title': 'Smart Interactive Collars', 'subtitle': '800+ searches today'},
    {'title': 'Orthopedic Cat Beds', 'subtitle': 'Rising interest'},
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            radius: 20.r,
            child: ClipOval(
              child: Image.asset(
                'assets/dogsmileface.png',
                fit: BoxFit.cover,
                width: 40.w,
                height: 40.w,
              ),
            ),
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
            child: Icon(Icons.notifications_none, color: Color(0xffA73927)),
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
                TextField(
                  keyboardType: TextInputType.text,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Search for treats, toys, or \n food...',
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: Icon(Icons.mic_none),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide(color: Colors.orange),
                    ),
                  ),
                ),
                SizedBox(height: 25.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Searches',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20.sp,
                        color: Color(0xff1B1C1C),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          recentsearches.clear();
                        });
                      },
                      child: Text(
                        'CLEAR ALL',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                          color: Color(0xffA73927),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15.h),
                Wrap(
                  spacing: 10.w,
                  runSpacing: 10.h,
                  children:
                      recentsearches.map((search) {
                        return Chip(
                          label: Text(search),
                          backgroundColor: Color.fromARGB(0, 192, 185, 51),
                          side: BorderSide(
                            color: Color.fromARGB(41, 192, 152, 51),
                            width: 1.5,
                          ),
                          deleteIcon: const Icon(
                            Icons.close,
                            color: Colors.grey,
                          ),
                          onDeleted: () {
                            setState(() {
                              recentsearches.remove(search);
                            });
                          },
                        );
                      }).toList(),
                ),
                SizedBox(height: 25.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Shop by Category',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20.sp,
                      color: Color(0xff1B1C1C),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(categories.length, (index) {
                    final item = categories[index];

                    return Column(
                      children: [
                        Material(
                          color: item['bgcolor'],
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => SearchCategories(
                                        title: "${item['name']} Essentials",
                                        categoryId: 'categoryId',
                                      ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.all(18.w),
                              child: Icon(
                                item['icon'],
                                color: item['iconcolor'],
                                size: 30.sp,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          item["name"],
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
                SizedBox(height: 20.h),
                Container(
                  width: 350.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.trending_up,
                            color: Color(0xffA73927),
                            size: 25.sp,
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Trending Searches',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 20.sp,
                                color: Color(0xff1B1C1C),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15.h),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: trendingSearch.length,
                        separatorBuilder:
                            (_, __) => Divider(
                              height: 30.h,
                              color: const Color.fromARGB(64, 158, 158, 158),
                            ),
                        itemBuilder: (context, index) {
                          final item = trendingSearch[index];
                          return Row(
                            children: [
                              Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16.sp,
                                  color: Color(0xffA73927),
                                ),
                              ),
                              SizedBox(width: 15.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['title'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14.sp,
                                        color: Color(0xff1B1C1C),
                                      ),
                                    ),
                                    Text(
                                      item['subtitle'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12.sp,
                                        color: Color(0xff57423D),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.arrow_forward_ios, color: Colors.grey),
                            ],
                          );
                        },
                      ),
                      SizedBox(height: 40.h),
                      Container(
                        height: 190.h,
                        width: 350.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Image.asset(
                          'assets/summer_sale.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
