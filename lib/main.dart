import 'package:aula05_lista_de_compras/models/item_model.dart';
import 'package:aula05_lista_de_compras/models/lista_model.dart';
import 'package:aula05_lista_de_compras/util/dbhelper.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(AppListaCompras());
}

class AppListaCompras extends StatelessWidget {
  const AppListaCompras({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ListasView(),
    );
  }
}

class ListasView extends StatefulWidget {
  const ListasView({Key? key}) : super(key: key);

  @override
  State<ListasView> createState() => _ListasViewState();
}

class _ListasViewState extends State<ListasView> {
  late ListaDialog dialog;

  DbHelper helper = DbHelper();
  List<ListaModel> listas = [];

  @override
  void initState() {
    dialog = ListaDialog();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    showData();
    return Scaffold(
      appBar: AppBar(
        title: Text('Listas'),
      ),
      body: Center(
        child: ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: (listas != null) ? listas.length : 0,
            itemBuilder: (BuildContext context, int index) {
              return Dismissible(
                key: Key(listas[index].id.toString()),
                onDismissed: (direction) {
                  String nome = listas[index].nome;
                  helper.deleteList(listas[index]);
                  setState(() {
                    listas.removeAt(index);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('$nome foi deletado'),
                  ));
                },
                child: ListTile(
                  title: Text(listas[index].nome),
                  leading: CircleAvatar(
                    // backgroundColor: Colors.amber,
                    child: Text(
                      listas[index].prioridade.toString(),
                    ),
                  ),
                  trailing: IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) =>
                            dialog.buildDialog(context, listas[index], false),
                      );
                    },
                    icon: Icon(Icons.edit),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ItemsView(listas[index]),
                        ));
                  },
                ),
              );
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) => dialog.buildDialog(
                context, ListaModel(id: 0, nome: '', prioridade: 0), true),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future showData() async {
    await helper.openDb();

    listas = await helper.getListas();

    setState(() {
      listas = listas;
    });

  }
}

class ItemsView extends StatefulWidget {
  final ListaModel lista;
  ItemsView(this.lista);

  @override
  State<ItemsView> createState() => _ItemsViewState(this.lista);
}

class _ItemsViewState extends State<ItemsView> {
  
  late ItemDialog dialog;

  DbHelper helper = DbHelper();
  List<ItemModel> itens = [];

  final ListaModel lista;
  _ItemsViewState(this.lista);

  @override
  void initState() {
    dialog = ItemDialog();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    showData(this.lista.id);
    return Scaffold(
      appBar: AppBar(
        title: Text(lista.nome),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: (itens != null) ? itens.length : 0,
          itemBuilder: (BuildContext context, int index) {
            return Dismissible(
              key: Key(itens[index].id.toString()),
              onDismissed: (direction){
                String itemNome = itens[index].nome;
                String listaNome = lista.nome;
                helper.deleteItem(itens[index]);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Item $itemNome removido da lista $listaNome'))
                );
                setState(() {
                  itens.removeAt(index);
                });
              },
              child: ListTile(
                title: Text(itens[index].nome),
                subtitle: Text(
                    'Quantidade: ${itens[index].quantidade} - Descrição: ${itens[index].descricao}'),
                trailing: IconButton(
                  onPressed: () {
                    showDialog(context: context, builder: (BuildContext context) =>
                      dialog.buildDialog(context, itens[index], lista, false)
                    );
                  },
                  icon: Icon(Icons.edit),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
        onPressed: (){
        showDialog(context: context, builder: (BuildContext context) =>
          dialog.buildDialog(context, ItemModel(id: 0, id_lista: lista.id, nome: '', quantidade: '', descricao: ''), lista, true)
        );
      }),
    );
  }

  Future showData(int idLista) async {
    await helper.openDb();

    itens = await helper.getItens(idLista);

    setState(() {
      if (mounted) {
        itens = itens;
      }
    });
  }
}

class ListaDialog {
  late var txtNome = TextEditingController();
  late var txtPrioridade = TextEditingController();

  Widget buildDialog(BuildContext context, ListaModel lista, bool isNew) {
    DbHelper helper = DbHelper();

    if (!isNew) {
      txtNome = TextEditingController(text: lista.nome);
      txtPrioridade = TextEditingController(text: lista.prioridade.toString());
    }

    return AlertDialog(
      title:
          Text((isNew) ? "Nova lista de compras" : "Editar lista de compras"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: txtNome,
              decoration: InputDecoration(hintText: 'Nome da lista de compras'),
            ),
            TextField(
              controller: txtPrioridade,
              keyboardType: TextInputType.number,
              decoration:
                  InputDecoration(hintText: 'Prioridade da lista de compras'),
            ),
            ElevatedButton(
              onPressed: () {
                lista.nome = txtNome.text;
                lista.prioridade = int.parse(txtPrioridade.text);
                helper.insertLista(lista);
                Navigator.pop(context);
              },
              child: Text("Salvar lista de compras"),
            )
          ],
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
    );
  }
}

class ItemDialog {

  DbHelper helper = DbHelper();

  late var txtListaNome = TextEditingController();
  late var txtNome = TextEditingController();
  late var txtQuantidade = TextEditingController();
  late var txtDescricao = TextEditingController();

  Widget buildDialog(
      BuildContext context, ItemModel item, ListaModel lista, bool isNew) {
    txtListaNome = TextEditingController(text: lista.nome.toString());
    if (!isNew) {
      //edição
      txtNome = TextEditingController(text: item.nome.toString());
      txtQuantidade = TextEditingController(text: item.quantidade.toString());
      txtDescricao = TextEditingController(text: item.descricao.toString());
    }

    return AlertDialog(
      title: Text((isNew) ? "Cadastrar Item" : "Editar Item"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: txtListaNome,
              decoration: InputDecoration(
                enabled: false,
                hintText: "Insira o nome do item",
              ),
            ),
            TextField(
              controller: txtNome,
              decoration: InputDecoration(
                hintText: "Insira o nome do item",
              ),
            ),
            TextField(
              controller: txtQuantidade,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Insira a quantidade do item",
              ),
            ),
            TextField(
              controller: txtDescricao,
              decoration: InputDecoration(
                hintText: "Insira a descrição do item",
              ),
            ),
            ElevatedButton(
              onPressed: () {
                item.nome = txtNome.text;
                item.quantidade = txtQuantidade.text;
                item.descricao = txtDescricao.text;

                helper.insertItem(item);
                Navigator.pop(context);

              },
              child: Text("Salvar Item"),
            )
          ],
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
    );
  }
}
