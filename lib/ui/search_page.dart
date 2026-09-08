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
      'id': 'STQGoqVwl5nfbYRGzOPm',
      'name': 'Dogs',
      'bgcolor': const Color.fromARGB(54, 242, 112, 89),
      'icon': Icons.pets,
      'iconcolor': const Color(0xffF27059),
    },
    {
      'id': 'lmieR6OK2MCUK4eiTnps',
      'name': 'Cats',
      'bgcolor': const Color.fromARGB(53, 0, 108, 118),
      'icon': Icons.cruelty_free,
      'iconcolor': const Color(0xff006D76),
    },
  ];

  final List<Map<String, dynamic>> trendingSearch = [
    {'title': 'Organic Puppy Food', 'subtitle': '1.2k searches today'},
    {'title': 'Smart Interactive Collars', 'subtitle': '800+ searches today'},
    {'title': 'Orthopedic Cat Beds', 'subtitle': 'Rising interest'},
  ];

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final bool isLandscape = orientation == Orientation.landscape;

        return LayoutBuilder(
          builder: (context, constraints) {
            final double screenWidth = constraints.maxWidth;

            // ==================================================
            // RESPONSIVE VALUES
            // ==================================================

            final bool isTablet = screenWidth >= 600;

            final double horizontalPadding =
                isLandscape
                    ? screenWidth >= 900
                        ? 50.w
                        : 25.w
                    : screenWidth < 400
                    ? 20.w
                    : 30.w;

            final double titleFontSize = isLandscape ? 16.sp : 20.sp;

            final double bodyFontSize = isLandscape ? 12.sp : 14.sp;

            final double searchHeight = isLandscape ? 52 : 58;

            return Scaffold(
              // ==================================================
              // APP BAR
              // ==================================================
              appBar: AppBar(
                automaticallyImplyLeading: false,

                leading: Padding(
                  padding: EdgeInsets.all(isLandscape ? 6.w : 8.w),

                  child: CircleAvatar(
                    radius: isLandscape ? 20.r : 22.r,

                    child: ClipOval(
                      child: Image.asset(
                        'assets/dogsmileface.png',
                        fit: BoxFit.cover,
                        width: isLandscape ? 38 : 40,
                        height: isLandscape ? 38 : 40,
                      ),
                    ),
                  ),
                ),

                title: Text(
                  'PetLife',

                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: isLandscape ? 18.sp : 20.sp,
                    color: const Color(0xffA73927),
                  ),
                ),

                actions: [
                  Padding(
                    padding: EdgeInsets.only(right: isLandscape ? 25.w : 30.w),

                    child: Icon(
                      Icons.notifications_none,
                      color: const Color(0xffA73927),
                      size: isLandscape ? 23.sp : 25.sp,
                    ),
                  ),
                ],
              ),

              // ==================================================
              // BODY
              // ==================================================
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        SizedBox(height: isLandscape ? 12.h : 20.h),

                        // ==================================================
                        // SEARCH BAR
                        // ==================================================
                        SizedBox(
                          height: searchHeight,

                          child: TextField(
                            keyboardType: TextInputType.text,

                            maxLines: 1,

                            style: TextStyle(
                              fontSize: isLandscape ? 13.sp : 14.sp,
                            ),

                            decoration: InputDecoration(
                              hintText: 'Search for treats, toys, or food...',

                              hintStyle: TextStyle(
                                fontSize: isLandscape ? 11.sp : 13.sp,
                              ),

                              prefixIcon: Icon(
                                Icons.search,
                                size: isLandscape ? 21.sp : 24.sp,
                              ),

                              suffixIcon: Icon(
                                Icons.mic_none,
                                size: isLandscape ? 21.sp : 24.sp,
                              ),

                              filled: true,
                              fillColor: Colors.white,

                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                              ),

                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.r),
                                borderSide: const BorderSide(
                                  color: Colors.grey,
                                ),
                              ),

                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.r),
                                borderSide: const BorderSide(
                                  color: Colors.grey,
                                ),
                              ),

                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.r),
                                borderSide: const BorderSide(
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: isLandscape ? 18.h : 25.h),

                        // ==================================================
                        // RECENT SEARCH HEADER
                        // ==================================================
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Recent Searches',

                                maxLines: 1,

                                overflow: TextOverflow.ellipsis,

                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: titleFontSize,
                                  color: const Color(0xff1B1C1C),
                                ),
                              ),
                            ),

                            TextButton(
                              onPressed: () {
                                setState(() {
                                  recentsearches.clear();
                                });
                              },

                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 8.w),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),

                              child: Text(
                                'CLEAR ALL',

                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: isLandscape ? 10.sp : 12.sp,
                                  color: const Color(0xffA73927),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: isLandscape ? 10.h : 15.h),

                        // ==================================================
                        // RECENT SEARCH CHIPS
                        // ==================================================
                        Wrap(
                          spacing: 10.w,
                          runSpacing: 8.h,

                          children:
                              recentsearches.map((search) {
                                return Chip(
                                  label: Text(
                                    search,
                                    style: TextStyle(
                                      fontSize: isLandscape ? 11.sp : 13.sp,
                                    ),
                                  ),

                                  backgroundColor: const Color.fromARGB(
                                    0,
                                    192,
                                    185,
                                    51,
                                  ),

                                  side: const BorderSide(
                                    color: Color.fromARGB(41, 192, 152, 51),
                                    width: 1.5,
                                  ),

                                  deleteIcon: Icon(
                                    Icons.close,
                                    color: Colors.grey,
                                    size: isLandscape ? 16.sp : 18.sp,
                                  ),

                                  onDeleted: () {
                                    setState(() {
                                      recentsearches.remove(search);
                                    });
                                  },
                                );
                              }).toList(),
                        ),

                        SizedBox(height: isLandscape ? 18.h : 25.h),

                        // ==================================================
                        // SHOP BY CATEGORY
                        // ==================================================
                        Text(
                          'Shop by Category',

                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: titleFontSize,
                            color: const Color(0xff1B1C1C),
                          ),
                        ),

                        SizedBox(height: isLandscape ? 12.h : 20.h),

                        // ==================================================
                        // CATEGORY LIST
                        // ==================================================
                        // ==================================================
                        // CATEGORY LIST
                        // ==================================================
                        // ==================================================
                        // CATEGORY LIST
                        // ==================================================
                        LayoutBuilder(
                          builder: (context, categoryConstraints) {
                            final double availableWidth =
                                categoryConstraints.maxWidth;

                            final double circleSize =
                                isLandscape
                                    ? (availableWidth * 0.14).clamp(64.0, 80.0)
                                    : (availableWidth * 0.24).clamp(76.0, 88.0);

                            // Slightly bigger category name
                            final double categoryFontSize =
                                isLandscape ? 14.0 : 16.0;

                            return SizedBox(
                              width: double.infinity,
                              height: isLandscape ? 125.0 : 135.0,

                              child: Row(
                                children: List.generate(categories.length, (
                                  index,
                                ) {
                                  final item = categories[index];

                                  return Expanded(
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // ==========================================
                                          // CATEGORY CIRCLE
                                          // ==========================================
                                          Material(
                                            color: item['bgcolor'],
                                            shape: const CircleBorder(),

                                            child: InkWell(
                                              customBorder:
                                                  const CircleBorder(),

                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (
                                                          context,
                                                        ) => SearchCategories(
                                                          title:
                                                              '${item['name']} Essentials',
                                                          categoryId:
                                                              item['id'],
                                                        ),
                                                  ),
                                                );
                                              },

                                              child: SizedBox(
                                                width: circleSize,
                                                height: circleSize,

                                                child: Center(
                                                  child: Icon(
                                                    item['icon'],
                                                    color: item['iconcolor'],
                                                    size:
                                                        isLandscape
                                                            ? 35.0
                                                            : 40.0,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),

                                          // ==========================================
                                          // SPACE
                                          // ==========================================
                                          SizedBox(
                                            height: isLandscape ? 7.0 : 9.0,
                                          ),

                                          // ==========================================
                                          // CATEGORY NAME
                                          // ==========================================
                                          SizedBox(
                                            height: 22.0,

                                            child: Text(
                                              item['name'],

                                              maxLines: 1,
                                              softWrap: false,
                                              overflow: TextOverflow.ellipsis,

                                              textAlign: TextAlign.center,

                                              style: TextStyle(
                                                fontSize: categoryFontSize,
                                                fontWeight: FontWeight.w600,

                                                // IMPORTANT:
                                                // Don't use height: 2.0 here.
                                                height: 1.0,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            );
                          },
                        ),

                        SizedBox(height: isLandscape ? 15.h : 20.h),

                        // ==================================================
                        // TRENDING SEARCHES CARD
                        // ==================================================
                        Container(
                          width: double.infinity,

                          padding: EdgeInsets.all(isLandscape ? 15.w : 18.w),

                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.r),
                            color: Colors.white,
                          ),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              // ==========================================
                              // TRENDING HEADER
                              // ==========================================
                              Row(
                                children: [
                                  Icon(
                                    Icons.trending_up,
                                    color: const Color(0xffA73927),
                                    size: isLandscape ? 22.sp : 25.sp,
                                  ),

                                  SizedBox(width: isLandscape ? 6.w : 8.w),

                                  Expanded(
                                    child: Text(
                                      'Trending Searches',

                                      maxLines: 1,

                                      overflow: TextOverflow.ellipsis,

                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: titleFontSize,
                                        color: const Color(0xff1B1C1C),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: isLandscape ? 10.h : 15.h),

                              // ==========================================
                              // TRENDING ITEMS
                              // ==========================================
                              ListView.separated(
                                shrinkWrap: true,

                                physics: const NeverScrollableScrollPhysics(),

                                itemCount: trendingSearch.length,

                                separatorBuilder:
                                    (_, __) => Divider(
                                      height: isLandscape ? 20.h : 30.h,
                                      color: const Color.fromARGB(
                                        64,
                                        158,
                                        158,
                                        158,
                                      ),
                                    ),

                                itemBuilder: (context, index) {
                                  final item = trendingSearch[index];

                                  return Row(
                                    children: [
                                      SizedBox(
                                        width: isLandscape ? 20.w : 25.w,

                                        child: Text(
                                          '${index + 1}',

                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize:
                                                isLandscape ? 14.sp : 16.sp,
                                            color: const Color(0xffA73927),
                                          ),
                                        ),
                                      ),

                                      SizedBox(
                                        width: isLandscape ? 10.w : 15.w,
                                      ),

                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,

                                          children: [
                                            Text(
                                              item['title'],

                                              maxLines: 1,

                                              overflow: TextOverflow.ellipsis,

                                              style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: bodyFontSize,
                                                color: const Color(0xff1B1C1C),
                                              ),
                                            ),

                                            SizedBox(height: 2.h),

                                            Text(
                                              item['subtitle'],

                                              maxLines: 1,

                                              overflow: TextOverflow.ellipsis,

                                              style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize:
                                                    isLandscape ? 10.sp : 12.sp,
                                                color: const Color(0xff57423D),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      SizedBox(width: 8.w),

                                      Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.grey,
                                        size: isLandscape ? 14.sp : 17.sp,
                                      ),
                                    ],
                                  );
                                },
                              ),

                              SizedBox(height: isLandscape ? 20.h : 30.h),

                              // ==========================================
                              // SUMMER SALE BANNER
                              // ==========================================
                              // ==========================================
                              // SUMMER SALE BANNER
                              // ==========================================
                              // ==========================================
                              // SUMMER SALE BANNER
                              // ==========================================
                              LayoutBuilder(
                                builder: (context, bannerConstraints) {
                                  final double bannerWidth =
                                      bannerConstraints.maxWidth;

                                  final double bannerHeight =
                                      isLandscape
                                          ? bannerWidth * 0.35
                                          : bannerWidth * 0.55;

                                  return SizedBox(
                                    width: bannerWidth,
                                    height: bannerHeight,

                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16.r),

                                      child: Image.asset(
                                        'assets/summer_sale.png',
                                        width: bannerWidth,
                                        height: bannerHeight,

                                        // Keeps the complete image visible
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: isLandscape ? 25.h : 40.h),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
