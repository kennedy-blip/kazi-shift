import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

class LocalStore {
  LocalStore._();
  static final LocalStore instance=LocalStore._();
  late Box<String> _box;
  Future<void> init() async {
    await Hive.initFlutter();
    _box=await Hive.openBox<String>('kazishift_v1');
    for(final k in ['shifts','handovers','overtime']) { if(!_box.containsKey(k)) await _box.put(k,'[]'); }
  }
  List<Map<String,dynamic>> read(String key)=>(jsonDecode(_box.get(key,defaultValue:'[]')!) as List).map((e)=>Map<String,dynamic>.from(e as Map)).toList();
  Future<void> write(String key,List<Map<String,dynamic>> value)=>_box.put(key,jsonEncode(value));
  bool get isReady=>_box.isOpen;
}
