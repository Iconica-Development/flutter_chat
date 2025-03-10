import "dart:convert";
import "dart:typed_data";
import "package:mime/mime.dart";

/// Error thrown when there is no
/// mimetype found
class MimetypeMissingError extends Error {
  @override
  String toString() => "You can only provide files that contain a mimetype";
}

/// Extension that provides a converter function from
/// Uin8List to a base64Encoded data uri.
extension ToDataUri on Uint8List {
  /// This function converts the Uint8List into
  /// a uri with a data-scheme.
  String toDataUri() {
    var mimeType = lookupMimeType("", headerBytes: this);
    if (mimeType == null) throw MimetypeMissingError();

    var base64Data = base64Encode(this);

    return "data:$mimeType;base64,$base64Data";
  }
}
