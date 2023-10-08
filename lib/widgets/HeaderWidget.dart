import 'package:flutter/material.dart';

AppBar header(context,
    {bool isAppTitle, String strTitle, disappearedBackButton = false}) {
  return AppBar(
    iconTheme: IconThemeData(
      color: Colors.white,
    ),
    automaticallyImplyLeading: disappearedBackButton ? false : true,
    title: Text(
      isAppTitle ? '2value' : strTitle,
      style: TextStyle(
        color: Colors.white,
        fontFamily: isAppTitle ? 'signatra' : '',
        fontSize: isAppTitle ? 45.0 : 22.0,
      ),
      overflow: TextOverflow.ellipsis,
    ),
    centerTitle: true,
    backgroundColor: Theme.of(context).primaryColor,
  );
}
