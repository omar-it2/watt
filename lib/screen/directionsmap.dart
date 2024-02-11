import 'dart:async';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'dart:convert';
import 'dart:math' show Random, max, min, cos, sqrt, asin;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:testforwatt/screen/endLocation.dart';
import 'package:testforwatt/screen/splash.dart';

import '../authentication/auhentication.dart';
import '../services/locationfunctions.dart';
import '../widgets/connectivitywidget.dart';


class DirectionsMap extends StatefulWidget {
  const DirectionsMap({super.key});

  @override
  State<DirectionsMap> createState() => _DirectionsMapState();
}

class _DirectionsMapState extends State<DirectionsMap> {
  static final LatLng initialTarget = LatLng(25.276987, 55.296249);
  final Completer<GoogleMapController> mapController = Completer();
  LatLng? _latLng;
  PolylinePoints? polylinePoints;
  final startTime=DateTime.now().obs;
  late final AuthenticationManager _authManager;
  late BitmapDescriptor pinLocationIconStart;
  late BitmapDescriptor pinLocationIconEnd;
  late BitmapDescriptor pinLocationIconduration;
  final endTime=DateTime.now().obs;
  final positionTime=DateTime.now().obs;
  Timer? _timer;
  final controller = Get.put(Functions());
  List<LatLng> polylineCoordinates = [];
  List<LatLng> polylineCoordinatesfordirection = [];
  Map<PolylineId, Polyline> polylines = {};
  double totalDistance = 0.0;
  String? _placeDistance;
  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }
  _createPolylines(LatLng start, LatLng destination) async {
    // Initializing PolylinePoints
    polylinePoints = PolylinePoints();

    // Generating the list of coordinates to be used for
    // drawing the polylines
    PolylineResult result = await polylinePoints!.getRouteBetweenCoordinates(
      "AIzaSyDKET0erHag1uU5p4LVulYAsId8sgRWu-Y", // Google Maps API Key
      PointLatLng(start.latitude, start.longitude),
      PointLatLng(destination.latitude, destination.longitude),
      travelMode: TravelMode.driving,
    );

    // Adding the coordinates to the list
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    setState(() {
      totalDistance = 0.00;
    });
    for (int i = 0; i < polylineCoordinates.length - 1; i++) {
      totalDistance += _coordinateDistance(
        polylineCoordinates[i].latitude,
        polylineCoordinates[i].longitude,
        polylineCoordinates[i + 1].latitude,
        polylineCoordinates[i + 1].longitude,
      );
    }
    setState(() {
      if (totalDistance != 0.0) {
       controller.setTotalDistance(totalDistance);
      }
      _placeDistance = totalDistance.toStringAsFixed(2);
      print('DISTANCE: $_placeDistance km');
    });
    // Defining an ID
    PolylineId id = PolylineId('poly');

    // Initializing Polyline
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.blue,
      points: polylineCoordinates,
      width: 5,
    );

    // Adding the polyline to the map
    polylines[id] = polyline;
  }
  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }
  Future<BitmapDescriptor> getBitmapDescriptorFromAssetBytes(
      String path, int width) async {
    final Uint8List imageData = await getBytesFromAsset(path, width);
    return BitmapDescriptor.fromBytes(imageData);
  }
  /// Indicator for the selected location
  final Set<Marker> markers = Set();
    // ..add(
    //   Marker(
    //     position: initialTarget,
    //     markerId: MarkerId("selected-location"),
    //   ),
    // );
  void onMapCreated(GoogleMapController controller) {
    mapController.complete(controller);
    moveToLocation();
    // moveToCurrentUserLocation();
  }
  void moveToLocation() {
    final LatLng southwest = LatLng(
      min(controller.startLocations.value.latitude, controller.endLocations.value.latitude),
      min(controller.startLocations.value.longitude, controller.endLocations.value.longitude),
    );

    final LatLng northeast = LatLng(
      max(controller.startLocations.value.latitude, controller.endLocations.value.latitude),
      max(controller.startLocations.value.longitude, controller.endLocations.value.longitude),
    );
    LatLngBounds builder =
    LatLngBounds(northeast: northeast, southwest: southwest);
    mapController.future.then((controller) async {
      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(
          builder, 50, // padding
        ),
      );
    });

    setMarker(controller.startLocations.value);



  }
  OverlayEntry? overlayEntry;
  void clearOverlay() {
    if (overlayEntry != null) {
      overlayEntry!.remove();
      overlayEntry = null;
    }
  }
  void setMarker(LatLng latLng) {
    final controllerGet = Get.find<Functions>();
    // markers.clear();
    setState(() {
      markers.clear();
      markers.add(
        Marker(
          icon: pinLocationIconStart,
          position: controllerGet.startLocations.value,
          markerId: MarkerId("first-location"),
        ),
      );
      markers.add(
        Marker(
          icon: pinLocationIconduration,
          markerId: MarkerId("place-location"),
          position: latLng,
        ),
      );
      markers.add(
        Marker(
          icon: pinLocationIconEnd,
          markerId: MarkerId("selected-location"),
          position: controllerGet.endLocations.value,
        ),
      );
    });
  }
  // void moveToCurrentUserLocation() {
  //   var location = Location();
  //   location.getLocation().then((locationData) {
  //     LatLng target = LatLng(locationData.latitude!, locationData.longitude!);
  //     moveToLocation(target);
  //
  //   });
  // }
  @override
  void initState() {
    super.initState();
    _authManager = Get.find();
    Future.delayed(Duration.zero, () async {
      pinLocationIconStart = await getBitmapDescriptorFromAssetBytes(

          'assets/icons/shop_icon.png', 100);
      pinLocationIconEnd = await getBitmapDescriptorFromAssetBytes(
          'assets/icons/icon_here_map.png', 100);
      pinLocationIconduration  = await getBitmapDescriptorFromAssetBytes(
          'assets/icons/icon_box_map.png', 100);
      _createPolylines(controller.startLocations.value,controller.endLocations.value);

    });
  }

  @override
  void dispose() {
    overlayEntry?.remove();
    _timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseConnectivityWidget(
      child: Scaffold(
        appBar: AppBar(title: Text("directions"),actions: [IconButton(onPressed: (){
          _authManager.logOut();
          Get.to(SplashView());
        }, icon: Icon(Icons.logout,color: Colors.red,))],),
        body: Column(
          children: <Widget>[
            Expanded(
              child: GoogleMap(
                polylines: Set<Polyline>.of(polylines.values),
                initialCameraPosition: CameraPosition(
                  target: initialTarget,
                  zoom: 15,
                ),
                myLocationButtonEnabled: true,
                myLocationEnabled: true,
                onMapCreated: onMapCreated,
                onTap: (latLng)  {
                  _createPolylines(controller.startLocations.value,controller.endLocations.value);
                  // clearOverlay();
                  moveToLocation();
                  // setState(() {
                  //   _latLng = latLng;
                  // });
                  // controller.updateStart(_latLng!);
                  // Get.to(EndLocation());
                },
                markers: markers,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black45,
                      offset: Offset(0.0, 1.0), //(x,y)
                      blurRadius: 8.0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right:20.0,left: 20,top:15,bottom: 5),
                      child: Obx(()=>Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "${controller.totalDistance.value.toStringAsFixed(2)} KM",
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "${(controller.totalDistance.value*2).toStringAsFixed(2)} AED",
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),),
                    ),
                    Obx(()=>Padding(
                      padding: const EdgeInsets.only(right:20.0,left: 20,bottom: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            "Time start:${DateFormat('HH:mm:ss').format(startTime.value)}",
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            "duration: ${positionTime.value.difference(startTime.value).inSeconds}",
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )),
                    Obx(()=>Padding(
                      padding: const EdgeInsets.only(right:20.0,left: 20,bottom: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            "Time End: ${DateFormat('HH:mm:ss').format(endTime.value)}",
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )),
                    const Divider(
                      height: 2,
                    ),
      //
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius:
                          const BorderRadius.all(Radius.circular(30)),
                          color:
                          Theme.of(context).primaryColor,
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_timer !=null){
                              _timer!.cancel();
                            }
                            int time=1;
                            startTime.value=DateTime.now();
                            endTime.value=DateTime.now();
                            int distance=0;
                            _timer =
                                Timer.periodic(Duration(seconds: 1), (Timer t){
                                  positionTime.value=DateTime.now();
                                  endTime.value=DateTime.now();
                                  print("time");
                                  time++;
                                  print(time);
                                  print(time%2);
                                  print(polylineCoordinates.length);
                                  if(time%2 ==0){

                                    if(distance<polylineCoordinates.length){
                                      setMarker(polylineCoordinates[distance]);
                                    }else{
                                      endTime.value=DateTime.now();
                                      t.cancel();
                                    }
                                    distance++;
                                  }
                                });

                          },
      //                        color: Theme.of(context).primaryColor,
                          child: const Text("Click to follow the path"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
