import 'dart:isolate';

import 'package:flutter/material.dart';

void main() => runApp(const MyApp());
// khi ứng dụng flutter được khởi tạo sẽ sinh ra 1 Main Isolate -> trong main Isolate tất cả code sẽ nằm trong cái main isolate này
// khi có 1 tác vụ animation hoặc jj đó đang chạy , và 1 tác vụ khác nặng thì 1 trong 2 tác vụ sẽ bị dừng
// do chúng đều chạy trên 1 mainthread

// cách giải quyết : tạo thêm 1 isolate để giải quyết
// dart là ngôn ngữ single thread

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Scaffold(body: IsolateDemo()),
    );
  }
}

class IsolateDemo extends StatelessWidget{
  const IsolateDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const ImageRotate(),
        Center(
          child: Container(
            margin: EdgeInsets.only(top: 20),
            child: TextButton(
              onPressed: (){
                //trên này sử dụng isolate
                // createNewIsolate();

                //ở đây là trường hợp k sử dụng isolate
                // sum().then((value){
                //   print(value);
                // });
              },
              child: Text('Click to button'),
            ),
          ),
        )
      ],
    );
  }

  void createNewIsolate(){
    //main isolate
    var receivePort = ReceivePort();
    Isolate.spawn(taskRunner, receivePort.sendPort);
        // entry poin : static fun || top fun
    receivePort.listen((data){
      print(data);
    });

    receivePort.listen((message) {
      print(message[0]);
      if(message[1] is SendPort){
        message[1].send('From main isolate');
      }
    });
  }

  //static function
  static void taskRunner(SendPort sendPort){

    //new isolate
    var total = 0;
    for(var i = 0;i<1000000000;i++){
      total +=1;
    }
    sendPort.send(total);
  }

  //static function
  static void taskRunner2(SendPort sendPort){
    var receivePort = ReceivePort();

    receivePort.listen((message) {
      print(message);
    });

    //new isolate
    var total = 0;
    for(var i = 0;i<1000000000;i++){
      total +=1;
    }
    //gửi theo list
    sendPort.send([total,receivePort.sendPort]);
  }


  Future<int> sum()async{
    var total = 0;
    for(var i = 0; i<1000000000;i++){
      total+=i;
    }
    return total;
  }

}



class ImageRotate extends StatefulWidget {
  const ImageRotate({super.key});

  @override
  _ImageRotateState createState() => _ImageRotateState();
}

class _ImageRotateState extends State<ImageRotate>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    );

    animationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: AnimatedBuilder(
        animation: animationController,
        child: Container(
          child: Image.asset('assets/images/setting_2.png'),
        ),
        builder: (BuildContext context, Widget? _widget) {
          return Transform.rotate(
            angle: animationController.value * 40,
            child: _widget,
          );
        },
      ),
    );
  }
}


