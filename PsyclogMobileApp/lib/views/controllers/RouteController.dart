import 'package:flutter/material.dart';
import 'package:psyclog_app/src/models/ClientAppointment.dart';
import 'package:psyclog_app/src/models/TherapistAppointment.dart';
import 'package:psyclog_app/src/models/Topic.dart';
import 'package:psyclog_app/views/controllers/RouteArguments.dart';
import 'package:psyclog_app/views/screens/Client/ClientProfilePage.dart';
import 'package:psyclog_app/views/screens/Client/ClientVideoCallPage.dart';
import 'package:psyclog_app/views/screens/Shared/HomePage.dart';
import 'package:psyclog_app/views/screens/Shared/LoginPage.dart';
import 'package:psyclog_app/views/screens/Shared/PostCreatePage.dart';
import 'package:psyclog_app/views/screens/Shared/PostListPage.dart';
import 'package:psyclog_app/views/screens/Shared/RegisterPage.dart';
import 'package:psyclog_app/views/screens/Client/ClientCreateAppointmentPage.dart';
import 'package:psyclog_app/views/screens/Shared/TopicCreatePage.dart';
import 'package:psyclog_app/views/screens/SplashPage.dart';
import 'package:psyclog_app/views/screens/Therapist/TherapistIntervalsPage.dart';
import 'package:psyclog_app/views/screens/Therapist/TherapistPendingRequestPage.dart';
import 'package:psyclog_app/views/screens/Therapist/TherapistProfilePage.dart';
import 'package:psyclog_app/views/screens/Therapist/TherapistRegisterPage.dart';
import 'package:psyclog_app/views/screens/Client/ClientRegisterPage.dart';
import 'package:psyclog_app/views/screens/Client/ClientRequestPage.dart';
import 'package:psyclog_app/views/screens/Therapist/TherapistVideoCallPage.dart';
import 'package:psyclog_app/views/screens/WalletPage.dart';
import 'package:psyclog_app/views/screens/WelcomePage.dart';
import 'package:psyclog_app/views/util/ViewConstants.dart';
import 'package:psyclog_app/views/screens/Client/ClientTherapistListPage.dart';
import 'package:psyclog_app/views/widgets/InnerDrawerWithScreen.dart';
import 'package:psyclog_app/views/screens/Client/ClientPendingRequestPage.dart';

class RouteController {
  static Route<dynamic> generateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case ViewConstants.splashRoute:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => SplashPage(),
        );
        break;
      case ViewConstants.welcomeRoute:
        return PageRouteBuilder(
          settings: settings,
          transitionDuration: Duration(milliseconds: 1666),
          pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
            return WelcomePage();
          },
          transitionsBuilder:
              (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
            var curve = Curves.linearToEaseOut;

            var curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: curve,
            );

            return FadeTransition(
              opacity: curvedAnimation,
              child: child,
            );
          },
        );
        break;
      case ViewConstants.loginRoute:
        return PageRouteBuilder(
          settings: settings,
          transitionDuration: Duration(milliseconds: 800),
          pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
            return LoginPage();
          },
          transitionsBuilder:
              (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );
        break;
      case ViewConstants.registerRoute:
        return PageRouteBuilder(
          settings: settings,
          transitionDuration: Duration(milliseconds: 800),
          pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
            return RegisterPage();
          },
          transitionsBuilder:
              (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
            var curve = Curves.linearToEaseOut;

            var curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: curve,
            );

            return FadeTransition(
              opacity: curvedAnimation,
              child: child,
            );
          },
        );
        break;
      case ViewConstants.registerClientRoute:
        return PageRouteBuilder(
          settings: settings,
          transitionDuration: Duration(milliseconds: 800),
          pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
            return ClientRegisterPage();
          },
          transitionsBuilder:
              (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
            var curve = Curves.decelerate;

            var begin = Offset(1.0, 0.0);
            var end = Offset.zero;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        );
        break;
      case ViewConstants.registerTherapistRoute:
        return PageRouteBuilder(
          settings: settings,
          transitionDuration: Duration(milliseconds: 800),
          pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
            return TherapistRegisterPage();
          },
          transitionsBuilder:
              (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
            var curve = Curves.decelerate;

            var begin = Offset(1.0, 0.0);
            var end = Offset.zero;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        );
        break;
      case ViewConstants.homeRoute:
        return PageRouteBuilder(
          settings: settings,
          transitionDuration: Duration(milliseconds: 800),
          pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
            return InnerDrawerWithScreen(scaffoldArea: HomePage());
          },
          transitionsBuilder:
              (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
            var curve = Curves.linearToEaseOut;

            var curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: curve,
            );

            return FadeTransition(
              opacity: curvedAnimation,
              child: child,
            );
          },
        );
        break;
      case ViewConstants.allTherapistsRoute:

        // TODO Passing settings.arguments to pages
        // TODO Changing the structure of AllTherapistListPage to TherapistListPage

        final String pageName = settings.arguments;

        return PageRouteBuilder(
          settings: settings,
          transitionDuration: Duration(milliseconds: 800),
          pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
            return ClientTherapistsListPage(pageName: pageName);
          },
          transitionsBuilder:
              (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
            var curve = Curves.linear;

            var curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: curve,
            );

            return FadeTransition(
              opacity: curvedAnimation,
              child: child,
            );
          },
        );
        break;
      case ViewConstants.therapistRequestRoute:
        final TherapistRequestScreenArguments _args = settings.arguments;

        return PageRouteBuilder(
          settings: settings,
          transitionDuration: Duration(milliseconds: 800),
          pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
            return ClientRequestPage(therapist: _args.therapist, currentUserApplied: _args.currentUserApplied);
          },
          transitionsBuilder:
              (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
            var curve = Curves.linear;

            var curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: curve,
            );

            return FadeTransition(
              opacity: curvedAnimation,
              child: child,
            );
          },
        );
        break;
      case ViewConstants.clientProfileRoute:
        return PageRouteBuilder(
          settings: settings,
          transitionDuration: Duration(milliseconds: 800),
          pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
            return InnerDrawerWithScreen(scaffoldArea: ClientProfilePage());
          },
          transitionsBuilder:
              (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
            var curve = Curves.linearToEaseOut;

            var curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: curve,
            );

            return FadeTransition(
              opacity: curvedAnimation,
              child: child,
            );
          },
        );
        break;
      case ViewConstants.therapistProfileRoute:
        return PageRouteBuilder(
          settings: settings,
          transitionDuration: Duration(milliseconds: 800),
          pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
            return InnerDrawerWithScreen(scaffoldArea: TherapistProfilePage());
          },
          transitionsBuilder:
              (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
            var curve = Curves.linearToEaseOut;

            var curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: curve,
            );

            return FadeTransition(
              opacity: curvedAnimation,
              child: child,
            );
          },
        );
        break;
      case ViewConstants.clientPendingRequestRoute:
        return PageRouteBuilder(
          settings: settings,
          transitionDuration: Duration(milliseconds: 800),
          pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
            return ClientPendingRequestPage();
          },
          transitionsBuilder:
              (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
            var curve = Curves.decelerate;

            var begin = Offset(1.0, 0.0);
            var end = Offset.zero;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        );
        break;
      case ViewConstants.therapistPendingRequestRoute:
        return PageRouteBuilder(
          settings: settings,
          transitionDuration: Duration(milliseconds: 800),
          pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
            return TherapistPendingRequestPage();
          },
          transitionsBuilder:
              (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
            var curve = Curves.decelerate;

            var begin = Offset(1.0, 0.0);
            var end = Offset.zero;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        );
        break;
      case ViewConstants.therapistIntervalRoute:
        return PageRouteBuilder(
          settings: settings,
          transitionDuration: Duration(milliseconds: 800),
          pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
            return TherapistIntervalsPage();
          },
          transitionsBuilder:
              (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
            var curve = Curves.decelerate;

            var begin = Offset(1.0, 0.0);
            var end = Offset.zero;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        );
        break;
      case ViewConstants.clientCreateAppointmentRoute:
        final CreateAppointmentScreenArguments _args = settings.arguments;

        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
            return ClientCreateAppointmentPage(_args.therapist);
          },
          transitionDuration: Duration(milliseconds: 800),
          transitionsBuilder:
              (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
            var curve = Curves.linearToEaseOut;

            var curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: curve,
            );

            return FadeTransition(
              opacity: curvedAnimation,
              child: child,
            );
          },
        );
        break;
      case ViewConstants.topicCreateRoute:
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
            return TopicCreatePage();
          },
          transitionsBuilder:
              (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
            var curve = Curves.linearToEaseOut;

            var curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: curve,
            );

            return FadeTransition(
              opacity: curvedAnimation,
              child: child,
            );
          },
        );
        break;
      case ViewConstants.postListRoute:
        final Topic _currentTopic = settings.arguments;

        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
            return PostListPage(_currentTopic);
          },
          transitionsBuilder:
              (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
            var curve = Curves.linearToEaseOut;

            var curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: curve,
            );

            return FadeTransition(
              opacity: curvedAnimation,
              child: child,
            );
          },
        );
        break;
      case ViewConstants.postCreateRoute:
        final Topic _currentTopic = settings.arguments;

        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
            return PostCreatePage(_currentTopic);
          },
          transitionsBuilder:
              (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
            var curve = Curves.linearToEaseOut;

            var curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: curve,
            );

            return FadeTransition(
              opacity: curvedAnimation,
              child: child,
            );
          },
        );
        break;
      case ViewConstants.walletRoute:
        return MaterialPageRoute(settings: settings, builder: (_) => InnerDrawerWithScreen(scaffoldArea: WalletPage()));
        break;
      case ViewConstants.clientVideoCallRoute:
        final ClientAppointment _currentAppointment = settings.arguments;

        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
            return ClientVideoCallPage(_currentAppointment);
          },
          transitionsBuilder:
              (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
            var curve = Curves.linearToEaseOut;

            var curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: curve,
            );

            return FadeTransition(
              opacity: curvedAnimation,
              child: child,
            );
          },
        );
      case ViewConstants.therapistVideoCallRoute:
        final TherapistAppointment _currentAppointment = settings.arguments;

        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
            return TherapistVideoCallPage(_currentAppointment);
          },
          transitionsBuilder:
              (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
            var curve = Curves.linearToEaseOut;

            var curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: curve,
            );

            return FadeTransition(
              opacity: curvedAnimation,
              child: child,
            );
          },
        );
      default:
        return MaterialPageRoute(
            settings: settings,
            builder: (_) => Scaffold(
                  body: Center(child: Text('No route defined for ${settings.name}')),
                ));
        break;
    }
  }
}
