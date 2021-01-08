import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:psyclog_app/service/ClientServerService.dart';
import 'package:psyclog_app/service/util/ServiceErrorHandling.dart';
import 'package:psyclog_app/src/models/Review.dart';
import 'package:psyclog_app/src/models/Therapist.dart';
import 'package:psyclog_app/view_models/client/ClientReviewListViewModel.dart';
import 'package:psyclog_app/views/util/DateParser.dart';
import 'package:psyclog_app/views/util/ViewConstants.dart';

class ClientRequestPage extends StatefulWidget {
  final Therapist therapist;
  final bool currentUserApplied;
  final String therapistArea;

  const ClientRequestPage({Key key, this.therapist, this.currentUserApplied, this.therapistArea}) : super(key: key);

  @override
  _ClientRequestPageState createState() => _ClientRequestPageState();
}

class _ClientRequestPageState extends State<ClientRequestPage> {
  TextEditingController _textEditingController;
  ClientServerService _clientServerService;
  ClientReviewListViewModel _clientReviewListViewModel;

  bool _applied;
  final ValueNotifier _reviewsVisible = new ValueNotifier(false);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _textEditingController = TextEditingController(text: "");
    _applied = widget.currentUserApplied;
    _clientReviewListViewModel = ClientReviewListViewModel(widget.therapist);
    initializeService();
  }

  initializeService() async {
    try {
      _clientServerService = await ClientServerService.getClientServerService();
    } catch (error) {
      print(error);
    }
  }

  Future<bool> createPatientRequest(BuildContext context) async {
    final String infoText = _textEditingController.text;

    if (infoText.isNotEmpty) {
      String response = await _clientServerService.createPatientRequest(widget.therapist.userID, infoText);

      if (response == ServiceErrorHandling.successfulStatusCode) {
        _applied = true;
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: ViewConstants.myWhite,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment(3, 3), colors: [ViewConstants.myWhite, ViewConstants.myBlue]),
        ),
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              centerTitle: true,
              title: Container(
                width: MediaQuery.of(context).size.width / 3,
                child: Image.asset(
                  "assets/PSYCLOG_black_text.png",
                  fit: BoxFit.fitWidth,
                ),
              ),
              iconTheme: IconThemeData(
                color: ViewConstants.myBlack,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
                child: CustomScrollView(
                  physics: ClampingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.20,
                        child: Row(
                          children: [
                            Hero(
                              tag: "${widget.therapist.userID}",
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.3,
                                height: MediaQuery.of(context).size.height * 0.2,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(width: 3, color: ViewConstants.myGreyBlue),
                                ),
                                child: ClipRRect(
                                  clipBehavior: Clip.hardEdge,
                                  borderRadius: BorderRadius.circular(7),
                                  child: Image.network(
                                    widget.therapist.profileImageURL,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(left: 5),
                                decoration: BoxDecoration(
                                  color: ViewConstants.myBlack,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(width: 3, color: ViewConstants.myGreyBlue),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    LayoutBuilder(builder: (context, constraints) {
                                      return SizedBox(
                                        width: constraints.maxWidth,
                                        child: Hero(
                                          tag: "${widget.therapist.userID}2",
                                          child: Material(
                                            shadowColor: Colors.transparent,
                                            color: Colors.transparent,
                                            child: AutoSizeText(
                                              widget.therapist.getFullName(),
                                              style: GoogleFonts.heebo(
                                                  color: ViewConstants.myWhite, fontWeight: FontWeight.bold),
                                              minFontSize: 25,
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5),
                                      child: LayoutBuilder(builder: (context, constraints) {
                                        return SizedBox(
                                          width: constraints.maxWidth * 0.95,
                                          child: Hero(
                                            tag: "${widget.therapist.userID}3",
                                            child: Material(
                                              shadowColor: Colors.transparent,
                                              color: Colors.transparent,
                                              child: AutoSizeText(
                                                widget.therapistArea,
                                                style: GoogleFonts.heebo(
                                                    color: ViewConstants.myGreyBlue, fontWeight: FontWeight.bold),
                                                maxLines: 1,
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5),
                                      child: LayoutBuilder(builder: (context, constraints) {
                                        return SizedBox(
                                          width: constraints.maxWidth * 0.80,
                                          child: Hero(
                                            tag: "${widget.therapist.userID}4",
                                            child: Material(
                                              shadowColor: Colors.transparent,
                                              color: Colors.transparent,
                                              child: AutoSizeText(
                                                Random().nextInt(20).toString() + " years experience",
                                                style: GoogleFonts.heebo(
                                                    color: ViewConstants.myYellow, fontWeight: FontWeight.bold),
                                                maxLines: 1,
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: !_applied
                            ? Builder(
                                builder: (BuildContext context) {
                                  return FlatButton(
                                    splashColor: ViewConstants.myYellow,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    color: ViewConstants.myBlack,
                                    padding: EdgeInsets.zero,
                                    onPressed: () async {
                                      bool isApplied = await showDialog(
                                          barrierColor: Colors.transparent,
                                          context: context,
                                          builder: (BuildContext dialogContext) {
                                            _textEditingController.text = "";

                                            return AlertDialog(
                                              backgroundColor: Colors.transparent,
                                              contentPadding: EdgeInsets.zero,
                                              actionsPadding: EdgeInsets.zero,
                                              buttonPadding: EdgeInsets.zero,
                                              titlePadding: EdgeInsets.zero,
                                              content: SizedBox(
                                                height: MediaQuery.of(context).size.height * 0.6,
                                                width: MediaQuery.of(context).size.width * 0.8,
                                                child: Container(
                                                  clipBehavior: Clip.hardEdge,
                                                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(10),
                                                      border: Border.all(color: ViewConstants.myWhite, width: 3),
                                                      gradient: LinearGradient(
                                                          begin: Alignment.topLeft,
                                                          end: Alignment(0, 0),
                                                          colors: [ViewConstants.myGreyBlue, ViewConstants.myBlack])),
                                                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                                    Padding(
                                                      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10),
                                                      child: AutoSizeText(
                                                        "Give some information about yourself. This might help " +
                                                            widget.therapist.getFullName() +
                                                            " to understand your situation.",
                                                        maxLines: 3,
                                                        style: GoogleFonts.heebo(fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          color: ViewConstants.myWhite,
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                        child: TextField(
                                                          decoration: InputDecoration(
                                                            contentPadding: EdgeInsets.all(10.0),
                                                            focusedBorder: InputBorder.none,
                                                            enabledBorder: InputBorder.none,
                                                            border: InputBorder.none,
                                                          ),
                                                          controller: _textEditingController,
                                                          style: GoogleFonts.heebo(color: ViewConstants.myBlack),
                                                          minLines: null,
                                                          maxLines: null,
                                                          expands: true,
                                                        ),
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                            child: FlatButton(
                                                          color: ViewConstants.myWhite,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(10)),
                                                          onPressed: () async {
                                                            bool isCreated = await createPatientRequest(context);
                                                            Navigator.pop(context, isCreated);
                                                          },
                                                          child: Text(
                                                            "Apply",
                                                            style: GoogleFonts.heebo(
                                                                color: ViewConstants.myBlack, fontWeight: FontWeight.bold),
                                                          ),
                                                        ))
                                                      ],
                                                    ),
                                                  ]),
                                                ),
                                              ),
                                              insetPadding: EdgeInsets.all(20),
                                            );
                                          });

                                      if (isApplied != null && isApplied) {
                                        final snackBar = SnackBar(
                                            duration: Duration(milliseconds: 1500),
                                            backgroundColor: ViewConstants.myBlack,
                                            content: Padding(
                                              padding: const EdgeInsets.all(5.0),
                                              child: Text(
                                                "Your application is sent.",
                                                style: TextStyle(color: ViewConstants.myWhite),
                                              ),
                                            ));
                                        Scaffold.of(context).showSnackBar(snackBar);
                                      } else if (isApplied != null && !isApplied) {
                                        final snackBar = SnackBar(
                                            duration: Duration(milliseconds: 1500),
                                            backgroundColor: ViewConstants.myBlack,
                                            content: Padding(
                                              padding: const EdgeInsets.all(5.0),
                                              child: Text(
                                                "Something went wrong. Please try again.",
                                                style: TextStyle(color: ViewConstants.myWhite),
                                              ),
                                            ));
                                        Scaffold.of(context).showSnackBar(snackBar);
                                      }
                                    },
                                    child: Text("Apply",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.heebo(color: ViewConstants.myWhite, fontWeight: FontWeight.bold)),
                                  );
                                },
                              )
                            : Builder(
                                builder: (BuildContext context) {
                                  return FlatButton(
                                    onPressed: () {
                                      final snackBar = SnackBar(
                                          duration: Duration(milliseconds: 1500),
                                          backgroundColor: ViewConstants.myBlack,
                                          content: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Text(
                                              "You already applied for this consultant. Please wait for his/her response.",
                                              style: TextStyle(color: ViewConstants.myWhite),
                                            ),
                                          ));
                                      Scaffold.of(context).showSnackBar(snackBar);
                                    },
                                    splashColor: ViewConstants.myYellow,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    color: ViewConstants.myYellow,
                                    padding: EdgeInsets.zero,
                                    child: Text("Pending",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.heebo(color: ViewConstants.myWhite, fontWeight: FontWeight.bold)),
                                  );
                                },
                              ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              margin: EdgeInsets.symmetric(vertical: 15),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: ViewConstants.myBlack,
                                border: Border.all(width: 3, color: ViewConstants.myGreyBlue),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  LayoutBuilder(builder: (context, constraints) {
                                    return SizedBox(
                                      width: constraints.maxWidth * 0.15,
                                      child: AutoSizeText(
                                        "About",
                                        style: TextStyle(color: ViewConstants.myWhite, fontWeight: FontWeight.w600),
                                        maxLines: 1,
                                        presetFontSizes: [26, 24, 22, 20, 18],
                                      ),
                                    );
                                  }),
                                  Divider(
                                    thickness: 1.5,
                                    color: ViewConstants.myGreyBlue,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    child: LayoutBuilder(builder: (context, constraints) {
                                      return SizedBox(
                                        width: constraints.maxWidth,
                                        child: AutoSizeText(
                                          "Phasellus non sem id magna faucibus pharetra nec eu orci. "
                                          "Nam eu rhoncus nibh. Praesent et risus porttitor, "
                                          "laoreet ex eget, vestibulum tellus. Sed non commodo lacus. "
                                          "Quisque cursus ultrices odio, eleifend consequat ante mattis id. "
                                          "Suspendisse consectetur sollicitudin tortor ac efficitur. "
                                          "Proin ac varius tortor, a scelerisque arcu. ",
                                          style: GoogleFonts.heebo(color: ViewConstants.myWhite),
                                          presetFontSizes: [18, 16, 14, 12, 10],
                                          maxLines: 6,
                                        ),
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 5),
                              child: LayoutBuilder(builder: (context, constraints) {
                                return Container(
                                  width: constraints.maxWidth,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 10),
                                          decoration: BoxDecoration(
                                            color: ViewConstants.myBlack,
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(width: 3, color: ViewConstants.myGreyBlue),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 15),
                                                child: SizedBox(
                                                  width: constraints.maxWidth * 0.20,
                                                  child: AutoSizeText(
                                                    "Patients",
                                                    style:
                                                        TextStyle(color: ViewConstants.myWhite, fontWeight: FontWeight.w600),
                                                    maxLines: 1,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 5),
                                                child: SizedBox(
                                                  width: constraints.maxWidth,
                                                  child: AutoSizeText(
                                                    (Random.secure().nextInt(50) + 50).toString(),
                                                    style: GoogleFonts.heebo(color: ViewConstants.myWhite),
                                                    maxLines: 1,
                                                    presetFontSizes: [20, 19, 17],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      VerticalDivider(
                                        color: Colors.transparent,
                                      ),
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 10),
                                          decoration: BoxDecoration(
                                            color: ViewConstants.myBlack,
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(width: 3, color: ViewConstants.myGreyBlue),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 15),
                                                child: SizedBox(
                                                  width: constraints.maxWidth * 0.20,
                                                  child: AutoSizeText(
                                                    "Sessions",
                                                    style:
                                                        TextStyle(color: ViewConstants.myWhite, fontWeight: FontWeight.w600),
                                                    maxLines: 1,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 5),
                                                child: SizedBox(
                                                  width: constraints.maxWidth,
                                                  child: AutoSizeText(
                                                    (Random.secure().nextInt(500) + 100).toString(),
                                                    style: GoogleFonts.heebo(color: ViewConstants.myWhite),
                                                    maxLines: 1,
                                                    presetFontSizes: [20, 19, 17],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                        child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      margin: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: ViewConstants.myBlack,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(width: 3, color: ViewConstants.myGreyBlue),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AutoSizeText(
                            "Reviews",
                            style: TextStyle(color: ViewConstants.myWhite, fontWeight: FontWeight.w600),
                            maxLines: 1,
                          ),
                          ValueListenableBuilder(
                              valueListenable: _reviewsVisible,
                              builder: (context, value, child) {
                                return IconButton(
                                  onPressed: () {
                                    _reviewsVisible.value = !_reviewsVisible.value;
                                  },
                                  icon: _reviewsVisible.value
                                      ? Icon(Icons.arrow_upward_rounded)
                                      : Icon(Icons.arrow_downward_rounded),
                                );
                              })
                        ],
                      ),
                    )),
                    ChangeNotifierProvider<ClientReviewListViewModel>(
                      create: (context) => _clientReviewListViewModel,
                      child: Consumer<ClientReviewListViewModel>(
                        builder: (context, model, child) => ValueListenableBuilder(
                            valueListenable: _reviewsVisible,
                            builder: (context, value, child) {
                              return SliverVisibility(
                                sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      Review _currentReview = model.getReviewByElement(index);

                                      return Container(
                                        decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment(1, 1),
                                                colors: [ViewConstants.myWhite, ViewConstants.myGreyBlue]),
                                            color: ViewConstants.myWhite,
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: ViewConstants.myBlack, width: 2)),
                                        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      AutoSizeText(
                                                        _currentReview.getTitle,
                                                        style: GoogleFonts.heebo(
                                                            color: ViewConstants.myBlack, fontWeight: FontWeight.bold),
                                                      ),
                                                      Spacer(),
                                                      _currentReview.getAuthorID == model.getCurrentUserID()
                                                          ? IconButton(
                                                              padding: EdgeInsets.zero,
                                                              icon: Icon(Icons.delete, color: ViewConstants.myBlack),
                                                              onPressed: () async {
                                                                bool isDeleted =
                                                                    await model.deleteReview(_currentReview.getReviewID);

                                                                if (isDeleted) {
                                                                  final snackBar = SnackBar(
                                                                      duration: Duration(milliseconds: 1500),
                                                                      backgroundColor: ViewConstants.myBlack,
                                                                      content: Padding(
                                                                        padding: const EdgeInsets.all(5.0),
                                                                        child: Text(
                                                                          "Your review is deleted.",
                                                                          style: TextStyle(color: ViewConstants.myWhite),
                                                                        ),
                                                                      ));
                                                                  Scaffold.of(context).showSnackBar(snackBar);
                                                                }
                                                              })
                                                          : Container(),
                                                    ],
                                                  ),
                                                  Divider(
                                                    color: ViewConstants.myBlack,
                                                    thickness: 1,
                                                  ),
                                                  AutoSizeText(
                                                    _currentReview.getContent,
                                                    style: GoogleFonts.heebo(color: ViewConstants.myBlack),
                                                  ),
                                                  Divider(
                                                    color: ViewConstants.myBlack,
                                                    thickness: 1,
                                                  ),
                                                  Row(
                                                    children: [
                                                      AutoSizeText(
                                                        DateParser.monthToString(_currentReview.getCreationDate),
                                                        style: GoogleFonts.heebo(
                                                            color: ViewConstants.myBlack, fontWeight: FontWeight.bold),
                                                      ),
                                                      Spacer(),
                                                      Row(
                                                        children: List<Widget>.generate(
                                                            _currentReview.getRating,
                                                            (index) => Icon(
                                                                  Icons.star,
                                                                  color: ViewConstants.myBlack,
                                                                )),
                                                      )
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                            Column(),
                                          ],
                                        ),
                                      );
                                    },
                                    childCount: model.getCurrentListLength(),
                                  ),
                                ),
                                visible: value,
                              );
                            }),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
