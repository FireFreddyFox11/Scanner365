// ignore_for_file: file_names
import 'package:supabase_flutter/supabase_flutter.dart';

// ignore: strict_top_level_inference, non_constant_identifier_names
class BackendServices {  
  Future<void> initializeDatabase() async {
    try {  
      await Supabase.initialize(
        url: 'https://kykpapahghvtjmwbortw.supabase.co',
        anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt5a3BhcGFoZ2h2dGptd2JvcnR3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIxMzUzNDEsImV4cCI6MjA4NzcxMTM0MX0.EUVseuBRN9UXcFu82xzF4h9eM8pYJ69_ABmFfi3Kw60"
      );
      // ignore: avoid_print
      print("Supabase Initialized Successfully");
    } on Exception catch (e) {
      // ignore: avoid_print
      print(e.toString());
    }
  }

  // ignore: non_constant_identifier_names
  Future<void> addToDatabase({
    // ignore: non_constant_identifier_names
    required String name,
    required String surname,
    required String email,
    String? job,
    String? company,
    required String password,
    bool? isSubscribed,
  }) async {
    //ignore: avoid_print
    print("Starting the insertion");
    try {
      await Supabase.instance.client.from('users').insert({
        'name': name,
        'surname': surname,
        'job': job ?? '',
        'email' : email,
        'company': company ?? '',
        'password': password,
        'loggedat': DateTime.now().toIso8601String(),
        'issubscriber': isSubscribed,
      });
    } on Exception catch (e) {
      //ignore: avoid_print
      print(e);
    }
    //ignore: avoid_print
    print("Insert Ended");
  }

  Future<void> addSubscriber(bool isSubscribed) async {
    try {
      await Supabase.instance.client.from('users').update({
        'issubscriber': isSubscribed,
      });
    } on Exception catch (e) {
      //ignore: avoid_print
      print(e);
    }
  }
}
