import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../services/locationfunctions.dart';
import '../widgets/connectivitywidget.dart';
import 'directionsmap.dart';

class EndLocation extends StatefulWidget {
  const EndLocation({super.key});

  @override
  State<EndLocation> createState() => _EndLocationState();
}

class _EndLocationState extends State<EndLocation> {
  static final LatLng initialTarget = LatLng(25.276987, 55.296249);
  final Completer<GoogleMapController> mapController = Completer();
  LatLng? _latLng;
  Functions _functions=Functions();
  /// Indicator for the selected location
  final Set<Marker> markers = Set()
    ..add(
      Marker(
        position: initialTarget,
        markerId: MarkerId("selected-location"),
      ),
    );

  void onMapCreated(GoogleMapController controller) {
    mapController.complete(controller);
    moveToCurrentUserLocation();
  }

  void moveToLocation(LatLng latLng) {
    mapController.future.then((controller) {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: latLng,
            zoom: 15.0,
          ),
        ),
      );
    });

    setMarker(latLng);
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
          position: controllerGet.startLocations.value,
          markerId: MarkerId("first-location"),
        ),
      );
      markers.add(
        Marker(
          markerId: MarkerId("selected-location"),
          position: latLng,
        ),
      );
    });
  }

  void moveToCurrentUserLocation() {
    var location = Location();
    location.getLocation().then((locationData) {
      LatLng target = LatLng(locationData.latitude!, locationData.longitude!);
      moveToLocation(target);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controllerPut = Get.put(Functions());

    return BaseConnectivityWidget(
      child: Scaffold(
        appBar: AppBar(
          title: Text("select end location"),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: initialTarget,
                  zoom: 15,
                ),
                myLocationButtonEnabled: true,
                myLocationEnabled: true,
                onMapCreated: onMapCreated,
                onTap: (latLng) {
                  clearOverlay();
                  moveToLocation(latLng);
                  setState(() {
                    _latLng = latLng;
                  });
                  controllerPut.updateEnd(_latLng!);
                  Get.to(DirectionsMap());
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
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(right:20.0,left: 20,top:15,bottom: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "Select second postion to see direction",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),

                        ],
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
