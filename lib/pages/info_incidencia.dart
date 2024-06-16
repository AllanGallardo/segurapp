// info_incidencia.dart
import 'package:flutter/material.dart';

class InfoIncidencia extends StatelessWidget {
  final Map<String, dynamic> incident;

  const InfoIncidencia({Key? key, required this.incident}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de la Incidencia'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Usuario: ${incident['cliente']}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Fecha: ${incident['fecha']}', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text('Descripción: ${incident['descripcion']}', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text('Tipo: ${incident['tipo']}', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text('Estado: ${incident['estado']}', style: TextStyle(fontSize: 16)),
              if (incident['estado'] == 'Cerrada' && incident['fechaCierre'] != null)
                Text('Fecha de cierre: ${incident['fechaCierre']}', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              if (incident['imagen'] != null && incident['imagen'].isNotEmpty)
                Image.network(
                  incident['imagen'],
                  errorBuilder: (context, error, stackTrace) {
                    return const Text('Imagen no disponible');
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
