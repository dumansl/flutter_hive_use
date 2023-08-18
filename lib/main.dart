import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hive_use/model/student.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter("uygulama");
  //encryted
  FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  var containsEncryptionKey = await secureStorage.containsKey(key: 'key');
  if (!containsEncryptionKey) {
    var key = Hive.generateSecureKey();
    await secureStorage.write(key: 'key', value: base64UrlEncode(key));
  }

  var encryptionKey =
      base64Url.decode(await secureStorage.read(key: 'key') ?? 'sule');
  print('Encryption key: $encryptionKey');

  var encryptedBox = await Hive.openBox('ozel',
      encryptionCipher: HiveAesCipher(encryptionKey));
  await encryptedBox.put('secret', 'Hive is cool');
  await encryptedBox.put('password', '123456');

  print(encryptedBox.get('secret'));
  print(encryptedBox.get('password'));

  await Hive.openBox<Student>('student');
  Hive.registerAdapter(StudentAdapter());
  Hive.registerAdapter(EyesColorAdapter());

  await Hive.openLazyBox<int>("numbers");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() async {
    var box = Hive.box("testBox");
    await box.clear();
    box.add("sule"); // index 0, key 0, value sule
    box.add("duman"); // index 1, key 1, value duman
    box.add(true);
    box.add(123);
    // await box.addAll(["list1", "list2", false, 9532]);

    await box.put("tc", "12345678910");
    await box.put("tema", "dark");
    // await box.putAll({ "car": "mercedes","year": 2012,});

    // box.keys.forEach((element) {
    //   debugPrint(element.toString());
    // });
    debugPrint(box.toMap().toString());
    debugPrint(box.get("tema")); // key ile erisim
    debugPrint(box.getAt(3).toString()); // index ile erisim

    await box.delete("tc");

    debugPrint(box.toMap().toString());
    box.putAt(1, "new value");
    debugPrint(box.toMap().toString());
  }

  void _customData() async {
    var sule = Student(id: 5, name: "sule", eyesColor: EyesColor.BLACK);
    var seckin = Student(id: 15, name: "seckin", eyesColor: EyesColor.GREEN);

    var box = Hive.box<Student>("student");
    await box.clear();
    box.add(sule);
    box.add(seckin);

    box.put("sule", sule);
    box.put("seckin", seckin);

    debugPrint(box.toMap().toString());
  }

  void _lazyAndEncrytedBox() async {
    var numbers = Hive.lazyBox<int>("numbers");
    for (int i = 0; i < 50; i++) {
      await numbers.add(i * 50);
    }
    for (int i = 0; i < 50; i++) {
      debugPrint((await numbers.get(i)).toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _lazyAndEncrytedBox,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
