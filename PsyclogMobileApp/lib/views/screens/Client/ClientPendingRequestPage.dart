import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:psyclog_app/src/models/Therapist.dart';
import 'package:psyclog_app/src/models/TherapistRequest.dart';
import 'package:psyclog_app/views/util/ViewConstants.dart';
import 'package:psyclog_app/view_models/client/ClientPendingListViewModel.dart';
import 'package:psyclog_app/views/widgets/AwareListItem.dart';

class ClientPendingRequestPage extends StatefulWidget {
  @override
  _ClientPendingRequestPageState createState() =>
      _ClientPendingRequestPageState();
}

class _ClientPendingRequestPageState extends State<ClientPendingRequestPage> {
  ClientPendingListViewModel _pendingListViewModel;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _pendingListViewModel = ClientPendingListViewModel();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment(10, 10),
            colors: [ViewConstants.myWhite, ViewConstants.myLightBlue]),
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
              decoration: BoxDecoration(
                  color: ViewConstants.myLightBlue.withOpacity(0.4)),
              child: Center(
                child: AutoSizeText(
                  "You can check your pending requests or remove them by sliding the cards to the left.",
                  maxLines: 2,
                  minFontSize: 8,
                  maxFontSize: 20,
                  stepGranularity: 1,
                  style: TextStyle(
                      color: ViewConstants.myGrey, fontFamily: "OpenSans"),
                ),
              ),
            ),
          ),
        ),
        ChangeNotifierProvider<ClientPendingListViewModel>(
            create: (context) => _pendingListViewModel,
            child: Consumer<ClientPendingListViewModel>(
              builder: (context, model, child) => SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    TherapistRequest _request =
                        model.getTherapistByIndex(index);

                    Therapist therapist = _request.getTherapist;

                    double containerHeight =
                        MediaQuery.of(context).size.height / 5 - 20;

                    return AwareListItem(
                      itemCreated: () {
                        SchedulerBinding.instance
                            .addPostFrameCallback((duration) {
                          model.handleItemCreated(index);
                        });
                      },
                      child: Builder(
                        builder: (BuildContext context) {
                          if (_request == null) {
                            return CircularProgressIndicator();
                          } else {
                            return Dismissible(
                              key: UniqueKey(),
                              confirmDismiss: (direction) =>
                                  checkDismissibleAction(index),
                              dismissThresholds: {
                                DismissDirection.endToStart: 0.7
                              },
                              direction: DismissDirection.endToStart,
                              background: Container(
                                padding: EdgeInsets.symmetric(horizontal: 25),
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                      ViewConstants.myPink,
                                      ViewConstants.myPink.withOpacity(0.50)
                                    ])),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Icon(
                                    Icons.clear,
                                    color: ViewConstants.myWhite,
                                    size: 75,
                                  ),
                                ),
                              ),
                              child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 10),
                                  elevation: 2,
                                  child: Container(
                                    height:
                                        MediaQuery.of(context).size.height / 5,
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
                                            color: ViewConstants.myLightBlue
                                                .withOpacity(0.4),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Dr. " +
                                                      therapist.getFullName(),
                                                  style: GoogleFonts.lato(
                                                      fontSize: 15,
                                                      color:
                                                          ViewConstants.myBlack,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 5.0),
                                                  child: Text(
                                                    "Family and Marriage Therapist",
                                                    style: GoogleFonts.lato(
                                                        fontSize: 12,
                                                        color: ViewConstants
                                                            .myPink,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 3.0),
                                                  child: Text(
                                                    "Appointment Price: " +
                                                        therapist
                                                            .appointmentPrice
                                                            .toString() +
                                                        " \$ per Hour",
                                                    style: GoogleFonts.lato(
                                                        fontSize: 12,
                                                        color: ViewConstants
                                                            .myBlack,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      FlatButton(
                                                        materialTapTargetSize:
                                                            MaterialTapTargetSize
                                                                .shrinkWrap,
                                                        onPressed: () {},
                                                        padding:
                                                            EdgeInsets.zero,
                                                        child: Text(
                                                          "CV",
                                                          style: GoogleFonts
                                                              .lato(),
                                                        ),
                                                        color: ViewConstants
                                                            .myGrey,
                                                        splashColor:
                                                            ViewConstants
                                                                .myLightBlue,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.only(
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          5)),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      5.0),
                                                          child: FlatButton(
                                                            materialTapTargetSize:
                                                                MaterialTapTargetSize
                                                                    .shrinkWrap,
                                                            padding:
                                                                EdgeInsets.zero,
                                                            onPressed: () {},
                                                            child: Text(
                                                              "Biography",
                                                              style: GoogleFonts
                                                                  .lato(),
                                                            ),
                                                            color: ViewConstants
                                                                .myPink,
                                                            splashColor:
                                                                ViewConstants
                                                                    .myBlack,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.only(
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              5)),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  )),
                            );
                          }
                        },
                      ),
                    );
                  },
                  childCount: model.getCurrentListLength(),
                ),
              ),
            ))
      ]),
    );
  }

  Future<bool> checkDismissibleAction(int index) async {
    return await showDialog<bool>(
        barrierColor: Colors.transparent,
        context: context,
        builder: (context) =>
            AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: ViewConstants.myWhite,
              title: Text("Are you sure you want to remove this request?"),
              titleTextStyle: TextStyle(color: ViewConstants.myGrey),
              insetPadding: EdgeInsets.all(20),
              actionsPadding: EdgeInsets.all(10),
              actions: <Widget>[
                FlatButton(
                  child: Text(
                    'Remove',
                    style: TextStyle(color: ViewConstants.myLightBlue),
                  ),
                  onPressed: () async {
                    bool isRemoved = await _pendingListViewModel
                        .removePendingRequestByIndex(index);
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
            ) ??
            false // In case the user dismisses the dialog by clicking away from it
        );
  }
}
