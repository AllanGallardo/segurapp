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
  String? selectedType; // Almacena el tipo seleccionado del filtro
  DateTime? selectedDate; // Almacena la fecha seleccionada del filtro
  List<dynamic> allIncidents = []; // Lista de todas las incidencias
  List<dynamic> filteredIncidents = []; // Lista de incidencias filtradas y paginadas
  bool isAscending = true; // Indica el orden de clasificación de las incidencias
  int currentPage = 0; // Página actual de la paginación
  final int itemsPerPage = 10; // Número de elementos por página
  final ScrollController _scrollController = ScrollController(); // Controlador de scroll para la lista

  final DateFormat dateFormat = DateFormat('dd/MM/yyyy'); // Formato de fecha para mostrar
  final DateFormat dbDateFormat = DateFormat('dd/MM/yyyy HH:mm:ss'); // Formato de fecha para la base de datos

  @override
  void initState() {
    super.initState();
    loadIncidents(); // Cargar incidencias al inicializar el estado
    _scrollController.addListener(_onScroll); // Agregar listener para detectar scroll
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Eliminar el controlador de scroll al destruir el estado
    super.dispose();
  }

  void _onScroll() {
    // Detecta cuando el usuario llega al final del scroll y carga más incidencias si es necesario
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      loadMoreIncidents();
    }
  }

  Future<void> loadIncidents() async {
    // Carga todas las incidencias desde la base de datos
    var incidents = await getIncidents();
    setState(() {
      allIncidents = incidents;
      filteredIncidents = incidents.sublist(0, itemsPerPage);
      sortIncidents();
    });
  }

  Future<void> loadMoreIncidents() async {
    // Carga más incidencias para la paginación
    if ((currentPage + 1) * itemsPerPage < allIncidents.length) {
      setState(() {
        currentPage++;
        filteredIncidents = allIncidents.sublist(0, (currentPage + 1) * itemsPerPage);
      });
    }
  }

  void filterIncidents() {
    // Filtra las incidencias según el tipo y la fecha seleccionada
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
    // Ordena las incidencias por fecha
    setState(() {
      filteredIncidents.sort((a, b) {
        int compareResult = dbDateFormat.parse(a['fecha']).compareTo(dbDateFormat.parse(b['fecha']));
        return isAscending ? compareResult : -compareResult;
      });
    });
  }

  Future<void> _showUpdatePage(BuildContext context, dynamic incident) async {
    // Navega a la página de actualización de incidencia
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
    // Construye los botones de paginación
    int totalPages = (allIncidents.length / itemsPerPage).ceil(); // Calcula el total de páginas
    List<Widget> pageButtons = []; // Lista de botones de páginas

    for (int i = 0; i < totalPages; i++) {
      pageButtons.add(
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(), // Forma circular
              padding: const EdgeInsets.all(12.0), // Tamaño del botón
              minimumSize: const Size(40, 40), // Tamaño mínimo
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
        // Tamaño y posición del FloatingActionButton
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 10.0,
        splashColor: Colors.red,
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
          // Barra de paginación
          _buildPagination(),
        ],
      ),
    );
  }
}
