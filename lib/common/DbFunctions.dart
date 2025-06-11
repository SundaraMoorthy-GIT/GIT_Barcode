import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DbFunctions {
  String serverUrl = "https://crmapi.genuineitsolution.com";
  String token = "";
  String company = "_1";

  Future<void> loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('auth_token') ?? "";

    if (token.isEmpty) {
      await getToken(); // Fetch token if not stored
    }
  }

  Future<void> getToken() async {
    try {
      var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
      var body = {
        'grant_type': 'password',
        'UserName': 'admin',
        'Password': 'admin'
      };

      var response = await http.post(
        Uri.parse("$serverUrl/token"),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        token = data['access_token'];

        // Store token in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
      } else {
        Fluttertoast.showToast(msg: "Error: ${response.body}");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error Contact Admin: $e");
    }
  }

  Future<http.Response> get(String url) async {
    var headers = {
      'Content-Type': 'text/plain',
      'Authorization': 'Bearer $token'
    };

    return await http.get(Uri.parse("$serverUrl$url&Company=$company"),
        headers: headers);
  }

  Future<http.Response> getc(String url) async {
    var headers = {'Authorization': 'Bearer $token'};
    return await http.get(Uri.parse("$serverUrl$url?Company=$company"),
        headers: headers);
  }
}
