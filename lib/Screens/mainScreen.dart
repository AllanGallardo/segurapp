import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:segurapp/Screens/navbar.dart';
import 'package:segurapp/services/firebase.dart';

// ignore: constant_identifier_names
const MAPBOX_ACCESS_TOKEN = 'sk.eyJ1IjoiYWJ1cmlrIiwiYSI6ImNsd3k5ZWdlZzFqbDUybXB6NXFiaDRpMnEifQ.BzLqhvgP3XxaD3Vk1mAxzA';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  LatLng? myPosition;
  late MapController mapController;
  List<dynamic> incidents = [];
  List<LatLng> dangerZones = [];
  Map<String, bool> filterOptions = {
    'robo': true,
    'accidente': true,
    'violencia': true,
    'incendio': true,
    'extravio': true,
    'sospecha': true,
    'disturbio': true,
    'corte': true,
    'portazo': true,
    'otro': true,
  };

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
    super.initState();
    mapController = MapController();
    getCurrentLocation();
    loadIncidents();
  }

  Future<void> loadIncidents() async {
    var loadedIncidents = await getIncidents();
    setState(() {
      incidents = loadedIncidents.map((incident) {
        if (incident['ubicacion'] is String) {
          var location = incident['ubicacion'].split(',');
          incident['ubicacion'] = LatLng(double.parse(location[0]), double.parse(location[1]));
        }
        return incident;
      }).toList();
    });
    detectDangerZones();
  }

  void detectDangerZones() {
    Map<String, List<LatLng>> incidentGroups = {};
    for (var incident in incidents) {
      String type = incident['tipo'];
      LatLng location = incident['ubicacion'];
      if (!incidentGroups.containsKey(type)) {
        incidentGroups[type] = [];
      }
      incidentGroups[type]!.add(location);
    }

    List<LatLng> dangerZonesDetected = [];
    incidentGroups.forEach((type, locations) {
      for (int i = 0; i < locations.length; i++) {
        int count = 1;
        for (int j = 0; j < locations.length; j++) {
          if (i != j && Geolocator.distanceBetween(
              locations[i].latitude, locations[i].longitude,
              locations[j].latitude, locations[j].longitude
          ) <= 1000) {
            count++;
          }
        }
        if (count >= 3) {
          dangerZonesDetected.add(locations[i]);
        }
      }
    });

    setState(() {
      dangerZones = dangerZonesDetected.toSet().toList();
    });

    print('Zonas peligrosas detectadas: $dangerZones');
  }

  Widget getIconForIncident(String type) {
    switch (type) {
      case 'robo':
        return Icon(Icons.local_police, color: Colors.red, size: 40);
      case 'accidente':
        return Icon(Icons.car_crash, color: Colors.orange, size: 40);
      case 'violencia':
        return Icon(Icons.warning, color: Colors.purple, size: 40);
      case 'incendio':
        return Icon(Icons.fire_extinguisher, color: Colors.red, size: 40);
      case 'extravio':
        return Icon(Icons.search, color: Colors.blue, size: 40);
      case 'sospecha':
        return Icon(Icons.help, color: Colors.yellow, size: 40);
      case 'disturbio':
        return Icon(Icons.warning_amber, color: Colors.deepOrange, size: 40);
      case 'corte':
        return Icon(Icons.block, color: Colors.black, size: 40);
      case 'portazo':
        return Icon(Icons.car_crash_outlined, color: Colors.redAccent, size: 40);
      case 'otro':
        return Icon(Icons.report, color: Colors.grey, size: 40);
      default:
        return Icon(Icons.location_on, color: Colors.blue, size: 40);
    }
  }

  void showIncidentDetails(BuildContext context, dynamic incident) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detalle de Incidencia'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Tipo: ${incident['tipo']}'),
              Text('Descripción: ${incident['descripcion']}'),
              Text('Fecha: ${incident['fecha']}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Column(
            children: filterOptions.keys.map((String key) {
              return CheckboxListTile(
                title: Text(key),
                value: filterOptions[key],
                onChanged: (bool? value) {
                  setState(() {
                    filterOptions[key] = value!;
                  });
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('SegurApp'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              showFilterOptions(context);
            },
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          myPosition == null
              ? const CircularProgressIndicator()
              : FlutterMap(
            mapController: mapController,
            options: MapOptions(
              center: myPosition,
              zoom: 16,
              onTap: (tapPosition, latLng) {
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
                  ),
                  ...incidents.where((incident) {
                    return filterOptions[incident['tipo']] ?? false;
                  }).map((incident) {
                    if (incident['ubicacion'] != null) {
                      return Marker(
                        width: 80.0,
                        height: 80.0,
                        point: incident['ubicacion'],
                        child: GestureDetector(
                          onTap: () => showIncidentDetails(context, incident),
                          child: getIconForIncident(incident['tipo']),
                        ),
                      );
                    }
                    return Marker(
                      width: 0.0,
                      height: 0.0,
                      point: LatLng(0, 0),
                      child: Container(),
                    );
                  }).toList(),
                ],
              ),
              CircleLayer(
                circles: dangerZones.map((zone) {
                  return CircleMarker(
                    point: zone,
                    color: Colors.red.withOpacity(0.5),
                    borderStrokeWidth: 2,
                    borderColor: Colors.red,
                    radius: 1000, // 1 km radius
                  );
                }).toList(),
              ),
            ],
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
                LatLng currentLocation = await getCurrentLocation();
                mapController.move(currentLocation, 16);
              },
              backgroundColor: const Color.fromARGB(255, 255, 3, 3),
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
