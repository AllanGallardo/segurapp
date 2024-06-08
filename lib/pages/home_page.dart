import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:segurapp/services/firebase.dart';

import 'create_page.dart';

class Home extends StatefulWidget {
  const Home({
    Key? key,
  }) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? selectedType;
  DateTime? selectedDate;
  List<dynamic> allIncidents = [];
  List<dynamic> filteredIncidents = [];
  bool isAscending = true;
  int currentPage = 0;
  final int itemsPerPage = 10;
  final ScrollController _scrollController = ScrollController();

  final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
  final DateFormat dbDateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');

  @override
  void initState() {
    super.initState();
    loadIncidents();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      loadMoreIncidents();
    }
  }

  Future<void> loadIncidents() async {
    var incidents = await getIncidents();
    setState(() {
      allIncidents = incidents;
      filteredIncidents = incidents;
      sortIncidents();
    });
  }

  Future<void> loadMoreIncidents() async {
    if ((currentPage + 1) * itemsPerPage < allIncidents.length) {
      setState(() {
        currentPage++;
        filteredIncidents = allIncidents.sublist(0, (currentPage + 1) * itemsPerPage);
      });
    }
  }

  void filterIncidents() {
    setState(() {
      filteredIncidents = allIncidents.where((incident) {
        DateTime incidentDate = dbDateFormat.parse(incident['fecha']);
        bool matchesType = selectedType == null || incident['tipo'] == selectedType;
        bool matchesDate = selectedDate == null || dateFormat.format(incidentDate) == dateFormat.format(selectedDate!);
        return matchesType && matchesDate;
      }).toList();
      sortIncidents();
    });
  }

  void sortIncidents() {
    setState(() {
      filteredIncidents.sort((a, b) {
        DateTime dateA = dbDateFormat.parse(a['fecha']);
        DateTime dateB = dbDateFormat.parse(b['fecha']);
        return isAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
      });
    });
  }

  void resetFilters() {
    setState(() {
      selectedType = null;
      selectedDate = null;
      filteredIncidents = allIncidents;
      sortIncidents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Incidencias'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String result) {
              setState(() {
                if (result == 'Orden Ascendente') {
                  isAscending = true;
                } else {
                  isAscending = false;
                }
                sortIncidents();
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Orden Ascendente',
                child: Text('Orden Ascendente'),
              ),
              const PopupMenuItem<String>(
                value: 'Orden Descendente',
                child: Text('Orden Descendente'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'Tipo de Incidencia'),
                          value: selectedType,
                          items: const [
                            DropdownMenuItem(value: 'robo', child: Text('Robo/Asalto')),
                            DropdownMenuItem(value: 'extravio', child: Text('Extravío')),
                            DropdownMenuItem(value: 'violencia', child: Text('Violencia Domestica')),
                            DropdownMenuItem(value: 'accidente', child: Text('Accidente de Tránsito')),
                            DropdownMenuItem(value: 'sospecha', child: Text('Actividad Sospechosa')),
                            DropdownMenuItem(value: 'disturbio', child: Text('Disturbios')),
                            DropdownMenuItem(value: 'incendio', child: Text('Incendio')),
                            DropdownMenuItem(value: 'cortes', child: Text('Corte de Tránsito')),
                            DropdownMenuItem(value: 'portonazo', child: Text('Portonazo')),
                            DropdownMenuItem(value: 'otro', child: Text('Otro')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedType = value;
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (picked != null) {
                              setState(() {
                                selectedDate = picked;
                              });
                            }
                          },
                          child: Text(selectedDate == null
                              ? 'Seleccionar Fecha'
                              : 'Fecha: ${dateFormat.format(selectedDate!)}'),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            filterIncidents();
                          },
                          child: const Text('Aplicar Filtros'),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            resetFilters();
                          },
                          child: const Text('Restablecer Filtros'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: filteredIncidents.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              controller: _scrollController,
              itemCount: filteredIncidents.length + (currentPage + 1 < allIncidents.length / itemsPerPage ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == filteredIncidents.length) {
                  return const Center(child: CircularProgressIndicator());
                }
                DateTime incidentDate = dbDateFormat.parse(filteredIncidents[index]['fecha']);
                return Dismissible(
                  onDismissed: (direction) async {
                    deleteIncident(filteredIncidents[index]['id']);
                    setState(() {
                      filteredIncidents.removeAt(index);
                    });
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
                      },
                    );
                    return result;
                  },
                  key: Key(filteredIncidents[index]['id'] ?? ''),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Colors.black),
                      ),
                      title: Text(filteredIncidents[index]['cliente']),
                      subtitle: Text(dateFormat.format(incidentDate)),
                      onTap: () async {
                        await Navigator.pushNamed(context, '/update', arguments: {
                          filteredIncidents[index]['cliente'] ?? '',
                          filteredIncidents[index]['fecha'] ?? '',
                          filteredIncidents[index]['id'],
                          filteredIncidents[index]['descripcion'],
                          filteredIncidents[index]['tipo'],
                          filteredIncidents[index]['estado'],
                          filteredIncidents[index]['imagen'] ?? ''
                        });
                        loadIncidents();
                      },
                    ),
                  ),
                );
              },
            ),
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
              loadIncidents();
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
