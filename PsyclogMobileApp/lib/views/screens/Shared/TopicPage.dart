import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:psyclog_app/service/ForumService.dart';
import 'package:psyclog_app/src/models/Author.dart';
import 'package:psyclog_app/src/models/Topic.dart';
import 'package:psyclog_app/src/models/User.dart';
import 'package:psyclog_app/view_models/shared/TopicListViewModel.dart';
import 'package:psyclog_app/views/util/DateParser.dart';
import 'package:psyclog_app/views/util/ViewConstants.dart';
import 'package:psyclog_app/views/widgets/AwareListItem.dart';

class TopicPage extends StatefulWidget {
  @override
  _TopicPageState createState() => _TopicPageState();
}

class _TopicPageState extends State<TopicPage> {
  ForumService _forumService;
  TopicListViewModel _topicListViewModel;

  @override
  void initState() {
    // TODO: implement initState
    _topicListViewModel = TopicListViewModel();
    _topicListViewModel.initializeModel();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> initializeService() async {
    _forumService = await ForumService.getForumService();
    await _topicListViewModel.initializeService(_forumService);
    return _forumService != null ? true : false;
  }

  Future<List<Widget>> getRecentTopics(double containerWidth) async {
    List<Widget> _cards;

    List<Topic> _topics = await _forumService.retrieveRecentTenTopics();

    _cards = List<Widget>.generate(_topics.length, (index) {
      Author indexedAuthor = _topics[index].getAuthor;

      String profileImage;

      if (indexedAuthor.getProfileImageURL != null)
        profileImage = indexedAuthor.getProfileImageURL + "/people/" + (index % 10).toString();

      return Container(
        width: containerWidth * 1.2,
        child: Card(
          elevation: 5,
          child: InkWell(
            splashColor: ViewConstants.myBlue,
            onTap: () {
              Navigator.pushNamed(context, ViewConstants.postListRoute, arguments: _topics[index].getID);
            },
            child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft, end: Alignment(3, 3), colors: [ViewConstants.myWhite, ViewConstants.myBlue]),
                ),
                child: FlatButton(
                  highlightColor: Colors.transparent,
                  splashColor: ViewConstants.myBlue.withOpacity(0.5),
                  padding: EdgeInsets.all(10),
                  onPressed: () {
                    Navigator.pushNamed(context, ViewConstants.postListRoute, arguments: _topics[index]);
                  },
                  child: Column(
                    children: [
                      AutoSizeText(
                        _topics[index].getTitle,
                        minFontSize: 13,
                        maxFontSize: 14,
                        style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: AutoSizeText(
                            _topics[index].getDescription,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 5,
                            maxFontSize: 12,
                            minFontSize: 11,
                            style: GoogleFonts.lato(),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 5),
                            child: profileImage != null
                                ? CircleAvatar(
                                    radius: 12,
                                    backgroundImage: Image.network(profileImage).image,
                                  )
                                : Icon(
                                    Icons.person,
                                    size: 18,
                                  ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: AutoSizeText(
                                indexedAuthor.getFullName(),
                                maxFontSize: 12,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                )),
          ),
        ),
      );
    });

    return _cards;
  }

  Future<List<Widget>> getPopularTopics(double containerWidth) async {
    List<Widget> _cards;

    List<Topic> _topics = await _forumService.retrievePopularTenTopics();

    _cards = List<Widget>.generate(_topics.length, (index) {
      Author indexedAuthor = _topics[index].getAuthor;

      String profileImage;

      if (indexedAuthor.getProfileImageURL != null)
        profileImage = indexedAuthor.getProfileImageURL + "/people/" + (index % 10).toString();

      return Container(
        width: containerWidth * 1.2,
        child: Card(
          elevation: 5,
          child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment(3, 3), colors: [ViewConstants.myWhite, ViewConstants.myPink]),
              ),
              child: FlatButton(
                highlightColor: Colors.transparent,
                splashColor: ViewConstants.myPink.withOpacity(0.5),
                padding: EdgeInsets.all(10),
                onPressed: () {
                  Navigator.pushNamed(context, ViewConstants.postListRoute, arguments: _topics[index]);
                },
                child: Column(
                  children: [
                    AutoSizeText(
                      _topics[index].getTitle,
                      minFontSize: 13,
                      maxFontSize: 14,
                      style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: AutoSizeText(
                          _topics[index].getDescription,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 5,
                          maxFontSize: 12,
                          minFontSize: 11,
                          style: GoogleFonts.lato(),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 5),
                          child: profileImage != null
                              ? CircleAvatar(
                                  radius: 12,
                                  backgroundImage: Image.network(profileImage).image,
                                )
                              : Icon(
                                  Icons.person,
                                  size: 18,
                                ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: AutoSizeText(
                              indexedAuthor.getFullName(),
                              maxFontSize: 12,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              )),
        ),
      );
    });

    return _cards;
  }

  @override
  Widget build(BuildContext context) {
    double containerWidth = MediaQuery.of(context).size.width / 3 + 20;

    return Stack(children: [
      BackdropFilter(
          filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment(5, 5),
                  colors: [ViewConstants.myWhite, ViewConstants.myLightBlueTransparent]),
            ),
          )),
      SafeArea(
        child: Theme(
            data: ThemeData(
              accentColor: ViewConstants.myBlack,
            ),
            child: FutureBuilder(
              future: initializeService(),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData) {
                  return CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        expandedHeight: MediaQuery.of(context).size.height * 0.25,
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
                                Center(
                                  child: Container(
                                    padding: EdgeInsets.only(top: 10, bottom: 20),
                                    width: MediaQuery.of(context).size.width / 3,
                                    child: Image.asset(
                                      "assets/PSYCLOG_black_text.png",
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: 20,
                                      ),
                                      child: Text("Feed",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontSize: 30, color: ViewConstants.myBlack, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                                Flexible(
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height * 0.075,
                                    margin: EdgeInsets.only(top: 20, right: 20, left: 20),
                                    child: FlatButton(
                                      color: ViewConstants.myGrey,
                                      splashColor: ViewConstants.myGreyBlue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Create a Topic",
                                            style: TextStyle(
                                                color: ViewConstants.myWhite,
                                                fontWeight: FontWeight.w700,
                                                fontFamily: "OpenSans",
                                                fontSize: 13),
                                          ),
                                          Icon(Icons.arrow_forward, color: ViewConstants.myWhite)
                                        ],
                                      ),
                                      onPressed: () async {
                                        bool isCreated =
                                            await Navigator.pushNamed(context, ViewConstants.topicCreateRoute) as bool;
                                        if (isCreated != null && isCreated) {
                                          final snackBar = SnackBar(
                                              content: Text('Topic is created successfully.',
                                                  style: GoogleFonts.lato(color: ViewConstants.myGrey)));

                                          Scaffold.of(context).showSnackBar(snackBar);
                                        }
                                      },
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
                        child: Column(
                          children: [
                            Padding(
                                padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                                child: AutoSizeText(
                                  "Find the Information You Need",
                                  maxLines: 1,
                                  presetFontSizes: [22, 26, 28],
                                  wrapWords: true,
                                  softWrap: true,
                                  stepGranularity: 2,
                                  textAlign: TextAlign.left,
                                  style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: ViewConstants.myBlack),
                                )),
                            Padding(
                                padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                                child: AutoSizeText(
                                  "by looking at the topics from our users.",
                                  maxLines: 1,
                                  presetFontSizes: [14, 16, 18],
                                  textAlign: TextAlign.left,
                                  style: GoogleFonts.lato(color: ViewConstants.myBlack),
                                )),
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: 10,
                                left: 20,
                              ),
                              child: Text("Recent Topics",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(fontSize: 20, color: ViewConstants.myBlack, fontWeight: FontWeight.bold)),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 20, right: 20),
                              height: containerWidth,
                              child: Theme(
                                data: ThemeData(
                                  accentColor: ViewConstants.myWhite,
                                ),
                                child: FutureBuilder(
                                  future: getRecentTopics(containerWidth),
                                  builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                                    if (snapshot.hasData) {
                                      return ListView(
                                        scrollDirection: Axis.horizontal,
                                        children: snapshot.data as List<Widget>,
                                      );
                                    } else {
                                      return Container();
                                    }
                                  },
                                ),
                              ),
                            ),
                            Padding(
                                padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                                child: AutoSizeText(
                                  "Check the Most Popular Topics",
                                  maxLines: 1,
                                  presetFontSizes: [22, 26, 28],
                                  wrapWords: true,
                                  softWrap: true,
                                  stepGranularity: 2,
                                  textAlign: TextAlign.left,
                                  style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: ViewConstants.myBlack),
                                )),
                            Padding(
                                padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                                child: AutoSizeText(
                                  "and solve your problems!",
                                  maxLines: 1,
                                  presetFontSizes: [14, 16, 18],
                                  textAlign: TextAlign.left,
                                  style: GoogleFonts.lato(color: ViewConstants.myBlack),
                                )),
                            Padding(
                              padding: EdgeInsets.only(
                                top: 10,
                                bottom: 10,
                                left: 20,
                              ),
                              child: Text("Popular Topics",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(fontSize: 20, color: ViewConstants.myBlack, fontWeight: FontWeight.bold)),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 20, right: 20),
                              height: containerWidth,
                              child: Theme(
                                data: ThemeData(
                                  accentColor: ViewConstants.myWhite,
                                ),
                                child: FutureBuilder(
                                  future: getPopularTopics(containerWidth),
                                  builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                                    if (snapshot.hasData) {
                                      return ListView(
                                        scrollDirection: Axis.horizontal,
                                        children: snapshot.data as List<Widget>,
                                      );
                                    } else {
                                      return Container();
                                    }
                                  },
                                ),
                              ),
                            ),
                            Padding(
                                padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                                child: AutoSizeText(
                                  "All the Topics We Have",
                                  maxLines: 1,
                                  presetFontSizes: [22, 26, 28],
                                  wrapWords: true,
                                  softWrap: true,
                                  stepGranularity: 2,
                                  textAlign: TextAlign.left,
                                  style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: ViewConstants.myBlack),
                                )),
                            Padding(
                                padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                                child: AutoSizeText(
                                  "collected just for you.",
                                  maxLines: 1,
                                  presetFontSizes: [14, 16, 18],
                                  textAlign: TextAlign.left,
                                  style: GoogleFonts.lato(color: ViewConstants.myBlack),
                                )),
                          ],
                        ),
                      ),
                      ChangeNotifierProvider<TopicListViewModel>(
                          create: (context) => _topicListViewModel,
                          child: Consumer<TopicListViewModel>(
                              builder: (context, model, child) => SliverList(
                                      delegate: SliverChildBuilderDelegate((context, index) {
                                    Topic indexedTopic = model.getTopicByElement(index);

                                    Author indexedAuthor = indexedTopic.getAuthor;

                                    String profileImage;

                                    if (indexedAuthor.getProfileImageURL != null)
                                      profileImage = indexedAuthor.getProfileImageURL + "/people/" + (index % 10).toString();

                                    return AwareListItem(itemCreated: () {
                                      print("List Item:" + index.toString());
                                      SchedulerBinding.instance.addPostFrameCallback((duration) {
                                        model.handleItemCreated(index);
                                      });
                                    }, child: Builder(
                                      builder: (BuildContext context) {
                                        return Card(
                                          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                          elevation: 2,
                                          clipBehavior: Clip.hardEdge,
                                          child: Container(
                                            width: containerWidth * 1.2,
                                            height: containerWidth * 1.2,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment(8, 8),
                                                  colors: [ViewConstants.myWhite, ViewConstants.myYellow]),
                                            ),
                                            child: Container(
                                                padding: EdgeInsets.symmetric(horizontal: 10),
                                                child: FlatButton(
                                                  highlightColor: Colors.transparent,
                                                  splashColor: ViewConstants.myLightBlueTransparent,
                                                  padding: EdgeInsets.all(10),
                                                  onPressed: () {
                                                    Navigator.pushNamed(context, ViewConstants.postListRoute,
                                                        arguments: indexedTopic);
                                                  },
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Padding(
                                                            padding: EdgeInsets.only(right: 5),
                                                            child: profileImage != null
                                                                ? CircleAvatar(
                                                                    radius: 12,
                                                                    backgroundImage: Image.network(profileImage).image,
                                                                  )
                                                                : Icon(
                                                                    Icons.person,
                                                                    size: 18,
                                                                  ),
                                                          ),
                                                          Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Padding(
                                                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                                                child: AutoSizeText(
                                                                  indexedAuthor.getFullName(),
                                                                  overflow: TextOverflow.ellipsis,
                                                                  style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                                                child: Row(
                                                                  children: [
                                                                    AutoSizeText(
                                                                      "Created at ",
                                                                      style: GoogleFonts.heebo(color: ViewConstants.myBlack),
                                                                    ),
                                                                    AutoSizeText(
                                                                      DateParser.monthToString(DateParser.jsonToDateTime(
                                                                          indexedTopic.getCreatedAt)),
                                                                      style: GoogleFonts.heebo(
                                                                          color: ViewConstants.myBlack,
                                                                          fontWeight: FontWeight.bold),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                              child: AutoSizeText(
                                                                indexedTopic.getTitle,
                                                                maxFontSize: 18,
                                                                minFontSize: 16,
                                                                style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                                                              ),
                                                            ),
                                                            indexedAuthor.getAuthorId ==
                                                                    (_forumService.currentUser as User).userID
                                                                ? IconButton(
                                                                    icon: Icon(Icons.delete),
                                                                    onPressed: () async {
                                                                      bool isDeleted =
                                                                          await model.deleteTopic(indexedTopic.getID);

                                                                      if (isDeleted) {
                                                                        final snackBar = SnackBar(
                                                                            content: Text('Topic is deleted successfully.',
                                                                                style: GoogleFonts.lato(
                                                                                    color: ViewConstants.myGrey)));

                                                                        Scaffold.of(context).showSnackBar(snackBar);
                                                                      } else {
                                                                        final snackBar = SnackBar(
                                                                            content: Text('Something went wrong. Try again.',
                                                                                style: GoogleFonts.lato(
                                                                                    color: ViewConstants.myGrey)));

                                                                        Scaffold.of(context).showSnackBar(snackBar);
                                                                      }
                                                                    })
                                                                : Container(),
                                                          ],
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 15),
                                                          child: AutoSizeText(
                                                            indexedTopic.getDescription,
                                                            overflow: TextOverflow.ellipsis,
                                                            maxLines: 4,
                                                            maxFontSize: 13,
                                                            minFontSize: 12,
                                                            style: GoogleFonts.lato(),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )),
                                          ),
                                        );
                                      },
                                    ));
                                  }, childCount: model.getCurrentListLength()))))
                    ],
                  );
                } else {
                  return CircularProgressIndicator();
                }
              },
            )),
      )
    ]);
  }
}
