import 'package:flutter/material.dart';
import 'package:psyclog_app/views/util/ViewConstants.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

class LoadingIndicator extends StatelessWidget {
  final CustomConfig config;

  const LoadingIndicator({Key key, this.config}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: WaveWidget(
        config: config == null
            ? CustomConfig(
                colors: [
                  ViewConstants.myPink,
                  ViewConstants.myYellow,
                  ViewConstants.myBlue,
                  ViewConstants.myLightBlue,
                ],
                durations: [
                  50000,
                  46000,
                  42000,
                  38000,
                ],
                heightPercentages: [0.64, 0.66, 0.68, 0.70],
              )
            : config,
        backgroundColor: Colors.transparent,
        size: Size(
          MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height,
        ),
      ),
    );
  }
}
