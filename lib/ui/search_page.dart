import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
