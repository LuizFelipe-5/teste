import 'dart:io';
import 'dart:isolate';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

void appTest() {
  print(Isolate.current.hashCode);
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TestApp());
}

void downloadCallback(String id, DownloadTaskStatus status, int progress) {}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize();
  FlutterDownloader.registerCallback(downloadCallback);

  await AndroidAlarmManager.initialize();
  runApp(const MyApp());
  final int helloAlarmID = 0;
  await AndroidAlarmManager.periodic(
    const Duration(minutes: 1),
    helloAlarmID,
    appTest,
    exact: true,
  );
}

class TestApp extends StatelessWidget {
  const TestApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          color: Colors.blue,
          child: ElevatedButton(
            onPressed: () async {},
            child: const Text('Close'),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            Draggable(
              child: Container(
                width: 10,
                height: 10,
                color: Colors.blue,
              ),
              childWhenDragging: SizedBox(),
              feedback: Container(width: 10, height: 10, color: Colors.orange),
            ),
            ElevatedButton(
              onPressed: () async {
                final download = await getExternalStorageDirectories(
                    type: StorageDirectory.downloads);
                final taskId = await FlutterDownloader.enqueue(
                  url:
                      'https://www.enel.com.br/content/dam/enel-br/megamenu/taxas,-tarifas-e-impostos/tarifas-enel-ceara-bandeira-vermelha-julho-2021.pdf',
                  savedDir: download!.first.path,
                  saveInPublicStorage: true,
                );
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    opaque: false,
                    pageBuilder: (BuildContext context, _, __) {
                      return Draggable(
                        child: _buildBody(),
                        childWhenDragging: const SizedBox(
                          width: 10,
                          height: 10,
                        ),
                        feedback: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(50),
                            ),
                          ),
                          child: _buildBody(),
                        ),
                      );
                    },
                  ),
                );
              },
              child: const Text('BOTAO'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  _buildBody() {
    return Scaffold(
      body: Container(
        color: Colors.orange,
        child: const Center(
          child: Text('bla'),
        ),
      ),
    );
  }
}
