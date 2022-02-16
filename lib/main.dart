import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';

void downloadCallback(String id, DownloadTaskStatus status, int progress) {
  print(Isolate.current.hashCode);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize();
  FlutterDownloader.registerCallback(downloadCallback);

  runApp(const MyApp());
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                final download = await getApplicationDocumentsDirectory();

                final taskId = await FlutterDownloader.enqueue(
                  url:
                      'https://www.enel.com.br/content/dam/enel-br/megamenu/taxas,-tarifas-e-impostos/tarifas-enel-ceara-bandeira-vermelha-julho-2021.pdf',
                  savedDir: download.path,
                  showNotification: true,
                  saveInPublicStorage: true,
                  openFileFromNotification: true,
                );

                bool waitTask = true;

                while (waitTask) {
                  String query =
                      "SELECT * FROM task WHERE task_id='" + taskId! + "'";
                  var _tasks = await FlutterDownloader.loadTasksWithRawQuery(
                    query: query,
                  );
                  String taskStatus = _tasks![0].status.toString();
                  int taskProgress = _tasks[0].progress;
                  if (taskStatus == "DownloadTaskStatus(3)" &&
                      taskProgress == 100) {
                    waitTask = false;
                  }
                }

                await FlutterDownloader.open(taskId: taskId!);
              },
              child: const Text('BOTAO'),
            ),
          ],
        ),
      ),
    );
  }
}
