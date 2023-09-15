import 'dart:convert';

import 'solat.dart';
import 'package:flutter/material.dart';
import 'home.dart';
import 'package:http/http.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  List<Solat>? waktuSolat;
  Map<String, dynamic>? data;
  Solat? today;

  Future<void> getData() async {
    try {
      Response response = await get(Uri.parse(
          'https://www.e-solat.gov.my/index.php?r=esolatApi/takwimsolat&period=week&zone=JHR02'));
      if (response.statusCode == 200) {
        // Request was successful, print the response body.
        print(response.body);

        Map<String, dynamic> data = jsonDecode(response.body)['prayerTime'][0];
        today = Solat(
          hijri: data['hijri'],
          date: data['date'],
          day: data['day'],
          imsak: data['imsak'],
          fajr: data['fajr'],
          syuruk: data['syuruk'],
          dhuhr: data['dhuhr'],
          asr: data['asr'],
          maghrib: data['maghrib'],
          isha: data['isha'],
        );
      } else {
        // Request was not successful, print the status code and reason.
        print('Failed to fetch data. Status code: ${response.statusCode}.');
      }
    } catch (e) {
      // An error occurred during the request, print the error message.
      print('Error during HTTP request: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Loading'),
      ),
      body: Center(
        child: FutureBuilder(
          future: getData(), // Use getData() as the future
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              // Handle the case where an error occurred during data fetching.
              return Text('Error: ${snapshot.error}');
            } else {
              if (today != null) {
                // Navigate to MyHomePage when today is not null
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyHomePage(today: today),
                    ),
                  );
                });
                return CircularProgressIndicator();
              } else {
                // Handle the case where 'today' is null.
                return Text('Data not available');
              }
            }
          },
        ),
      ),
    );
  }
}
