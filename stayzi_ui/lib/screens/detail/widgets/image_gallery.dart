import 'package:flutter/material.dart';

class ListingImageGallery extends StatelessWidget {
  final List<String> imageList;

  const ListingImageGallery({super.key, required this.imageList});

  @override
  Widget build(BuildContext context) {
    final List<String> imageList = [
      'assets/images/ilan2.jpg',
      'assets/images/ilan2.jpg',
      'assets/images/ilan2.jpg',
    ];

    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.35,
      child: PageView.builder(
        itemCount: imageList.length,
        itemBuilder:
            (context, index) =>
                Image.asset(imageList[index], fit: BoxFit.cover),
      ),
    );
  }
}
