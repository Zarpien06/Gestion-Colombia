import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Colombia App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DepartamentosPage(),
    const CiudadesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión Colombia'),
        elevation: 2,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.location_city),
            label: 'Departamentos',
          ),
          NavigationDestination(
            icon: Icon(Icons.place),
            label: 'Ciudades',
          ),
        ],
      ),
    );
  }
}


class Departamento {
  final int idDepartamento;
  final String nombre;

  Departamento({required this.idDepartamento, required this.nombre});

  factory Departamento.fromJson(Map<String, dynamic> json) {
    return Departamento(
      idDepartamento: json['id_departamento'],
      nombre: json['nombre'],
    );
  }
}

class Ciudad {
  final int idCiudad;
  final String nombre;
  final int? idDepartamento;
  final String? nombreDepartamento;

  Ciudad({
    required this.idCiudad,
    required this.nombre,
    this.idDepartamento,
    this.nombreDepartamento,
  });

  factory Ciudad.fromJson(Map<String, dynamic> json) {
    return Ciudad(
      idCiudad: json['id_ciudad'],
      nombre: json['nombre'],
      idDepartamento: json['id_departamento'],
      nombreDepartamento: json['nombre_departamento'],
    );
  }
}



class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';
 
  static Future<List<Departamento>> getDepartamentos() async {
    final response = await http.get(Uri.parse('$baseUrl/departamentos'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Departamento.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar departamentos');
    }
  }

  static Future<void> createDepartamento(String nombre) async {
    final response = await http.post(
      Uri.parse('$baseUrl/departamentos'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'nombre': nombre}),
    );
    if (response.statusCode != 201) {
      throw Exception('Error al crear departamento');
    }
  }

  static Future<void> deleteDepartamento(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/departamentos/$id'),
    );
    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['error']);
    }
  }

  static Future<List<Ciudad>> getCiudades() async {
    final response = await http.get(Uri.parse('$baseUrl/ciudades'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Ciudad.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar ciudades');
    }
  }

  static Future<void> createCiudad(String nombre, int? idDepartamento) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ciudades'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'nombre': nombre,
        'id_departamento': idDepartamento,
      }),
    );
    if (response.statusCode != 201) {
      throw Exception('Error al crear ciudad');
    }
  }

  static Future<void> deleteCiudad(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/ciudades/$id'),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar ciudad');
    }
  }

  static Future<List<Departamento>> buscarDepartamentos(String nombre) async {
  final response = await http.get(Uri.parse('$baseUrl/departamentos/buscar/$nombre'));
  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    return data.map((json) => Departamento.fromJson(json)).toList();
  } else {
    throw Exception('Error al buscar departamentos');
  }
}

static Future<List<Ciudad>> buscarCiudades(String nombre) async {
  final response = await http.get(Uri.parse('$baseUrl/ciudades/buscar/$nombre'));
  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    return data.map((json) => Ciudad.fromJson(json)).toList();
  } else {
    throw Exception('Error al buscar ciudades');
  }
}

}



class DepartamentosPage extends StatefulWidget {
  const DepartamentosPage({super.key});

  @override
  State<DepartamentosPage> createState() => _DepartamentosPageState();
}

class _DepartamentosPageState extends State<DepartamentosPage> {
  List<Departamento> departamentos = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    loadDepartamentos();
  }

  Future<void> loadDepartamentos() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService.getDepartamentos();
      setState(() {
        departamentos = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> searchDepartamentos(String query) async {
    setState(() {
      isLoading = true;
      searchQuery = query;
    });
    try {
      final data = query.isEmpty
          ? await ApiService.getDepartamentos()
          : await ApiService.buscarDepartamentos(query);
      setState(() {
        departamentos = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> showAddDialog() async {
    final controller = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Departamento'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nombre del departamento',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                try {
                  await ApiService.createDepartamento(controller.text);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Departamento agregado exitosamente')),
                    );
                    // Recarga lista con o sin búsqueda activa
                    await searchDepartamentos(searchQuery);
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  Future<void> showConsultDialog(Departamento dept) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Información del Departamento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${dept.idDepartamento}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Nombre: ${dept.nombre}', style: const TextStyle(fontSize: 16)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> confirmDelete(Departamento dept) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de eliminar "${dept.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await ApiService.deleteDepartamento(dept.idDepartamento);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Departamento eliminado exitosamente')),
                  );
                  await searchDepartamentos(searchQuery);
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Departamentos'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar departamento',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: searchDepartamentos,
              textCapitalization: TextCapitalization.words,
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => searchDepartamentos(searchQuery),
                    child: departamentos.isEmpty
                        ? const Center(child: Text('No hay departamentos registrados'))
                        : ListView.builder(
                            itemCount: departamentos.length,
                            itemBuilder: (context, index) {
                              final dept = departamentos[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    child: Text(dept.nombre[0].toUpperCase()),
                                  ),
                                  title: Text(dept.nombre,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  subtitle: Text('ID: ${dept.idDepartamento}'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.visibility,
                                            color: Colors.blue),
                                        onPressed: () => showConsultDialog(dept),
                                        tooltip: 'Consultar',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () => confirmDelete(dept),
                                        tooltip: 'Eliminar',
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
      ),
    );
  }
}

class CiudadesPage extends StatefulWidget {
  const CiudadesPage({super.key});

  @override
  State<CiudadesPage> createState() => _CiudadesPageState();
}

class _CiudadesPageState extends State<CiudadesPage> {
  List<Ciudad> ciudades = [];
  List<Departamento> departamentos = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    try {
      final ciudadesData = await ApiService.getCiudades();
      final deptData = await ApiService.getDepartamentos();
      setState(() {
        ciudades = ciudadesData;
        departamentos = deptData;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> searchCiudades(String query) async {
    setState(() {
      isLoading = true;
      searchQuery = query;
    });
    try {
      final deptData = await ApiService.getDepartamentos();
      final ciudadesData = query.isEmpty
          ? await ApiService.getCiudades()
          : await ApiService.buscarCiudades(query);
      setState(() {
        departamentos = deptData;
        ciudades = ciudadesData;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> showAddDialog() async {
    final controller = TextEditingController();
    int? selectedDept;

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Agregar Ciudad'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la ciudad',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int?>(
                value: selectedDept,
                decoration: const InputDecoration(
                  labelText: 'Departamento (opcional)',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Sin departamento'),
                  ),
                  ...departamentos.map((dept) => DropdownMenuItem<int?>(
                        value: dept.idDepartamento,
                        child: Text(dept.nombre),
                      )),
                ],
                onChanged: (value) {
                  setStateDialog(() {
                    selectedDept = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                if (controller.text.isNotEmpty) {
                  try {
                    await ApiService.createCiudad(controller.text, selectedDept);
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ciudad agregada exitosamente')),
                      );
                      // Recarga con filtro activo
                      await searchCiudades(searchQuery);
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                }
              },
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showConsultDialog(Ciudad ciudad) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Información de la Ciudad'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${ciudad.idCiudad}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Nombre: ${ciudad.nombre}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Departamento: ${ciudad.nombreDepartamento ?? "Sin departamento"}', style: const TextStyle(fontSize: 16)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> confirmDelete(Ciudad ciudad) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de eliminar "${ciudad.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await ApiService.deleteCiudad(ciudad.idCiudad);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ciudad eliminada exitosamente')),
                  );
                  await searchCiudades(searchQuery);
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ciudades'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar ciudad',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: searchCiudades,
              textCapitalization: TextCapitalization.words,
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => searchCiudades(searchQuery),
                    child: ciudades.isEmpty
                        ? const Center(child: Text('No hay ciudades registradas'))
                        : ListView.builder(
                            itemCount: ciudades.length,
                            itemBuilder: (context, index) {
                              final ciudad = ciudades[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.green,
                                    child: Text(ciudad.nombre[0].toUpperCase()),
                                  ),
                                  title: Text(ciudad.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text(ciudad.nombreDepartamento ?? 'Sin departamento'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.visibility, color: Colors.blue),
                                        onPressed: () => showConsultDialog(ciudad),
                                        tooltip: 'Consultar',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => confirmDelete(ciudad),
                                        tooltip: 'Eliminar',
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
      ),
    );
  }
}
