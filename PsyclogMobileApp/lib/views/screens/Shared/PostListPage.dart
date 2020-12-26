import 'dart:ffi';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:psyclog_app/src/models/Author.dart';
import 'package:psyclog_app/src/models/Post.dart';
import 'package:psyclog_app/src/models/Topic.dart';
import 'package:psyclog_app/view_models/shared/PostListViewModel.dart';
import 'package:psyclog_app/views/util/DateParser.dart';
import 'package:psyclog_app/views/util/ViewConstants.dart';
import 'package:psyclog_app/views/widgets/AwareListItem.dart';

class PostListPage extends StatefulWidget {
  final Topic _currentTopic;

  const PostListPage(this._currentTopic, {Key key}) : super(key: key);

  @override
  _PostListPageState createState() => _PostListPageState();
}

class _PostListPageState extends State<PostListPage> {
  PostListViewModel _postListViewModel;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _postListViewModel = PostListViewModel(widget._currentTopic);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Builder(
        builder: (BuildContext builderContext) {
          return FloatingActionButton(
            tooltip: "Add Post",
            child: Icon(Icons.add),
            onPressed: () async {
              bool isCreated =
                  await Navigator.pushNamed(context, ViewConstants.postCreateRoute, arguments: widget._currentTopic) as bool;
              if (isCreated != null && isCreated) {
                final snackBar = SnackBar(
                    content: Text('Post is created successfully.', style: GoogleFonts.lato(color: ViewConstants.myGrey)));

                Scaffold.of(builderContext).showSnackBar(snackBar);

                _postListViewModel.updatePosts();
              }
            },
          );
        },
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment(5, 5), colors: [ViewConstants.myWhite, ViewConstants.myWhite]),
        ),
        child: Center(
          child: SafeArea(
            child: CustomScrollView(
              physics: ClampingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  pinned: true,
                  stretch: true,
                  backgroundColor: ViewConstants.myWhite,
                  iconTheme: IconThemeData(
                    color: ViewConstants.myBlack,
                  ),
                  flexibleSpace: Center(
                    child: Container(
                      padding: EdgeInsets.only(top: 10, bottom: 20),
                      width: MediaQuery.of(context).size.width / 3,
                      child: Image.asset(
                        "assets/PSYCLOG_black_text.png",
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                      child: AutoSizeText(
                        widget._currentTopic.getTitle,
                        style: GoogleFonts.heebo(color: ViewConstants.myBlack, fontWeight: FontWeight.bold),
                        minFontSize: 22,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                      child: AutoSizeText(
                        widget._currentTopic.getDescription,
                        style: GoogleFonts.heebo(color: ViewConstants.myBlack),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    child: Divider(
                      color: ViewConstants.myBlack,
                    ),
                  ),
                ),
                ChangeNotifierProvider<PostListViewModel>(
                    create: (context) => _postListViewModel,
                    child: Consumer<PostListViewModel>(
                        builder: (context, model, child) => SliverList(
                                delegate: SliverChildBuilderDelegate((context, index) {
                              return AwareListItem(
                                itemCreated: () {
                                  print("List Item:" + index.toString());
                                  SchedulerBinding.instance.addPostFrameCallback((duration) {
                                    model.handleItemCreated(index);
                                  });
                                },
                                child: Builder(
                                  builder: (BuildContext context) {
                                    if (index % 2 == 0) {
                                      Post indexedPost = model.getPostByElement(index ~/ 2);

                                      return Card(
                                        elevation: 2,
                                        clipBehavior: Clip.hardEdge,
                                        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                        child: Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment(8, 8),
                                                  colors: [ViewConstants.myWhite, ViewConstants.myBlue]),
                                            ),
                                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                                            child: Column(
                                              children: [
                                                !indexedPost.isAuthorAnonymous
                                                    ? Row(
                                                        children: [
                                                          Padding(
                                                            padding: const EdgeInsets.symmetric(horizontal: 5),
                                                            child: (indexedPost.getAuthor as Author).getProfileImageURL != null
                                                                ? CircleAvatar(
                                                                    backgroundImage: Image.network(
                                                                            (indexedPost.getAuthor as Author)
                                                                                    .getProfileImageURL +
                                                                                "/people/" +
                                                                                (index % 10).toString())
                                                                        .image,
                                                                  )
                                                                : Container(
                                                                    padding: EdgeInsets.all(8),
                                                                    decoration: BoxDecoration(
                                                                      shape: BoxShape.circle,
                                                                      color: ViewConstants.myBlack,
                                                                    ),
                                                                    child: Icon(
                                                                      Icons.person,
                                                                      color: ViewConstants.myWhite,
                                                                    ),
                                                                  ),
                                                          ),
                                                          Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Padding(
                                                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                                                child: AutoSizeText(
                                                                  (indexedPost.getAuthor as Author).getFullName(),
                                                                  style: GoogleFonts.heebo(
                                                                      color: ViewConstants.myBlack,
                                                                      fontWeight: FontWeight.bold),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                                                child: Row(
                                                                  children: [
                                                                    AutoSizeText(
                                                                      "Answered on ",
                                                                      style: GoogleFonts.heebo(color: ViewConstants.myBlack),
                                                                    ),
                                                                    AutoSizeText(
                                                                      DateParser.monthToString(
                                                                          DateParser.jsonToDateTime(indexedPost.getCreatedAt)),
                                                                      style: GoogleFonts.heebo(
                                                                          color: ViewConstants.myBlack,
                                                                          fontWeight: FontWeight.bold),
                                                                    ),
                                                                  ],
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                          Spacer(),
                                                          (indexedPost.getAuthor as Author).getAuthorId ==
                                                                  model.getCurrentUserID()
                                                              ? IconButton(
                                                                  icon: Icon(
                                                                    Icons.delete,
                                                                    color: ViewConstants.myBlack,
                                                                  ),
                                                                  onPressed: () async {
                                                                    bool isDeleted =
                                                                        await model.deletePost(indexedPost.getPostID);

                                                                    if (isDeleted) {
                                                                      final snackBar = SnackBar(
                                                                          content: Text('Post is deleted successfully.',
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
                                                      )
                                                    : Row(
                                                        children: [
                                                          Padding(
                                                            padding: const EdgeInsets.symmetric(horizontal: 5),
                                                            child: Container(
                                                              padding: EdgeInsets.all(8),
                                                              decoration: BoxDecoration(
                                                                shape: BoxShape.circle,
                                                                color: ViewConstants.myBlack,
                                                              ),
                                                              child: Icon(
                                                                Icons.person,
                                                                color: ViewConstants.myWhite,
                                                              ),
                                                            ),
                                                          ),
                                                          Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Padding(
                                                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                                                child: AutoSizeText(
                                                                  "Anonymous User",
                                                                  style: GoogleFonts.heebo(
                                                                      color: ViewConstants.myBlack,
                                                                      fontWeight: FontWeight.bold),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                                                child: Row(
                                                                  children: [
                                                                    AutoSizeText(
                                                                      "Answered on ",
                                                                      style: GoogleFonts.heebo(color: ViewConstants.myBlack),
                                                                    ),
                                                                    AutoSizeText(
                                                                      DateParser.monthToString(
                                                                          DateParser.jsonToDateTime(indexedPost.getCreatedAt)),
                                                                      style: GoogleFonts.heebo(
                                                                          color: ViewConstants.myBlack,
                                                                          fontWeight: FontWeight.bold),
                                                                    ),
                                                                  ],
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                          Spacer(),
                                                          (indexedPost.getAuthor as Author).getAuthorId ==
                                                                  model.getCurrentUserID()
                                                              ? IconButton(
                                                                  icon: Icon(
                                                                    Icons.delete,
                                                                    color: ViewConstants.myBlack,
                                                                  ),
                                                                  onPressed: () async {
                                                                    bool isDeleted =
                                                                        await model.deletePost(indexedPost.getPostID);

                                                                    if (isDeleted) {
                                                                      final snackBar = SnackBar(
                                                                          content: Text('Post is deleted successfully.',
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
                                                Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: AutoSizeText(indexedPost.getContent,
                                                      style: GoogleFonts.heebo(color: ViewConstants.myBlack)),
                                                ),
                                                (indexedPost.getImageURLs as List<String>).isNotEmpty
                                                    ? SizedBox(
                                                        height: MediaQuery.of(context).size.height / 4,
                                                        child: Container(
                                                          clipBehavior: Clip.antiAlias,
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(10),
                                                          ),
                                                          margin: EdgeInsets.symmetric(horizontal: 10),
                                                          child: ListView.builder(
                                                              physics: BouncingScrollPhysics(),
                                                              itemCount: (indexedPost.getImageURLs as List<String>).length,
                                                              scrollDirection: Axis.horizontal,
                                                              shrinkWrap: true,
                                                              itemBuilder: (BuildContext context, int index) {
                                                                return Padding(
                                                                  padding: const EdgeInsets.symmetric(horizontal: 5),
                                                                  child: Image.network(
                                                                      (indexedPost.getImageURLs as List<String>)[index] +
                                                                          "?${indexedPost.getPostID}$index"),
                                                                );
                                                              }),
                                                        ),
                                                      )
                                                    : Container(),
                                              ],
                                            )),
                                      );
                                    } else {
                                      return Divider(
                                        color: ViewConstants.myGrey.withOpacity(0.25),
                                      );
                                    }
                                  },
                                ),
                              );
                            }, childCount: 2 * model.getCurrentListLength() - 1)))),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height / 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
