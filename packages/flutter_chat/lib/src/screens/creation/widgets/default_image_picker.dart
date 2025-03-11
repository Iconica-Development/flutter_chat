import "dart:typed_data";

import "package:flutter/material.dart";
import "package:flutter_accessibility/flutter_accessibility.dart";
import "package:flutter_chat/src/config/chat_options.dart";
import "package:flutter_chat/src/util/scope.dart";
import "package:flutter_image_picker/flutter_image_picker.dart";

/// The function to call when the user selects an image
Future<void> onPressSelectImage(
  BuildContext context,
  ChatOptions options,
  Function(Uint8List image) onUploadImage,
) async {
  var image = await options.builders.imagePickerBuilder.call(context);

  if (image == null) return;
  await onUploadImage(image);
}

/// Default image picker dialog for selecting an image from the gallery or
/// taking a photo.
class DefaultImagePickerDialog extends StatelessWidget {
  /// Creates a new default image picker dialog.
  const DefaultImagePickerDialog({
    super.key,
  });

  /// Builds the default image picker dialog.
  static Future<Uint8List?> builder(BuildContext context) async =>
      showModalBottomSheet<Uint8List?>(
        context: context,
        builder: (context) => const DefaultImagePickerDialog(),
      );

  @override
  Widget build(BuildContext context) {
    var chatScope = ChatScope.of(context);
    var options = chatScope.options;
    var translations = options.translations;
    var theme = Theme.of(context);
    var textTheme = theme.textTheme;

    return options.builders.imagePickerContainerBuilder?.call(
          context,
          () => Navigator.of(context).pop(),
          translations,
        ) ??
        Container(
          padding: const EdgeInsets.all(8.0),
          color: Colors.white,
          child: ImagePicker(
            config: ImagePickerConfig(
              imageQuality: options.imageQuality.clamp(0, 100),
            ),
            theme: ImagePickerTheme(
              spaceBetweenIcons: 32.0,
              iconColor: theme.primaryColor,
              title: translations.imagePickerTitle,
              titleStyle: textTheme.titleMedium,
              iconSize: 60.0,
              makePhotoText: translations.takePicture,
              selectImageText: translations.uploadFile,
              selectImageIcon: Icon(
                color: theme.primaryColor,
                Icons.insert_drive_file_rounded,
                size: 60,
              ),
              closeButtonBuilder: (ontap) => CustomSemantics(
                identifier: options.semantics.imagePickerCancelButton,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    translations.cancelImagePickerBtn,
                    style: textTheme.bodyMedium!.copyWith(
                      fontSize: 18,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
  }
}
