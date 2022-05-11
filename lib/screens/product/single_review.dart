// ignore: import_of_legacy_library_into_null_safe
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skyewooapp/app_colors.dart';
import 'package:skyewooapp/models/comment.dart';

class SingleReview extends StatelessWidget {
  const SingleReview({
    Key? key,
    required this.comment,
  }) : super(key: key);

  final Comment comment;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10, top: 10),
      child: Row(
        children: [
          //avatar
          SizedBox(
            height: 40,
            width: 40,
            child: (() {
              if (comment.getUserImage.length > 15) {
                //greater that 15 will surely be an image
                return ClipRRect(
                  borderRadius: BorderRadius.circular(50.0),
                  child: CachedNetworkImage(
                    memCacheHeight: 40,
                    memCacheWidth: 40,
                    imageUrl: comment.getUserImage,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: AppColors.f1,
                      highlightColor: Colors.white,
                      period: const Duration(milliseconds: 500),
                      child: Container(
                        color: AppColors.hover,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.f1,
                      child: const Padding(
                        padding: EdgeInsets.all(80.0),
                        child: Icon(Icons.error),
                      ),
                    ),
                  ),
                );
              } else {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(50.0),
                  child: Image.asset(
                    "assets/images/default_avatar.jpg",
                    height: 70,
                    width: 70,
                    cacheHeight: 90,
                    cacheWidth: 90,
                  ),
                );
              }
            }()),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //star
                RatingBar.builder(
                  ignoreGestures: true,
                  initialRating: double.parse(
                      comment.getRating.isNotEmpty ? comment.getRating : "5"),
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemSize: 15,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    //nothing
                  },
                ),
                //username
                Text(
                  comment.getUsername,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Html(
                  data: comment.getComment,
                  defaultTextStyle: const TextStyle(
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
