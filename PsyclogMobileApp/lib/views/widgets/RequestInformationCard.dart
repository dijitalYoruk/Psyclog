import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:psyclog_app/service/WebServerService.dart';
import 'package:psyclog_app/service/util/ServiceErrorHandling.dart';
import 'package:psyclog_app/views/util/ViewConstants.dart';

class RequestInformationCard extends StatefulWidget {
  final String therapistID;
  final String therapistName;
  final bool currentUserApplied;

  const RequestInformationCard(
      {Key key, this.therapistID, this.therapistName, this.currentUserApplied})
      : super(key: key);

  @override
  _RequestInformationCardState createState() => _RequestInformationCardState();
}

class _RequestInformationCardState extends State<RequestInformationCard> {
  bool _onApply;
  TextEditingController _contactInfoController;
  WebServerService _service;
  bool _applied;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _onApply = false;
    _contactInfoController = TextEditingController();
    _applied =
        widget.currentUserApplied != null ? widget.currentUserApplied : false;
    initializeService();
  }

  initializeService() async {
    try {
      _service = await WebServerService.getWebServerService();
    } catch (error) {
      print(error);
    }
  }

  createPatientRequest(BuildContext context) async {
    final String infoText = _contactInfoController.text;
    String _snackText;

    _onApply = !_onApply;

    if (infoText.isNotEmpty) {
      String response =
          await _service.createPatientRequest(widget.therapistID, infoText);

      if (response == ServiceErrorHandling.successfulStatusCode) {
        _snackText = "Successfully created a patient request.";
        _applied = true;
      } else {
        _snackText = response;
      }
    } else {
      _snackText = "Please fill out the message area.";
    }

    setState(() {
      final snackBar = SnackBar(
          duration: Duration(milliseconds: 1500),
          backgroundColor: ViewConstants.myBlack,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          behavior: SnackBarBehavior.floating,
          content: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text(
              _snackText,
              style: TextStyle(color: ViewConstants.myWhite),
            ),
          ));
      Scaffold.of(context).showSnackBar(snackBar);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _contactInfoController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          color: Colors.transparent,
          margin: EdgeInsets.only(bottom: 10),
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            decoration: BoxDecoration(
              color: _onApply
                  ? ViewConstants.myBlack.withOpacity(0.75)
                  : ViewConstants.myBlack,
              borderRadius: BorderRadius.circular(10),
            ),
            width: _onApply
                ? constraints.maxWidth * 0.9
                : constraints.maxWidth * 0.5,
            height: _onApply
                ? constraints.maxHeight
                : constraints.maxHeight * 0.075,
            duration: Duration(milliseconds: 666),
            curve: Curves.easeOutCirc,
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 666),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: _applied == false
                    ? Container(
                        padding: EdgeInsets.zero,
                        decoration: BoxDecoration(
                          color: ViewConstants.myBlack,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: MaterialButton(
                          padding: EdgeInsets.zero,
                          height: constraints.maxHeight * 0.075,
                          minWidth: constraints.maxWidth,
                          onPressed: () {
                            setState(() {
                              _onApply = !_onApply;
                            });
                          },
                          child: Text("Apply",
                              textAlign: TextAlign.center,
                              style: ViewConstants.fieldStyle.copyWith(
                                  fontSize: 15,
                                  color: ViewConstants.myWhite,
                                  fontWeight: FontWeight.w500)),
                        ),
                      )
                    : Container(
                        padding: EdgeInsets.zero,
                        decoration: BoxDecoration(
                          color: ViewConstants.myLightBlue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text("Pending",
                              textAlign: TextAlign.center,
                              style: ViewConstants.fieldStyle.copyWith(
                                  fontSize: 15,
                                  color: ViewConstants.myBlack,
                                  fontWeight: FontWeight.w500)),
                        ),
                      ),
              ),
              transitionBuilder: (Widget child, Animation<double> animation) {
                if (_onApply == false)
                  return ScaleTransition(child: child, scale: animation);
                else
                  return ScaleTransition(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Stack(
                          children: [
                            Container(
                              color: ViewConstants.myBlack.withOpacity(0.5),
                              margin: EdgeInsets.only(
                                  bottom: constraints.maxHeight * 0.075),
                              child: Column(
                                children: [
                                  Flexible(
                                    flex: 1,
                                    child: Container(
                                      color: ViewConstants.myBlack,
                                      child: Center(
                                        child: AutoSizeText(
                                          "Give some information about yourself. This might help Dr. " +
                                              widget.therapistName +
                                              " to understand your situation.",
                                          textAlign: TextAlign.center,
                                          minFontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 5,
                                    child: Theme(
                                      data: ThemeData(
                                        primaryColor: ViewConstants.myBlack,
                                        cursorColor: ViewConstants.myBlack,
                                      ),
                                      child: ListView(
                                        physics: NeverScrollableScrollPhysics(),
                                        children: [
                                          TextField(
                                            keyboardType: TextInputType.text,
                                            maxLines: null,
                                            maxLength: 250,
                                            controller: _contactInfoController,
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: ViewConstants.myWhite),
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 20),
                                              border: InputBorder.none,
                                              hintText: 'Your message...',
                                              hintStyle: TextStyle(
                                                  fontSize: 20,
                                                  color: ViewConstants.myWhite),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: MaterialButton(
                                padding: EdgeInsets.zero,
                                color: ViewConstants.myBlack,
                                height: constraints.maxHeight * 0.08,
                                minWidth: constraints.maxWidth * 0.9,
                                onPressed: () {
                                  createPatientRequest(context);
                                },
                                child: Text("Contact",
                                    textAlign: TextAlign.center,
                                    style: ViewConstants.fieldStyle.copyWith(
                                        fontSize: 15,
                                        color: ViewConstants.myWhite,
                                        fontWeight: FontWeight.w500)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      scale: animation);
              },
            ),
          ),
        );
      },
    );
  }
}
