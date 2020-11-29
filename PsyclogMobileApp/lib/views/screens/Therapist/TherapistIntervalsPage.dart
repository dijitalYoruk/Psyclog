import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:psyclog_app/views/util/ViewConstants.dart';

class TherapistIntervalsPage extends StatefulWidget {
  @override
  _TherapistIntervalsPageState createState() => _TherapistIntervalsPageState();
}

class _TherapistIntervalsPageState extends State<TherapistIntervalsPage> {
  @override
  Widget build(BuildContext context) {
    return         Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: IconThemeData(color: ViewConstants.myBlack),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: Text(
          "Blocked Intervals",
          style: GoogleFonts.lato(fontSize: 20, color: ViewConstants.myBlack, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment(4, 4),
                      colors: [ViewConstants.myWhite, ViewConstants.myLightBlue]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
