import 'package:flutter/material.dart';
import 'package:google_firebase_signin/allConstants/all_constants.dart';

Widget errorContainer() {
  return Container(
    clipBehavior: Clip.hardEdge,
    child: Image.asset(
      'assets/images/img_not_available.jpeg',
      height: Sizes.dimen_200,
      width: Sizes.dimen_200,
    ),
  );
}

/**
    Class for loading widget
 */

Widget chatImage({required String imageSrc, required Function onTap}) {
  return OutlinedButton(
    onPressed: onTap(),
    child: Image.network(
      imageSrc,
      width: Sizes.dimen_200,
      height: Sizes.dimen_200,
      fit: BoxFit.cover,
      loadingBuilder:
          (BuildContext ctx, Widget child, ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          decoration: BoxDecoration(
            color: AppColors.greyColor2,
            borderRadius: BorderRadius.circular(Sizes.dimen_10),
          ),
          width: Sizes.dimen_200,
          height: Sizes.dimen_200,
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.burgundy,
              value: loadingProgress.expectedTotalBytes != null &&
                      loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (context, object, stackTrace) => errorContainer(),
    ),
  );
}

Widget messageBubble(
    {required String chatContent,
    required EdgeInsetsGeometry? margin,
    Color? color,
    Color? textColor,
    Color? borderColor}) {
  return Container(
    padding: const EdgeInsets.all(Sizes.dimen_10),
    margin: margin,
    width: Sizes.dimen_200,
    decoration: BoxDecoration(
      color: color,
      border: Border.all(color: borderColor!, width: 1.0,),
        // border: Border.all(color: borderColor!),
      borderRadius: BorderRadius.circular(Sizes.dimen_20),
    ),
    child: Text(
      chatContent,
      style: TextStyle(fontSize: 15, color: textColor),
    ),
  );
}
