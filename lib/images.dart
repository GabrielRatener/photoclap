
import 'dart:io';
import 'package:photo_manager/photo_manager.dart';

Stream<File> getAllPhotos() async* {
  var permitted = await PhotoManager.requestPermission();

  if (permitted) {
    final List<AssetPathEntity> photos = await PhotoManager.getImageAsset();

    for (var entity in photos) {
      List<AssetEntity> list = await entity.getAssetListPaged(0, 100000000);

      for (var image in list) {
        yield await image.file;
      }
    }
  }
}
