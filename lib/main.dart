import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;

void main() {
  runApp(PlanetApp());
}

class PlanetApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerenciador de Planetas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PlanetListScreen(),
    );
  }
}

class Planet {
  int? id;
  String name;
  double distance;
  double size;
  String? nickname;

  Planet({
    this.id,
    required this.name,
    required this.distance,
    required this.size,
    this.nickname,
  });

  // Converte o objeto para um mapa
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'distance': distance,
      'size': size,
      'nickname': nickname,
    };
  }

  // Converte um mapa para um objeto Planet
  factory Planet.fromMap(Map<String, dynamic> map) {
    return Planet(
      id: map['id'] as int?,
      name: map['name'] as String,
      distance: map['distance'] as double,
      size: map['size'] as double,
      nickname: map['nickname'] as String?,
    );
  }
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('planets.db');
    return _database!;
  }

  // Inicializa o banco de dados
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Cria a tabela do banco de dados
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE planets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        distance REAL NOT NULL,
        size REAL NOT NULL,
        nickname TEXT
      )
    ''');
  }

  // Insere um planeta no banco de dados
  Future<int> insertPlanet(Planet planet) async {
    final db = await database;
    return await db.insert('planets', planet.toMap());
  }

  // Recupera todos os planetas do banco de dados
  Future<List<Planet>> getPlanets() async {
    final db = await database;
    final result = await db.query('planets');
    return result.map((map) => Planet.fromMap(map)).toList();
  }

  // Atualiza um planeta no banco de dados
  Future<int> updatePlanet(Planet planet) async {
    final db = await database;
    return await db.update(
      'planets',
      planet.toMap(),
      where: 'id = ?',
      whereArgs: [planet.id],
    );
  }

  // Deleta um planeta do banco de dados
  Future<int> deletePlanet(int id) async {
    final db = await database;
    return await db.delete(
      'planets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  openDatabase(String path, {required int version, required Future<void> Function(dynamic db, int version) onCreate}) {}
}

class PlanetListScreen extends StatefulWidget {
  @override
  _PlanetListScreenState createState() => _PlanetListScreenState();
}

class _PlanetListScreenState extends State<PlanetListScreen> {
  late Future<List<Planet>> _planetList;

  @override
  void initState() {
    super.initState();
    _planetList = DatabaseHelper.instance.getPlanets();
  }

  // Atualiza a lista de planetas após ações
  void _refreshPlanetList() {
    setState(() {
      _planetList = DatabaseHelper.instance.getPlanets();
    });
  }

  // Deleta um planeta
  void _deletePlanet(int id) async {
    await DatabaseHelper.instance.deletePlanet(id);
    _refreshPlanetList();
  }

  // Adiciona um planeta fictício (para teste rápido)
  void _addSamplePlanet() async {
    final newPlanet = Planet(
      name: 'Planeta X',
      distance: 100.0,
      size: 5000.0,
      nickname: 'Desconhecido',
    );
    await DatabaseHelper.instance.insertPlanet(newPlanet);
    _refreshPlanetList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Planetas')),
      body: FutureBuilder<List<Planet>>(
        future: _planetList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum planeta encontrado.'));
          }
          final planets = snapshot.data!;
          return ListView.builder(
            itemCount: planets.length,
            itemBuilder: (context, index) {
              final planet = planets[index];
              return ListTile(
                title: Text(planet.name),
                subtitle: Text(planet.nickname ?? 'Sem apelido'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deletePlanet(planet.id!),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSamplePlanet,
        child: const Icon(Icons.add),
      ),
    );
  }
}