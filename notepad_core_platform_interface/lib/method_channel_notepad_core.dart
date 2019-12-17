import 'package:flutter/services.dart';
import 'package:notepad_core_platform_interface/notepad_core_platform_interface.dart';

const _method = const MethodChannel('notepad_core/method');
const _event_scanResult = const EventChannel('notepad_core/event.scanResult');

class MethodChannelNotepadCore extends NotepadCorePlatform {
  @override
  Future<dynamic> requestDevice() {
    throw UnimplementedError('Not implemented in MethodChannelNotepadCore');
  }

  @override
  void startScan() {
    _method
        .invokeMethod('startScan')
        .then((_) => print('startScan invokeMethod success'));
  }

  @override
  void stopScan() {
    _method
        .invokeMethod('stopScan')
        .then((_) => print('stopScan invokeMethod success'));
  }

  @override
  Stream<dynamic> get scanResultStream =>
    _event_scanResult.receiveBroadcastStream({'name': 'scanResult'});

  @override
  void connect(scanResult) {
    // TODO: implement connect
  }

  @override
  void disconnect() {
    // TODO: implement disconnect
  }
}