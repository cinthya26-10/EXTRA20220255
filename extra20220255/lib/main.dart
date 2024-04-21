import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<List<Character>> createCharacters() async {
  final response = await http
      .get(Uri.parse('https://harry-potter-api.onrender.com/personajes'));

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    final characters = <Character>[];
    for (final json in jsonResponse) {
      characters.add(Character.fromJson(json));
    }
    return characters;
  } else {
    throw Exception('error');
  }
}

class Character {
  final String? personaje;
  final String? apodo;
  final String? casaDeHogwarts;
  final String? interpretado_por;
  final String? imagen;

  const Character({
    this.personaje,
    this.apodo,
    this.casaDeHogwarts,
    this.interpretado_por,
    this.imagen,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      personaje: json['personaje'],
      apodo: json['apodo'],
      casaDeHogwarts: json['casaDeHogwarts'],
      interpretado_por: json['interpretado_por'],
      imagen: json['imagen'],
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<Character>> _futureCharacters;

  @override
  void initState() {
    super.initState();
    _futureCharacters = createCharacters();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Harry Potter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Personajes de Harry Potter'),
        ),
        body: Container(
          decoration: BoxDecoration(color: Colors.pinkAccent),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8),
          child: FutureBuilder<List<Character>>(
            future: _futureCharacters,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final characters = snapshot.data![index];
                    return ListTile(
                      title: Text(
                        characters.personaje ?? '',
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (characters.apodo != null)
                            Text(
                              'Alias: ${characters.apodo}',
                              style: TextStyle(color: Colors.white),
                            ),
                          if (characters.casaDeHogwarts != null)
                            Text(
                              'House: ${characters.casaDeHogwarts}',
                              style: TextStyle(color: Colors.white),
                            ),
                          if (characters.interpretado_por != null)
                            Text(
                              'Actor: ${characters.interpretado_por}',
                              style: TextStyle(color: Colors.white),
                            ),
                        ],
                      ),
                      leading: Image.network('${characters.imagen}'),
                    );
                  },
                );
              } else {
                return const Text('Error');
              }
            },
          ),
        ),
      ),
    );
  }
}
