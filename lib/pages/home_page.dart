import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:segurapp/pages/update_page.dart';
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
      filteredIncidents = incidents.sublist(0, itemsPerPage);
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
        int compareResult = dbDateFormat.parse(a['fecha']).compareTo(dbDateFormat.parse(b['fecha']));
        return isAscending ? compareResult : -compareResult;
      });
    });
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
        child: const Icon(Icons.add, color: Colors.white),
      ),
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
                  items: ['Tipo1', 'Tipo2', 'Tipo3'].map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedType = newValue;
                      filterIncidents();
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
                        filterIncidents();
                      });
                    }
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
                      sortIncidents();
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: filteredIncidents.length + 1,
              itemBuilder: (context, index) {
                if (index == filteredIncidents.length) {
                  return filteredIncidents.length < allIncidents.length
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : const SizedBox.shrink();
                }

                final incident = filteredIncidents[index];
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
        ],
      ),
    );
  }
}
