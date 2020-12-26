import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:psyclog_app/src/models/Note.dart';
import 'package:psyclog_app/src/models/Patient.dart';
import 'package:psyclog_app/view_models/therapist/TherapistNoteListViewModel.dart';
import 'package:psyclog_app/views/util/DateParser.dart';
import 'package:psyclog_app/views/util/ViewConstants.dart';

class TherapistNotePage extends StatefulWidget {
  final Patient _currentPatient;

  const TherapistNotePage(this._currentPatient, {Key key}) : super(key: key);

  @override
  _TherapistNotePageState createState() => _TherapistNotePageState();
}

class _TherapistNotePageState extends State<TherapistNotePage> {
  TextEditingController _textEditingController;

  TherapistNoteListViewModel _therapistNoteListViewModel;

  List<Color> _backgroundColors = [
    ViewConstants.myYellow,
    ViewConstants.myBlue,
    ViewConstants.myGreen,
    ViewConstants.myPink,
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("Current Patient ID: " + widget._currentPatient.userID);
    _therapistNoteListViewModel = TherapistNoteListViewModel(widget._currentPatient);
    _textEditingController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ViewConstants.myWhite,
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: CustomScrollView(physics: const BouncingScrollPhysics(), slivers: [
                SliverAppBar(
                  expandedHeight: MediaQuery.of(context).size.height * 0.27,
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: ViewConstants.myBlack,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                          top: 20,
                                          left: 20,
                                        ),
                                        child: AutoSizeText(widget._currentPatient.getFullName(),
                                            textAlign: TextAlign.left,
                                            maxLines: 1,
                                            minFontSize: 23,
                                            style: TextStyle(color: ViewConstants.myWhite, fontWeight: FontWeight.bold)),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          top: 3,
                                          left: 20,
                                        ),
                                        child: AutoSizeText("@" + widget._currentPatient.userUsername,
                                            textAlign: TextAlign.left,
                                            maxLines: 1,
                                            style: TextStyle(color: ViewConstants.myWhite)),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          top: 20,
                                          left: 20,
                                        ),
                                        child: AutoSizeText("Contact",
                                            textAlign: TextAlign.left,
                                            minFontSize: 18,
                                            style: TextStyle(color: ViewConstants.myWhite, fontWeight: FontWeight.bold)),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          top: 3,
                                          left: 20,
                                          bottom: 20,
                                        ),
                                        child: AutoSizeText(widget._currentPatient.userEmail,
                                            textAlign: TextAlign.left,
                                            maxLines: 1,
                                            style: TextStyle(color: ViewConstants.myWhite)),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 20,
                                    horizontal: 20,
                                  ),
                                  child: Container(
                                      clipBehavior: Clip.hardEdge,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Image.network(widget._currentPatient.profileImageURL, fit: BoxFit.fill)),
                                )
                              ],
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
                    shadowColor: ViewConstants.myBlue,
                    color: ViewConstants.myWhite,
                    clipBehavior: Clip.antiAlias,
                    margin: EdgeInsets.only(bottom: 15),
                    child: Container(
                      padding: EdgeInsets.all(15),
                      height: MediaQuery.of(context).size.height / 8,
                      decoration: BoxDecoration(color: ViewConstants.myBlack),
                      child: Center(
                        child: AutoSizeText(
                          "From the list below, you can find the notes you added before. If you want to add more, click + button on the right side.",
                          maxLines: 2,
                          minFontSize: 8,
                          maxFontSize: 20,
                          stepGranularity: 1,
                          style: GoogleFonts.lato(fontSize: 13, color: ViewConstants.myWhite),
                        ),
                      ),
                    ),
                  ),
                ),
                ChangeNotifierProvider<TherapistNoteListViewModel>(
                  create: (context) => _therapistNoteListViewModel,
                  child: Consumer<TherapistNoteListViewModel>(
                    builder: (context, model, child) => SliverStaggeredGrid(
                        delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
                          Color _backgroundColor = _backgroundColors[index % 4];

                          Note _currentNote = model.getNoteByIndex(index);

                          return Card(
                            margin: EdgeInsets.only(bottom: 10, top: 10),
                            shadowColor: Colors.transparent,
                            clipBehavior: Clip.hardEdge,
                            child: Container(
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment(1, 1),
                                      colors: [ViewConstants.myGrey.withOpacity(0.2), _backgroundColor])),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 5),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(top: 8.0),
                                            child: AutoSizeText(
                                              DateParser.monthToString(_currentNote.getCreatedAt),
                                              minFontSize: 16,
                                              style: GoogleFonts.heebo(
                                                color: ViewConstants.myWhite,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                              child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 5),
                                            child: AutoSizeText(
                                              _currentNote.getContent.toString(),
                                              style: GoogleFonts.heebo(
                                                  color: ViewConstants.myWhite, fontWeight: FontWeight.w600),
                                            ),
                                          )),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: ViewConstants.myBlack.withOpacity(0.75),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: FlatButton(
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            onPressed: () async {
                                              await showDialog(
                                                  barrierColor: Colors.transparent,
                                                  context: context,
                                                  builder: (BuildContext dialogContext) {
                                                    _textEditingController.text = _currentNote.getContent;

                                                    return AlertDialog(
                                                      backgroundColor: Colors.transparent,
                                                      content: SizedBox(
                                                        height: MediaQuery.of(context).size.height * 0.6,
                                                        width: MediaQuery.of(context).size.width * 0.75,
                                                        child: Container(
                                                          clipBehavior: Clip.hardEdge,
                                                          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                                                          decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(10),
                                                              gradient: LinearGradient(
                                                                  begin: Alignment.topLeft,
                                                                  end: Alignment(1, 1),
                                                                  colors: [ViewConstants.myGrey, _backgroundColor])),
                                                          child:
                                                              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10),
                                                              child: AutoSizeText(
                                                                "After changing your notes, do not forget to update. Otherwise it will not be saved",
                                                                maxLines: 2,
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
                                                                    color: ViewConstants.myBlack.withOpacity(0.5),
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(10)),
                                                                    onPressed: () async {
                                                                      bool isUpdated = await model.updateNoteByIndex(
                                                                          index, _textEditingController.text);
                                                                      Navigator.pop(context, isUpdated);
                                                                    },
                                                                    child: Text(
                                                                      "Update",
                                                                      style: GoogleFonts.heebo(
                                                                          color: ViewConstants.myWhite,
                                                                          fontWeight: FontWeight.bold),
                                                                    ),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ]),
                                                        ),
                                                      ),
                                                      insetPadding: EdgeInsets.all(20),
                                                    );
                                                  });
                                            },
                                            child: Text("Update",
                                                style: GoogleFonts.heebo(
                                                    fontWeight: FontWeight.bold, color: ViewConstants.myWhite)),
                                            padding: EdgeInsets.all(15),
                                          ),
                                        ),
                                        Expanded(
                                          child: FlatButton(
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            onPressed: () async {
                                              await showDialog(
                                                  barrierColor: Colors.transparent,
                                                  context: context,
                                                  builder: (BuildContext dialogContext) {
                                                    return AlertDialog(
                                                      backgroundColor: Colors.transparent,
                                                      content: SizedBox(
                                                        height: MediaQuery.of(context).size.height / 5,
                                                        width: MediaQuery.of(context).size.width * 0.75,
                                                        child: Container(
                                                          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                                                          decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(10),
                                                              gradient: LinearGradient(
                                                                  begin: Alignment.topLeft,
                                                                  end: Alignment(1, 1),
                                                                  colors: [ViewConstants.myGrey, _backgroundColor])),
                                                          child:
                                                              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                                            Expanded(
                                                              child: Center(
                                                                child: AutoSizeText(
                                                                  "Do you want to delete this note?",
                                                                  maxLines: 1,
                                                                  style: GoogleFonts.heebo(color: ViewConstants.myWhite, fontWeight: FontWeight.bold),
                                                                ),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.only(top: 12.0),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                children: [
                                                                  FlatButton(
                                                                      shape: RoundedRectangleBorder(
                                                                          side: BorderSide(
                                                                              color: ViewConstants.myWhite.withOpacity(0.5),
                                                                              width: 2),
                                                                          borderRadius: BorderRadius.circular(10)),
                                                                      onPressed: () async {
                                                                        bool isDeleted =
                                                                            await model.deleteNoteByIndex(index);

                                                                        if (isDeleted) {
                                                                          Navigator.pop(context);

                                                                          final snackBar = SnackBar(
                                                                              content: Text('Note is deleted.',
                                                                                  style: GoogleFonts.lato(
                                                                                      color: ViewConstants.myGrey)));

                                                                          Scaffold.of(context).showSnackBar(snackBar);
                                                                        }
                                                                      },
                                                                      child: Text("Delete",
                                                                          style: GoogleFonts.heebo(
                                                                              color: ViewConstants.myWhite,
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 14))),
                                                                  FlatButton(
                                                                      onPressed: () {
                                                                        Navigator.pop(context);
                                                                      },
                                                                      child: Text("Return",
                                                                          style: GoogleFonts.heebo(
                                                                              color: ViewConstants.myWhite,
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 14))),
                                                                ],
                                                              ),
                                                            ),
                                                          ]),
                                                        ),
                                                      ),
                                                      insetPadding: EdgeInsets.all(20),
                                                    );
                                                  });
                                            },
                                            child: Text("Delete",
                                                style: GoogleFonts.heebo(
                                                    fontWeight: FontWeight.bold, color: ViewConstants.myWhite)),
                                            padding: EdgeInsets.all(15),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        }, childCount: model.getNoteListLength()),
                        gridDelegate: SliverStaggeredGridDelegateWithMaxCrossAxisExtent(
                          mainAxisSpacing: 4.0,
                          crossAxisSpacing: 10.0,
                          staggeredTileCount: model.getNoteListLength(),
                          staggeredTileBuilder: (int index) {
                            Note _currentNote = model.getNoteByIndex(index);

                            double contentSize = (_currentNote.getContent.toString().length) / 125;

                            if (contentSize < 1.5) contentSize = 1.75;

                            return StaggeredTile.count(1, contentSize);
                          },
                          maxCrossAxisExtent: MediaQuery.of(context).size.width / 2,
                        )),
                  ),
                ),
              ]),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                onPressed: () async {
                  await showDialog(
                      barrierColor: Colors.transparent,
                      context: context,
                      builder: (BuildContext dialogContext) {
                        _textEditingController.text = "";

                        return AlertDialog(
                          backgroundColor: Colors.transparent,
                          content: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            width: MediaQuery.of(context).size.width * 0.75,
                            child: Container(
                              clipBehavior: Clip.hardEdge,
                              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment(1, 1),
                                      colors: [ViewConstants.myGrey, ViewConstants.myBlack])),
                              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10),
                                  child: AutoSizeText(
                                    "After creating your note, the list will be updated for you.",
                                    maxLines: 2,
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
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        onPressed: () async {
                                          bool isCreated =
                                              await _therapistNoteListViewModel.createNote(_textEditingController.text);
                                          Navigator.pop(context, isCreated);
                                        },
                                        child: Text(
                                          "Create",
                                          style:
                                              GoogleFonts.heebo(color: ViewConstants.myBlack, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ]),
                            ),
                          ),
                          insetPadding: EdgeInsets.all(20),
                        );
                      });
                },
                child: Icon(Icons.add),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
