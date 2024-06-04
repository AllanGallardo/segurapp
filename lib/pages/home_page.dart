import 'package:flutter/material.dart';
import 'package:segurapp/services/firebase.dart';

import 'create_page.dart';


class Home extends StatefulWidget {
  const Home({
    super.key,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( // Agregado AppBar
        leading: IconButton( // Agregado IconButton
          icon: const Icon(Icons.arrow_back), // Icono de flecha hacia atrás
          onPressed: () {
            Navigator.pop(context); // Navega hacia atrás en el stack de navegación
          },
        ),
      ),
      //TODO: Hay que transformar la lista para que se vea por paginas.
      body: FutureBuilder(
        future: getIncidents(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
            itemCount: snapshot.data?.length ?? 0,
            itemBuilder: (context, index) {
              return Dismissible(
                onDismissed: (direction) async{
                  deleteIncident(snapshot.data?[index]['id']);
                  snapshot.data?.removeAt(index);
                  setState(() {});
                },
                confirmDismiss: (direction) async {
                  bool result = false;
                  result = await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Confirmar'),
                        content: const Text('¿Está seguro que desea eliminar esta incidencia?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, false);
                            },
                            child: const Text('No')),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, true);
                            },
                            child: const Text('Sí, eliminar')),
                        ],
                      );
                    }
                  );
                  return result;
                },
                key: Key(snapshot.data?[index]['id']??''),
                direction: DismissDirection.endToStart,
                background: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.all(8.0),
                  child: const Icon(Icons.delete),
                ),
                child: Container(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    shape: RoundedRectangleBorder (
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Colors.black),
                    ),
                    title: Text(snapshot.data?[index]['cliente']),
                    subtitle: Text(snapshot.data?[index]['fecha']??''),
                    onTap: () async {
                      await Navigator.pushNamed(context, '/update', arguments:{
                      snapshot.data?[index]['cliente']??'',
                      snapshot.data?[index]['fecha']??'',
                      snapshot.data?[index]['id'],
                      snapshot.data?[index]['descripcion'],
                      snapshot.data?[index]['tipo'],
                      snapshot.data?[index]['estado'],
                      snapshot.data?[index]['imagen']??''
                      });
                      //Actualizar la lista de incidencias
                      setState(() {});
                    },
                  ),
                ),
              );
            }
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreatePage(),
                  ),
                );
                // Update the list of incidents (if needed)
                setState(() {});
              },
              child: const Icon(Icons.add),
            ),
            // const SizedBox(width: 10),
            //  FloatingActionButton( // New button for experimental page
            //    onPressed: () {
            //      Navigator.pushNamed(context, '/experimental');
            //    },
            //    child: const Icon(Icons.explore), // You can customize the icon
            //  ),
          ],
        ),
      );
    }
  }