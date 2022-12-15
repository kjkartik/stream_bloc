import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(

          primarySwatch: Colors.blue,
        ),
        home: const HomePage()
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  //create stream
  StreamController<DataModel> _streamController = StreamController();

  @override
  void dispose() {
    // stop streaming when app close
    _streamController.close();
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // A Timer method that run every 3 seconds

    Timer.periodic(Duration(seconds: 3), (timer) {
      getCryptoPrice();
    });

  }

  // a future method that fetch data from API
  Future<void> getCryptoPrice() async{

    var url = Uri.parse('https://api.nomics.com/v1/currencies/ticker?key=your_api_key&ids=DOGE');

    final response = await http.get(url);
    final databody = json.decode(response.body).first;

    DataModel dataModel = new DataModel.fromJson(databody);

    // add API response to stream controller sink
    _streamController.sink.add(dataModel);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: StreamBuilder<DataModel>(
          stream: _streamController.stream,
          builder: (context,snapdata){
            switch(snapdata.connectionState){
              case ConnectionState.waiting: return Center(child: CircularProgressIndicator(),);
              default: if(snapdata.hasError){
                return Text('Please Wait....');
              }else{
                return BuildCoinWidget(snapdata.data!);
              }
            }
          },
        ),
      ),
    );
  }

  Widget BuildCoinWidget(DataModel dataModel){
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('${dataModel.name}',style: TextStyle(fontSize: 25),),
          SizedBox(height: 20,),
          SvgPicture.network('${dataModel.image}',width: 150,height: 150,),
          SizedBox(height: 20,),
          Text('\$${dataModel.price}',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),)
        ],
      ),
    );
  }
}


class DataModel{
  String name;
  String image;
  String price;

  DataModel.fromJson(Map<String,dynamic> json)
      : name = json['name'],
        image=json['logo_url'],
        price=json['price'];

  //a method that convert object to json
  Map<String, dynamic> toJson() => {
    'name': name,
    'logo_url': image,
    'price':price
  };

}