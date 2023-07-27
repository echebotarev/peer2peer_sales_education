import 'package:peer2peer_sales_education/services/call/call_event.dart';

abstract class ActiveCallEvent {}

class ReadyToStartCallEvent implements ActiveCallEvent {
  final bool isIncoming;
  final String endpoint;

  ReadyToStartCallEvent({required this.isIncoming, required this.endpoint});
}

class CallChangedEvent implements ActiveCallEvent {
  final CallEvent event;

  CallChangedEvent({required this.event});
}

class SendVideoPressedEvent implements ActiveCallEvent {
  final bool send;

  SendVideoPressedEvent({required this.send});
}

class SwitchCameraPressedEvent implements ActiveCallEvent {}

class HoldPressedEvent implements ActiveCallEvent {
  final bool hold;

  HoldPressedEvent({required this.hold});
}

class MutePressedEvent implements ActiveCallEvent {
  final bool mute;

  MutePressedEvent({required this.mute});
}

class HangupPressedEvent implements ActiveCallEvent {}
