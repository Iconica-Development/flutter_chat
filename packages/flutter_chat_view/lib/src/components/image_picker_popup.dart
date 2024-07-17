import "dart:typed_data";

import "package:flutter/material.dart";
import "package:flutter_chat_view/flutter_chat_view.dart";
import "package:flutter_chat_view/src/components/image_loading_snackbar.dart";

Future<void> onPressSelectImage(
  BuildContext context,
  ChatTranslations translations,
  ChatOptions options,
  Function(Uint8List image) onUploadImage,
) async =>
    showModalBottomSheet<Uint8List?>(
      context: context,
      builder: (BuildContext context) => options.imagePickerContainerBuilder(
        () => Navigator.of(context).pop(),
        translations,
        context,
      ),
    ).then(
      (image) async {
        if (image == null) return;
        var messenger = ScaffoldMessenger.of(context)
          ..showSnackBar(
            getImageLoadingSnackbar(translations),
          )
          ..activate();
        await onUploadImage(image);
        Future.delayed(const Duration(seconds: 1), () {
          messenger.hideCurrentSnackBar();
        });
      },
    );
