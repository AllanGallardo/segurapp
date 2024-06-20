import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:segurapp/pages/update_page.dart';
import 'package:segurapp/services/firebase.dart';
import 'package:segurapp/pages/mis_inicidencias.dart';
import 'create_page.dart';

class Home extends StatefulWidget {
  // ignore: use_super_parameters
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
    List<dynamic> incidents = allIncidents.where((incident) {
      DateTime incidentDate = dbDateFormat.parse(incident['fecha']);
      bool matchesType = selectedType == null || selectedType == 'todos' || incident['tipo'] == selectedType;
      bool matchesDate = selectedDate == null || dateFormat.format(incidentDate) == dateFormat.format(selectedDate!);
      return matchesType && matchesDate;
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePage()),
          );

          if (result == true) {
            await loadIncidents();
          }
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 10.0,
        splashColor: Colors.red,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      appBar: AppBar(
        title: const Text('Listado de Incidencias'),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MisIncidencias()),
                );
              },
              child: const Icon(Icons.account_circle, size: 35.0),
            ),
          ),
        ],
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