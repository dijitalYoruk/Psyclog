import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:psyclog_app/service/WebServerService.dart';
import 'package:psyclog_app/src/models/Patient.dart';
import 'package:psyclog_app/src/models/Therapist.dart';
import 'package:psyclog_app/view_models/client/ClientUserMessageListViewModel.dart';
import 'package:psyclog_app/view_models/therapist/TherapistUserMessageListViewModel.dart';
import 'package:psyclog_app/views/screens/Client/ClientAppointmentPage.dart';
import 'package:psyclog_app/views/screens/Client/ClientMessagePage.dart';
import 'package:psyclog_app/views/screens/Client/ClientSessionPage.dart';
import 'package:psyclog_app/views/screens/Client/ClientSearchPage.dart';
import 'package:psyclog_app/views/screens/Shared/TopicPage.dart';
import 'package:psyclog_app/views/screens/Therapist/TherapistAppointmentPage.dart';
import 'package:psyclog_app/views/screens/Therapist/TherapistMessagePage.dart';
import 'package:psyclog_app/views/screens/Therapist/TherapistSessionPage.dart';
import 'package:psyclog_app/views/util/ViewConstants.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  static List<Widget> _homepageTabs;
  static List<CustomNavigationBarItem> bottomIconButtons;

  ClientUserMessageListViewModel _clientMessageListViewModel;
  TherapistUserMessageListViewModel _therapistMessageListViewModel;

  PageController _pageController;
  WebServerService _webServerService;
  int _currentIndex;

  @override
  void initState() {
    _pageController = PageController(initialPage: 2);
    _currentIndex = _pageController.initialPage;
    super.initState();
  }

  Future<bool> initializeService() async {
    // Wait for Web Server Service to be created
    try {
      _webServerService = await WebServerService.getWebServerService();

      if (_webServerService.currentUser is Patient) {
        _clientMessageListViewModel = ClientUserMessageListViewModel(context);
        await _clientMessageListViewModel.initializeService();
        _therapistMessageListViewModel = null;

        _homepageTabs = <Widget>[
          TopicPage(),
          ClientSearchPage(),
          ClientSessionPage(),
          ClientAppointmentPage(),
          ChangeNotifierProvider.value(
            value: _clientMessageListViewModel,
            child: ClientMessagePage(),
          )
        ];

        bottomIconButtons = <CustomNavigationBarItem>[
          CustomNavigationBarItem(icon: Icons.all_inclusive),
          CustomNavigationBarItem(icon: Icons.search),
          CustomNavigationBarItem(icon: Icons.add),
          CustomNavigationBarItem(icon: Icons.access_time),
          CustomNavigationBarItem(icon: Icons.chat),
        ];
      } else if (_webServerService.currentUser is Therapist) {
        _therapistMessageListViewModel = TherapistUserMessageListViewModel(context);
        await _therapistMessageListViewModel.initializeService();
        _clientMessageListViewModel = null;

        _homepageTabs = <Widget>[
          TopicPage(),
          TherapistSessionPage(),
          TherapistAppointmentPage(),
          ChangeNotifierProvider.value(value: _therapistMessageListViewModel, child: TherapistMessagePage()),
        ];

        bottomIconButtons = <CustomNavigationBarItem>[
          CustomNavigationBarItem(icon: Icons.all_inclusive),
          CustomNavigationBarItem(icon: Icons.add),
          CustomNavigationBarItem(icon: Icons.access_time),
          CustomNavigationBarItem(icon: Icons.chat),
        ];
      }
    } catch (e) {
      print(e);
    }
    return true;
  }

  @override
  void setState(fn) {
    // TODO: implement setState
    super.setState(fn);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initializeService(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.data == true) {
          return Scaffold(
            resizeToAvoidBottomPadding: false,
            backgroundColor: ViewConstants.myWhite,
            bottomNavigationBar: StatefulBuilder(
              builder: (context, StateSetter stateSetter) {
                return CustomNavigationBar(
                  scaleFactor: 0.2,
                  iconSize: 25.0,
                  selectedColor: ViewConstants.myBlue,
                  strokeColor: ViewConstants.myBlue,
                  unSelectedColor: ViewConstants.myWhite,
                  backgroundColor: ViewConstants.myBlack,
                  items: bottomIconButtons,
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    _pageController.animateToPage(index, duration: Duration(milliseconds: 500), curve: Curves.decelerate);
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                );
              },
            ),
            body: PageView(
              physics: NeverScrollableScrollPhysics(),
              controller: _pageController,
              children: _homepageTabs,
            ),
          );
        } else {
          return Scaffold();
        }
      },
    );
  }
}
