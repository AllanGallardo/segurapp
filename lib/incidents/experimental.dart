import 'dart:io';

import 'package:flutter/material.dart';

class ExperimentalPage extends StatefulWidget {
  const ExperimentalPage({super.key});

  @override
  State<ExperimentalPage> createState() => _ExperimentalPageState();
}

class _ExperimentalPageState extends State<ExperimentalPage> {

  File? imagenUpload;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Experimental'),
      ),
      body: const Center(
        child: Text("Pagina para hacer pruebas experimentales"),
      ),
    );
  }
}