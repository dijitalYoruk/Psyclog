import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:psyclog_app/service/util/ServiceConstants.dart';
import 'package:psyclog_app/src/models/Patient.dart';
import 'package:psyclog_app/src/models/TherapistAppointment.dart';
import 'package:psyclog_app/views/util/CustomPainter.dart';
import 'package:psyclog_app/views/util/ViewConstants.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:psyclog_app/views/widgets/LoadingIndicator.dart';

class TherapistVideoCallPage extends StatefulWidget {
  final TherapistAppointment _currentAppointment;

  const TherapistVideoCallPage(this._currentAppointment, {Key key}) : super(key: key);

  @override
  _ClientVideoCallPageState createState() => _ClientVideoCallPageState();
}

class _ClientVideoCallPageState extends State<TherapistVideoCallPage> {
  RtcEngine _engine;

  PageController _pageController;

  bool muted = false;
  bool isConnected = false;

  Timer _timer;
  int duration;

  final _infoStrings = <String>[];
  final _users = <int>[];

  @override
  void initState() {
    super.initState();
    // initialize agora sdk
    initialize();
    _pageController = PageController(initialPage: 1);
    duration = 0;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      duration++;
    });
  }

  @override
  void dispose() {
    // clear users
    _users.clear();
    // destroy sdk
    _engine.leaveChannel();
    _engine.destroy();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> initialize() async {
    if (ServiceConstants.agoraAPIKey.isEmpty) {
      setState(() {
        _infoStrings.add(
          'APP_ID missing',
        );
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }

    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    await _engine.enableWebSdkInteroperability(true);
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = VideoDimensions(1920, 1080);
    await _engine.setVideoEncoderConfiguration(configuration);
    await _engine.joinChannel("", widget._currentAppointment.getAppointmentID, null, 0);
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(ServiceConstants.agoraAPIKey);
    await _engine.enableVideo();
    await _engine.setChannelProfile(ChannelProfile.Communication);
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    _engine.setEventHandler(RtcEngineEventHandler(error: (code) {
      setState(() {
        final info = 'onError: $code';
        _infoStrings.add(info);
      });
    }, joinChannelSuccess: (channel, uid, elapsed) {
      setState(() {
        final info = 'onJoinChannel: $channel, uid: $uid';
        _infoStrings.add(info);
      });
    }, leaveChannel: (stats) {
      setState(() {
        _infoStrings.add('onLeaveChannel');
        _users.clear();
      });
    }, userJoined: (uid, elapsed) {
      setState(() {
        final info = 'userJoined: $uid';
        _infoStrings.add(info);
        _users.add(uid);
        isConnected = true;
      });
      Flushbar(
        margin: EdgeInsets.all(14),
        borderRadius: 8,
        leftBarIndicatorColor: ViewConstants.myBlue,
        messageText: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: AutoSizeText("Client joined the channel."),
        ),
        flushbarStyle: FlushbarStyle.FLOATING,
        reverseAnimationCurve: Curves.decelerate,
        forwardAnimationCurve: Curves.decelerate,
        flushbarPosition: FlushbarPosition.TOP,
        backgroundColor: ViewConstants.myBlack,
        duration: Duration(seconds: 3),
      )..show(context);
    }, userOffline: (uid, elapsed) {
      setState(() {
        final info = 'userOffline: $uid';
        _infoStrings.add(info);
        _users.remove(uid);
        isConnected = false;
      });
      Flushbar(
        margin: EdgeInsets.all(14),
        borderRadius: 8,
        leftBarIndicatorColor: ViewConstants.myBlue,
        messageText: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: AutoSizeText("Client left the channel."),
        ),
        flushbarStyle: FlushbarStyle.FLOATING,
        reverseAnimationCurve: Curves.decelerate,
        forwardAnimationCurve: Curves.decelerate,
        flushbarPosition: FlushbarPosition.TOP,
        backgroundColor: ViewConstants.myBlack,
        duration: Duration(seconds: 3),
      )..show(context);
    }, firstRemoteVideoFrame: (uid, width, height, elapsed) {
      setState(() {
        final info = 'firstRemoteVideo: $uid ${width}x $height';
        _infoStrings.add(info);
      });
    }));
  }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final List<StatefulWidget> list = [];
    list.add(RtcLocalView.SurfaceView());
    _users.forEach((int uid) => list.add(RtcRemoteView.SurfaceView(uid: uid)));
    return list;
  }

  /// Video layout wrapper
  Widget _viewRows() {
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        return Container(
            child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment(5, 5), colors: [ViewConstants.myWhite, ViewConstants.myBlue]),
              ),
              child: Stack(
                children: [
                  LoadingIndicator(),
                ],
              ),
            ),
            Positioned(
              child: SizedBox(
                height: MediaQuery.of(context).size.height / 4,
                width: MediaQuery.of(context).size.width / 4,
                child: Card(
                  elevation: 5,
                  child: views[0],
                  clipBehavior: Clip.hardEdge,
                ),
              ),
              top: 30,
              right: 15,
            )
          ],
        ));
      case 2:
        return Container(
            child: Stack(
          children: [
            Container(
              child: views[1],
            ),
            Positioned(
              child: SizedBox(
                height: MediaQuery.of(context).size.height / 4,
                width: MediaQuery.of(context).size.width / 4,
                child: Card(
                  elevation: 5,
                  child: views[0],
                  clipBehavior: Clip.hardEdge,
                ),
              ),
              top: 30,
              right: 15,
            )
          ],
        ));
      default:
    }
    return Container();
  }

  /// Toolbar layout
  Widget _toolbar() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Client",
                      style: GoogleFonts.heebo(color: ViewConstants.myWhite),
                    ),
                    AutoSizeText(
                      (widget._currentAppointment.getPatient as Patient).getFullName(),
                      style: GoogleFonts.heebo(fontWeight: FontWeight.bold, color: ViewConstants.myWhite),
                      minFontSize: 25,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RawMaterialButton(
                  onPressed: () => _onCallEnd(context),
                  child: Icon(
                    Icons.call_end,
                    color: ViewConstants.myWhite,
                    size: 25.0,
                  ),
                  shape: CircleBorder(),
                  elevation: 2.0,
                  fillColor: ViewConstants.myPink,
                  padding: const EdgeInsets.all(15.0),
                ),
              ),
              Expanded(
                child: RawMaterialButton(
                  onPressed: _onToggleMute,
                  child: Icon(
                    muted ? Icons.mic_off : Icons.mic,
                    color: muted ? Colors.white : ViewConstants.myBlue,
                    size: 15.0,
                  ),
                  shape: CircleBorder(),
                  elevation: 2.0,
                  fillColor: muted ? ViewConstants.myBlue : Colors.white,
                  padding: const EdgeInsets.all(12.0),
                ),
              ),
              Expanded(
                child: RawMaterialButton(
                  onPressed: _onSwitchCamera,
                  child: Icon(
                    Icons.switch_camera,
                    color: ViewConstants.myBlue,
                    size: 15.0,
                  ),
                  shape: CircleBorder(),
                  elevation: 2.0,
                  fillColor: Colors.white,
                  padding: const EdgeInsets.all(12.0),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  void _onCallEnd(BuildContext context) {
    Navigator.pop(context);
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
  }

  void _onSwitchCamera() {
    _engine.switchCamera();
  }

  Widget _viewNotes() {
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ViewConstants.myWhite,
      body: Center(
        child: PageView(
          controller: _pageController,
          physics: ClampingScrollPhysics(),
          children: [
            _viewNotes(),
            Stack(
              children: <Widget>[
                _viewRows(),
                _toolbar(),
                Positioned(
                  left: 0,
                  top: MediaQuery.of(context).size.height / 2,
                  child: SizedBox(
                    width: 60,
                    height: 140,
                    child: Stack(
                      children: [
                        CustomPaint(
                          size: Size(60, 140),
                          //You can Replace this with your desired WIDTH and HEIGHT
                          painter: NoteButtonPainter(),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [Icon(Icons.notes, color: ViewConstants.myBlue)],
                        ),
                      ],
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
