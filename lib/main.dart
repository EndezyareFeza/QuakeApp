import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

Map _data;
List _features;  // features object list
void main() async {
  _data = await getQuakes();
  _features = _data["features"];
  //print(_data["features"][0]["properties"]);
  runApp(new MaterialApp(
    title: "Quakes",
    home: new Quakes(),
    debugShowCheckedModeBanner: false,
  ));
}

class Quakes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Quakes"),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: new Center(
        child: new ListView.builder(
          itemCount: _features.length,
          padding: EdgeInsets.all(15.0),
          // Date format: https://pub.dartlang.org/packages/intl#-readme-tab-
          // https://stackoverflow.com/questions/45357520/dart-converting-milliseconds-since-epoch-unix-timestamp-into-human-readable#
          // Date Format: https://pub.dartlang.org/documentation/intl/0.15.1/intl/DateFormat-class.html
          itemBuilder: (BuildContext context, int position){
            //Creating rows for our Listview
            if (position.isOdd) return Divider();
            final index = position; //We are dividing by 2 and returning an integer result
            var format = new DateFormat.yMMMMd("en_US").add_jm();
            //var dateString = format.format(date);
            var date = format.format(new DateTime.fromMicrosecondsSinceEpoch(_features[index]["properties"]["time"]*1000, isUtc: true));
            return new ListTile(
              title: new Text("At: $date",
              style: new TextStyle(fontSize: 19.5,
              color: Colors.orange,
                fontWeight: FontWeight.w500
              ),
              ),
              subtitle: new Text("${_features[index]["properties"]["place"]}",
              style: new TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14.5,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
              ),
              leading: new CircleAvatar(
                backgroundColor: Colors.green,
                child: new Text("${_features[index]["properties"]["mag"]}",
                style: new TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.5,
                  color: Colors.white,
                  fontStyle: FontStyle.normal,
                ),
                ),
              ),
              onTap: () {_showAlertMessage(context, "${_features[index]["properties"]["title"]}");},
            );
          },
        ),
      ),
    );
  }

  void _showAlertMessage(BuildContext context, String message) {
    var alert = new AlertDialog(
      title: new Text("Quakes"),
      content: new Text(message),
      actions: <Widget>[
        new FlatButton(onPressed: (){Navigator.pop(context);}, child: new Text("OK"))
      ],
    );
    showDialog(context: context, child: alert);
  }
}

Future<Map> getQuakes() async {
  String apiUrl = "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson";
  http.Response response = await http.get(apiUrl);
  return json.decode(response.body);
}