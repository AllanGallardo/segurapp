import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class IncidentProvider extends ChangeNotifier{
  //Variables
  LatLng _incidentLocation = const LatLng(0, 0);
  //Getters
  void getLocation( LatLng myPosition ) {
    _incidentLocation = myPosition;
    notifyListeners();
  }

  LatLng get incidentLocation => _incidentLocation;

}