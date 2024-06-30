import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:segurapp/services/firebase.dart';
import 'package:segurapp/Screens/ListPage_Deploy.dart';

class Feed extends StatefulWidget {
  const Feed({
    super.key,
  });

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
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

  Future<void> _showListPage(BuildContext context, dynamic incident) async {
    final result = await Navigator.pushNamed(
      context,
      '/incidentDetails',
      arguments: incident,
    );

    if (result == true) {
      await loadIncidents();
    }
  }

  Widget _buildPagination() {
    int totalPages = (allIncidents.length / itemsPerPage).ceil();
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
                filteredIncidents = allIncidents.sublist(
                  currentPage * itemsPerPage,
                  (currentPage + 1) * itemsPerPage > allIncidents.length
                      ? allIncidents.length
                      : (currentPage + 1) * itemsPerPage,
                );
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
              filteredIncidents = allIncidents.sublist(
                currentPage * itemsPerPage,
                (currentPage + 1) * itemsPerPage > allIncidents.length
                    ? allIncidents.length
                    : (currentPage + 1) * itemsPerPage,
              );
            });
          }
              : null,
        ),
        ...pageButtons,
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: (currentPage + 1) * itemsPerPage < allIncidents.length
              ? () {
            setState(() {
              currentPage++;
              filteredIncidents = allIncidents.sublist(
                currentPage * itemsPerPage,
                (currentPage + 1) * itemsPerPage > allIncidents.length
                    ? allIncidents.length
                    : (currentPage + 1) * itemsPerPage,
              );
            });
          }
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.last_page),
          onPressed: currentPage < totalPages - 1
              ? () {
            setState(() {
              currentPage = totalPages - 1;
              filteredIncidents = allIncidents.sublist(
                currentPage * itemsPerPage,
                allIncidents.length,
              );
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
        backgroundColor: const Color.fromARGB(255, 32, 133, 192),
        title: const Text('Feed de incidencias'),
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
                  items: [
                    {'id': 'robo', 'displayValue': 'Robo/Asalto'},
                    {'id': 'extravio', 'displayValue': 'Extravío'},
                    {'id': 'violencia', 'displayValue': 'Violencia doméstica'},
                    {'id': 'accidente', 'displayValue': 'Accidente de tránsito'},
                    {'id': 'sospecha', 'displayValue': 'Actividad sospechosa'},
                    {'id': 'disturbio', 'displayValue': 'Disturbios'},
                    {'id': 'incendio', 'displayValue': 'Incendio'},
                    {'id': 'cortes', 'displayValue': 'Corte de tránsito'},
                    {'id': 'portonazo', 'displayValue': 'Portonazo'},
                    {'id': 'otro', 'displayValue': 'Otro...'},
                  ].map((Map<String, String> item) {
                    return DropdownMenuItem<String>(
                      value: item['id'],
                      child: Text(item['displayValue']!),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedType = newValue;
                      filterIncidents();
                    });
                  },
                ),
                const SizedBox(width: 4.0),
                ElevatedButton(
                  onPressed: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2030),
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
                Expanded(
                    child: IconButton(
                      icon:
                      Icon(isAscending ? Icons.arrow_upward : Icons.arrow_downward),
                      onPressed: () {
                        setState(() {
                          isAscending = !isAscending;
                          sortIncidents();
                        });
                      },
                    )),
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
                return InkWell(
                  onTap: () => _showListPage(context, incident),
                  child: ListTile(
                    title: Text(
                      'Usuario: ${incident['cliente']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Descripción: ${incident['descripcion']}'),
                        Text('Fecha: ${incident['fecha']}'),
                        Text(
                            'Ubicación: ${incident['ubicacion']}'), // Mostrar ubicación
                        if (incident['tipo'] == 'robo')
                          const Text('Categoría de la incidencia: Robo/Asalto'),
                        if (incident['tipo'] == 'extravio')
                          const Text('Categoría de la incidencia: Extravío'),
                        if (incident['tipo'] == 'violencia')
                          const Text(
                              'Categoría de la incidencia: Violencia doméstica'),
                        if (incident['tipo'] == 'accidente')
                          const Text(
                              'Categoría de la incidencia: Accidente de tránsito'),
                        if (incident['tipo'] == 'sospecha')
                          const Text(
                              'Categoría de la incidencia: Actividad sospechosa'),
                        if (incident['tipo'] == 'disturbio')
                          const Text('Categoría de la incidencia: Disturbios'),
                        if (incident['tipo'] == 'incendio')
                          const Text('Categoría de la incidencia: Incendio'),
                        if (incident['tipo'] == 'cortes')
                          const Text('Categoría de la incidencia: Corte de tránsito'),
                        if (incident['tipo'] == 'portonazo')
                          const Text('Categoría de la incidencia: Portonazo'),
                        if (incident['tipo'] == 'otro')
                          const Text('Categoría de la incidencia: Otro...'),
                      ],
                    ),
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
