import 'dart:convert';
import 'package:depflow_ai_app/utilities/twitter_manager.dart';
import 'package:http/http.dart' as http;

class DepFlowModelManager {

  final TwitterManager twitterManager;

  final String url = "http://10.0.2.2:8000";
  final headers = {'Content-Type': 'application/json'};

  DepFlowModelManager({required this.twitterManager});

  Future<dynamic> getDepressive(Map<String, dynamic> jsonPayload) async {
    final response = await http.post(
      Uri.parse("$url/predict"),
      headers: headers,
      body: jsonEncode(jsonPayload),
    );

    final predictions = jsonDecode(response.body);

    return predictions;
  }

}