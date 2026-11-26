import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/records.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_panel.dart';
class HandoverScreen extends StatelessWidget {
  const HandoverScreen({super.key,required this.palette,required this.entries,required this.onAdd,required this.onComplete});
  final AppPalette palette; final List<HandoverRecord> entries; final VoidCallback onAdd; final ValueChanged<HandoverRecord> onComplete;
  @override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(18),children:[
    Row(children:[Expanded(child:Text('Shift handover',style:Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight:FontWeight.w800))),FilledButton.icon(onPressed:onAdd,icon:const Icon(Icons.edit_note),label:const Text('Log note'))]),
    const SizedBox(height:6),Text('Keep open tasks visible between teams.',style:TextStyle(color:palette.muted)),const SizedBox(height:16),
    ...entries.map((e)=>Padding(padding:const EdgeInsets.only(bottom:10),child:GlassPanel(palette:palette,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Row(children:[Expanded(child:Text(e.title,style:const TextStyle(fontWeight:FontWeight.w800,fontSize:16))),_tag(e.urgency)]),
      const SizedBox(height:8),Text(e.note),const SizedBox(height:10),
      Row(children:[Icon(Icons.person_outline,size:15,color:palette.muted),Text(' ${e.owner} · ${DateFormat('MMM d, HH:mm').format(e.createdAt)}',style:TextStyle(color:palette.muted,fontSize:11)),const Spacer(),Icon(e.equipmentOk?Icons.check_circle:Icons.error_outline,size:16,color:e.equipmentOk?Colors.green:Colors.orange),const SizedBox(width:4),Text(e.equipmentOk?'Equipment OK':'Check needed',style:TextStyle(fontSize:11,color:palette.muted))]),
      if(e.urgency!=Urgency.completed)Align(alignment:Alignment.centerRight,child:TextButton(onPressed:()=>onComplete(e),child:const Text('Mark completed')))
    ])))),
    if(entries.isEmpty)const Center(child:Padding(padding:EdgeInsets.all(30),child:Text('No handover notes. Log the first update.')))
  ]);
  Widget _tag(Urgency u){final c=u==Urgency.urgent?Colors.orange:u==Urgency.completed?Colors.green:palette.accent;return Chip(label:Text(u.name.toUpperCase(),style:TextStyle(color:c,fontSize:10,fontWeight:FontWeight.w800)),backgroundColor:c.withValues(alpha:.13),side:BorderSide.none,visualDensity:VisualDensity.compact);}
}
