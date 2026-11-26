import 'package:flutter/material.dart';
enum KaziTheme { obsidian, daylight, contrast }
extension KaziThemeLabel on KaziTheme {
  String get label=>switch(this){KaziTheme.obsidian=>'Shift Obsidian',KaziTheme.daylight=>'Daylight Roster',KaziTheme.contrast=>'High-Contrast Duty'};
}
class AppPalette {
  AppPalette(this.mode); final KaziTheme mode;
  bool get light=>mode==KaziTheme.daylight;
  Color get background=>light?const Color(0xffeaf3f4):mode==KaziTheme.contrast?const Color(0xff080a0d):const Color(0xff0b111c);
  Color get surface=>light?const Color(0xfff7fbfc):const Color(0xff151f2d);
  Color get text=>light?const Color(0xff142b35):Colors.white;
  Color get muted=>light?const Color(0xff607782):const Color(0xff9aabba);
  Color get accent=>mode==KaziTheme.contrast?const Color(0xffffc247):const Color(0xff49d9d0);
  Color get secondary=>const Color(0xffa78bfa);
  Color get border=>light?const Color(0xffc9dadd):Colors.white.withValues(alpha:.12);
  ThemeData get theme=>ThemeData(useMaterial3:true,brightness:light?Brightness.light:Brightness.dark,scaffoldBackgroundColor:background,colorScheme:ColorScheme.fromSeed(seedColor:accent,brightness:light?Brightness.light:Brightness.dark),textTheme:ThemeData(brightness:light?Brightness.light:Brightness.dark).textTheme.apply(bodyColor:text,displayColor:text),inputDecorationTheme:InputDecorationTheme(filled:true,fillColor:surface,border:OutlineInputBorder(borderRadius:BorderRadius.circular(14),borderSide:BorderSide(color:border))),snackBarTheme:const SnackBarThemeData(behavior:SnackBarBehavior.floating));
}
