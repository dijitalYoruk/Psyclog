import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:psyclog_app/views/util/ViewConstants.dart';

class ClientMessagePage extends StatefulWidget {
  @override
  _ClientMessagePageState createState() => _ClientMessagePageState();
}

class _ClientMessagePageState extends State<ClientMessagePage> {
  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
        filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          color: ViewConstants.myWhite,
        ));
  }
}
