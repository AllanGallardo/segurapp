import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  DateTime? fechaCierre;

  final DateFormat dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');

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

    clientController.text = clienteData;
    fechaController.text = fechaData;
    descController.text = descData;
    tipoController.text = tipoData;
    estadoController.text = estadoData;

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
                  await updateIncident(
                    argumentsList[2],
                    clientController.text,
                    fechaController.text,
                    descController.text,
                    tipoController.text,
                    estadoController.text,
                    fechaCierre != null ? dateFormat.format(fechaCierre!) : null,
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
