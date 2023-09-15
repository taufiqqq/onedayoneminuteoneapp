import 'dart:async';
import 'dart:developer';

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
  Timer? timer;
  DateTime currentTime = DateTime.now();
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
    log(prayerTimes.toString());
    // Find the index of the next upcoming prayer
    int nextPrayerIndex = -1;

    for (int i = 0; i < prayerTimes.length; i++) {
      if (prayerTimes[i].isAfter(currentTime)) {
        nextPrayerIndex = i;
        break;
      }
    }
    // If the next prayer index is -1, it means all prayers for the day have passed,
    // so the next prayer will be the next day's Imsak.
    if (nextPrayerIndex == -1) {
      return 'Imsak tomorrow';
    }
    // Otherwise, return the name of the next prayer based on its index
    switch (nextPrayerIndex) {
      case 0:
        return 'Imsak';
      case 1:
        return 'Fajr';
      case 2:
        return 'Syuruk';
      case 3:
        return 'Dhuhr';
      case 4:
        return 'Asr';
      case 5:
        return 'Maghrib';
      case 6:
        return 'Isha';
      default:
        return 'unknown';
    }
  }

  String getSolatTime(String solatName) {
    if (solatName == 'Imsak') {
      return widget.today!.imsak;
    } else if (solatName == 'Fajr') {
      return widget.today!.fajr;
    } else if (solatName == 'Syuruk') {
      return widget.today!.syuruk;
    } else if (solatName == 'Dhuhr') {
      return widget.today!.dhuhr;
    } else if (solatName == 'Asr') {
      return widget.today!.asr;
    } else if (solatName == 'Maghrib') {
      return widget.today!.maghrib;
    } else if (solatName == 'Isha') {
      return widget.today!.isha;
    } else {
      return 'unknown';
    }
  }

  @override
  void initState() {
    super.initState();
    // Set up a timer to update the time every second
    timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
        currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    timer?.cancel();
    super.dispose();
  }

  void toggleImage() {
    setState(() {
      showFirstImage = !showFirstImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mytTime = DateFormat('HH:mm:ss').format(currentTime);
    final nextPrayer = getNextPrayer();
    final imageUrl =
        showFirstImage ? 'lib/icon/masjid.jpg' : 'lib/icon/smurf.jpg';

    DateTime tomorrow = currentTime.add(const Duration(days: 1));

    DateTime nextPrayerTime = getNextPrayer() != 'Imsak tomorrow'
        ? DateFormat('dd-MM-yyyy HH:mm:ss').parse(
            '${DateFormat('dd-MM-yyyy').format(currentTime)} ${getSolatTime(nextPrayer)}')
        : DateFormat('dd-MM-yyyy HH:mm:ss').parse(
            '${DateFormat('dd-MM-yyyy').format(tomorrow)} ${getSolatTime('Imsak')}'); // Replace with the correct prayer time

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
                  child: Image(image: AssetImage(imageUrl)),
                ),
              ),
            ),
            Text(
              'Imsak Time: ${widget.today!.imsak}',
              style: TextStyle(
                color: getNextPrayer() == 'Imsak' ||
                        getNextPrayer() == 'Imsak tomorrow'
                    ? Colors.blue
                    : Colors.black, // Change color conditionally
              ),
            ),
            Text(
              'Fajr Time: ${widget.today!.fajr}',
              style: TextStyle(
                color: getNextPrayer() == 'Fajr'
                    ? Colors.blue
                    : Colors.black, // Change color conditionally
              ),
            ),
            Text(
              'Syuruk Time: ${widget.today!.syuruk}',
              style: TextStyle(
                color: getNextPrayer() == 'Syuruk'
                    ? Colors.blue
                    : Colors.black, // Change color conditionally
              ),
            ),
            Text(
              'Zuhur Time: ${widget.today!.dhuhr}',
              style: TextStyle(
                color: getNextPrayer() == 'Dhuhr'
                    ? Colors.blue
                    : Colors.black, // Change color conditionally
              ),
            ),
            Text(
              'Asar Time: ${widget.today!.asr}',
              style: TextStyle(
                color: getNextPrayer() == 'Asr'
                    ? Colors.blue
                    : Colors.black, // Change color conditionally
              ),
            ),
            Text(
              'Maghrib Time: ${widget.today!.maghrib}',
              style: TextStyle(
                color: getNextPrayer() == 'Maghrib'
                    ? Colors.blue
                    : Colors.black, // Change color conditionally
              ),
            ),
            Text(
              'Isha Time: ${widget.today!.isha}',
              style: TextStyle(
                color: getNextPrayer() == 'Isha'
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
