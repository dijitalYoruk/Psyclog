import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:psyclog_app/view_models/client/ApprovedTherapistListViewModel.dart';
import 'package:psyclog_app/views/util/ViewConstants.dart';

class ClientSessionPage extends StatefulWidget {
  @override
  _ClientSessionPageState createState() => _ClientSessionPageState();
}

class _ClientSessionPageState extends State<ClientSessionPage> {
  ApprovedTherapistListViewModel _approvedTherapistListViewModel;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _approvedTherapistListViewModel = ApprovedTherapistListViewModel();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
        filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment(10, 10),
                colors: [ViewConstants.myWhite, ViewConstants.myLightBlue]),
          ),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: MediaQuery.of(context).size.height * 0.18,
                pinned: false,
                stretch: true,
                automaticallyImplyLeading: false,
                backgroundColor: Colors.transparent,
                iconTheme: IconThemeData(
                  color: ViewConstants.myBlack,
                ),
                flexibleSpace: SafeArea(
                  child: FlexibleSpaceBar(
                    background: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                left: 20,
                              ),
                              child: Text("Consultants",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontSize: 30,
                                      color: ViewConstants.myBlack,
                                      fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                left: 20,
                                right: 20,
                              ),
                              child: CircleAvatar(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(context,
                                        ViewConstants.clientProfileRoute);
                                  },
                                ),
                                maxRadius:
                                    MediaQuery.of(context).size.height * 0.025,
                                backgroundImage: NetworkImage(
                                    "https://instagram.fayt2-1.fna.fbcdn.net/v/t51.2885-19/s150x150/117315051_369085030753678_5319131320934149030_n.jpg?_nc_ht=instagram.fayt2-1.fna.fbcdn.net&_nc_ohc=tRNmhh4X0KcAX_7h_fq&oh=0cb73887d5990eb9ca7a32d9689561d9&oe=5F932D22"),
                              ),
                            ),
                          ],
                        ),
                        Flexible(
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height / 12,
                            margin:
                                EdgeInsets.only(top: 20, right: 20, left: 20),
                            child: FlatButton(
                              color:
                                  ViewConstants.myLightBlue.withOpacity(0.75),
                              splashColor: ViewConstants.myPink,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Pending Requests",
                                    style: TextStyle(
                                        color: ViewConstants.myWhite,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: "OpenSans",
                                        fontSize: 13),
                                  ),
                                  Icon(Icons.arrow_forward)
                                ],
                              ),
                              onPressed: () {},
                            ),
                          ),
                        ),
                      ],
                    ),
                    stretchModes: [
                      StretchMode.zoomBackground,
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Card(
                  elevation: 4,
                  shadowColor: ViewConstants.myLightBlue,
                  color: ViewConstants.myWhite,
                  clipBehavior: Clip.antiAlias,
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Container(
                    padding: EdgeInsets.all(18),
                    height: MediaQuery.of(context).size.height / 8,
                    decoration: BoxDecoration(
                        color: ViewConstants.myLightBlue.withOpacity(0.4)),
                    child: Center(
                      child: AutoSizeText(
                        "From the list below, you can find the registered therapists for fast and efficient consultation.",
                        maxLines: 2,
                        minFontSize: 8,
                        maxFontSize: 20,
                        stepGranularity: 1,
                        style: TextStyle(
                            color: ViewConstants.myGrey,
                            fontFamily: "OpenSans"),
                      ),
                    ),
                  ),
                ),
              ),
              ChangeNotifierProvider<ApprovedTherapistListViewModel>(
                create: (context) => _approvedTherapistListViewModel,
                child: Consumer<ApprovedTherapistListViewModel>(
                  builder: (context, model, child) => SliverGrid(
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: MediaQuery.of(context).size.width / 2,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        return Card(
                          elevation: 2,
                          shadowColor: ViewConstants.myLightBlue,
                          color: ViewConstants.myWhite,
                          margin: EdgeInsets.only(
                              left: index.isEven ? 20 : 10,
                              right: index.isEven ? 10 : 20,
                              bottom: 20),
                        );
                      },
                      childCount: model.getTherapistListLength(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}