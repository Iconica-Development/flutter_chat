import "dart:typed_data";

import "package:flutter/material.dart";
import "package:flutter_chat/src/config/chat_options.dart";
import "package:flutter_chat/src/config/chat_translations.dart";
import "package:flutter_image_picker/flutter_image_picker.dart";

/// The function to call when the user selects an image
Future<void> onPressSelectImage(
  BuildContext context,
  ChatOptions options,
  Function(Uint8List image) onUploadImage,
) async {
  var theme = Theme.of(context);
  return showModalBottomSheet<Uint8List?>(
    context: context,
    builder: (BuildContext context) =>
        options.builders.imagePickerContainerBuilder?.call(
          context,
          () => Navigator.of(context).pop(),
          options.translations,
        ) ??
        Container(
          padding: const EdgeInsets.all(8.0),
          color: Colors.white,
          child: ImagePicker(
            theme: ImagePickerTheme(
              titleStyle: theme.textTheme.titleMedium,
              iconSize: 40,
              selectImageText: "UPLOAD FILE",
              makePhotoText: "TAKE PICTURE",
              selectImageIcon: const Icon(
                size: 40,
                Icons.insert_drive_file,
              ),
              closeButtonBuilder: (onTap) => TextButton(
                onPressed: () {
                  onTap();
                },
                child: Text(
                  "Cancel",
                  style: theme.textTheme.bodyMedium!.copyWith(
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ),
        ),
  ).then(
    (image) async {
      if (image == null) return;
      var messenger = ScaffoldMessenger.of(context)
        ..showSnackBar(
          _getImageLoadingSnackbar(options.translations),
        )
        ..activate();
      await onUploadImage(image);
      Future.delayed(const Duration(seconds: 1), () {
        messenger.hideCurrentSnackBar();
      });
    },
  );
}

SnackBar _getImageLoadingSnackbar(ChatTranslations translations) => SnackBar(
      duration: const Duration(minutes: 1),
      content: Row(
        children: [
          const SizedBox(
            width: 25,
            height: 25,
            child: CircularProgressIndicator(color: Colors.grey),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(translations.imageUploading),
          ),
        ],
      ),
    );
