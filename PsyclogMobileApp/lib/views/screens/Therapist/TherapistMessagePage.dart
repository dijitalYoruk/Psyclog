import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:psyclog_app/views/util/ViewConstants.dart';

class TherapistMessagePage extends StatefulWidget {
  @override
  _TherapistMessagePageState createState() => _TherapistMessagePageState();
}

class _TherapistMessagePageState extends State<TherapistMessagePage> {
  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
        filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          color: ViewConstants.myWhite,
        ));
  }
}
