import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

Uint8List rgba2bitmap(
  Uint8List content, 
  int width, 
  int height
) {
  const int headerSize = 122;
  final int contentSize = content.length;
  final int fileLength =  contentSize + headerSize;

  final Uint8List headerIntList = Uint8List(fileLength);

  final ByteData bd = headerIntList.buffer.asByteData();
  bd.setUint8(0x0, 0x42);
  bd.setUint8(0x1, 0x4d);
  bd.setInt32(0x2, fileLength, Endian.little);
  bd.setInt32(0xa, headerSize, Endian.little);
  bd.setUint32(0xe, 108, Endian.little);
  bd.setUint32(0x12, width, Endian.little);
  bd.setUint32(0x16, -height, Endian.little);//-height
  bd.setUint16(0x1a, 1, Endian.little);
  bd.setUint32(0x1c, 32, Endian.little); // pixel size
  bd.setUint32(0x1e, 3, Endian.little); //BI_BITFIELDS
  bd.setUint32(0x22, contentSize , Endian.little);
  bd.setUint32(0x36, 0x000000ff, Endian.little);
  bd.setUint32(0x3a, 0x0000ff00, Endian.little);
  bd.setUint32(0x3e, 0x00ff0000, Endian.little);
  bd.setUint32(0x42, 0xff000000, Endian.little);

  headerIntList.setRange(
    headerSize,
    fileLength,
    content,
  );

  return headerIntList;
}
Uint8List rgb2rgba(Uint8List content,int alpha,[int? toTransparent]){
  final int size = content.length~/3;
  alpha = alpha<0?0:alpha>255?255:alpha;
  final Uint8List list = Uint8List(size*4);

  for(int i = 0, j= 0; i < list.length-4;i+=4,j+=3){
    list[i] = content[j];
    list[i+1] = content[j+1];
    list[i+2] = content[j+2];
    int val = content[j]+content[j+1]+content[j+2];
    if(toTransparent != null && val < 75){
      list[i+3] = 0;
    }
    else{
      list[i+3] = alpha;
    }
  }
  return list;
}
/// Image format that ML Kit takes to process the image.
class InputImage {
  /// The file path to the image.
  final String? filePath;

  /// The bytes of the image.
  final Uint8List? bytes;

  /// The type of image.
  final InputImageType type;

  /// The image data when creating an image of type = [InputImageType.bytes].
  final InputImageMetadata? metadata;

  InputImage._({this.filePath, this.bytes, required this.type, this.metadata});

  /// Creates an instance of [InputImage] from path of image stored in device.
  factory InputImage.fromFilePath(String path) {
    return InputImage._(filePath: path, type: InputImageType.file);
  }

  /// Creates an instance of [InputImage] by passing a file.
  factory InputImage.fromFile(File file) {
    return InputImage._(filePath: file.path, type: InputImageType.file);
  }

  /// Creates an instance of [InputImage] using bytes.
  factory InputImage.fromBytes(
      {required Uint8List bytes, required InputImageMetadata metadata}) {
    return InputImage._(
        bytes: bytes, type: InputImageType.bytes, metadata: metadata);
  }

  /// Returns a json representation of an instance of [InputImage].
  Map<String, dynamic> toJson() => {
        'bytes': bytes,
        'type': type.name,
        'path': filePath,
        'metadata': metadata?.toJson()
      };
}

/// The type of [InputImage].
enum InputImageType {
  file,
  bytes,
}

/// Data of image required when creating image from bytes.
class InputImageMetadata {
  /// Size of image.
  final Size size;

  /// Image rotation degree.
  final InputImageRotation rotation;

  /// Format of the input image.
  ///
  /// Not used on Android.
  final InputImageFormat format;

  /// The row stride for color plane, in bytes.
  ///
  /// Not used on Android.
  final int bytesPerRow;

  /// Constructor to create an instance of [InputImageMetadata].
  InputImageMetadata({
    required this.size,
    required this.rotation,
    required this.format,
    required this.bytesPerRow,
  });

  /// Returns a json representation of an instance of [InputImageMetadata].
  Map<String, dynamic> toJson() => {
        'width': size.width,
        'height': size.height,
        'rotation': rotation.rawValue,
        'image_format': format.rawValue,
        'bytes_per_row': bytesPerRow,
      };
}

/// The camera rotation angle to be specified
enum InputImageRotation {
  rotation0deg,
  rotation90deg,
  rotation180deg,
  rotation270deg
}

extension InputImageRotationValue on InputImageRotation {
  int get rawValue {
    switch (this) {
      case InputImageRotation.rotation0deg:
        return 0;
      case InputImageRotation.rotation90deg:
        return 90;
      case InputImageRotation.rotation180deg:
        return 180;
      case InputImageRotation.rotation270deg:
        return 270;
    }
  }

  static InputImageRotation? fromRawValue(int rawValue) {
    try {
      return InputImageRotation.values
          .firstWhere((element) => element.rawValue == rawValue);
    } catch (_) {
      return null;
    }
  }
}

/// To indicate the format of image while creating input image from bytes
enum InputImageFormat {
  nv21,
  yv12,
  yuv_420_888,
  yuv420,
  bgra8888,
}

extension InputImageFormatValue on InputImageFormat {
  // source: https://developers.google.com/android/reference/com/google/mlkit/vision/common/InputImage#constants
  int get rawValue {
    switch (this) {
      case InputImageFormat.nv21:
        return 17;
      case InputImageFormat.yv12:
        return 842094169;
      case InputImageFormat.yuv_420_888:
        return 35;
      case InputImageFormat.yuv420:
        return 875704438;
      case InputImageFormat.bgra8888:
        return 1111970369;
    }
  }

  static InputImageFormat? fromRawValue(int rawValue) {
    try {
      return InputImageFormat.values
          .firstWhere((element) => element.rawValue == rawValue);
    } catch (_) {
      return null;
    }
  }
}
