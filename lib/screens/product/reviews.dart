import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:fluttertoast/fluttertoast.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart';
import 'package:skyewooapp/app_colors.dart';
import 'package:skyewooapp/components/loading_box.dart';
import 'package:skyewooapp/handlers/app_styles.dart';
import 'package:skyewooapp/handlers/handlers.dart';
import 'package:skyewooapp/handlers/user_session.dart';
import 'package:skyewooapp/models/comment.dart';
import 'package:skyewooapp/site.dart';
import 'package:skyewooapp/screens/product/single_review.dart';

class Reviews extends StatefulWidget {
  const Reviews({
    Key? key,
    required this.haveReviews,
    required this.averageRating,
    required this.reviewsCount,
    required this.comments,
    required this.productID,
    required this.userSession,
    required this.onReviewUpdated,
  }) : super(key: key);

  final String productID;
  final UserSession userSession;
  final bool haveReviews;
  final double averageRating;
  final int reviewsCount;
  final List<Comment> comments;
  final Function(int newReviewCount, bool didHaveReviews,
      List<Comment> newComments, double userRating) onReviewUpdated;

  @override
  State<Reviews> createState() => _ReviewsState();
}

class _ReviewsState extends State<Reviews> {
  double newReviewRating = 0;
  final commentTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        (() {
          if (widget.haveReviews) {
            return Column(
              children: [
                Center(
                  child: RatingBar.builder(
                    ignoreGestures: true,
                    initialRating: widget.averageRating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 45,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      //do nothing, not allowed to be changed
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    "(" + widget.reviewsCount.toString() + " Customer Reviews)",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(0),
                  children: List.generate(widget.comments.length, (index) {
                    var comment = widget.comments[index];
                    return SingleReview(
                      comment: comment,
                    );
                  }),
                ),
              ],
            );
          } else {
            return Container(
              color: AppColors.primary,
              padding: const EdgeInsets.all(10),
              child: const Center(
                child: Text(
                  "There are no reviews yet.",
                  style: TextStyle(
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
            );
          }
        }()),
        const SizedBox(height: 20),
        const Center(
          child: Text(
            "Your rating *",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: RatingBar.builder(
            initialRating: 0,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemSize: 45,
            itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) => const Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) {
              newReviewRating = rating;
            },
          ),
        ),
        const SizedBox(height: 10),
        const Center(
          child: Text(
            "Your comment *",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.black12,
            border: Border.all(
              color: AppColors.hover,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          child: TextField(
            controller: commentTextController,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            minLines: 5,
            maxLines: 5,
            decoration: const InputDecoration.collapsed(
              hintText: 'Comment',
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          style: AppStyles.flatButtonStyle(),
          onPressed: addReview,
          child: const Text(
            "Submit Review",
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  addReview() async {
    var connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      Toaster.show(message: "Bad Internet connection");
      return;
    }
    if (!widget.userSession.logged()) {
      ToastBar.show(context, "Please login to add review.");
      return;
    }
    if (newReviewRating < 1) {
      ToastBar.show(
          context, "Please tap the rating start, to rate this product.");
      return;
    }
    if (commentTextController.text.isEmpty) {
      ToastBar.show(context, "Please write a comment.");
      return;
    }
    try {
      //show progress dialog
      SmartDialog.show(
          clickBgDismissTemp: false,
          widget: const LoadingBox(text: "Adding review..."));
      //fetch
      String url =
          Site.ADD_REVIEW + widget.productID + "/" + widget.userSession.ID;
      dynamic data = {
        "rating": newReviewRating.toString(),
        "comment": commentTextController.text,
        "token_key": Site.TOKEN_KEY,
      };

      Response response = await post(url, body: data);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        Map<String, dynamic> json = jsonDecode(response.body);
        if (json["status"] == "success") {
          widget.comments.add(Comment(
            username: widget.userSession.username,
            comment: commentTextController.text,
            rating: newReviewRating.toString(),
            userImage: widget.userSession.profile_image,
          ));
          widget.onReviewUpdated(
            widget.comments.length,
            true,
            widget.comments,
            newReviewRating,
          );
          Toaster.showIcon(
            message: "Review submitted",
            icon: Icons.check,
            context: context,
            gravity: ToastGravity.TOP,
          );
        } else {
          ToastBar.show(context, "Unable to add review... Please try again!");
        }
      } else {
        ToastBar.show(context, "Unable to add review... Please try again!");
      }
    } finally {
      if (mounted) {
        commentTextController.text = "";
        SmartDialog.dismiss();
        setState(() {});
      }
    }
  }
}
