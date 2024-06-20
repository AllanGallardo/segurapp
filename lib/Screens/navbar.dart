import 'package:flutter/material.dart';


class CustomNavigationBar extends StatelessWidget {
  final BuildContext context;

  const CustomNavigationBar({super.key, required this.context});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushNamed(this.context, '/mainScreen');
            },
          ),
          IconButton(
            icon: const Icon(Icons.description),
            onPressed: () {
              Navigator.pushNamed(this.context, '/DescriptionPage');
            },
          ),
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.pushNamed(this.context, '/ListPage');
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/editarperfil'); // Cambio aquí
            },
          ),
        ],
      ),
    );
  }
}
