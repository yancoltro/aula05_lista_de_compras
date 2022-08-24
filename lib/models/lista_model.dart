class ListaModel {
  int id;
  String nome;
  int prioridade;

  ListaModel({required this.id, required this.nome, required this.prioridade});

  Map<String, dynamic> toMap() {
    return {
      'id': (id == 0) ? null : id, // definimos como 0, para que o sqlite incremente automaticamente
      'nome': nome,
      'prioridade': prioridade
    };
  }
}
