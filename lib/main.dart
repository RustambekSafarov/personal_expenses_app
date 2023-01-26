import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:personal_expenses_app/widget/chart.dart';
import 'package:personal_expenses_app/widget/new_transaction.dart';
import 'package:sqflite/sqflite.dart';

import 'models/transaction.dart';
import 'widget/transaction_list.dart';

void main() {
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Personal Expanses',
      theme: ThemeData(
          primarySwatch: Colors.teal,
          accentColor: Colors.amber,
          fontFamily: 'Quicksand',
          textTheme: ThemeData.light().textTheme.copyWith(
                titleLarge: const TextStyle(
                  fontFamily: 'OpenSans',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
          appBarTheme: const AppBarTheme(
              titleTextStyle: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ))),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Transactions> userTransactions = [];
  Database? _db;
  // String titleInput;
  final titleController = TextEditingController();

  final amountController = TextEditingController();

  List<Transactions> get _recentTransactions {
    return userTransactions.where((tx) {
      return tx.date.isAfter(
        DateTime.now().subtract(
          const Duration(days: 7),
        ),
      );
    }).toList();
  }

  void _addNewTransaction(
      String txTitle, double txAmount, DateTime selectedDate) {
    final newTx = Transactions(
      title: txTitle,
      amount: txAmount,
      date: selectedDate,
      id: DateTime.now().toString(),
    );

    setState(() {
      userTransactions.add(newTx);
    });
    _insertItem(newTx);
  }

  void startAddNewTransaction(BuildContext ctx) {
    showModalBottomSheet(
        context: ctx,
        builder: (_) {
          return GestureDetector(
            onTap: () {},
            behavior: HitTestBehavior.opaque,
            child: NewTransaction(_addNewTransaction),
          );
        });
  }

  void _deleteTransaction(String id) {
    setState(() {
      userTransactions.removeWhere((tx) => tx.id == id);
    });
  }

  @override
  void initState() {
    super.initState();

    // Open the database and read the list of items when the app starts
    _openDb().then((value) {
      _readItems().then((items) {
        setState(() {
          userTransactions = items as List<Transactions>;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      title: const Text(
        'Personal Expanses',
        style: TextStyle(fontFamily: 'OpenSans', fontSize: 20),
      ),
      actions: [
        IconButton(
            onPressed: () => startAddNewTransaction(context),
            icon: Icon(Icons.add))
      ],
    );
    return Scaffold(
      appBar: appBar,
      body: SingleChildScrollView(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              height: (MediaQuery.of(context).size.height -
                      appBar.preferredSize.height -
                      MediaQuery.of(context).padding.top) *
                  0.26,
              child: Chart(_recentTransactions),
            ),
            Container(
                height: (MediaQuery.of(context).size.height -
                        appBar.preferredSize.height -
                        MediaQuery.of(context).padding.top) *
                    0.7,
                child: TransactionList(userTransactions, _deleteTransaction)),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            print(userTransactions);
            return startAddNewTransaction(context);
          }),
    );
  }

// Opens the database
  Future<void> _openDb() async {
    // Get the path to the database
    final String path = join(await getDatabasesPath(), 'my_database.db');

    // Open the database
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (Database newDb, int version) {
        // When creating the db, create
        // When creating the db, create the table
        newDb.execute("""
CREATE TABLE items (
  id INTEGER PRIMARY KEY,
  name TEXT
)
""");
      },
    );
  }

  // Inserts an item into the database
  Future<void> _insertItem(Transactions name) async {
    // Insert the new row into the table
    await _db!.insert('items', {'name': name});

    // Read the list of items from the database and update the state
    _readItems().then((items) {
      setState(() {
        userTransactions = items;
      });
    });
  }

  // Reads the list of items from the database
  Future<List<Transactions>> _readItems() async {
    // Get the list of items from the database
    List<Map> maps = await _db!.query('items');

    // Convert the list of maps to a list of strings
    return List.generate(maps.length, (i) {
      return maps[i]['name'];
    });
  }
}
