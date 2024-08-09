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
) async =>
    showModalBottomSheet<Uint8List?>(
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
              imagePickerTheme: ImagePickerTheme(
                title: options.translations.imagePickerTitle,
                titleTextSize: 16,
                titleAlignment: TextAlign.center,
                iconSize: 60.0,
                makePhotoText: options.translations.takePicture,
                selectImageText: options.translations.uploadFile,
                selectImageIcon: const Icon(
                  Icons.insert_drive_file_rounded,
                  size: 60,
                ),
              ),
              customButton: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  options.translations.cancelImagePickerBtn,
                  style: Theme.of(context).textTheme.bodyMedium,
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
