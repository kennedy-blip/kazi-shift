import 'package:flutter/material.dart';
import '../models/records.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_panel.dart';
class OvertimeScreen extends StatelessWidget {
  const OvertimeScreen({super.key,required this.palette,required this.records,required this.isAdmin,required this.onAdd,required this.onApprove});
  final AppPalette palette; final List<OvertimeRecord> records; final bool isAdmin; final VoidCallback onAdd; final ValueChanged<OvertimeRecord> onApprove;
  @override Widget build(BuildContext context){
    final total=records.fold<double>(0,(v,r)=>v+r.overtimeHours);final pending=records.where((r)=>r.approval==Approval.pending).length;
    return ListView(padding:const EdgeInsets.all(18),children:[
      Row(children:[Expanded(child:Text('Hours & overtime',style:Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight:FontWeight.w800))),FilledButton.icon(onPressed:onAdd,icon:const Icon(Icons.add),label:const Text('Log hours'))]),
      const SizedBox(height:6),Text('Actual time compared with scheduled hours.',style:TextStyle(color:palette.muted)),const SizedBox(height:16),
      Row(children:[Expanded(child:_stat('Overtime hours',total.toStringAsFixed(1),palette.accent)),const SizedBox(width:10),Expanded(child:_stat('Pending review','$pending',Colors.orange))]),const SizedBox(height:16),
      ...records.map((r)=>Padding(padding:const EdgeInsets.only(bottom:10),child:GlassPanel(palette:palette,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Row(children:[Expanded(child:Text(r.member,style:const TextStyle(fontWeight:FontWeight.w800))),Text(r.approval.name.toUpperCase(),style:TextStyle(color:r.approval==Approval.approved?Colors.green:Colors.orange,fontSize:10,fontWeight:FontWeight.w800))]),
        const SizedBox(height:8),Text('${r.date} · ${r.scheduled.toStringAsFixed(1)}h scheduled / ${r.actual.toStringAsFixed(1)}h actual'),
        const SizedBox(height:6),Text('${r.overtimeHours.toStringAsFixed(1)}h overtime · ${r.multiplier}× multiplier · ${r.overtimePay.toStringAsFixed(2)} estimated',style:TextStyle(color:palette.accent,fontWeight:FontWeight.w700)),
        if(isAdmin&&r.approval==Approval.pending)Align(alignment:Alignment.centerRight,child:TextButton(onPressed:()=>onApprove(r),child:const Text('Approve')))
      ])))),
      if(records.isEmpty)const Center(child:Text('No hours logged yet.'))
    ]);
  }
  Widget _stat(String label,String value,Color c)=>GlassPanel(palette:palette,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(value,style:TextStyle(fontSize:24,fontWeight:FontWeight.w900,color:c)),Text(label,style:TextStyle(color:palette.muted,fontSize:12))]));
}
