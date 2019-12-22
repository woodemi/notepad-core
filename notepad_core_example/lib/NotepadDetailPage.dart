import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:notepad_core/notepad_core.dart';

class NotepadDetailPage extends StatefulWidget {
  final scanResult;

  NotepadDetailPage(this.scanResult);

  @override
  State<StatefulWidget> createState() => _NotepadDetailPageState();
}

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

_toast(String msg) => _scaffoldKey.currentState
  .showSnackBar(SnackBar(content: Text(msg), duration: Duration(seconds: 2)));

class _NotepadDetailPageState extends State<NotepadDetailPage> implements NotepadClientCallback {
  @override
  void initState() {
    super.initState();
    notepadConnector.connectionChangeHandler = _handleConnectionChange;
  }

  @override
  void dispose() {
    super.dispose();
    notepadConnector.connectionChangeHandler = null;
  }

  NotepadClient _notepadClient;
  
  void _handleConnectionChange(NotepadClient client, NotepadConnectionState state) {
    print('_handleConnectionChange $client $state');
    if (state == NotepadConnectionState.connected) {
      _notepadClient = client;
      _notepadClient.callback = this;
    } else {
      _notepadClient?.callback = null;
      _notepadClient = null;
    }
  }

  @override
  void handlePointer(List<NotePenPointer> list) {
    print('handlePointer ${list.length}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('NotepadDetailPage'),
      ),
      body: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              RaisedButton(
                child: Text('connect'),
                onPressed: () {
                  notepadConnector.connect(widget.scanResult, Uint8List.fromList([0x00, 0x00, 0x00, 0x02]));
                },
              ),
              RaisedButton(
                child: Text('disconnect'),
                onPressed: () {
                  notepadConnector.disconnect();
                },
              ),
            ],
          ),
          _buildAuthorizationButtons(),
          ..._buildDeviceInfoButtons(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              RaisedButton(
                child: Text('setMode'),
                onPressed: () async {
                  await _notepadClient.setMode(NotepadMode.Sync);
                },
              ),
            ],
          ),
          ..._buildImportMemoButtons(),
        ],
      ),
    );
  }

  Widget _buildAuthorizationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        RaisedButton(
          child: Text('claimAuth'),
          onPressed: () async {
            if (_notepadClient != null) {
              await _notepadClient.claimAuth();
              _toast('claimAuth success');
            } else {
              _toast('_notepadClient = null');
            }
          },
        ),
        RaisedButton(
          child: Text('disclaimAuth'),
          onPressed: () async {
            if (_notepadClient != null) {
              await _notepadClient.disclaimAuth();
              _toast('disclaimAuth success');
            } else {
              _toast('_notepadClient = null');
            }
          },
        ),
      ],
    );
  }

  List<Widget> _buildDeviceInfoButtons() {
    return <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          RaisedButton(
            child: Text('getDeviceSize'),
            onPressed: () async {
              var size = _notepadClient.getDeviceSize();
              _toast('device size = $size');
            },
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          RaisedButton(
            child: Text('getDeviceName'),
            onPressed: () async {
              _toast('DeviceName: ${await _notepadClient.getDeviceName()}');
            },
          ),
          RaisedButton(
            child: Text('setDeviceName'),
            onPressed: () async => {
              await _notepadClient.setDeviceName('abc'),
              _toast('New DeviceName: ${await _notepadClient.getDeviceName()}'),
            },
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          RaisedButton(
            child: Text('getBatteryInfo'),
            onPressed: () async {
              BatteryInfo battery = await _notepadClient.getBatteryInfo();
              _toast('battery.percent = ${battery.percent}  battery.charging = ${battery.charging}');
            },
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          RaisedButton(
            child: Text('getDeviceDate'),
            onPressed: () async {
              _toast('date = ${await _notepadClient.getDeviceDate()}');
            },
          ),
          RaisedButton(
            child: Text('setDeviceDate'),
            onPressed: () async => {
              await _notepadClient.setDeviceDate(0), // second
              _toast('new DeivceDate = ${await _notepadClient.getDeviceDate()}'),
            },
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          RaisedButton(
            child: Text('getAutoLockTime'),
            onPressed: () async => _toast(
                'AutoLockTime = ${await _notepadClient.getAutoLockTime()}'),
          ),
          RaisedButton(
            child: Text('setAutoLockTime'),
            onPressed: () async => {
              await _notepadClient.setAutoLockTime(10),
              _toast('new AutoLockTime = ${await _notepadClient.getAutoLockTime()}')
            },
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildImportMemoButtons() {
    return <Widget> [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          RaisedButton(
            child: Text('getMemoSummary'),
            onPressed: () async {
              var memoSummary = await _notepadClient.getMemoSummary();
              print('getMemoSummary $memoSummary');
            },
          ),
          RaisedButton(
            child: Text('getMemoInfo'),
            onPressed: () async {
              var memoInfo = await _notepadClient.getMemoInfo();
              print('getMemoInfo $memoInfo');
            },
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          RaisedButton(
            child: Text('importMemo'),
            onPressed: () async {
              var memoData = await _notepadClient
                  .importMemo((progress) => print('progress $progress'));
              print('importMemo finish');
              memoData.pointers.forEach((p) async {
                print('memoData x = ${p.x}\ty = ${p.y}\tt = ${p.t}\tp = ${p.p}');
              });
            },
          ),
          RaisedButton(
            child: Text('deleteMemo'),
            onPressed: () {
              _notepadClient.deleteMemo();
            },
          ),
        ],
      ),
    ];
  }
}