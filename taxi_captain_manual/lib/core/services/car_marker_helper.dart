import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CarMarkerHelper {
  static BitmapDescriptor? _carIcon;

  /// تحميل أيقونة السيارة من الـ assets
  static Future<BitmapDescriptor> getCarIcon() async {
    if (_carIcon != null) return _carIcon!;
    
    final ByteData data = await rootBundle.load('assets/car_icon.png');
    final Uint8List bytes = data.buffer.asUint8List();
    
    // تصغير الصورة لحجم مناسب للماركر
    final ui.Codec codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: 80,
      targetHeight: 80,
    );
    final ui.FrameInfo fi = await codec.getNextFrame();
    final ByteData? byteData = await fi.image.toByteData(format: ui.ImageByteFormat.png);
    
    if (byteData != null) {
      _carIcon = BitmapDescriptor.bytes(byteData.buffer.asUint8List());
    } else {
      _carIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    }
    
    return _carIcon!;
  }

  /// إنشاء أيقونة سيارة مع دوران (heading)
  static Future<BitmapDescriptor> getRotatedCarIcon(double heading) async {
    final ByteData data = await rootBundle.load('assets/car_icon.png');
    final Uint8List bytes = data.buffer.asUint8List();
    
    final ui.Codec codec = await ui.instantiateImageCodec(bytes, targetWidth: 80, targetHeight: 80);
    final ui.FrameInfo fi = await codec.getNextFrame();
    final ui.Image originalImage = fi.image;
    
    // رسم الصورة مع الدوران
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final double size = 80;
    
    canvas.translate(size / 2, size / 2);
    canvas.rotate(heading * math.pi / 180);
    canvas.translate(-size / 2, -size / 2);
    
    canvas.drawImage(originalImage, ui.Offset.zero, ui.Paint());
    
    final ui.Picture picture = recorder.endRecording();
    final ui.Image rotatedImage = await picture.toImage(size.toInt(), size.toInt());
    final ByteData? byteData = await rotatedImage.toByteData(format: ui.ImageByteFormat.png);
    
    if (byteData != null) {
      return BitmapDescriptor.bytes(byteData.buffer.asUint8List());
    }
    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
  }
}
