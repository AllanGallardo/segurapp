import 'package:flutter/material.dart';
import 'package:segurapp/Screens/navbar.dart';
void main() {
  runApp(const MyApp());
}

class UserProfile {
  String email;
  String name;
  String lastName;
  String mobileNumber;
  String language;
  String country;
  String city;
  String address;

  UserProfile({
    required this.email,
    required this.name,
    required this.lastName,
    required this.mobileNumber,
    required this.language,
    required this.country,
    required this.city,
    required this.address,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Perfil de Usuario',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: EditProfileScreen(
        userProfile: UserProfile(
          email: 'usuario@example.com',
          name: 'example',
          lastName: 'example',
          mobileNumber: '+569',
          language: 'Es',
          country: 'example',
          city: 'example',
          address: 'example',
        ),
      ),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  final UserProfile userProfile;

  const EditProfileScreen({super.key, required this.userProfile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _emailController;
  late TextEditingController _nameController;
  late TextEditingController _lastNameController;
  late TextEditingController _mobileNumberController;
  late TextEditingController _languageController;
  late TextEditingController _countryController;
  late TextEditingController _cityController;
  late TextEditingController _addressController;

// Lista de idiomas disponibles
  final List<String> _languages = ['Español', 'Inglés', 'Francés', 'Alemán', 'Italiano'];

  String _selectedLanguage = 'Español'; // Idioma seleccionado por defecto

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.userProfile.email);
    _nameController = TextEditingController(text: widget.userProfile.name);
    _lastNameController = TextEditingController(text: widget.userProfile.lastName);
    _mobileNumberController = TextEditingController(text: widget.userProfile.mobileNumber);
    _languageController = TextEditingController(text: widget.userProfile.language);
    _countryController = TextEditingController(text: widget.userProfile.country);
    _cityController = TextEditingController(text: widget.userProfile.city);
    _addressController = TextEditingController(text: widget.userProfile.address);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _lastNameController.dispose();
    _mobileNumberController.dispose();
    _languageController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Correo electrónico'),
            ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(labelText: 'Apellido'),
            ),
            TextField(
              controller: _mobileNumberController,
              decoration: const InputDecoration(labelText: 'Teléfono móvil'),
            ),
            // IDIOMA
            DropdownButton<String>(
              value: _selectedLanguage,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedLanguage = newValue!;
                });
              },
              items: _languages.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            TextField(
              controller: _countryController,
              decoration: const InputDecoration(labelText: 'País'),
            ),
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(labelText: 'Ciudad'),
            ),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Dirección'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Aquí puedes agregar la lógica para guardar los datos del perfil
                // Puedes acceder a los valores de los controladores de texto (_emailController.text, etc.)
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
        
      ),
      bottomNavigationBar: const CustomNavigationBar(),
    );
    
  }
}
