import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../manager.dart';
import '../../../utils/utils.dart';

class MapWidget extends StatefulWidget {
  MapWidget({super.key, required this.manager});
  Manager manager;
  final Completer<GoogleMapController> controllerCompleter =
      Completer<GoogleMapController>();

  //const MapWidget({super.key, required this.controllerCompleter});
  @override
  State<MapWidget> createState() => _MapState();
}

class _MapState extends State<MapWidget> {
  final Map<String, LatLng> locals = {
    'ess': const LatLng(38.52275567301086, -8.841010269144789),
    'esce': const LatLng(38.52266940145118, -8.841144169323442),
    'ese': const LatLng(38.520075729121054, -8.838204661370296),
    'ests': const LatLng(38.52199531703995, -8.838600716392541),
    'estb': const LatLng(38.65254138787937, -9.048843018238152),
  };
  final _markers = <Marker>{
    Marker(
      markerId: const MarkerId('ess'),
      position: const LatLng(38.52275567301086, -8.841010269144789),
      infoWindow: const InfoWindow(
        title: 'ESS',
        snippet: 'Escola Superior de Saúde',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
    ),
    Marker(
      markerId: const MarkerId('esce'),
      position: const LatLng(38.52266940145118, -8.841144169323442),
      infoWindow: const InfoWindow(
        title: 'ESCE',
        snippet: 'Escola Superior de Ciências Empresariais',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    ),
    Marker(
      markerId: const MarkerId('ese'),
      position: const LatLng(38.520075729121054, -8.838204661370296),
      infoWindow: const InfoWindow(
        title: 'ESE',
        snippet: 'Escola Superior de Educação',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
    ),
    Marker(
      markerId: const MarkerId('ests'),
      position: const LatLng(38.52199531703995, -8.838600716392541),
      infoWindow: const InfoWindow(
        title: 'ESTS',
        snippet: 'Escola Superior de Tecnologia de Setúbal',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
    ),
    Marker(
      markerId: const MarkerId('estb'),
      position: const LatLng(38.65254138787937, -9.048843018238152),
      infoWindow: const InfoWindow(
        title: 'ESTB',
        snippet: 'Escola Superior de Tecnologia do Barreiro',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
    ),
  };
  final _polygons = <Polygon>{
    Polygon(
      polygonId: const PolygonId('ips'),
      points: const [
        LatLng(38.52369782149787, -8.842641622206202),
        LatLng(38.517588663290326, -8.838750185915375),
        LatLng(38.519575194826196, -8.835088408159743),
        LatLng(38.523498184000566, -8.838622597840265),
      ],
      fillColor: Colors.green.withOpacity(0.3),
      strokeColor: Colors.green,
      strokeWidth: 4,
    ),
  };
  @override
  void initState() {
    _requestPermission();

    super.initState();
  }

  bool _hasPermission = false;
  Future<void> _requestPermission() async {
    _hasPermission = await widget.manager.getPermission("location");
    print(_hasPermission);
    if (!_hasPermission) {
      showSnackbar(
          backgroundColor: Colors.red,
          context: context,
          message: 'Necessita de Permitir a sua localização nos Settings!');
      return;
    }
    await Permission.location.request();
    if (mounted) {
      setState(() {});
    }
  }

  static const CameraPosition _ipsCameraPosition = CameraPosition(
      target: LatLng(38.52225817080751, -8.838708916649127), zoom: 15);
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      GoogleMap(
          initialCameraPosition: _ipsCameraPosition,
          myLocationEnabled: _hasPermission,
          markers: _markers,
          polygons: _polygons,
          onMapCreated: (GoogleMapController controller) {
            widget.controllerCompleter.complete(controller);
          }),
      Container(
        decoration: BoxDecoration(
            color: Colors.white70,
            boxShadow: [BoxShadow(color: Colors.black12, spreadRadius: 1)],
            borderRadius: BorderRadius.all(Radius.circular(4))),
        height: 70,
        width: 260,
        child: Row(
          children: [
            Column(
              children: [
                IconButton(
                    onPressed: () => {goToLocation(locals['ests']!)},
                    icon: Icon(
                      Icons.school,
                      color: Colors.yellow,
                      size: 40,
                    )),
                Center(child: Text('ESTS'))
              ],
            ),
            Column(
              children: [
                IconButton(
                    onPressed: () => {goToLocation(locals['ese']!)},
                    icon: Icon(
                      Icons.school,
                      color: Colors.orange,
                      size: 40,
                    )),
                Center(child: Text('ESE'))
              ],
            ),
            Column(
              children: [
                IconButton(
                    onPressed: () => {goToLocation(locals['esce']!)},
                    icon: Icon(
                      Icons.school,
                      color: Color.fromARGB(255, 10, 7, 192),
                      size: 40,
                    )),
                Center(child: Text('ESCE'))
              ],
            ),
            Column(
              children: [
                IconButton(
                    onPressed: () => {goToLocation(locals['ess']!)},
                    icon: Icon(
                      Icons.school,
                      color: Color.fromARGB(255, 142, 39, 176),
                      size: 40,
                    )),
                Center(child: Text('ESS'))
              ],
            ),
            Column(
              children: [
                IconButton(
                    onPressed: () => {goToLocation(locals['estb']!)},
                    icon: Icon(
                      Icons.school,
                      color: Color.fromARGB(255, 220, 88, 243),
                      size: 40,
                    )),
                Center(child: Text('ESTB'))
              ],
            ),
          ],
        ),
      ),
    ]);
  }

  void goToLocation(LatLng location) async {
    final GoogleMapController controller =
        await widget.controllerCompleter.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(location.latitude, location.longitude),
        zoom: 17.0,
      ),
    ));
  }
}
