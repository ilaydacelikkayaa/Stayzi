import 'package:flutter/material.dart';
import 'package:stayzi_ui/services/api_constants.dart';

class ListingImageGallery extends StatelessWidget {
  final List<String> imageList;

  const ListingImageGallery({super.key, required this.imageList});

  final String baseUrl = ApiConstants.baseUrl;
  String getListingImageUrl(String? path) {
    if (path == null || path.isEmpty) return 'assets/images/user.jpg';
    if (path.startsWith('/uploads')) {
      return baseUrl + path;
    }
    return path;
  }

  Widget buildListingImage(String imageUrl) {
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(imageUrl, fit: BoxFit.cover);
    } else {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[200],
            child: const Icon(
              Icons.home_outlined,
              size: 64,
              color: Colors.grey,
            ),
          );
        },
      );
    }
  }

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
          return buildListingImage(getListingImageUrl(imageUrl));
        },
      ),
    );
  }
}
