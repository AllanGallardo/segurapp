import 'package:flutter/material.dart';

class IncidentDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final incident = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle de Incidente'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cliente: ${incident['cliente']}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Fecha: ${incident['fecha']}', style: TextStyle(fontSize: 16)),
            Text('Descripción: ${incident['descripcion']}', style: TextStyle(fontSize: 16)),
            Text('Tipo: ${incident['tipo']}', style: TextStyle(fontSize: 16)),
            Text('Estado: ${incident['estado']}', style: TextStyle(fontSize: 16)),
            if (incident['ubicacion'] != null)
              Text('Ubicación: ${incident['ubicacion']}', style: TextStyle(fontSize: 16)),
            if (incident['imagen'] != null && incident['imagen'].isNotEmpty)
              Image.network(incident['imagen']),
          ],
        ),
      ),
    );
  }
}
