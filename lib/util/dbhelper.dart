import 'package:aula05_lista_de_compras/models/item_model.dart';
import 'package:aula05_lista_de_compras/models/lista_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  final int version = 1;
  Database? db;
  
  static final DbHelper _dbHelper = DbHelper._internal();

  DbHelper._internal();

  factory DbHelper(){
    return _dbHelper;
  }

  Future<Database?> openDb() async {
    // ignore: prefer_conditional_assignment
    if (db == null) {
      db =
          await openDatabase(join(await getDatabasesPath(), 'lista_compras.db'),
              onCreate: (database, version) {
        database.execute('''
            CREATE TABLE listas (
              id INTEGER PRIMARY KEY,
              nome TEXT,
              prioridade INTEGER
            )
          ''');
        database.execute('''
            CREATE TABLE itens (
              id INTEGER PRIMARY KEY,
              id_lista INTEGER,
              nome TEXT,
              quantidade TEXT,
              descricao TEXT,
              FOREIGN KEY (id_lista) REFERENCES listas(id)
            )
          ''');
      }, version: version);

      return db;
    } else {
      return db;
    }
  }

  // método responsável por testar se a conexão com o banco de dados foi criada corretamente
  // verificar se podemos fazer a inserção com o inser e com o sql padrão
  Future testDb() async {
    db = await openDb();
    db!.execute("INSERT INTO listas VALUES (2 'Frutas', 2)");
    db!.insert('itens', {
      'id_lista': '1',
      'nome': "Maça",
      'quantidade': '1Kg',
      'descricao': 'Preferência para a maça Fuji'
    });

    List listas = await db!.rawQuery('SELECT * FROM listas');
    // List items = await db.
    List<Map<String, Object?>> itens = await db!.query('itens');

    print("Iniciando o debug");
    print(listas.toString());
    print(itens.first.toString());
  }

  Future<int> insertLista(ListaModel lista) async {
    // conflictAlgorithm especifica como o banco deve tratar quando inserimos dados com id duplicados
    // Nesse caso, se a mesma lista for inserida várias vezes, ela substituirá os dados anteriores pela nova lista que foi passada para a função.
    int id = await this.db!.insert('listas', lista.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return id;
  }

  Future<int> insertItem(ItemModel item) async {
    int id = await this.db!.insert(
          'itens',
          item.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
    return id;
  }

  Future<List<ListaModel>> getListas() async {
    final List<Map<String, dynamic>> mapListas = await this.db!.query('listas');

    return List.generate(mapListas.length, (index) {
      return ListaModel(
        id: mapListas[index]['id'],
        nome: mapListas[index]['nome'],
        prioridade: mapListas[index]['prioridade'],
      );
    });
  }

  Future<List<ItemModel>> getItens(int idLista) async {
    final List<Map<String, dynamic>> mapItens = await this
        .db!
        .query('itens', where: 'id_lista = ?', whereArgs: [idLista]);

    return List.generate(mapItens.length, (index) {
      return ItemModel(
        id: mapItens[index]['id'],
        id_lista: mapItens[index]['id_lista'],
        nome: mapItens[index]['nome'],
        quantidade: mapItens[index]['quantidade'],
        descricao: mapItens[index]['descricao'],
      );
    });
  }

  Future<int> deleteList(ListaModel lista) async{
    int result = await this.db!.delete('itens', where: 'id_lista = ?', whereArgs: [lista.id]);
    result = await this.db!.delete('listas',where: 'id = ?', whereArgs: [lista.id]);

    return result;
  }

  Future<int> deleteItem(ItemModel item) async{
    int result = await this.db!.delete('itens', where: 'id = ?', whereArgs: [item.id]);
    return result;
  }
}
