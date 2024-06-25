import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:segurapp/pages/update_page.dart';
import 'package:segurapp/services/firebase.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MisIncidencias extends StatefulWidget {
  const MisIncidencias({
    super.key,
  });

  @override
  State<MisIncidencias> createState() => _MisIncidenciasState();
}

class _MisIncidenciasState extends State<MisIncidencias> {
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
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadIncidents();
  }

  Future<void> loadIncidents() async {
    setState(() {
      isLoading = true;
    });

    var incidents = await getIncidents();
    setState(() {
      allIncidents = incidents;
      filterAndPaginateIncidents();
      isLoading = false;
    });
  }

  void filterAndPaginateIncidents() {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    String currentUserId = user!.uid; // Obtén el ID del usuario actualmente autenticado
    //print(currentUserId);

    List<dynamic> incidents = allIncidents.where((incident) {
    DateTime incidentDate = dbDateFormat.parse(incident['fecha']);
    bool matchesType = selectedType == null || selectedType == 'todos' || incident['tipo'] == selectedType;
    bool matchesDate = selectedDate == null || dateFormat.format(incidentDate) == dateFormat.format(selectedDate!);
    bool matchesUser = incident['userId'] == currentUserId; // Comprueba si el ID del usuario de la incidencia coincide con el ID del usuario autenticado
    return matchesType && matchesDate && matchesUser;
  }).toList();

    incidents.sort((a, b) {
      int compareResult = dbDateFormat.parse(a['fecha']).compareTo(dbDateFormat.parse(b['fecha']));
      return isAscending ? compareResult : -compareResult;
    });

    setState(() {
      filteredIncidents = incidents;
      currentPage = 0;
    });
  }

  List<dynamic> getPaginatedIncidents() {
    int startIndex = currentPage * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;
    if (endIndex > filteredIncidents.length) {
      endIndex = filteredIncidents.length;
    }
    return filteredIncidents.sublist(startIndex, endIndex);
  }

  Future<void> _showUpdatePage(BuildContext context, dynamic incident) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UpdatePage(),
        settings: RouteSettings(
          arguments: {
            incident['cliente'],
            incident['fecha'],
            incident['id'],
            incident['descripcion'],
            incident['tipo'],
            incident['estado'],
            incident['imagen'],
          },
        ),
      ),
    );

    if (result == true) {
      await loadIncidents();
    }
  }

  Widget _buildPagination() {
    int totalPages = (filteredIncidents.length / itemsPerPage).ceil();
    List<Widget> pageButtons = [];

    for (int i = 0; i < totalPages; i++) {
      pageButtons.add(
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(12.0),
              minimumSize: const Size(40, 40),
            ),
            onPressed: currentPage != i
                ? () {
                    setState(() {
                      currentPage = i;
                    });
                  }
                : null,
            child: Text('${i + 1}'),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: currentPage > 0
              ? () {
                  setState(() {
                    currentPage--;
                  });
                }
              : null,
        ),
        ...pageButtons,
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: currentPage < totalPages - 1
              ? () {
                  setState(() {
                    currentPage++;
                  });
                }
              : null,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listado de Incidencias'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                DropdownButton<String>(
                  hint: const Text('Filtrar por tipo'),
                  value: selectedType,
                  items: ['todos', 'robo', 'extravio', 'violencia', 'accidente', 'sospecha', 'disturbio', 'incendio', 'cortes', 'portonazos', 'otro']
                      .map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedType = newValue;
                      filterAndPaginateIncidents();
                    });
                  },
                ),
                const SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        selectedDate = pickedDate;
                        filterAndPaginateIncidents();
                      });
                    }
                  },
                  onLongPress: () {
                    setState(() {
                      selectedDate = null;
                      filterAndPaginateIncidents();
                    });
                  },
                  child: Text(selectedDate == null
                      ? 'Filtrar por fecha'
                      : dateFormat.format(selectedDate!)),
                ),
                const SizedBox(width: 8.0),
                IconButton(
                  icon: Icon(isAscending ? Icons.arrow_upward : Icons.arrow_downward),
                  onPressed: () {
                    setState(() {
                      isAscending = !isAscending;
                      filterAndPaginateIncidents();
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: getPaginatedIncidents().length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == getPaginatedIncidents().length) {
                  return isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : const SizedBox.shrink();
                }

                final incident = getPaginatedIncidents()[index];
                return ListTile(
                  title: Text(
                    'Cliente: ${incident['cliente']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Descripción: ${incident['descripcion']}'),
                      Text('Fecha: ${incident['fecha']}'),
                      Text('Tipo: ${incident['tipo']}'),
                      Text('Estado: ${incident['estado']}'),
                      if (incident['estado'] == 'Cerrada' && incident['fechaCierre'] != null)
                        Text('Fecha de cierre: ${incident['fechaCierre']}'),
                    ],
                  ),
                  trailing: ElevatedButton(
                    child: const Text('Modificar'),
                    onPressed: () => _showUpdatePage(context, incident),
                  ),
                );
              },
            ),
          ),
          _buildPagination(),
        ],
      ),
    );
  }
}