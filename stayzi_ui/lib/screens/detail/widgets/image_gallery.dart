import 'package:flutter/material.dart';

class ListingImageGallery extends StatelessWidget {
  final List<String> imageList;

  const ListingImageGallery({super.key, required this.imageList});

  @override
  Widget build(BuildContext context) {
    if (imageList.isEmpty) {
      return const Center(child: Text("Fotoğraf bulunamadı"));
    }

    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.35,
      child: PageView.builder(
        itemCount: imageList.length,
        itemBuilder: (context, index) {
          final imageUrl = imageList[index];
          return imageUrl.startsWith('http')
              ? Image.network(imageUrl, fit: BoxFit.cover)
              : Image.asset(imageUrl, fit: BoxFit.cover);
        },
      ),
    );
  }
}
