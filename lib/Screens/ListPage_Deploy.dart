// ignore_for_file: file_names

import 'package:flutter/material.dart';

class DeployFeed extends StatefulWidget {
  const DeployFeed({super.key});

  @override
  State<DeployFeed> createState() => _FeedPageState();
}

class _FeedPageState extends State<DeployFeed> {
  int _counter = 0;

  Text categorizeIncident(String tipo) {
    if (tipo == 'robo') {
      return const Text('Categoría de la incidencia: Robo/Asalto');
    } else if (tipo == 'extravio') {
      return const Text('Categoría de la incidencia: Extravío');
    } else if (tipo == 'violencia') {
      return const Text('Categoría de la incidencia: Violencia doméstica');
    } else if (tipo == 'accidente') {
      return const Text('Categoría de la incidencia: Accidente de tránsito');
    } else if (tipo == 'sospecha') {
      return const Text('Categoría de la incidencia: Actividad sospechosa');
    } else if (tipo == 'disturbio') {
      return const Text('Categoría de la incidencia: Disturbios');
    } else if (tipo == 'incendio') {
      return const Text('Categoría de la incidencia: Incendio');
    } else if (tipo == 'cortes') {
      return const Text('Categoría de la incidencia: Corte de tránsito');
    } else if (tipo == 'portonazo') {
      return const Text('Categoría de la incidencia: Portonazo');
    } else if (tipo == 'otro') {
      return const Text('Categoría de la incidencia: Otro...');
    } else {
      return const Text('Categoría de la incidencia: Desconocida');
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
    final imagen = argumentsList[6];
    final ubicacion = argumentsList[7];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Información detallada'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                width: 360,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color.fromARGB(255, 32, 133, 192)),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Text('Nombre de usuario: $clienteData'),
              ),
              Container(
                padding: const EdgeInsets.all(8.0),
                width: 360,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color.fromARGB(255, 32, 133, 192)),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Text('Fecha de la incidencia: $fechaData'),
              ),
              Container(
                padding: const EdgeInsets.all(8.0),
                width: 360,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color.fromARGB(255, 32, 133, 192)),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Text('Descripción sobre la incidencia: $descData'),
              ),
              Container(
                padding: const EdgeInsets.all(8.0),
                width: 360,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color.fromARGB(255, 32, 133, 192)),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: categorizeIncident(tipoData),
              ),
              Container(
                padding: const EdgeInsets.all(8.0),
                width: 360,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color.fromARGB(255, 32, 133, 192)),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Text('Ubicación: $ubicacion'),  // Mostrar ubicación
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
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Tooltip(
                          message: 'Confirmar',
                          child: IconButton(
                            icon: const Icon(Icons.check_box, color: Colors.green, size: 30),
                            onPressed: () {
                              setState(() {
                                _counter++;
                              });
                            },
                          ),
                        ),
                        Text('$_counter'), //Counter que debería mostrar las confirmaciones
                      ],
                    ),
                    const SizedBox(width: 10),
                    Row(
                      children: <Widget>[
                        Tooltip(
                          message: 'Reportar incidencia',
                          child: IconButton(
                            icon: const Icon(Icons.error, color: Colors.red, size: 30),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Confirmación'),
                                    content: const Text('¿Estás seguro de que quieres reportar la incidencia?'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('Cancelar'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: const Text('Confirmar'),
                                        onPressed: () {
                                          Navigator.pop(context);
                                          // Aquí puedes poner el código para reportar la incidencia
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        Text('$_counter'), //Texto que deberia mostrar los reportes actuales
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
