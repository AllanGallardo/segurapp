// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:segurapp/Screens/navbar.dart';
import 'package:segurapp/incidents/providers/incident_provider.dart';
//import 'package:flutter_map/flutter_map.dart' show Crs;

// ignore: constant_identifier_names
const MAPBOX_ACCESS_TOKEN =
    'sk.eyJ1IjoiYWJ1cmlrIiwiYSI6ImNsd3k5ZWdlZzFqbDUybXB6NXFiaDRpMnEifQ.BzLqhvgP3XxaD3Vk1mAxzA';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  LatLng? myPosition;

  Future<Position> determinePosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('error');
      }
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<LatLng> getCurrentLocation() async {
    Position position = await determinePosition();
    setState(() {
      myPosition = LatLng(position.latitude, position.longitude);
      // ignore: avoid_print
      print(myPosition);
    });
    return myPosition!;
  }

  @override
  void initState() {
    getCurrentLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    IncidentProvider incidentProvider = context.watch<IncidentProvider>();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text('SegurApp'),
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        children: <Widget>[
          myPosition == null
            ? const CircularProgressIndicator()
            : FlutterMap(
                options: MapOptions(
                  onMapReady: () {
                    incidentProvider.getLocation(myPosition!);
                  },
                  initialCenter: myPosition!,
                  initialZoom: 16,
                  onTap: (tapPosition, latLng) {
                    // Aquí puedes usar tapPosition y latLng
                    // Por ejemplo, puedes querer actualizar myPosition con latLng
                    setState(() {
                      myPosition = latLng;
                    });
                  },
                  minZoom: 5, 
                  maxZoom: 25, 
                  crs: const Epsg3857(), 
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}',
                    additionalOptions: const {
                      'accessToken': MAPBOX_ACCESS_TOKEN,
                      'id': 'mapbox/streets-v12'
                    },
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 80.0,
                        height: 80.0,
                        point: myPosition!,
                        child: const Icon(
                          Icons.person_pin,
                          color: Color.fromARGB(255, 104, 144, 212),
                          size: 40,
                        ),
                      )
                    ],
                  )
                ],
              ),
            Positioned(
            top: 10.0,
            left: 10.0,
            child: FloatingActionButton(
              onPressed: () {
              Navigator.pushNamed(context, '/editarperfil'); // Cambio aquí
              },
              backgroundColor: Colors.blueGrey,
              child: const Icon(Icons.manage_accounts, size: 40), // Cambio aquí
              shape: CircleBorder(),
            ),
            ),
          Positioned(
            top: 10.0,
            right: 10.0,
            child: FloatingActionButton(
              onPressed: () {
                // Aquí va tu código para el botón de pánico
              },
              backgroundColor: Colors.red,
              child: const Icon(Icons.warning),
            ),
          ),
          Positioned(
            bottom: 10.0,
            right: 10.0,
            child: FloatingActionButton(
              onPressed: () async {
                Position position = await determinePosition();
                setState(() {
                  myPosition = LatLng(position.latitude, position.longitude);
                });
              },
              backgroundColor: Colors.red,
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomNavigationBar(
        context: context,
      ),
    );
  }
}