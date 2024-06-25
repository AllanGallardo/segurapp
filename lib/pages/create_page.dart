import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../services/firebase.dart';
import '../services/imagen_up.dart';
import 'package:firebase_auth/firebase_auth.dart';


class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {

  TextEditingController fechaController = TextEditingController(text: '' );
  TextEditingController descController = TextEditingController(text: '' );
  String tipo = 'robo';
  File? imagenUpload;
  String linkImagen = '';

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    String currentUserId = user!.uid; // Obtén el ID del usuario actualmente autenticado
    String currentMail = user.email ?? '';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Incidencia'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
        child: Column(
          children: [
            TextField(
              controller: TextEditingController(text: currentMail),
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Correo del usuario',
                labelStyle: TextStyle(color: Theme.of(context).primaryColor), // Cambia el color del texto a morado
              ),
              style: const TextStyle(color: Colors.black), // Cambia el color del texto a negro
            ),
             
            const Gap(10),

            TextField( 
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Describa la situación',
              ),
            ),

            /*TextField( 
              controller: fechaController,
              decoration: const InputDecoration(
                labelText: 'Ingrese la fecha de la incidencia',
              ),
            ),*/

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
                  ? Image.file(imagenUpload!) // Mostrar imagen si está seleccionada
                  : const Center(
                      child: Text(// Mostrar texto si no hay imagen
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
              //Con getImagenCamara() se puede subir una foto
              final imagen = await getImagen(); //
              setState(() {
                imagenUpload = File(imagen!.path);
              });
            }, 
            child: 
              const Text('Seleccionar imagen')),
            
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
              onPressed: () async{
                if (descController.text.length < 25) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('La descripción debe tener al menos 25 caracteres'),
                    ),
                  );
                  return;
                }
                DateTime ahora = DateTime.now();
                String horaFormateada = DateFormat('dd/MM/yyyy kk:mm:ss').format(ahora);
                fechaController.text = horaFormateada;
                if (imagenUpload != null) {
                  linkImagen = await subirImagen( imagenUpload!);
                }
                // ignore: avoid_print
                print (linkImagen);
                createIncident(currentMail, fechaController.text, descController.text, tipo, 'Abierta', linkImagen, currentUserId).then((_) => {
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