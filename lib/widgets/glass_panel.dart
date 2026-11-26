import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
class GlassPanel extends StatelessWidget {
  const GlassPanel({super.key,required this.child,this.padding=const EdgeInsets.all(16),required this.palette,this.radius=20});
  final Widget child; final EdgeInsets padding; final AppPalette palette; final double radius;
  @override Widget build(BuildContext context)=>ClipRRect(borderRadius:BorderRadius.circular(radius),child:BackdropFilter(filter:ImageFilter.blur(sigmaX:18,sigmaY:18),child:Container(padding:padding,decoration:BoxDecoration(color:palette.surface.withValues(alpha:palette.light ? .88 : .76),borderRadius:BorderRadius.circular(radius),border:Border.all(color:palette.border),boxShadow:[BoxShadow(color:palette.accent.withValues(alpha:.06),blurRadius:26)]),child:child)));
}
