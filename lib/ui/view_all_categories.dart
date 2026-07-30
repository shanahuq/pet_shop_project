import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'search_categories.dart';

class ViewAllCategories extends StatelessWidget {
  ViewAllCategories({super.key});

  final FirebaseFirestore db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> get categoriesStream {
    return db.collection('categories').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All Categories',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xffA73927),
          ),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: categoriesStream,

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
              ),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No categories found'),
            );
          }

          final categories = snapshot.data!.docs;

          return GridView.builder(
            padding: EdgeInsets.all(20.w),
            itemCount: categories.length,

            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15.w,
              mainAxisSpacing: 15.h,
              childAspectRatio: 1,
            ),

            itemBuilder: (context, index) {
              final categoryDoc = categories[index];

              final data =
                  categoryDoc.data() as Map<String, dynamic>;

              // Get the actual Firestore document ID
              final String categoryId = categoryDoc.id;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchCategories(
                        title: data['name'] ?? '',
                        categoryId: categoryId,
                      ),
                    ),
                  );
                },

                child: Card(
                  elevation: 3,

                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15.r),
                  ),

                  child: Padding(
                    padding: EdgeInsets.all(12.w),

                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,

                      children: [
                        CircleAvatar(
                          radius: 35.r,
                          backgroundColor:
                              Colors.grey.shade300,

                          backgroundImage:
                              NetworkImage(
                            data['imageUrl'] ?? '',
                          ),
                        ),

                        SizedBox(height: 12.h),

                        Text(
                          data['name'] ?? '',
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,

                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}