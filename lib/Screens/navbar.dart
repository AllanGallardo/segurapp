import 'package:flutter/material.dart';


class CustomNavigationBar extends StatelessWidget {
  final String? latitude;
  final String? longitude;
  const CustomNavigationBar({super.key, this.latitude, this.longitude});

  @override
  Widget build(BuildContext context) {
    print('Me llegaron estos datos: $latitude, $longitude');
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushNamed(context, '/mainScreen');
            },
          ),
          IconButton(
            icon: const Icon(Icons.description),
            onPressed: () {
              Navigator.pushNamed(context, '/DescriptionPage', arguments:{latitude , longitude});
            },
          ),
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.pushNamed(
                context, '/ListPage',);
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
