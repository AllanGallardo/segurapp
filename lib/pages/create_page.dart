import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase.dart';
import '../services/imagen_up.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final TextEditingController fechaController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  String tipo = 'robo';
  File? imagenUpload;
  String linkImagen = '';
  String? userName = 'Cargando...';

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get();
        if (userDoc.exists) {
          setState(() {
            userName = userDoc['nombre'];
          });
        } else {
          setState(() {
            userName = 'Usuario Desconocido';
          });
        }
      } else {
        setState(() {
          userName = 'No autenticado';
        });
      }
    } catch (e) {
      print('Error al obtener el nombre de usuario: $e');
      setState(() {
        userName = 'Error';
      });
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
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Usuario: $userName',
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
              child: const Text('Seleccionar imagen'),
            ),
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
              onPressed: () async {
                if (descController.text.length < 50) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('La descripción debe tener al menos 50 caracteres'),
                    ),
                  );
                  return;
                }
                DateTime ahora = DateTime.now();
                String horaFormateada = DateFormat('dd/MM/yyyy kk:mm:ss').format(ahora);
                fechaController.text = horaFormateada;
                if (imagenUpload != null) {
                  linkImagen = await subirImagen(imagenUpload!);
                }
                createIncident(userName ?? 'Usuario Desconocido', fechaController.text, descController.text, tipo, 'Abierta', linkImagen).then((_) => {
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
