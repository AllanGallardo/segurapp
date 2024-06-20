import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../services/firebase.dart';
import '../services/imagen_up.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  TextEditingController clientController = TextEditingController(text: '');
  TextEditingController fechaController = TextEditingController(text: '');
  TextEditingController descController = TextEditingController(text: '');
  TextEditingController locationController = TextEditingController(text: '');
  String tipo = 'robo';
  File? imagenUpload;
  String linkImagen = '';
  LatLng? incidentLocation;

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
        locationController.text =
        '${position.latitude}, ${position.longitude}';
      });
    } catch (e) {
      // Handle the error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al obtener la ubicación: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Incidencia'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
        child: Column(
          children: [
            TextField(
              controller: clientController,
              decoration: const InputDecoration(
                labelText: 'Ingrese nombre del usuario',
              ),
            ),
            const Gap(10),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Describa la situación',
              ),
            ),
            const Gap(15),
            Container(
              margin: const EdgeInsets.all(10),
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(10),
              ),
              child: imagenUpload != null
                  ? Image.file(imagenUpload!)
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
                onPressed: () async {
                  final imagen = await getImagen();
                  setState(() {
                    imagenUpload = File(imagen!.path);
                  });
                },
                child: const Text('Seleccionar imagen')),
            const Gap(20),
            const Text('Seleccione el tipo de incidencia'),
            DropdownButton<String>(
              value: tipo,
              items: const [
                DropdownMenuItem(
                  value: 'robo',
                  child: Text('Robo / Asalto'),
                ),
                DropdownMenuItem(
                  value: 'extravio',
                  child: Text('Extravío'),
                ),
                DropdownMenuItem(
                  value: 'violencia',
                  child: Text('Violencia doméstica'),
                ),
                DropdownMenuItem(
                  value: 'accidente',
                  child: Text('Accidente de tránsito'),
                ),
                DropdownMenuItem(
                  value: 'sospecha',
                  child: Text('Actividad sospechosa'),
                ),
                DropdownMenuItem(
                  value: 'disturbio',
                  child: Text('Disturbios'),
                ),
                DropdownMenuItem(
                  value: 'incendio',
                  child: Text('Incendio'),
                ),
                DropdownMenuItem(
                  value: 'cortes',
                  child: Text('Corte de tránsito'),
                ),
                DropdownMenuItem(
                  value: 'portonazo',
                  child: Text('Portonazo'),
                ),
                DropdownMenuItem(
                  value: 'otro',
                  child: Text('Otro..'),
                ),
              ],
              onChanged: (String? newValue) {
                setState(() {
                  tipo = newValue!;
                });
              },
            ),
            const Gap(10),
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
                if (descController.text.length < 50) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'La descripción debe tener al menos 50 caracteres'),
                    ),
                  );
                  return;
                }
                DateTime ahora = DateTime.now();
                String horaFormateada =
                DateFormat('dd/MM/yyyy kk:mm:ss').format(ahora);
                fechaController.text = horaFormateada;
                if (imagenUpload != null) {
                  linkImagen = await subirImagen(imagenUpload!);
                }
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
                if (locationToUse == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Debe proporcionar una ubicación'),
                    ),
                  );
                  return;
                }
                createIncident(
                  clientController.text,
                  fechaController.text,
                  descController.text,
                  tipo,
                  'Abierta',
                  linkImagen,
                  locationToUse,
                ).then((_) => {
                  Navigator.pop(context),
                });
              },
              child: const Text('Crear'),
            ),
          ],
        ),
      ),
    );
  }
}
