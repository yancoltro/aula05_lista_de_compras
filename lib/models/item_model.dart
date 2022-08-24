// ignore_for_file: non_constant_identifier_names

class ItemModel {
  int id;
  int id_lista;
  String nome;
  String quantidade;
  String descricao;

  ItemModel(
      {required this.id,
      required this.id_lista,
      required this.nome,
      required this.quantidade,
      required this.descricao});

  Map<String, dynamic> toMap() {
    return {
      'id': (id == 0) ? null : id,
      'id_lista': id_lista,
      'nome': nome,
      'quantidade': quantidade,
      'descricao': descricao
    };
  }
}
