import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestLocationPermission(BuildContext context) async {
  var status = await Permission.location.status;

  if (status.isDenied) {
    var result = await Permission.location.request();
    if (result.isGranted) {
      // _goToCachedOrCurrentLocation();
      return true;
    } else if (result.isPermanentlyDenied) {
      return false;
      // showPermissionDialog(context);
    }
  } else if (status.isGranted) {
    return true;
    // _goToCachedOrCurrentLocation();
  } else if (status.isPermanentlyDenied) {
    return false;
    // showPermissionDialog(context);
  } else if (status.isGranted){
    return true;
  }
  return false;
}