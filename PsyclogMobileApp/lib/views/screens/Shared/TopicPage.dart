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
import 'package:psyclog_app/view_models/shared/TopicListViewModel.dart';
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

    super.initState();
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
          child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment(3, 3), colors: [ViewConstants.myWhite, ViewConstants.myBlue]),
              ),
              padding: EdgeInsets.all(10),
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
              )),
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
              padding: EdgeInsets.all(10),
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
                  begin: Alignment.topLeft, end: Alignment(5, 5), colors: [ViewConstants.myWhite, ViewConstants.myBlue]),
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
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            Center(
                              child: Container(
                                padding: EdgeInsets.only(top: 10, bottom: 10),
                                width: MediaQuery.of(context).size.width / 3,
                                child: Image.asset(
                                  "assets/PSYCLOG_black_text.png",
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                            ),
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
                                  "Check the Most Popular Posts",
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
                                        return Container(
                                          width: containerWidth * 1.2,
                                          height: containerWidth,
                                          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                          child: Card(
                                            elevation: 5,
                                            child: Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end: Alignment(3, 3),
                                                      colors: [ViewConstants.myWhite.withOpacity(0.5), ViewConstants.myWhite]),
                                                ),
                                                padding: EdgeInsets.all(10),
                                                child: Column(
                                                  children: [
                                                    AutoSizeText(
                                                      indexedTopic.getTitle,
                                                      maxFontSize: 20,
                                                      minFontSize: 18,
                                                      style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                                                    ),
                                                    Expanded(
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                        child: AutoSizeText(
                                                          indexedTopic.getDescription,
                                                          overflow: TextOverflow.ellipsis,
                                                          maxLines: 5,
                                                          maxFontSize: 13,
                                                          minFontSize: 12,
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
                                                        ),
                                                      ],
                                                    )
                                                  ],
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
