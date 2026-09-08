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
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No categories found'));
          }

          final categories = snapshot.data!.docs;

          return GridView.builder(
            padding: EdgeInsets.all(20.w),
            itemCount: categories.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:
                  MediaQuery.of(context).orientation == Orientation.landscape
                      ? 3
                      : 2,

              // This controls the space between cards
              crossAxisSpacing: 20.w,

              mainAxisSpacing: 15.h,

              childAspectRatio: 0.95,
            ),

            itemBuilder: (context, index) {
              final categoryDoc = categories[index];

              final data = categoryDoc.data() as Map<String, dynamic>;

              final String categoryId = categoryDoc.id;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => SearchCategories(
                            title: data['name'] ?? '',
                            categoryId: categoryId,
                          ),
                    ),
                  );
                },

                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.r),
                  ),

                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final double imageSize = (constraints.maxWidth * 0.50)
                          .clamp(70.0, 120.0);

                      return Padding(
                        padding: EdgeInsets.all(10.w),

                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: imageSize,
                              height: imageSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey.shade300,
                              ),
                              child: ClipOval(
                                child: Image.network(
                                  data['imageUrl'] ?? '',
                                  width: imageSize,
                                  height: imageSize,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.image_not_supported_outlined,
                                      size: imageSize * 0.4,
                                      color: Colors.grey.shade600,
                                    );
                                  },
                                  loadingBuilder: (
                                    context,
                                    child,
                                    loadingProgress,
                                  ) {
                                    if (loadingProgress == null) {
                                      return child;
                                    }

                                    return Center(
                                      child: SizedBox(
                                        width: 25.w,
                                        height: 25.w,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                            SizedBox(height: 10.h),

                            Text(
                              data['name'] ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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
