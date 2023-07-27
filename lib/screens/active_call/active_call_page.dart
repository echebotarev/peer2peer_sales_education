/// Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_voximplant/flutter_voximplant.dart';
import 'package:peer2peer_sales_education/screens/active_call/active_call.dart';
import 'package:peer2peer_sales_education/screens/call_failed/call_failed.dart';
import 'package:peer2peer_sales_education/theme/voximplant_theme.dart';
import 'package:peer2peer_sales_education/utils/navigation_helper.dart';
import 'package:peer2peer_sales_education/widgets/widgets.dart';

class ActiveCallPage extends StatefulWidget {
  static const routeName = '/activeCall';

  const ActiveCallPage({super.key});

  @override
  State<StatefulWidget> createState() => _ActiveCallPageState();
}

class _ActiveCallPageState extends State<ActiveCallPage> {
  late ActiveCallBloc _bloc;

  final VIVideoViewController _localVideoViewController =
      VIVideoViewController();
  final VIVideoViewController _remoteVideoViewController =
      VIVideoViewController();

  double _localVideoAspectRatio = 1.0;
  double _remoteVideoAspectRatio = 1.0;

  // _ActiveCallPageState();

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<ActiveCallBloc>(context);
    _localVideoViewController.addListener(_localVideoHasChanged);
    _remoteVideoViewController.addListener(_remoteVideoHasChanged);
  }

  @override
  void dispose() {
    _localVideoViewController.removeListener(_localVideoHasChanged);
    _remoteVideoViewController.removeListener(_remoteVideoHasChanged);
    _localVideoViewController.dispose();
    _remoteVideoViewController.dispose();
    super.dispose();
  }

  void _localVideoHasChanged() => setState(
      () => _localVideoAspectRatio = _localVideoViewController.aspectRatio);

  void _remoteVideoHasChanged() => setState(
      () => _remoteVideoAspectRatio = _remoteVideoViewController.aspectRatio);

  @override
  Widget build(BuildContext context) {
    void _hangup() => _bloc.add(HangupPressedEvent());

    void _hold(bool hold) => _bloc.add(HoldPressedEvent(hold: hold));

    void _mute(bool mute) => _bloc.add(MutePressedEvent(mute: mute));

    void _sendVideo(bool send) => _bloc.add(SendVideoPressedEvent(send: send));

    void _switchCamera() => _bloc.add(SwitchCameraPressedEvent());

    return BlocListener<ActiveCallBloc, ActiveCallState>(
      listener: (context, state) {
        if (state is CallEndedActiveCallState) {
          state.failed
              ? Navigator.of(context).pushReplacementNamed(
                  AppRoutes.callFailed,
                  arguments: CallFailedPageArguments(
                    failureReason: state.callStatus,
                    endpoint: state.endpointName,
                  ),
                )
              : Navigator.of(context).pushReplacementNamed(AppRoutes.main);
        } else {
          _localVideoViewController.streamId = state.localVideoStreamID;
          _remoteVideoViewController.streamId = state.remoteVideoStreamID;
        }
      },
      child: BlocBuilder<ActiveCallBloc, ActiveCallState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: VoximplantColors.grey,
            body: SafeArea(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      child: Stack(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.center,
                            child: AspectRatio(
                              aspectRatio: _remoteVideoAspectRatio,
                              child: VIVideoView(_remoteVideoViewController),
                            ),
                          ),
                          Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width / 4,
                                  height:
                                      MediaQuery.of(context).size.height / 4,
                                  child: Align(
                                    child: AspectRatio(
                                      aspectRatio: _localVideoAspectRatio,
                                      child: VIVideoView(
                                          _localVideoViewController),
                                    ),
                                  ),
                                ),
                              )),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20, top: 20),
                              child: Widgets.iconButton(
                                icon: Icons.switch_camera,
                                color: VoximplantColors.button,
                                tooltip: 'Switch camera',
                                onPressed: _switchCamera,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Text(
                              state.callStatus,
                              style: const TextStyle(
                                  color: VoximplantColors.white),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 80,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Widgets.iconButton(
                                icon: state.isMuted ? Icons.mic : Icons.mic_off,
                                color: VoximplantColors.button,
                                tooltip: state.isMuted ? 'Unmute' : 'Mute',
                                onPressed: () {
                                  _mute(!state.isMuted);
                                }),
                            Widgets.iconButton(
                                icon: state.isOnHold
                                    ? Icons.play_arrow
                                    : Icons.pause,
                                color: VoximplantColors.button,
                                tooltip: state.isOnHold ? 'Resume' : 'Hold',
                                onPressed: () {
                                  _hold(!state.isOnHold);
                                }),
                            Widgets.iconButton(
                                icon: state.localVideoStreamID != null
                                    ? Icons.videocam_off
                                    : Icons.videocam,
                                color: VoximplantColors.button,
                                tooltip: 'Send video',
                                onPressed: () {
                                  _sendVideo(state.localVideoStreamID == null);
                                }),
                            Widgets.iconButton(
                                icon: Icons.call_end,
                                color: VoximplantColors.red,
                                tooltip: 'Hang up',
                                onPressed: _hangup)
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
