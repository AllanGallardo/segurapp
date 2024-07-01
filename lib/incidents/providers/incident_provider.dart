

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class IncidentProvider extends ChangeNotifier{
  //Variables
  final List<LatLng> _incidentLocation = [];
  //Getters
  void getLocation( LatLng myPosition ) {
    _incidentLocation.add(myPosition);
    notifyListeners();
  }

  LatLng get incidentLocation => _incidentLocation.last;

}