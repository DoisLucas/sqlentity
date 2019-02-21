import 'package:flutter/material.dart';
import 'package:sqlentity/base-entity/entity.dart';
import 'package:sqlentity/database/database-config.dart';
import 'package:sqlentity/repository/dao/i-dao-repository.dart';
import 'package:sqlentity/repository/dao/dao-repository.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<UserEntity> users = new List();
  IDAORepository<UserEntity> _idao;

  _MyAppState() {
    initDatabase();
    _idao = new DAORepository(new UserEntity());
    initData();
  }

  void initDatabase() {
    DataBaseConfig dataBaseConfig = DataBaseConfig.getInstance();
    dataBaseConfig.database_name = "Teste";
    dataBaseConfig.database_version = 1;
    dataBaseConfig.entitys = [new UserEntity()];
  }

  void initData() async {
    //criar a entidade
    UserEntity dart = new UserEntity(name: "DART");
    UserEntity flutter = new UserEntity(name: "FLUTTER");
    UserEntity android = new UserEntity(name: "ANDROID");

    //realiza a inserção no banco e retorna o id
    int iddart = await _idao.insert(dart);
    await _idao.insert(flutter);
    int idandroid = await _idao.insert(android);
    dart.id = iddart;
    dart.name = "KOTLIN";

    //realiza a atualização da entidade no banco e retorna um status
    await _idao.update(dart);
    android.id = idandroid;

    //realiza a exclusao no banco e retorna um status
    await _idao.delete(android);

    //lista de usuarios no banco
    var userlist = await _idao.select() as List<UserEntity>;
    setState(() {
      //setando lista
      users = userlist;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
          appBar: new AppBar(
            title: const Text('DataBase'),
          ),
          body: new ListView.builder(
              padding: new EdgeInsets.all(4.0),
              shrinkWrap: true,
              itemCount: users.length,
              itemBuilder: (context, index) {
                return new Container(
                    margin: new EdgeInsets.all(8.0),
                    child: new Center(
                        child: new Text(
                      '${users[index].name}',
                      style: new TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    )));
              })),
    );
  }
}

class UserEntity extends Entity {
  int _id;
  String _name;

  UserEntity({var id: 0, var name: ""}) : super('USER') {
    this.id = id;
    this.name = name;
  }

  @override
  void configColumn() {
    //O id deve ser sempre o primeiro caso queira usar as operaçoes padroes do DAO
    createColumn("ID", "INTEGER PRIMARY KEY AUTOINCREMENT", 1);

    //nova coluna
    createColumn("NAME", "TEXT", 1);
  }

  @override
  Entity map(Map<String, dynamic> map) {
    return new UserEntity(
      id: map['ID'],
      name: map['NAME'],
    );
  }

  int get id => _id;

  set id(int value) {
    _id = value;
    updateValeu("ID", value: id);
  }

  String get name => _name;

  set name(String value) {
    _name = value;
    updateValeu("NAME", value: _name);
  }
}
