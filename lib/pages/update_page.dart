import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Asegúrate de tener esta importación
import '../services/firebase.dart';

class UpdatePage extends StatefulWidget {
  const UpdatePage({super.key});

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  TextEditingController clientController = TextEditingController(text: '');
  TextEditingController fechaController = TextEditingController(text: '');
  TextEditingController descController = TextEditingController(text: '');
  TextEditingController tipoController = TextEditingController(text: '');
  TextEditingController estadoController = TextEditingController(text: '');
  TextEditingController locationController = TextEditingController(text: '');
  DateTime? fechaCierre;
  LatLng? incidentLocation;

  final DateFormat dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');

  Future<Position> determinePosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<void> getCurrentLocation() async {
    try {
      Position position = await determinePosition();
      setState(() {
        incidentLocation = LatLng(position.latitude, position.longitude);
        locationController.text = '${position.latitude}, ${position.longitude}';
      });
    } catch (e) {
      // Handle the error
    }
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Set<dynamic>;
    List<dynamic> argumentsList = arguments.toList();
    final clienteData = argumentsList[0];
    final fechaData = argumentsList[1];
    final descData = argumentsList[3];
    final tipoData = argumentsList[4];
    final estadoData = argumentsList[5];
    final imagen = argumentsList[6];
    final ubicacion = argumentsList[7];

    clientController.text = clienteData;
    fechaController.text = fechaData;
    descController.text = descData;
    tipoController.text = tipoData;
    estadoController.text = estadoData;
    locationController.text = ubicacion ?? '';

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        onPressed: () async {
          final confirmed = await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Confirmar'),
                content: const Text('¿Está seguro que desea eliminar esta incidencia?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('No'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Sí, eliminar'),
                  ),
                ],
              );
            },
          );

          if (confirmed ?? false) {
            await deleteIncident(argumentsList[2]);
            Navigator.pop(context);
          }
        },
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      appBar: AppBar(
        title: const Text('Modificar Incidencia'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: clientController,
                decoration: const InputDecoration(
                  labelText: 'Ingrese nombre del usuario',
                ),
              ),
              TextField(
                controller: fechaController,
                decoration: const InputDecoration(
                  labelText: 'Ingrese la fecha de la incidencia',
                ),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Descripción de la incidencia',
                ),
              ),
              TextField(
                controller: tipoController,
                decoration: const InputDecoration(
                  labelText: 'Tipo de incidencia',
                ),
              ),
              Container(
                margin: const EdgeInsets.all(10),
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: imagen != ''
                    ? Image.network(imagen)
                    : const Center(
                  child: Text(
                    "Imagen no seleccionada",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: getCurrentLocation,
                child: const Text('Obtener ubicación actual'),
              ),
              const Gap(10),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Ingrese la ubicación (opcional)',
                ),
              ),
              const Gap(10),
              ElevatedButton(
                onPressed: () async {
                  final newEstado = estadoController.text == 'Abierta' ? 'Cerrada' : 'Abierta';
                  final newFechaCierre = newEstado == 'Cerrada' ? dateFormat.format(DateTime.now()) : null;

                  await updateState(argumentsList[2], newEstado, newFechaCierre);
                  setState(() {
                    estadoController.text = newEstado;
                    fechaCierre = newEstado == 'Cerrada' ? DateTime.now() : null;
                  });
                  Navigator.pop(context, true);
                },
                child: Text(estadoController.text == 'Abierta' ? 'Cerrar Incidencia' : 'Reabrir Incidencia'),
              ),
              ElevatedButton(
                onPressed: () async {
                  LatLng? manualLocation;
                  if (locationController.text.isNotEmpty) {
                    final coords = locationController.text.split(',');
                    if (coords.length == 2) {
                      final lat = double.tryParse(coords[0].trim());
                      final lon = double.tryParse(coords[1].trim());
                      if (lat != null && lon != null) {
                        manualLocation = LatLng(lat, lon);
                      }
                    }
                  }
                  final locationToUse = manualLocation ?? incidentLocation;
                  GeoPoint? geoPoint;
                  if (locationToUse != null) {
                    geoPoint = GeoPoint(locationToUse.latitude, locationToUse.longitude);
                  }

                  await updateIncident(
                    argumentsList[2],
                    clientController.text,
                    fechaController.text,
                    descController.text,
                    tipoController.text,
                    estadoController.text,
                    fechaCierre != null ? dateFormat.format(fechaCierre!) : null,
                    geoPoint, // Pasar GeoPoint en lugar de LatLng
                  ).then((value) => Navigator.pop(context));
                },
                child: const Text('Actualizar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
