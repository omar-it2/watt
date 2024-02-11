import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Functions extends GetxController{
  final startLocations=const LatLng(0.0,0.0).obs;
  final endLocations=const LatLng(0.0,0.0).obs;
  final targetLocations=const LatLng(0.0,0.0).obs;
  final totalDistance=0.0.obs;
updateStart(LatLng _latLng){
  startLocations.value=_latLng;
  update();
}
updateEnd(LatLng latLng){
  endLocations.value=latLng;
  update();
}
setTotalDistance(double value){
  totalDistance.value=value;
  update();
}
}