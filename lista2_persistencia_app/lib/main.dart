import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:social_share/social_share.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(
    title:'Lista de Compra',
    debugShowCheckedModeBanner: false,
    home: MainApp(),
  ));
}
class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {

  final _formKey = GlobalKey<FormState>();
  var _itemController = TextEditingController();

  List<Item> _lista = new List<Item>();
  ItemRepository repository = new ItemRepository();

  @override
  void initState(){
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_){
      repository.readData().then((data){
        setState(() {
          _lista = data;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('App Lista'),
        centerTitle: true,//Coloca o titulo no centro
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            /*
            onPressed: () async {
              var itens = _lista.reduce((value, element) => value +'\n'+ element);
              SocialShare.shareWhatsapp("Lista de Compras:\n" + itens).then((data){
                //print(data);
              });

            },*/
          )
        ],
      ),
      body: Scrollbar(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            for(int i = 0;i < _lista.length;i++)
              ListTile(
                title: CheckboxListTile(
                  controlAffinity: ListTileControlAffinity.leading,
                  title: _lista[i].concluido?
                  Text(_lista[i].nome,style: TextStyle(decoration:TextDecoration.lineThrough),):
                  Text(_lista[i].nome),
                  value: _lista[i].concluido,
                  secondary: IconButton(
                    icon: Icon(
                      Icons.delete,
                      size: 20.0,
                      color:Colors.red[900],
                    ),
                    onPressed: (){
                      setState(() {
                        _lista.removeAt(i);
                        _updateLista();
                        _ordenarLista();
                      });
                    },
                  ),
                  onChanged: (c){
                    setState(() {
                      _lista[i].concluido = c;
                      _updateLista();
                      _ordenarLista();
                    });
                  },
              )),


          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _diplayDialog(context), // expressao lambda ex: (a,b) => { print(a, b);}

      ),
    );//Container - Cernter - Row - Column - Scaffold
  }

  _diplayDialog(context) async{
    return showDialog(
        context:context,
        builder: (context){
          return AlertDialog(
            content: Form(
              key: _formKey,
              child: TextFormField(
                controller: _itemController,
                validator: (s){
                  if(s.isEmpty)
                    return "Digite o item";
                  else
                    return null;
                },
                keyboardType: TextInputType.text,
                decoration: InputDecoration(labelText: "Item"),
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: new Text('Cancelar'),
                onPressed:(){
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: new Text('Salvar'),
                onPressed:(){
                  if(_formKey.currentState.validate()) {
                    setState(() {
                      _lista.add(Item(nome:_itemController.text,concluido: false));
                      _updateLista();
                      _ordenarLista();
                      _itemController.text = "";
                    });
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        }
    );
  }
  _updateLista() async {
    repository.saveData(_lista);
    _lista = await repository.readData();
  }
  _ordenarLista(){
    _lista.sort((a,b){
      if(a.concluido && !b.concluido) return 1;
      else if(!a.concluido && b.concluido) return -1;
      else return 0;
    });
  }
}
class Item {
  String nome;
  bool concluido;

  Item({this.nome, this.concluido});

  Item.fromJson(Map<String, dynamic> json) {
    nome = json['nome'];
    concluido = json['concluido'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nome'] = this.nome;
    data['concluido'] = this.concluido;
    return data;
  }
}

class ItemRepository{
  Future<String> get _localPath async{
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
  Future<File> get _localFile async{
    final path = await _localPath;
    return File('$path/data.json');
  }
  Future<List<Item>> readData() async{
    try{
      final file = await _localFile;
      //read file
      String dataJson = await file.readAsString();

      List<Item> data = (json.decode(dataJson) as List)
          .map((i)=> Item.fromJson(i)).toList();
      return data;
    }catch(e){
      return List<Item>();
    }
  }

  Future<bool> saveData(List<Item> list) async{
    try{
      final file = await _localFile;
      final String data = json.encode(list);
      //write in file
      file.writeAsString(data);
      return true;
    }catch(e){
      return false;
    }
  }

}



