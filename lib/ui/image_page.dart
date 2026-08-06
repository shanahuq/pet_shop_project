import 'package:flutter/material.dart';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ImagePage extends StatefulWidget {
  const ImagePage({super.key});

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  final ImagePicker _picker = ImagePicker();

File? imageFile;

final nameController = TextEditingController();
final priceController = TextEditingController();
final categoryController = TextEditingController();
Future<void> pickImage() async {
  final XFile? pickedImage =
      await _picker.pickImage(source: ImageSource.gallery);

  if (pickedImage != null) {
    setState(() {
      imageFile = File(pickedImage.path);
    });
  }
}
Future<String> uploadImage() async {
  final fileName = DateTime.now().millisecondsSinceEpoch.toString();

  final ref = FirebaseStorage.instance
      .ref()
      .child("products")
      .child(fileName);

  await ref.putFile(imageFile!);

  return await ref.getDownloadURL();
}
 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Upload Product"),
    ),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [

          imageFile == null
              ? Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.image, size: 80),
                )
              : Image.file(
                  imageFile!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: pickImage,
            child: const Text("Choose Image"),
          ),

          const SizedBox(height: 20),

          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: "Product Name",
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: priceController,
            decoration: const InputDecoration(
              labelText: "Price",
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: categoryController,
            decoration: const InputDecoration(
              labelText: "Category",
            ),
          ),

          const SizedBox(height: 30),

          ElevatedButton(
            onPressed: () async {
              if (imageFile == null) return;

              final imageUrl = await uploadImage();

              await FirebaseFirestore.instance
                  .collection("products")
                  .add({
                "name": nameController.text,
                "price": priceController.text,
                "category": categoryController.text,
                "imageUrl": imageUrl,
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Product Uploaded"),
                ),
              );
            },
            child: const Text("Upload Product"),
          ),
        ],
      ),
    ),
  );
}
}