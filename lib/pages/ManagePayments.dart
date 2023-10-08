import 'package:app/services/PaymentsService.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';

class ManagePayments extends StatefulWidget {
  @override
  _ManagePaymentsState createState() => _ManagePaymentsState();
}

class _ManagePaymentsState extends State<ManagePayments> {
//  PaymentMethod _paymentMethod;
//  Source _source;
  String _error;

  @override
  void initState() {}

  void setError(dynamic error) {
    _scaffoldKey.currentState
        .showSnackBar(SnackBar(content: Text(error.toString())));
    setState(() {
      _error = error.toString();
      print(error.toString());
    });
  }

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Manage payments'),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Text(
              'Cards',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 40.0,
              ),
            ),
            Text('You have 1 card on file'),
            Container(
              child: Row(
                children: <Widget>[
                  Image(image: AssetImage('assetName')),
                  Text('Visa ...5606')
                ],
              ),
            ),
            Container(),
            Container(),
            Container(),
            Container(
              width: 200,
              child: FlatButton(
                onPressed: () async {
                  ProgressDialog dialog = new ProgressDialog(context);
                  dialog.style(message: 'Please wait...');
                  await dialog.show();
                  var response = await PaymentService.payWithNewCard(
                      amount: '15000', currency: 'USD');
                  await dialog.hide();
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text(response.message),
                    duration: new Duration(
                        milliseconds: response.success == true ? 1200 : 3000),
                  ));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(Icons.add),
                    ),
                    Text(
                      'Add Card',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
