library;

import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import './secret.dart';

class BackendService {
  late final String _tName;

  late final List<String> _tNames;

  BackendService(this._tNames);

  static SupabaseClient get supabase => Supabase.instance.client;

  static List<Secret> jsonList = [];

  static Future<void> startServer() async {
    WidgetsFlutterBinding.ensureInitialized();
    final String response = await rootBundle.loadString('lib/secret.json');
    final List<dynamic> getStuff = jsonDecode(response);
    await Supabase.initialize(
      url: getStuff[0]['url'],
      anonKey: getStuff[0]['apiKey'],
    );
  }

  Future<List<Map<String, dynamic>>> getTable(int index) async {
    return await supabase.from(_tNames[index]).select();
  }

  Future<List<Map<String, dynamic>>> insertIntoTable(
    Map<String, dynamic> value,
    int index,
  ) async {
    try {
      return await supabase.from(_tName[index]).insert(value).select();
    } catch (e) {
      debugPrint("Insert failed: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getValue(
    List<String> value,
    int index,
  ) async {
    return await supabase.from(_tName[index]).select(value.join(','));
  }

  Future<void> modifyQuantity(int id, double newValue) async {
    try {
      await supabase
          .from(_tName[1])
          .update({'quantity': newValue})
          .eq('id', id);
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future<void> modifyBinNumber(int id, int bNumber) async {
    try {
      await supabase
          .from(_tName[1])
          .update({'binnumber': bNumber})
          .eq('id', id);
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future<List<Map<String, dynamic>>> deleteData(List<int> ids) async {
    return await supabase.from(_tName).delete().inFilter('id', ids).select();
  }
}
