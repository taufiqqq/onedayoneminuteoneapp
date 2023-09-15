import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'solat.dart';

class MyHomePage extends StatefulWidget {
  final Solat? today; // Define the 'today' parameter here

  const MyHomePage({Key? key, this.today}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  DateTime _currentTime = DateTime.now();
  Timer? _timer;
  DateTime currentTime = DateTime.now().toUtc().add(const Duration(hours: 8));
  bool showFirstImage = true;

  String getNextPrayer() {
    final formattedDate = DateFormat('dd-MM-yyyy').format(currentTime);
    // Create a list of prayer times in DateTime format
    List<DateTime> prayerTimes = [
      DateFormat('dd-MM-yyyy HH:mm:ss')
          .parse('$formattedDate ${widget.today!.imsak}'),
      DateFormat('dd-MM-yyyy HH:mm:ss')
          .parse('$formattedDate ${widget.today!.fajr}'),
      DateFormat('dd-MM-yyyy HH:mm:ss')
          .parse('$formattedDate ${widget.today!.syuruk}'),
      DateFormat('dd-MM-yyyy HH:mm:ss')
          .parse('$formattedDate ${widget.today!.dhuhr}'),
      DateFormat('dd-MM-yyyy HH:mm:ss')
          .parse('$formattedDate ${widget.today!.asr}'),
      DateFormat('dd-MM-yyyy HH:mm:ss')
          .parse('$formattedDate ${widget.today!.maghrib}'),
      DateFormat('dd-MM-yyyy HH:mm:ss')
          .parse('$formattedDate ${widget.today!.isha}'),
    ];

    // Sort the prayer times in ascending order
    prayerTimes.sort((a, b) => a.compareTo(b));
    print(prayerTimes);
    // Find the index of the next upcoming prayer
    int nextPrayerIndex =
        prayerTimes.indexWhere((time) => time.isAfter(currentTime));

    // If the next prayer index is -1, it means all prayers for the day have passed,
    // so the next prayer will be the next day's Imsak.
    if (nextPrayerIndex == -1) {
      return 'imsak';
    }
    // Otherwise, return the name of the next prayer based on its index
    switch (nextPrayerIndex) {
      case 0:
        return 'imsak';
      case 1:
        return 'fajr';
      case 2:
        return 'syuruk';
      case 3:
        return 'dhuhr';
      case 4:
        return 'asr';
      case 5:
        return 'maghrib';
      case 6:
        return 'isha';
      default:
        return 'unknown';
    }
  }

  String getSolatTime(String solatName) {
    if (solatName == 'imsak') {
      return widget.today!.imsak;
    } else if (solatName == 'fajr') {
      return widget.today!.fajr;
    } else if (solatName == 'syuruk') {
      return widget.today!.syuruk;
    } else if (solatName == 'dhuhr') {
      return widget.today!.dhuhr;
    } else if (solatName == 'asr') {
      return widget.today!.asr;
    } else if (solatName == 'maghrib') {
      return widget.today!.maghrib;
    } else if (solatName == 'isha') {
      return widget.today!.isha;
    } else {
      return 'unknown';
    }
  }

  @override
  void initState() {
    super.initState();
    // Set up a timer to update the time every second
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _timer?.cancel();
    super.dispose();
  }

  void toggleImage() {
    setState(() {
      showFirstImage = !showFirstImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mytTime = DateFormat('HH:mm:ss')
        .format(_currentTime.toUtc().add(const Duration(hours: 8)));
    final nextPrayer = getNextPrayer();
    final imageUrl = showFirstImage
        ? 'https://chancellery.utm.my/wp-content/uploads/sites/19/2020/06/tinggi.jpg'
        : 'https://i.kym-cdn.com/entries/icons/facebook/000/046/505/welivewelovewelie.jpg';

    DateTime currentTime = DateTime.now();
    DateTime tomorrow = currentTime.add(const Duration(days: 1));

    DateTime nextPrayerTime = getNextPrayer() != 'imsak'
        ? DateFormat('dd-MM-yyyy HH:mm:ss').parse(
            '${DateFormat('dd-MM-yyyy').format(currentTime)} ${getSolatTime(nextPrayer)}')
        : DateFormat('dd-MM-yyyy HH:mm:ss').parse(
            '${DateFormat('dd-MM-yyyy').format(tomorrow)} ${getSolatTime('imsak')}'); // Replace with the correct prayer time

    Duration timeDifference = nextPrayerTime.difference(currentTime);

    int hoursDifference = timeDifference.inHours;
    int minutesDifference = timeDifference.inMinutes.remainder(60);
    int secondsDifference = timeDifference.inSeconds.remainder(60);
    String timeUntilNextPrayer =
        '$hoursDifference hours, $minutesDifference minutes, $secondsDifference seconds';
    if (hoursDifference == 0) {
      timeUntilNextPrayer =
          '$minutesDifference minutes, $secondsDifference seconds';
      if (minutesDifference == 0) {
        timeUntilNextPrayer = '$secondsDifference seconds';
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Johor Bahru prayer tracking'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              mytTime,
              style: Theme.of(context).textTheme.displayLarge,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: Text(widget.today!.hijri),
                ),
                Text(widget.today!.day),
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Text(widget.today!.date),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: GestureDetector(
                  onTap: toggleImage,
                  child: Image.network(
                    imageUrl,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child; // Display the image once it's loaded
                      } else {
                        return CircularProgressIndicator(); // Display a loading indicator while the image is being loaded
                      }
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Text('Error loading image');
                    },
                  ),
                ),
              ),
            ),
            Text(
              'Imsak Time: ${widget.today!.imsak}',
              style: TextStyle(
                color: getNextPrayer() == 'imsak'
                    ? Colors.blue
                    : Colors.black, // Change color conditionally
              ),
            ),
            Text(
              'Fajr Time: ${widget.today!.fajr}',
              style: TextStyle(
                color: getNextPrayer() == 'fajr'
                    ? Colors.blue
                    : Colors.black, // Change color conditionally
              ),
            ),
            Text(
              'Syuruk Time: ${widget.today!.syuruk}',
              style: TextStyle(
                color: getNextPrayer() == 'syuruk'
                    ? Colors.blue
                    : Colors.black, // Change color conditionally
              ),
            ),
            Text(
              'Zuhur Time: ${widget.today!.dhuhr}',
              style: TextStyle(
                color: getNextPrayer() == 'dhuhr'
                    ? Colors.blue
                    : Colors.black, // Change color conditionally
              ),
            ),
            Text(
              'Asar Time: ${widget.today!.asr}',
              style: TextStyle(
                color: getNextPrayer() == 'asr'
                    ? Colors.blue
                    : Colors.black, // Change color conditionally
              ),
            ),
            Text(
              'Maghrib Time: ${widget.today!.maghrib}',
              style: TextStyle(
                color: getNextPrayer() == 'maghrib'
                    ? Colors.blue
                    : Colors.black, // Change color conditionally
              ),
            ),
            Text(
              'Isha Time: ${widget.today!.isha}',
              style: TextStyle(
                color: getNextPrayer() == 'isha'
                    ? Colors.blue
                    : Colors.black, // Change color conditionally
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Time Until $nextPrayer:',
            ),
            Center(
              child: Text(
                timeUntilNextPrayer,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
