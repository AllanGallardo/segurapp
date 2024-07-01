import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

// CRUD READ
Future<List> getIncidents() async {
  List incidents = [];
  CollectionReference collectionReferenceIncidents = db.collection('incidencia');
  QuerySnapshot queryIncidents = await collectionReferenceIncidents.get();

  for (var doc in queryIncidents.docs) {
    final Map<String, dynamic> docData = doc.data() as Map<String, dynamic>;
    final incidencia = {
      'cliente': docData['cliente'],
      'fecha': docData['fecha'],
      'id': doc.id,
      'descripcion': docData['descripcion'],
      'tipo': docData['tipo'],
      'estado': docData['estado'],
      'imagen': docData['imagen'],
      'fechaCierre': docData['fechaCierre'],
    };
    incidents.add(incidencia);
  }

  return incidents;
}

// CRUD CREATE
Future<void> createIncident(String cliente, String fecha, String descripcion, String tipo, String estado, String linkImagen, LatLng posicion) async {
  await db.collection('incidencia').add({
    'cliente': cliente,
    'fecha': fecha,
    'descripcion': descripcion,
    'tipo': tipo,
    'estado': estado,
    'imagen': linkImagen,
    'fechaCierre': null,
    'ubicacion': GeoPoint(posicion.latitude, posicion.longitude),
  });
}

// CRUD UPDATE
Future<void> updateIncident(String id, String cliente, String fecha, String descripcion, String tipo, String estado, String? fechaCierre) async {
  await db.collection('incidencia').doc(id).update({
    'cliente': cliente,
    'fecha': fecha,
    'descripcion': descripcion,
    'tipo': tipo,
    'estado': estado,
    'fechaCierre': fechaCierre,
  });
}

// CRUD DELETE
Future<void> deleteIncident(String id) async {
  await db.collection('incidencia').doc(id).delete();
}

// Actualización Estado
Future<void> updateState(String id, String estado, String? fechaCierre) async {
  await db.collection('incidencia').doc(id).update({
    'estado': estado,
    'fechaCierre': fechaCierre,
  });
}
