import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:psyclog_app/src/models/Client.dart';
import 'package:psyclog_app/src/models/ClientRequest.dart';
import 'package:psyclog_app/view_models/therapist/TherapistPendingListViewModel.dart';
import 'package:psyclog_app/views/util/ViewConstants.dart';
import 'package:psyclog_app/views/widgets/AwareListItem.dart';

class TherapistPendingRequestPage extends StatefulWidget {
  @override
  _TherapistPendingRequestPageState createState() => _TherapistPendingRequestPageState();
}

class _TherapistPendingRequestPageState extends State<TherapistPendingRequestPage> {
  TherapistPendingListViewModel _pendingListViewModel;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _pendingListViewModel = TherapistPendingListViewModel();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment(10, 10), colors: [ViewConstants.myWhite, ViewConstants.myLightBlue]),
      ),
      child: CustomScrollView(slivers: <Widget>[
        SliverAppBar(
          automaticallyImplyLeading: true,
          elevation: 0,
          expandedHeight: MediaQuery.of(context).size.height * 0.05,
          pinned: false,
          stretch: true,
          title: new Text(
            "Pending Requests",
            style: TextStyle(color: ViewConstants.myGrey),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(
            color: ViewConstants.myGrey,
          ),
        ),
        SliverToBoxAdapter(
          child: Card(
            elevation: 4,
            shadowColor: ViewConstants.myLightBlue,
            color: ViewConstants.myWhite,
            clipBehavior: Clip.antiAlias,
            margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Container(
              padding: EdgeInsets.all(18),
              height: MediaQuery.of(context).size.height / 8,
              decoration: BoxDecoration(color: ViewConstants.myLightBlue.withOpacity(0.4)),
              child: Center(
                child: AutoSizeText(
                  "You can check your pending requests here. To deny the request, slide left; to accept it, slide right.",
                  maxLines: 2,
                  minFontSize: 8,
                  maxFontSize: 20,
                  stepGranularity: 1,
                  style: TextStyle(color: ViewConstants.myGrey, fontFamily: "OpenSans"),
                ),
              ),
            ),
          ),
        ),
        ChangeNotifierProvider<TherapistPendingListViewModel>(
            create: (context) => _pendingListViewModel,
            child: Consumer<TherapistPendingListViewModel>(
              builder: (context, model, child) => SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    ClientRequest _request = model.getClientByIndex(index);

                    Client client = _request.getClient;

                    double containerHeight = MediaQuery.of(context).size.height / 6 - 20;

                    return AwareListItem(itemCreated: () {
                      SchedulerBinding.instance.addPostFrameCallback((duration) {
                        model.handleItemCreated(index);
                      });
                    }, child: Builder(builder: (BuildContext context) {
                      if (_request == null) {
                        return CircularProgressIndicator();
                      } else {
                        return Dismissible(
                          key: UniqueKey(),
                          confirmDismiss: (direction) => checkDismissibleAction(index, direction),
                          dismissThresholds: {DismissDirection.endToStart: 0.7, DismissDirection.startToEnd: 0.7},
                          background: Container(
                            padding: EdgeInsets.symmetric(horizontal: 25),
                            decoration: BoxDecoration(
                                gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [
                              ViewConstants.myGreen.withOpacity(0.85),
                              ViewConstants.myGreen.withOpacity(0.65),
                              ViewConstants.myPink.withOpacity(0.65),
                              ViewConstants.myPink.withOpacity(0.85)
                            ])),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Icon(
                                    Icons.done,
                                    color: ViewConstants.myWhite,
                                    size: 75,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Icon(
                                    Icons.clear,
                                    color: ViewConstants.myWhite,
                                    size: 75,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                              elevation: 2,
                              child: Container(
                                height: containerHeight + 20,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: ViewConstants.myWhite,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.all(10),
                                      height: containerHeight,
                                      width: containerHeight,
                                      decoration: BoxDecoration(
                                        color: ViewConstants.myLightBlue.withOpacity(0.4),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              client.getFullName(),
                                              style: GoogleFonts.lato(
                                                  fontSize: 15, color: ViewConstants.myBlack, fontWeight: FontWeight.bold),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                child: SingleChildScrollView(
                                                  physics: BouncingScrollPhysics(),
                                                  scrollDirection: Axis.vertical, //.horizontal
                                                  child: Text(_request.getContent,
                                                      style: GoogleFonts.lato(fontSize: 12, color: ViewConstants.myBlack)),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              )),
                        );
                      }
                    }));
                  },
                  childCount: model.getCurrentListLength(),
                ),
              ),
            ))
      ]),
    );
  }

  Future<bool> checkDismissibleAction(int index, DismissDirection direction) async {
    return await showDialog<bool>(
        barrierColor: Colors.transparent,
        context: context,
        builder: (context) =>
            Builder(
              builder: (context) {
                if (direction == DismissDirection.startToEnd) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: ViewConstants.myWhite,
                    title: Text("Are you sure you want to accept this request?"),
                    titleTextStyle: TextStyle(color: ViewConstants.myGrey),
                    insetPadding: EdgeInsets.all(20),
                    actionsPadding: EdgeInsets.all(10),
                    actions: <Widget>[
                      FlatButton(
                        child: Text(
                          'Accept',
                          style: TextStyle(color: ViewConstants.myLightBlue),
                        ),
                        onPressed: () async {
                          bool isAccepted = await _pendingListViewModel.acceptPendingRequestByIndex(index);
                          if (isAccepted)
                            Navigator.of(context).pop(true);
                          else
                            Navigator.of(context).pop(false);
                        },
                      ),
                      FlatButton(
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: ViewConstants.myGrey),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                      )
                    ],
                  );
                } else if (direction == DismissDirection.endToStart) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: ViewConstants.myWhite,
                    title: Text("Are you sure you want to deny this request?"),
                    titleTextStyle: TextStyle(color: ViewConstants.myGrey),
                    insetPadding: EdgeInsets.all(20),
                    actionsPadding: EdgeInsets.all(10),
                    actions: <Widget>[
                      FlatButton(
                        child: Text(
                          'Deny',
                          style: TextStyle(color: ViewConstants.myLightBlue),
                        ),
                        onPressed: () async {
                          bool isRemoved = false;
                          if (isRemoved)
                            Navigator.of(context).pop(true);
                          else
                            Navigator.of(context).pop(false);
                        },
                      ),
                      FlatButton(
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: ViewConstants.myGrey),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                      )
                    ],
                  );
                } else {
                  return CircularProgressIndicator();
                }
              },
            ) ??
            false // In case the user dismisses the dialog by clicking away from it
        );
  }
}
