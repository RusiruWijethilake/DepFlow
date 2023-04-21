import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depflow_ai_app/utilities/twitter_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TabHome extends StatefulWidget {

  final TwitterManager twitterManager;

  const TabHome({super.key, required this.twitterManager});

  @override
  State<TabHome> createState() => _TabHomeState();
}

class _TabHomeState extends State<TabHome> {

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<dynamic> statsData = [];

  int friendsCount = 0;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            const Text("Your Statistics" , style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: loadStats,
              icon: const Icon(Icons.refresh),
              label: const Text("Refresh"),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Divider(),
        const SizedBox(height: 12),
        StreamBuilder<DocumentSnapshot>(
          stream: firestore.collection("reports").doc(auth.currentUser!.uid).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {

              if (snapshot.data!.get("user") != null && snapshot.data!.get("friends") != null) {
                Map<String, dynamic> userLastScannedList = snapshot.data!.get("user");
                Map<String, dynamic> friendsLastScannedList = snapshot.data!.get("friends");

                Map<String, dynamic> sortedUsers = sortMapByKeys(userLastScannedList);
                Map<String, dynamic> sortedFriends = sortMapByKeys(friendsLastScannedList);

                LineChartData userCharData = LineChartData(
                  lineTouchData: LineTouchData(enabled: false),
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget:(value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 8,
                                fontWeight: FontWeight.bold
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget:(value, meta) {
                          // Get the index of the value in the sorted map
                          final index = value.toInt();
                          // Get the date from the corresponding key in the sorted map
                          final date = DateTime.parse(sortedUsers.keys.elementAt(index));
                          // Format the date as desired
                          final formattedDate = DateFormat('yyyy-MM-dd').format(date);
                          return Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: Text(
                              formattedDate,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: sortedUsers.length - 1.toDouble(),
                  minY: 0,
                  maxY: getMaxValueFromMap(sortedUsers),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        for (int i = 0; i < sortedUsers.length; i++)
                          FlSpot(i.toDouble(), sortedUsers.values.elementAt(i).toDouble()),
                      ],
                      isCurved: true,
                      color: Colors.black,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.black.withOpacity(0.2),
                      ),
                    ),
                  ],
                );

                LineChartData friendsrCharData = LineChartData(
                  lineTouchData: LineTouchData(enabled: false),
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget:(value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 8,
                                fontWeight: FontWeight.bold
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget:(value, meta) {
                          // Get the index of the value in the sorted map
                          final index = value.toInt();
                          // Get the date from the corresponding key in the sorted map
                          final date = DateTime.parse(sortedFriends.keys.elementAt(index));
                          // Format the date as desired
                          final formattedDate = DateFormat('yyyy-MM-dd').format(date);
                          return Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: Text(
                              formattedDate,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: sortedFriends.length - 1.toDouble(),
                  minY: 0,
                  maxY: getMaxValueFromMap(sortedFriends),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        for (int i = 0; i < sortedFriends.length; i++)
                          FlSpot(i.toDouble(), sortedFriends.values.elementAt(i).toDouble()),
                      ],
                      isCurved: true,
                      color: Colors.black,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.black.withOpacity(0.2),
                      ),
                    ),
                  ],
                );

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          children: [
                            const Text("Last Scanned User",
                                style: TextStyle(color: Colors.grey)),
                            Text(
                              sortedUsers.keys.last.toString(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(width: 24),
                        Column(
                          children: [
                            const Text("Last Scanned Friends",
                                style: TextStyle(color: Colors.grey)),
                            Text(
                              sortedFriends.keys.last.toString(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                            ),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text("You have $friendsCount friends on Twitter 🎉",
                        style: const TextStyle(fontSize: 18,)),
                    const SizedBox(height: 12),
                    Text(
                      "From your friends tweets we found, possible depressive tweets 😢",
                      style: const TextStyle(fontSize: 16,),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    if (snapshot.data!.get(
                        "friendsTweets").length > 0)
                      const Text(
                          "Here are some of them we detected earlier"),
                    const SizedBox(height: 12),
                    if (snapshot.data!.get(
                        "friendsTweets").length > 0)
                      Container(
                        height: snapshot.data!.get("friendsTweets").length > 1 ? 200 : 100,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.separated(
                          itemBuilder: (context, index) {
                            List depressivePosts = snapshot
                                .data!.get("friendsTweets");
                            return ListTile(
                              title: Text(depressivePosts[index]),
                            );
                          },
                          separatorBuilder: (context,
                              index) => const Divider(),
                          itemCount: snapshot.data!.get("friendsTweets").length < 2 ? snapshot.data!.get("friendsTweets").length : 2,
                        ),
                      ),
                    SizedBox(height: 12),
                    if (snapshot.data!.get(
                        "friendsTweets").length > 0)
                      const Text(
                        "Checkout more depressive tweets from your friends on find tab",
                        textAlign: TextAlign.center,),
                    if (snapshot.data!.get(
                        "friendsTweets").length == 0)
                      const Text(
                        "Go ahead and check out depressive Tweets from your friends on find tab",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    if (sortedUsers.length > 1)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Your depressive activities over time",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    if (sortedUsers.length > 1)
                      Container(
                        height: 240,
                        width: 380,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.lightGreen,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 32.0, right: 48.0, left: 48.0, bottom: 18.0),
                          child: LineChart(
                            userCharData == null ? LineChartData() : userCharData,
                            swapAnimationDuration: Duration(milliseconds: 150),
                            swapAnimationCurve: Curves.linear,
                          ),
                        ),
                      ),
                    if (sortedUsers.length > 1)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Friends depressive activities over time",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    if (sortedUsers.length > 1)
                      Container(
                        height: 240,
                        width: 380,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.lightGreen,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 32.0, right: 48.0, left: 48.0, bottom: 18.0),
                          child: LineChart(
                            friendsrCharData == null ? LineChartData() : friendsrCharData,
                            swapAnimationDuration: Duration(milliseconds: 150),
                            swapAnimationCurve: Curves.linear,
                          ),
                        ),
                      ),
                  ],
                );
              } else {
                return const Center(child: Text("No data found"));
              }
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
  }

  void loadStats() async {
    try {
      final me = await widget.twitterManager.twitter!.users.lookupMe();
      final followersResponse = await widget.twitterManager.twitter!.users
          .lookupFollowings(userId: me.data.id);
      setState(() {
        friendsCount = followersResponse.data.length;
      });
    } catch (e) {
      await widget.twitterManager.initNewTwitter();
      final me = await widget.twitterManager.twitter!.users.lookupMe();
      final followersResponse = await widget.twitterManager.twitter!.users
          .lookupFollowings(userId: me.data.id);
      setState(() {
        friendsCount = followersResponse.data.length;
      });
    }
  }

  Map<String, dynamic> sortMapByKeys(Map<String, dynamic> mapToSort) {
    // Get a list of map keys
    final keysList = mapToSort.keys.toList();

    // Sort the keys
    keysList.sort();

    // Create a new map sorted by keys
    final sortedMap = <String, dynamic>{};
    for (final key in keysList) {
      sortedMap[key] = mapToSort[key];
    }

    return sortedMap;
  }

  dynamic getMaxValueFromMap(Map<String, dynamic> map) {
    dynamic maxValue;
    for (final valueList in map.values) {
      if (valueList is List) {
        final maxInList = valueList.reduce((currMax, element) => currMax > element ? currMax : element);
        if (maxValue == null || maxInList > maxValue) {
          maxValue = maxInList;
        }
      }
    }
    return maxValue;
  }

}