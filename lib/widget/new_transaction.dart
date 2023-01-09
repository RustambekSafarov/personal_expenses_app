import 'package:flutter/material.dart';

class NewTransaction extends StatefulWidget {
  final Function addTx;

  NewTransaction(this.addTx);

  @override
  State<NewTransaction> createState() => _NewTransactionState();
}

final titleController = TextEditingController();
final amountController = TextEditingController();

class _NewTransactionState extends State<NewTransaction> {
  void submitData() {
    if (titleController.text.isEmpty ||
        double.parse(amountController.text) <= 0) {
      return;
    }

    widget.addTx(
      titleController,
      double.parse(amountController.text),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            TextField(
              decoration: InputDecoration(labelText: 'Title'),
              controller: titleController,
              onSubmitted: (_) => submitData(),
              // onChanged: (val) {
              //   titleInput = val;
              // },
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
              controller: amountController,
              onSubmitted: (_) {
                Navigator.pop(context);
                return submitData();
              },
              // onChanged: (val) => amountInput = val,
            ),
            TextButton(
              child: Text('Add Transaction'),
              onPressed: () {
                widget.addTx(
                  titleController.text,
                  amountController.text.isNotEmpty
                      ? double.parse(amountController.text)
                      : Text('No data!'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
